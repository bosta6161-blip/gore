-- Lambda Gore live-NPC client pose controller.
-- This file hides destroyed bones, gives broken legs a visible rotation and
-- lets finger bones inherit the arm's damaged pose.

local function HasPhysicsBone(ent, boneID)
    if not IsValid(ent) or boneID == nil or boneID < 0 then
        return false
    end

    local physID = ent:TranslateBoneToPhysBone(boneID)
    if physID == nil or physID < 0 then
        return false
    end

    local phys = ent:GetPhysicsObjectNum(physID)
    return IsValid(phys)
end

local function AddBoneChildrenRecursive(ent, boneID, destination)
    if boneID == nil or boneID < 0 then return end

    local children = ent:GetChildBones(boneID) or {}
    for _, childID in ipairs(children) do
        destination[childID] = true
        AddBoneChildrenRecursive(ent, childID, destination)
    end
end

local function IsFingerBone(name)
    name = string.lower(name or "")
    return string.find(name, "finger", 1, true) ~= nil
        or string.find(name, "thumb", 1, true) ~= nil
end

local function InstallLiveGoreCallback(npc)
    if npc.LambdaGoreBuildBoneCallback then
        return
    end

    npc.LambdaGoreBuildBoneCallback = true

    npc:AddCallback("BuildBonePositions", function(ent, boneCount)
        if not IsValid(ent) then return end

        -- Hide destroyed limbs and their descendants.
        for boneID in pairs(ent.goremod_bone_to_hide or {}) do
            local matrix = ent:GetBoneMatrix(boneID)
            if matrix then
                matrix:Scale(vector_origin)
                ent:SetBoneMatrix(boneID, matrix)
            end
        end

        -- Broken-leg pose. The matrix is modified locally so NPC animations
        -- continue to work while the injured bone remains visibly rotated.
        local breakAngle = GetConVar("goremod_live_leg_break_angle")
        breakAngle = breakAngle and breakAngle:GetFloat() or 35

        local function RotateBrokenLeg(boneName, sign)
            local boneID = ent:LookupBone(boneName)
            if boneID == nil or boneID < 0 then return end

            local matrix = ent:GetBoneMatrix(boneID)
            if not matrix then return end

            matrix:RotateAroundAxis(matrix:GetRight(), breakAngle * sign)
            ent:SetBoneMatrix(boneID, matrix)
        end

        if ent:GetNW2Bool("LambdaGore_BrokenLeftLeg", false) then
            RotateBrokenLeg("ValveBiped.Bip01_L_Calf", -1)
        end

        if ent:GetNW2Bool("LambdaGore_BrokenRightLeg", false) then
            RotateBrokenLeg("ValveBiped.Bip01_R_Calf", 1)
        end

        -- Fingers get a small curl when their parent arm is removed.
        for boneID in pairs(ent.goremod_damaged_fingers or {}) do
            local name = ent:GetBoneName(boneID)
            if IsFingerBone(name) then
                local matrix = ent:GetBoneMatrix(boneID)
                if matrix then
                    local fingerAngle = GetConVar("goremod_live_finger_curl_angle")\n                    fingerAngle = fingerAngle and fingerAngle:GetFloat() or 22\n                    matrix:RotateAroundAxis(matrix:GetRight(), fingerAngle)
                    ent:SetBoneMatrix(boneID, matrix)
                end
            end
        end
    end)
end

net.Receive("noob_gore_gib_npc_bone", function()
    local ent = net.ReadEntity()
    local boneID = net.ReadInt(16)

    if not IsValid(ent) or not ent:IsNPC() then
        return
    end

    if boneID < 0 or boneID >= ent:GetBoneCount() then
        return
    end

    gib_npc_Bone_cl(ent, ent:GetBoneName(boneID))
end)

function gib_npc_Bone_cl(npc, boneName)
    if not IsValid(npc) then return end

    local boneID = npc:LookupBone(boneName)
    if boneID == nil or boneID < 0 then return end

    -- Do not blindly assume every animation bone has a physics object.
    -- Visual-only bones are still hidden, but physics-dependent operations
    -- are skipped safely.
    local hasPhysics = HasPhysicsBone(npc, boneID)

    npc.goremod_bone_to_hide = npc.goremod_bone_to_hide or {}
    npc.goremod_damaged_fingers = npc.goremod_damaged_fingers or {}

    npc.goremod_bone_to_hide[boneID] = true

    local descendants = {}
    AddBoneChildrenRecursive(npc, boneID, descendants)

    for childID in pairs(descendants) do
        npc.goremod_bone_to_hide[childID] = true

        local childName = npc:GetBoneName(childID)
        if IsFingerBone(childName) then
            npc.goremod_damaged_fingers[childID] = true
        end
    end

    -- Keep the value around for debugging without spamming the console.
    npc.LambdaGoreLastBoneHadPhysics = hasPhysics

    InstallLiveGoreCallback(npc)
end
