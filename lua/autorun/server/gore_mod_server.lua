include( "gore_mod/ConVar.lua" )
include( "gore_mod/npc_customization.lua" )

goremod_explosion_limb_bones = {
    "ValveBiped.Bip01_Head1",
    "ValveBiped.Bip01_L_UpperArm",
    "ValveBiped.Bip01_R_UpperArm",
    "ValveBiped.Bip01_L_Thigh",
    "ValveBiped.Bip01_R_Thigh",
}

function goremod_explosion_dismember_limbs(ragdoll, dmg_data)
    if dmg_data.dmg_pos == nil or dmg_data.dmg_total_damege == nil then return end

    if !ragdoll.gib_bone then
        ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll)
    end

    local radius = 250
    local ratio = 0.67
    local base_force = 200

    for _, bone_name in ipairs(goremod_explosion_limb_bones) do
        local boneID = ragdoll:LookupBone(bone_name)
        if boneID then
            local physBone = ragdoll:TranslateBoneToPhysBone(boneID)
            local maxHealth = ragdoll.gore_mod_boneHealth[physBone]
            local bonePos = ragdoll:GetBonePosition(boneID)
            local dist = bonePos:Distance(dmg_data.dmg_pos)

            if maxHealth and dist <= radius and ragdoll.gib_bone[physBone] ~= physBone then
                ragdoll.gore_mod_boneHealth[physBone] = maxHealth - dmg_data.dmg_total_damege

                if dmg_data.dmg_total_damege >= (maxHealth * ratio) then
                    local force_dir = bonePos - dmg_data.dmg_pos
                    if force_dir:Length() < 1 then force_dir = VectorRand() end
                    force_dir = force_dir:GetNormalized()

                    local limb_dmg_data = {
                        dmg_type = dmg_data.dmg_type,
                        dmg_pos = bonePos,
                        dmg_force = dmg_data.dmg_force,
                        dmg_dir = force_dir:Angle(),
                        dmg_total_damege = dmg_data.dmg_total_damege,

                        slice = true,
                    }
                    gore_mod_dismember_limb(ragdoll, bone_name, limb_dmg_data)
                end
            end
        end
    end
    gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force,true)
end

