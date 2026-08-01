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
			if dmginfo:GetDamageType() == DMG_CRUSH and dmginfo:GetDamage() < 500 then
				doDamege = false    
			end 
            
			local dmg_force = dmginfo:GetDamage()
			local hit = gore_mod_GetClosestPhysBone_on_ragdoll(ragdoll,dmginfo:GetDamagePosition()) --get hit physbone
            if hit == nil then
				return 
			end
			local bone = ragdoll:TranslatePhysBoneToBone(hit)
			local bone_name = ragdoll:GetBoneName( bone ) 	
            if GetConVar("gore_debug"):GetBool() then
                print(bone_name.."is hit")
            end

            local damageForce = dmg_data.dmg_force:Length()
            if ragdoll.gore_mod_boneHealth[hit] and doDamege == true then
				ragdoll.gore_mod_boneHealth[hit] = ragdoll.gore_mod_boneHealth[hit] - dmginfo:GetDamage()
                if GetConVar("gore_debug"):GetBool() then
				    print(bone_name.." health"..ragdoll.gore_mod_boneHealth[hit])
                end
			end

			if ragdoll.gore_mod_boneHealth[hit] <= 0 and ragdoll.gib_bone[hit] ~= hit and doDamege == true then 
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    if dmg_data.dmg_type == 1 and GetConVar("DMG_CRUSH_slice_ragdoll"):GetBool() == false then
                        dmg_data.slice = false     
                    else
                        dmg_data.slice = true 
                    end

                else
                    ParticleEffect("blood_advisor_puncture", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), ragdoll)
                end

                if bone == 0 then
                    gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force,true )    
                elseif ragdoll.main_bone_sigma == bone then
                    ParticleEffect("blood_impact_red_01_goop", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), self)
                    gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force)
                else
                    gore_mod_dismember_limb(ragdoll,bone_name,dmg_data) 
                end
			end
		end 
	end
end)
