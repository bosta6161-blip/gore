CreateConVar("gore_enable", "1", FCVAR_ARCHIVE, "gore_enable")
CreateConVar("can_gib_only_npc_corpse", "0", FCVAR_ARCHIVE, "can_gib_only_npc_corpse")
CreateConVar("gore_debug", "0", FCVAR_ARCHIVE, "gore_debug")
CreateConVar("gib_fade_time", "30", FCVAR_ARCHIVE, "gib_fade_time") 
CreateConVar("sliced_ragdoll_fade_time", "30", FCVAR_ARCHIVE, "sliced_ragdoll_fade_time") 
CreateConVar("cannibalism", "1", FCVAR_ARCHIVE, "cannibalism")
hook.Add("EntityTakeDamage", "pai_do_reabilitado",function(npc, dmginfo) --gib script
    if npc:IsNPC() then
        npc.dmg_pos = dmginfo:GetDamagePosition()
        npc.dmg_type = dmginfo:GetDamageType()
        npc.dmg_force = dmginfo:GetDamageForce()
    end
end)
hook.Add("CreateEntityRagdoll", "Replace_shit_Ragdoll", function(owner, ragdoll)
    if owner.is_madness_combat_npc == true then return end
    local dmg_data = {
        dmg_type = owner.dmg_type,
        dmg_pos = owner.dmg_pos,
        dmg_force = owner.dmg_force,
        slice = false 
    }
    if GetConVar("gore_enable"):GetBool() then
        if dmg_data.dmg_type == 64 then
            gib_ragdolll(ragdoll,dmg_data.dmg_force)
        else
            local damageForce = dmg_data.dmg_force:Length()
            if damageForce > 1200 then
                local hit = GetClosestPhysBone(ragdoll,dmg_data.dmg_pos)
                local bone = ragdoll:TranslatePhysBoneToBone(hit)
                local bone_name = ragdoll:GetBoneName( bone ) 	
                if table.HasValue( gore_mod_slice_damege,dmg_data.dmg_type) then
                    dmg_data.slice = true 
                end
                dismember_limb(ragdoll,bone_name,dmg_data) 
            end
            ragdoll.destructible_Corpse = true 
            ragdoll.gib_start_delay = CurTime() + 1
        end
    end
end)
function ApplyCorpseEffects(ragdoll)
	ragdoll.destructible_Corpse = true
	ragdoll.gib_start_delay = CurTime() + 1
	ragdoll:CallOnRemove("Remove_ragdoll_from_the_table_shit", function()
        table.RemoveByValue(gib_PhysBone_RAGDOLLS, ragdoll) --remove ragdoll on the table
    end)
end
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