function goremod_do_ragdoll_gib_on_deafh(ragdoll,owner,dmg_data)
    if !ragdoll.gib_bone then
        ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll)
    end

    if dmg_data.dmg_type == 64 or dmg_data.dmg_type == 1 and dmg_data.dmg_total_damege > 100 then
        if GetConVar("goremod_npc_explode_type"):GetInt() == 1 then
            gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force,true)
        elseif GetConVar("goremod_npc_explode_type"):GetInt() == 2 then
            goremod_explosion_dismember_limbs(ragdoll,dmg_data)
        end
    elseif owner.goremod_is_slice_inhalf and owner:LookupBone("ValveBiped.Bip01_Spine2") ~= nil and GetConVar("goremod_sawblade_slice_EXPEREMENTAL"):GetBool()then
        dmg_data.slice = true 
        dmg_data.dmg_force = Vector(0,0,16000)
        ragdoll:EmitSound( "ambient/machines/slicer" .. math.random(1,4) .. ".wav", 120, 100, 1, CHAN_AUTO ) -- Same as below
        gore_mod_dismember_limb(ragdoll,"ValveBiped.Bip01_Spine2",dmg_data) 
    elseif dmg_data.dmg_type == 1048576 and owner:LookupBone("ValveBiped.Bip01_Spine") ~= nil and GetConVar("goremod_acid_efect_EXPEREMENTAL"):GetBool() then
        timer.Simple(1, function()
            if not IsValid(ragdoll) then return end
            ragdoll:SetRenderMode(RENDERMODE_TRANSCOLOR)
                gore_mod_bonemerge_prop(ragdoll,"models/player/skeleton.mdl")
                ragdoll:SetColor(Color(255, 255, 255, 0))
                ragdoll.nogap = true 
                ragdoll.no_limb = true 
                ragdoll.no_gibs = true 
                for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			        local colide = ragdoll:GetPhysicsObjectNum( i )
                    ParticleEffect("blood_impact_green_01",colide:GetPos(), ragdoll:GetAngles(), self)     
		        end
                EmitSound( "npc/antlion/antlion_shoot1.wav",ragdoll:GetPos() )
            end)
        elseif owner.isdissolverd then
            if GetConVar("goremod_dissolve_efect_EXPEREMENTAL"):GetBool() then
                dmg_data.dmg_total_damege = 0
                ragdoll.nogap = true 
                ragdoll.no_limb = true 
                ragdoll.no_gibs = true 
		        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			        local colide = ragdoll:GetPhysicsObjectNum( i )
			        colide:EnableGravity(true )
		        end
                timer.Simple(2, function()
			        if IsValid(ragdoll) then
                        goremod_make_dust(ragdoll)
			        end
		        end)
            end
        elseif owner:IsOnFire() and GetConVar("goremod_burned_corpse_effect_EXPEREMENTAL"):GetBool() and owner:LookupBone("ValveBiped.Bip01_Spine") ~= nil then --fire efect
            ragdoll:SetRenderMode(RENDERMODE_TRANSCOLOR)

            ragdoll:SetMaterial("models/charple/charple1_sheet") -- set material		
            gore_mod_bonemerge_prop(ragdoll,"models/player/charple.mdl")
            ragdoll:Ignite(15,5)
            ragdoll:SetColor(Color(255, 255, 255, 255))
            ragdoll.nogap = true 
            ragdoll.no_limb = true 
            ragdoll.no_gibs = true 
            local alpha = 255
            
		    timer.Simple(3, function()

                if not IsValid(ragdoll) then return end

                timer.Create("PropFadeOut_" .. ragdoll:EntIndex(), 0.05, 100, function()
                    if not IsValid(ragdoll) then return end

                    alpha = math.max(alpha - 3, 0)
                    ragdoll:SetColor(Color(255, 255, 255, alpha))

                    if alpha <= 0 then
                        timer.Remove("PropFadeOut_" .. ragdoll:EntIndex())
                    end
                end)
            end)     
        else
            if owner.LeftArmDestroid or owner.RightArmDestroid then
                dmg_data.slice = true 
                dmg_data.nogibs = true 
                if owner.RightArmDestroid then
                    gore_mod_dismember_limb(ragdoll,"ValveBiped.Bip01_R_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_R_Forearm") --call this hook to make cap based on bone name
                end
                if owner.LeftArmDestroid then
                    gore_mod_dismember_limb(ragdoll,"ValveBiped.Bip01_L_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_L_Forearm") --call this hook to make cap based on bone name
                end
            end
            dmg_data.slice = false  
            if dmg_data.dmg_force == nil  then
                return 
            end

            local PhysicsBone
            if dmg_data.dmg_type and bit.band(dmg_data.dmg_type, DMG_FALL) > 0 then
                -- fall damage bullcrap (look at player_gore.lua)
                PhysicsBone = gore_mod_GetClosestPhysBone_on_ragdoll(ragdoll,dmg_data.dmg_pos)
            elseif table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) then
                PhysicsBone = gore_mod_GetClosestPhysBone_on_ragdoll(ragdoll,dmg_data.dmg_pos) --get hit physbone
            else
                PhysicsBone = gore_mod_GetClosestPhysBone(ragdoll,dmg_data).PhysicsBone
            end
            local bone = ragdoll:TranslatePhysBoneToBone(PhysicsBone)
            local bone_name = ragdoll:GetBoneName( bone ) 	

            if GetConVar("goremod_debug"):GetBool() then
                print(bone_name.."is hit")
            end

            local maxHealth = ragdoll.gore_mod_boneHealth[PhysicsBone]
            local killshot_ratio = GetConVar("goremod_killshot_dismember_ratio"):GetFloat()
            local isKillshotDismember = maxHealth and killshot_ratio > 0 and dmg_data.dmg_total_damege >= (maxHealth * killshot_ratio)

            if maxHealth then
				ragdoll.gore_mod_boneHealth[PhysicsBone] = maxHealth - dmg_data.dmg_total_damege
			end

            if GetConVar("goremod_debug"):GetBool() then
                print(bone_name.." killshot dmg "..dmg_data.dmg_total_damege.."/".. (maxHealth or -1) .." (needs ".. ((maxHealth or 0) * killshot_ratio) ..")")
            end

            if isKillshotDismember and ragdoll.gib_bone[PhysicsBone] ~= PhysicsBone then 
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    dmg_data.slice = true 
                else
                    ParticleEffect("blood_advisor_puncture", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), self)                
                end
                gore_mod_dismember_limb(ragdoll,bone_name,dmg_data) 

                -- a fatal fall targets both legs
                if dmg_data.dmg_type and bit.band(dmg_data.dmg_type, DMG_FALL) > 0 then
                    local mirrored_name = nil
                    if bone_name:find("_L_") then
                        mirrored_name = bone_name:gsub("_L_", "_R_")
                    elseif bone_name:find("_R_") then
                        mirrored_name = bone_name:gsub("_R_", "_L_")
                    end

                    if mirrored_name and ragdoll:LookupBone(mirrored_name) then
                        local mirror_bone_id = ragdoll:LookupBone(mirrored_name)
                        local mirror_physbone = ragdoll:TranslateBoneToPhysBone(mirror_bone_id)
                        local mirror_maxHealth = ragdoll.gore_mod_boneHealth[mirror_physbone]

                        if mirror_maxHealth then
                            ragdoll.gore_mod_boneHealth[mirror_physbone] = mirror_maxHealth - dmg_data.dmg_total_damege
                        end

                        if mirror_maxHealth and dmg_data.dmg_total_damege >= (mirror_maxHealth * killshot_ratio) and ragdoll.gib_bone[mirror_physbone] ~= mirror_physbone then
                            gore_mod_dismember_limb(ragdoll,mirrored_name,dmg_data)
                        end
                    end
                end
            end
        end
