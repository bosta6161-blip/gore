include( "gore_mod/ConVar.lua" )


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
        if GetConVar("goremod_acid_efect_EXPEREMENTAL"):GetBool() then
            if dmginfo:IsDamageType(DMG_ACID) then
                npc.is_melt = true 
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

        if dmg_data.dmg_type == 64 or dmg_data.dmg_type == 1 and dmg_data.dmg_total_damege > 100 and GetConVar("goremod_can_npc_explode"):GetBool() then
            gore_mod_gib_ragdolll(ragdoll,dmg_data.dmg_force,true)
        elseif owner.goremod_is_slice_inhalf and owner:LookupBone("ValveBiped.Bip01_Spine2") ~= nil and GetConVar("goremod_sawblade_slice_EXPEREMENTAL"):GetBool()then
            dmg_data.slice = true 
            dmg_data.dmg_force = Vector(0,0,16000)
            ragdoll:EmitSound( "ambient/machines/slicer" .. math.random(1,4) .. ".wav", 120, 100, 1, CHAN_AUTO ) -- Same as below
            gore_mod_dismember_limb(ragdoll,"ValveBiped.Bip01_Spine2",dmg_data) 
        elseif owner.is_melt and owner:LookupBone("ValveBiped.Bip01_Spine") ~= nil then
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
                        local NoDecalFilter = {ragdoll}
					    util.Decal("Scorch", ragdoll:GetPos(), ragdoll:GetPos() - Vector(0, 0, 50), NoDecalFilter) 

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

            local PhysicsBone = gore_mod_GetClosestPhysBone(ragdoll,dmg_data).PhysicsBone
            if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) then
                PhysicsBone = gore_mod_GetClosestPhysBone_on_ragdoll(ragdoll,dmg_data.dmg_pos) --get hit physbone
            end
            local bone = ragdoll:TranslatePhysBoneToBone(PhysicsBone)
            local bone_name = ragdoll:GetBoneName( bone ) 	
            print(bone_name)

            if ragdoll.gore_mod_boneHealth[PhysicsBone] then
				ragdoll.gore_mod_boneHealth[PhysicsBone] = ragdoll.gore_mod_boneHealth[PhysicsBone] - dmg_data.dmg_total_damege
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
include( "gore_mod/function.lua" )
include( "gore_mod/damege.lua" )
include( "gore_mod/giblist.lua" )
include( "gore_mod/hook.lua" )
include( "gore_mod/livedismenber.lua" )