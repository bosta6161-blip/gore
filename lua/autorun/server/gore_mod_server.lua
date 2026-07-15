include( "gore_mod/ConVar.lua" )

hook.Add("EntityTakeDamage", "pai_do_reabilitado",function(npc, dmginfo) --gib script
    if npc:IsNPC() then
        npc.dmg_pos = dmginfo:GetDamagePosition()
        npc.dmg_type = dmginfo:GetDamageType()
        npc.dmg_force = dmginfo:GetDamageForce()
        npc.dmg_total_damege = dmginfo:GetDamage()
    end
end)
hook.Add("CreateEntityRagdoll", "Replace_shit_Ragdoll", function(owner, ragdoll)
    if owner.is_madness_combat_npc == true then return end
    if GetConVar("gore_enable"):GetBool() then
        local dmg_data = {
            dmg_type = owner.dmg_type,
            dmg_pos = owner.dmg_pos,
            dmg_force = owner.dmg_force,
            dmg_total_damege = owner.dmg_total_damege,
            slice = false 
        }
        ApplyCorpseEffects(ragdoll)
        if dmg_data.dmg_type == 64 and dmg_data.dmg_total_damege > 100 then
            gib_ragdolll(ragdoll,dmg_data.dmg_force)
        else
            if owner.LeftArmDestroid or owner.RightArmDestroid then
                dmg_data.slice = true 
                if owner.RightArmDestroid then
                    gib_PhysBone(ragdoll,"ValveBiped.Bip01_R_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_R_Forearm") --call this hook to make cap based on bone name
                end
                if owner.LeftArmDestroid then
                    gib_PhysBone(ragdoll,"ValveBiped.Bip01_L_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_L_Forearm") --call this hook to make cap based on bone name
                end
            end
            dmg_data.slice = false  
            local hit = GetClosestPhysBone(ragdoll,dmg_data.dmg_pos)
            local bone = ragdoll:TranslatePhysBoneToBone(hit)
            local bone_name = ragdoll:GetBoneName( bone ) 	
            if ragdoll.gore_mod_boneHealth[hit] then
				ragdoll.gore_mod_boneHealth[hit] = ragdoll.gore_mod_boneHealth[hit] - dmg_data.dmg_total_damege*2
			end	
            if ragdoll.gore_mod_boneHealth[hit] <= 0 and ragdoll.gib_bone[hit] ~= hit then 
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    dmg_data.slice = true 
                end
                dismember_limb(ragdoll,bone_name,dmg_data) 
            end
        end
    end
end)


hook.Add("OnEntityCreated", "On_shit_ent_is_created", function(ragdoll)
    if GetConVar("gore_enable"):GetBool() then 
		if GetConVar("can_gib_only_npc_corpse"):GetBool() == false and ragdoll:GetClass() == "prop_ragdoll" then 
			timer.Simple(0, function()
				if IsValid(ragdoll) and not ragdoll.destructible_Corpse then
					ApplyCorpseEffects(ragdoll) 
				end
			end)
		end
	end
end)
include( "gore_mod/function.lua" )
include( "gore_mod/damege.lua" )
include( "gore_mod/hook.lua" )
include( "gore_mod/livedismenber.lua" )