end
hook.Add("EntityTakeDamage", "pai_do_reabilitado",function(npc, dmginfo) --gib script
    if npc:IsNPC() then
        npc.dmg_pos = dmginfo:GetDamagePosition()
        npc.dmg_type = dmginfo:GetDamageType()
        npc.dmg_force = dmginfo:GetDamageForce()
        npc.dmg_dir = dmginfo:GetDamageForce():Angle()
        npc.dmg_total_damege = dmginfo:GetDamage()
        if GetConVar("goremod_dissolve_efect_EXPEREMENTAL"):GetBool() then
            if dmginfo:IsDamageType(DMG_DISSOLVE) then
                npc.isdissolverd = true 
            else
                npc.isdissolverd = false  
            end
        end

        if GetConVar("goremod_sawblade_slice_EXPEREMENTAL"):GetBool() and dmginfo:IsDamageType(DMG_CRUSH) and dmginfo:IsDamageType(DMG_SLASH) then
            npc.goremod_is_slice_inhalf = true 
        else
            npc.goremod_is_slice_inhalf = false  
        end
    end
end)
hook.Add("CreateEntityRagdoll", "Replace_shit_Ragdoll", function(owner, ragdoll)
    if owner.is_madness_combat_npc == true then return end

    -- A blacklisted NPC should behave exactly like the original game:
    -- no gore processing is attached to its corpse.
    if IsValid(owner) and owner:IsNPC() and goremod_IsNPCBlacklisted(owner) then
        return
    end

    if GetConVar("goremod_enable"):GetBool() then
        ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        local dmg_data = {
            dmg_type = owner.dmg_type,
            dmg_pos = owner.dmg_pos,
            dmg_force = owner.dmg_force,
            dmg_dir = owner.dmg_dir,
            dmg_total_damege = owner.dmg_total_damege,
            slice = false 
        }

        gore_mod_ApplyCorpseEffects(ragdoll)
        goremod_do_ragdoll_gib_on_deafh(ragdoll,owner,dmg_data)


    end
end)


hook.Add("OnEntityCreated", "On_shit_ent_is_created", function(ragdoll)
    if GetConVar("goremod_enable"):GetBool() then 
		if GetConVar("goremod_can_gib_only_npc_corpse"):GetBool() and ragdoll:GetClass() == "prop_ragdoll" then 
			timer.Simple(0, function()
				if IsValid(ragdoll) and not ragdoll.destructible_Corpse then
					gore_mod_ApplyCorpseEffects(ragdoll) 
				end
			end)
		end
	end
end)

