hook.Add("ScaleNPCDamage","ArmGib",function(npc,hitgroup,dmginfo)
    if GetConVar("gore_enable"):GetBool() == false then return end
    if GetConVar("live_dismenber_EXPEREMENTAL"):GetBool() == false then return end
    if npc:LookupBone("ValveBiped.Bip01_Spine") == nil then return end
	if not npc.LeftArmHealth then
		npc.RightArmHealth = npc:GetMaxHealth()/2.1
		npc.LeftArmHealth = npc:GetMaxHealth()/2
    end

    local dmg_data = {
        dmg_type = dmginfo:GetDamageType(),
        dmg_pos = dmginfo:GetDamagePosition(),
        dmg_force = dmginfo:GetDamageForce(),
        dmg = dmginfo:GetDamage(),
        slice = false 
    }
    if hitgroup == HITGROUP_RIGHTARM and not npc.RightArmDestroid then
        npc.RightArmHealth = npc.RightArmHealth - dmg_data.dmg
        if npc.RightArmHealth < 0 then
            npc.RightArmDestroid = true
            npc:DropWeapon()
            npc:SetEnemy(NULL)
            npc:SetSchedule(SCHED_RUN_FROM_ENEMY)

            bonemerge_prop(npc,"models/noob_dev2323/gib/upperarm_r.mdl")
            destroy_npc_limb(npc,"ValveBiped.Bip01_R_Forearm",dmg_data)
        end
    end
    if hitgroup == HITGROUP_LEFTARM and not npc.LeftArmDestroid then
        npc.LeftArmHealth = npc.LeftArmHealth - dmg_data.dmg
        if npc.LeftArmHealth < 0 then
            npc.LeftArmDestroid = true
            npc:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_POOR )
            npc:SetEnemy(NULL)
            npc:SetSchedule(SCHED_RUN_FROM_ENEMY)
            bonemerge_prop(npc,"models/noob_dev2323/gib/upperarm_l.mdl")
            destroy_npc_limb(npc,"ValveBiped.Bip01_L_Forearm",dmg_data)
        end
    end
end)


hook.Add("Think","ArmCripple_AI",function()
    for _,npc in ipairs(ents.GetAll()) do
        if not npc:IsNPC() then continue end
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
end)

function destroy_npc_limb(npc,bonename,dmg_data)
    if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) then
        decap_ragdoll(npc,bonename,dmg_data)
    else
        --ParticleEffect("blood_advisor_puncture", npc:GetBonePosition(npc:LookupBone(bonename)), npc:GetAngles(), self)       
        make_npc_gibs(npc,bonename,dmg_data)
    end

    net.Start( "noob_gore_gib_npc_bone" )
		net.WriteEntity(npc) 
		net.WriteInt(npc:LookupBone(bonename), 8 ) --bone to get cut
    net.Broadcast()
end
function make_npc_gibs(npc,bone_name,dmg_data)
    if npc:LookupBone(bone_name) == nil or npc:LookupBone(bone_name) == 0 then return end
    local bone_id = npc:LookupBone(bone_name) --get bone id from bone name
	
		hook.Call( "noob_gore_on_gib_destroid", nil,npc,bone_name,dmg_data) --call this hook to make gibs based on bone name

    local children = npc:GetChildBones(bone_id)
    for k, v in pairs(children) do --no more shit code
		local bone_children_name = npc:GetBoneName( v )
        make_npc_gibs(npc,bone_children_name,dmg_data)
    end
end