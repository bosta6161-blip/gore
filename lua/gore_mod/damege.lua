hook.Add("EntityTakeDamage", "goremod_damege", function(ragdoll, dmginfo)
	if GetConVar("gore_enable"):GetBool() == true and  GetConVar("can_gib_ragdoll"):GetBool() == true then
		if ragdoll:IsRagdoll() and ragdoll.destructible_Corpse and CurTime() > ragdoll.gib_start_delay then 
            if !ragdoll.gib_bone then
		        ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll)
	        end
            local dmg_data = {
                dmg_type = dmginfo:GetDamageType(),
                dmg_pos = dmginfo:GetDamagePosition(),
                dmg_force = dmginfo:GetDamageForce(),
                dmg_dir = dmginfo:GetDamageForce():Angle(),
                slice = false 
            }
			local doDamege = true 
			if dmgType == DMG_CRUSH and dmginfo:GetDamage() < 500 then
				doDamege = false    
			end 
            
			local dmg_force = dmginfo:GetDamage()
			local hit = GetClosestPhysBone(ragdoll,dmg_data) --get hit physbone
            if hit.PhysicsBone == nil then
				return 
			end
            local PhysicsBone = hit.PhysicsBone
			local bone = ragdoll:TranslatePhysBoneToBone(PhysicsBone)
			local bone_name = ragdoll:GetBoneName( bone ) 	
            print(bone_name)

            local damageForce = dmg_data.dmg_force:Length()
            if ragdoll.gore_mod_boneHealth[PhysicsBone] then
				ragdoll.gore_mod_boneHealth[PhysicsBone] = ragdoll.gore_mod_boneHealth[PhysicsBone] - dmginfo:GetDamage()
				print("health"..ragdoll.gore_mod_boneHealth[PhysicsBone])
			end

			if ragdoll.gore_mod_boneHealth[PhysicsBone] <= 0 and ragdoll.gib_bone[PhysicsBone] ~= PhysicsBone and doDamege == true then 
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    dmg_data.slice = true 
                else
                    ParticleEffect("blood_advisor_puncture", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), ragdoll)
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