--[[
    Lambda Gore - LIVE NPC LEG INJURY SYSTEM
    -----------------------------------------
    Accumulates damage on the leg that was actually hit. Once the configured
    threshold is reached, the client receives a networked "broken" state and
    the animation layer rotates the calf.

    We deliberately check the physics bone first. Some NPCs expose animation
    bones that have no physics representation; those bones must never be fed
    into physics APIs.
]]
local LambdaGoreLegBoneNames = {
    left = {
        "ValveBiped.Bip01_L_Thigh",
        "ValveBiped.Bip01_L_Calf",
        "ValveBiped.Bip01_L_Foot",
    },
    right = {
        "ValveBiped.Bip01_R_Thigh",
        "ValveBiped.Bip01_R_Calf",
        "ValveBiped.Bip01_R_Foot",
    },
}

local function LambdaGoreHasPhysicsBone(npc, boneID)
    if not IsValid(npc) or boneID == nil or boneID < 0 then return false end

    local physID = npc:TranslateBoneToPhysBone(boneID)
    if physID == nil or physID < 0 then return false end

    return IsValid(npc:GetPhysicsObjectNum(physID))
end

local function LambdaGoreFindLeg(npc, hitBoneName)
    local lower = string.lower(hitBoneName or "")
    if lower:find("_l_", 1, true) and (lower:find("thigh", 1, true) or lower:find("calf", 1, true) or lower:find("foot", 1, true)) then
        return "left"
    end
    if lower:find("_r_", 1, true) and (lower:find("thigh", 1, true) or lower:find("calf", 1, true) or lower:find("foot", 1, true)) then
        return "right"
    end
end

local function LambdaGoreResolveLegBone(npc, side)
    for _, name in ipairs(LambdaGoreLegBoneNames[side] or {}) do
        local id = npc:LookupBone(name)
        if id and id >= 0 then
            return id, name
        end
    end
end

hook.Add("EntityTakeDamage", "LambdaGore_LiveNPCInjuries", function(npc, dmginfo)
    if not GetConVar("goremod_enable"):GetBool() then return end
    if not GetConVar("goremod_live_leg_injury"):GetBool() then return end
    if not IsValid(npc) or not npc:IsNPC() or goremod_IsNPCBlacklisted(npc) then return end
    if dmginfo:GetDamage() <= 0 then return end

    local damagePos = dmginfo:GetDamagePosition()
    if not damagePos or damagePos == vector_origin then
        damagePos = npc:GetPos()
    end

    -- Find the closest valid animation bone. We only consider leg bones.
    local bestSide, bestDist
    for side, names in pairs(LambdaGoreLegBoneNames) do
        for _, boneName in ipairs(names) do
            local boneID = npc:LookupBone(boneName)
            if boneID and boneID >= 0 and LambdaGoreHasPhysicsBone(npc, boneID) then
                local bonePos = npc:GetBonePosition(boneID)
                if bonePos then
                    local dist = bonePos:DistToSqr(damagePos)
                    if not bestDist or dist < bestDist then
                        bestDist = dist
                        bestSide = side
                    end
                end
            end
        end
    end

    if not bestSide then return end

    npc.LambdaGoreLegDamage = npc.LambdaGoreLegDamage or {left = 0, right = 0}
    local state = npc.LambdaGoreLegDamage
    if state[bestSide] >= math.huge then return end

    state[bestSide] = state[bestSide] + dmginfo:GetDamage()

    local threshold = math.max(1, GetConVar("goremod_live_leg_break_damage"):GetFloat())
    if state[bestSide] >= threshold and not npc:GetNW2Bool("LambdaGore_Broken" .. (bestSide == "left" and "Left" or "Right") .. "Leg", false) then
        local boneID = LambdaGoreResolveLegBone(npc, bestSide)
        if boneID and LambdaGoreHasPhysicsBone(npc, boneID) then
            local suffix = bestSide == "left" and "Left" or "Right"
            npc:SetNW2Bool("LambdaGore_Broken" .. suffix .. "Leg", true)

            -- Store the original damage for debugging/other addons.
            npc["LambdaGore_" .. suffix .. "LegDamage"] = state[bestSide]
        end
    end
end)

include( "gore_mod/function.lua" )
include( "gore_mod/damege.lua" )
include( "gore_mod/giblist.lua" )
include( "gore_mod/hook.lua" )
include( "gore_mod/livedismenber.lua" )
include( "gore_mod/player_gore.lua" )
