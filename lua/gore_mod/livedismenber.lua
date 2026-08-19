gore_mod_npc_live_table = {}

function goremod_DoBleed(ent,bone,attacker)
    timer.Create("MyTimer_" .. ent:EntIndex(),0.1,200, function()
        if ent:IsValid()then
            local dmg = DamageInfo() -- Create a server-side damage information class
            dmg:SetDamage(ent:Health()/50+0.05)
            dmg:SetAttacker(attacker)

            dmg:SetDamageType(DMG_NEVERGIB)
            ent:TakeDamageInfo( dmg )

        end
    end)
end

hook.Add("ScaleNPCDamage","ArmGib",function(npc,hitgroup,dmginfo)
    if GetConVar("goremod_enable"):GetBool() and GetConVar("goremod_live_dismenber_EXPEREMENTAL"):GetBool() and not npc.IsLambdaPlayer then
        if goremod_IsNPCBlacklisted and goremod_IsNPCBlacklisted(npc) then return end
        if npc:LookupBone("ValveBiped.Bip01_Spine") == nil then return end
        if not npc.LeftArmHealth then
            npc.RightArmHealth = npc:GetMaxHealth()/1.6
            npc.LeftArmHealth = npc:GetMaxHealth()/1.6
            npc.LeftLegHealth = npc:GetMaxHealth()/1.6
            npc.RightLegHealth = npc:GetMaxHealth()/1.6
            table.insert(gore_mod_npc_live_table, npc)
        end

        local dmg_data = {
            dmg_type = dmginfo:GetDamageType(),
            dmg_pos = dmginfo:GetDamagePosition(),
            dmg_force = dmginfo:GetDamageForce(),
            dmg = dmginfo:GetDamage(),
            no_tiny_gibs = true,
            slice = false 
        }
        if hitgroup == HITGROUP_RIGHTARM and not npc.RightArmDestroid then
            npc.RightArmHealth = npc.RightArmHealth - dmg_data.dmg
            if npc.RightArmHealth < 0 then
                npc.RightArmDestroid = true
                npc:DropWeapon()
                npc:SetEnemy(NULL)
                goremod_DoBleed(npc,npc:LookupBone("ValveBiped.Bip01_R_Forearm"),dmginfo:GetAttacker())
                hook.Call( "noob_gore_gap", nil,npc,npc:GetModel(),"ValveBiped.Bip01_R_Forearm") --call this hook to make cap based on bone name
                destroy_npc_limb(npc,"ValveBiped.Bip01_R_Forearm",dmg_data)
                hook.Call( "noob_gore_make_gore_sound", nil,npc,"ValveBiped.Bip01_R_Forearm")
                	hook.Call( "noob_gore_make_limb_blood", nil,npc,"ValveBiped.Bip01_R_Forearm") --call this hook to make blood on bone name
            end
        end
        if hitgroup == HITGROUP_LEFTARM and not npc.LeftArmDestroid then
            npc.LeftArmHealth = npc.LeftArmHealth - dmg_data.dmg
            if npc.LeftArmHealth < 0 then
                npc.LeftArmDestroid = true
                npc:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_POOR )
                npc:SetEnemy(NULL)
                npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
                goremod_DoBleed(npc,npc:LookupBone("ValveBiped.Bip01_L_Forearm"),dmginfo:GetAttacker())
                hook.Call( "noob_gore_gap", nil,npc,npc:GetModel(),"ValveBiped.Bip01_L_Forearm") 
                hook.Call( "noob_gore_make_gore_sound", nil,npc,"ValveBiped.Bip01_L_Forearm") 
                destroy_npc_limb(npc,"ValveBiped.Bip01_L_Forearm",dmg_data)
                hook.Call( "noob_gore_make_limb_blood", nil,npc,"ValveBiped.Bip01_L_Forearm") --call this hook to make blood on bone name
            end
        end

        -- Legs can become visibly broken before the NPC is dismembered.
        -- Damage is tracked independently for each side.
        if GetConVar("goremod_live_leg_break"):GetBool() then
            local function BreakLeg(side)
                local isLeft = side == "L"
                local healthKey = isLeft and "LeftLegHealth" or "RightLegHealth"
                local brokenKey = isLeft and "LeftLegBroken" or "RightLegBroken"
                local nwKey = isLeft and "LambdaGore_BrokenLeftLeg" or "LambdaGore_BrokenRightLeg"

                if npc[brokenKey] then return end

                npc[healthKey] = (npc[healthKey] or npc:GetMaxHealth() / 1.6) - dmg_data.dmg
                local threshold = math.max(1, npc:GetMaxHealth() / 3)

                if npc[healthKey] <= threshold then
                    npc[brokenKey] = true
                    npc:SetNW2Bool(nwKey, true)

                    -- Make the NPC visibly limp instead of instantly removing
                    -- the leg. The client applies the animation-safe bone pose.
                    npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
                end
            end

            if hitgroup == HITGROUP_LEFTLEG then
                BreakLeg("L")
            elseif hitgroup == HITGROUP_RIGHTLEG then
                BreakLeg("R")
            end
        end
    end
end)


hook.Add("Think","ArmCripple_AI",function()
    if GetConVar("goremod_enable"):GetBool() and GetConVar("goremod_live_dismenber_EXPEREMENTAL"):GetBool() then
        for _,npc in ipairs( gore_mod_npc_live_table ) do
            if not npc:IsValid() then
                table.RemoveByValue(gore_mod_npc_live_table, npc) --remove ragdoll on the table
            end
            if npc.LeftArmDestroid then
                local sched = npc:GetCurrentSchedule()
                local act   = npc:GetActivity()

                if not npc.DroppedWeaponAlready then
                    if sched == SCHED_RELOAD or act == ACT_RELOAD then
                        npc.DroppedWeaponAlready = true

                        npc:DropWeapon()
                        npc:SetEnemy(NULL)
                        npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
                    end
                end
            end
        end
    end

end)

function destroy_npc_limb(npc,bonename,dmg_data)
    local boneID = npc:LookupBone(bonename)
    if boneID == nil or boneID < 0 then return end

    if table.HasValue(gore_mod_slice_damege, dmg_data.dmg_type) then
        gore_mod_decap_ragdoll(npc,bonename,dmg_data)
    else
        --ParticleEffect("blood_advisor_puncture", npc:GetBonePosition(npc:LookupBone(bonename)), npc:GetAngles(), self)       
        make_npc_gibs(npc,bonename,dmg_data)
    end

    net.Start("noob_gore_gib_npc_bone")
        net.WriteEntity(npc)
        net.WriteInt(boneID, 8)
    net.Broadcast()
end
function make_npc_gibs(npc,bone_name,dmg_data)
    local bone_id = npc:LookupBone(bone_name)
    if bone_id == nil or bone_id < 0 then return end

    -- Keep the recursive visual-gib path safe on models that expose animation
    -- bones without a matching physics bone.
    local physBone = npc:TranslateBoneToPhysBone(bone_id)
    if physBone ~= nil and physBone >= 0 then
        npc.LambdaGoreLastGibBoneHasPhysics = IsValid(npc:GetPhysicsObjectNum(physBone))
    else
        npc.LambdaGoreLastGibBoneHasPhysics = false
    end
	
		hook.Call( "noob_gore_on_gib_destroid", nil,npc,bone_name,dmg_data) --call this hook to make gibs based on bone name

    local children = npc:GetChildBones(bone_id)
    for k, v in pairs(children) do --no more shit code
		local bone_children_name = npc:GetBoneName( v )
        make_npc_gibs(npc,bone_children_name,dmg_data)
    end
end