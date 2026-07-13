hook.Add("EntityTakeDamage", "goremod_damege", function(ragdoll, dmginfo)
	if GetConVar("gore_enable"):GetBool() == true then
		if ragdoll:IsRagdoll() and ragdoll.destructible_Corpse and CurTime() > ragdoll.gib_start_delay then 
			local doDamege = true 
			local dmg_force = dmginfo:GetDamage()
			local hit = GetClosestPhysBone(ragdoll,dmginfo:GetDamagePosition()) --get hit physbone
			if hit == nil then
				return 
			end
			local bone = ragdoll:TranslatePhysBoneToBone(hit)
			local bone_name = ragdoll:GetBoneName( bone ) 		
            
            local dmg_data = {
                dmg_type = dmginfo:GetDamageType(),
                dmg_pos = dmginfo:GetDamagePosition(),
                dmg_force = dmginfo:GetDamageForce(),
                slice = false 
            }
            local damageForce = dmg_data.dmg_force:Length()
            if damageForce > 1200 then
                local hit = GetClosestPhysBone(ragdoll,dmg_data.dmg_pos)
                local bone = ragdoll:TranslatePhysBoneToBone(hit)
                local bone_name = ragdoll:GetBoneName( bone ) 	
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) then
                    dmg_data.slice = true 
                end
                PrintMessage(3,bone_name)
                dismember_limb(ragdoll,bone_name,dmg_data) 
            end
		end 
	end
end)