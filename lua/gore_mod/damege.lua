hook.Add("EntityTakeDamage", "goremod_damege", function(ragdoll, dmginfo)
	if GetConVar("gore_enable"):GetBool() == true then
		if ragdoll:IsRagdoll() and ragdoll.destructible_Corpse and CurTime() > ragdoll.gib_start_delay then 
			local doDamege = true 
			if dmgType == DMG_CRUSH and dmginfo:GetDamage() < 500 then
				doDamege = false    
			end 
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
            if ragdoll.gore_mod_boneHealth[hit] then
				ragdoll.gore_mod_boneHealth[hit] = ragdoll.gore_mod_boneHealth[hit] - dmginfo:GetDamage()
				print("health"..ragdoll.gore_mod_boneHealth[hit])
			end

			if ragdoll.gore_mod_boneHealth[hit] <= 0 and ragdoll.gib_bone[hit] ~= hit and doDamege == true then 
                local hit = GetClosestPhysBone(ragdoll,dmg_data.dmg_pos)
                local bone = ragdoll:TranslatePhysBoneToBone(hit)
                local bone_name = ragdoll:GetBoneName( bone ) 	
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    dmg_data.slice = true 
                else
                    ParticleEffect("blood_impact_red_01_goop", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), self)
                end

                if bone == 0 then
                    gib_ragdolll(ragdoll,dmg_data.dmg_force,true )    
                elseif ragdoll.main_bone_sigma == bone then
                    ParticleEffect("blood_impact_red_01_goop", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), self)
                    gib_ragdolll(ragdoll,dmg_data.dmg_force)
                else
                    dismember_limb(ragdoll,bone_name,dmg_data) 
                end
			end
		end 
	end
end)