--[[
    Lambda Gore - NPC customization
    This file owns persistent NPC model blacklist data and the optional
    per-NPC gap/gib model API.

    The blacklist is server authoritative. Clients only receive a read-only
    copy for the Derma menu.
]]

local BLACKLIST_FILE = "lambda_gore_npc_blacklist.json"

goremod_npc_blacklist = goremod_npc_blacklist or {}
goremod_npc_specific_gap_models = goremod_npc_specific_gap_models or {}

local function NormalizeModelPath(model)
    if not isstring(model) then return nil end

    model = string.Trim(string.lower(model))
    if model == "" then return nil end

    -- Only allow normal Source model paths. This also prevents arbitrary
    -- strings from being written to the persistent data file.
    if not model:StartWith("models/") or not model:EndsWith(".mdl") then
        return nil
    end

    return model
end

local function SaveBlacklist()
    file.Write(BLACKLIST_FILE, util.TableToJSON(goremod_npc_blacklist, true))
end

local function LoadBlacklist()
    goremod_npc_blacklist = {}

    if not file.Exists(BLACKLIST_FILE, "DATA") then
        return
    end

    local raw = file.Read(BLACKLIST_FILE, "DATA")
    local decoded = util.JSONToTable(raw)

    if not istable(decoded) then
        return
    end

    for model, value in pairs(decoded) do
        model = NormalizeModelPath(model)
        if model and value == true then
            goremod_npc_blacklist[model] = true
        end
    end
end

LoadBlacklist()

-- Public helper used by live-NPC and ragdoll hooks.
function goremod_IsNPCBlacklisted(npc)
    if not IsValid(npc) or not npc:IsNPC() then
        return false
    end

    local model = NormalizeModelPath(npc:GetModel())
    return model ~= nil and goremod_npc_blacklist[model] == true
end

-- Optional per-NPC gap model API.
-- Example:
-- goremod_npc_specific_gap_models["models/vortigaunt.mdl"] = {
--     ["ValveBiped.Bip01_Head1"] = "models/myaddon/vortigaunt_neckcap.mdl"
-- }
function goremod_GetNPCSpecificGapModel(npcModel, boneName)
    npcModel = NormalizeModelPath(npcModel)
    if not npcModel or not isstring(boneName) then
        return nil
    end

    local modelData = goremod_npc_specific_gap_models[npcModel]
    if not istable(modelData) then
        return nil
    end

    return NormalizeModelPath(modelData[boneName])
end

util.AddNetworkString("LambdaGore_BlacklistSync")
util.AddNetworkString("LambdaGore_BlacklistAction")

local function CanEditBlacklist(ply)
    return not IsValid(ply) or game.SinglePlayer() or ply:IsAdmin()
end

local function SyncBlacklist(ply)
    net.Start("LambdaGore_BlacklistSync")
        net.WriteUInt(table.Count(goremod_npc_blacklist), 16)

        for model in pairs(goremod_npc_blacklist) do
            net.WriteString(model)
        end

    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

net.Receive("LambdaGore_BlacklistAction", function(_, ply)
    if not CanEditBlacklist(ply) then
        return
    end

    local action = net.ReadString()
    local model = NormalizeModelPath(net.ReadString())

    if action == "request" then
        SyncBlacklist(ply)
        return
    end

    if not model then
        return
    end

    if action == "add" then
        goremod_npc_blacklist[model] = true
        SaveBlacklist()
    elseif action == "remove" then
        goremod_npc_blacklist[model] = nil
        SaveBlacklist()
    elseif action == "clear" then
        goremod_npc_blacklist = {}
        SaveBlacklist()
    else
        return
    end

    SyncBlacklist()
end)

hook.Add("PlayerInitialSpawn", "LambdaGore_SyncNPCBlacklist", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            SyncBlacklist(ply)
        end
    end)
end)
