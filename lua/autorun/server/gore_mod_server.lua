include( "gore_mod/ConVar.lua" )


hook.Add("EntityTakeDamage", "pai_do_reabilitado",function(npc, dmginfo) --gib script
    if npc:IsNPC() then
        npc.dmg_pos = dmginfo:GetDamagePosition()
        npc.dmg_type = dmginfo:GetDamageType()
        npc.dmg_force = dmginfo:GetDamageForce()
        npc.dmg_dir = dmginfo:GetDamageForce():Angle()
        npc.dmg_total_damege = dmginfo:GetDamage()
        if GetConVar("dissolve_efect_EXPEREMENTAL"):GetBool() then
            if dmginfo:IsDamageType(DMG_DISSOLVE) then
                npc.isdissolverd = true 
            end
        end
        if GetConVar("acid_efect_EXPEREMENTAL"):GetBool() then
            if dmginfo:IsDamageType(DMG_ACID) then
                npc.is_melt = true 
            end
        end
    end
end)
hook.Add("CreateEntityRagdoll", "Replace_shit_Ragdoll", function(owner, ragdoll)
    if owner.is_madness_combat_npc == true then return end
    if GetConVar("gore_enable"):GetBool() then
        local dmg_data = {
            dmg_type = owner.dmg_type,
            dmg_pos = owner.dmg_pos,
            dmg_force = owner.dmg_force,
            dmg_dir = owner.dmg_dir,
            dmg_total_damege = owner.dmg_total_damege,
            slice = false 
        }
        if owner.isdissolverd then
            if GetConVar("dissolve_efect_EXPEREMENTAL"):GetBool() then
                dmg_data.dmg_total_damege = 0
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
        end
        if owner:IsOnFire() and GetConVar("burned_corpse_effect_EXPEREMENTAL"):GetBool() and owner:LookupBone("ValveBiped.Bip01_Spine") ~= nil then --fire efect
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
                        local NoDecalFilter = {ragdoll}
					    util.Decal("Scorch", ragdoll:GetPos(), ragdoll:GetPos() - Vector(0, 0, 50), NoDecalFilter) 

                    end
                end)
            end)
		end
        if owner.is_melt and owner:LookupBone("ValveBiped.Bip01_Spine") ~= nil then
            ragdoll:SetRenderMode(RENDERMODE_TRANSCOLOR)
            gore_mod_bonemerge_prop(ragdoll,"models/player/skeleton.mdl")
            ragdoll:SetColor(Color(255, 255, 255, 255))
            ragdoll.nogap = true 
            ragdoll.no_limb = true 
            ragdoll.no_gibs = true 
            local alpha = 255

            --ParticleEffectAttach("smoke_gib_01",PATTACH_ABSORIGIN_FOLLOW,ragdoll,0)  
            timer.Create("PropFadeOut_" .. ragdoll:EntIndex(), 0.05, 100, function()
                if not IsValid(ragdoll) then return end

                alpha = math.max(alpha - 50, 0)
                ragdoll:SetColor(Color(255, 255, 255, alpha))
                if alpha <= 0 and not ragdoll.fucked then
                    ragdoll.fucked = true 
                    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			            local colide = ragdoll:GetPhysicsObjectNum( i )
                        ParticleEffect("blood_impact_green_01",colide:GetPos(), ragdoll:GetAngles(), self)     
		            end
                end
            end)
        end
        gore_mod_ApplyCorpseEffects(ragdoll)

        if dmg_data.dmg_type == 64 or dmg_data.dmg_type == 1 and dmg_data.dmg_total_damege > 100 then
            gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force,true)
        else
            if owner.LeftArmDestroid or owner.RightArmDestroid then
                dmg_data.slice = true 
                if owner.RightArmDestroid then
                    gore_mod_gib_PhysBone(ragdoll,"ValveBiped.Bip01_R_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_R_Forearm") --call this hook to make cap based on bone name
                end
                if owner.LeftArmDestroid then
                    gore_mod_gib_PhysBone(ragdoll,"ValveBiped.Bip01_L_Forearm",dmg_data)
                    hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),"ValveBiped.Bip01_L_Forearm") --call this hook to make cap based on bone name
                end
            end
            dmg_data.slice = false  
            local hit = gore_mod_GetClosestPhysBone(ragdoll,dmg_data)
            local PhysicsBone = hit.PhysicsBone
            local bone = ragdoll:TranslatePhysBoneToBone(PhysicsBone)
            local bone_name = ragdoll:GetBoneName( bone ) 	
            print(bone_name)

            if ragdoll.gore_mod_boneHealth[PhysicsBone] then
				ragdoll.gore_mod_boneHealth[PhysicsBone] = ragdoll.gore_mod_boneHealth[PhysicsBone] - dmg_data.dmg_total_damege*2
			end	
            if ragdoll.gore_mod_boneHealth[PhysicsBone] <= 0 and ragdoll.gib_bone[PhysicsBone] ~= PhysicsBone then 
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) or bone_name == "ValveBiped.Bip01_Spine2" then
                    dmg_data.slice = true 
                else
                    ParticleEffect("blood_advisor_puncture", ragdoll:GetBonePosition(bone), ragdoll:GetAngles(), self)                
                end
                gore_mod_dismember_limb(ragdoll,bone_name,dmg_data) 
            end
        end
    end
end)


hook.Add("OnEntityCreated", "On_shit_ent_is_created", function(ragdoll)
    if GetConVar("gore_enable"):GetBool() then 
		if GetConVar("can_gib_only_npc_corpse"):GetBool() == false and ragdoll:GetClass() == "prop_ragdoll" then 
			timer.Simple(0, function()
				if IsValid(ragdoll) and not ragdoll.destructible_Corpse then
					gore_mod_ApplyCorpseEffects(ragdoll) 
				end
			end)
		end
	end
end)
include( "gore_mod/function.lua" )
include( "gore_mod/damege.lua" )
include( "gore_mod/giblist.lua" )
include( "gore_mod/hook.lua" )
include( "gore_mod/livedismenber.lua" )