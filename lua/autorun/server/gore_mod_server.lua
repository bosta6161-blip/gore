CreateConVar("gore_enable", "1", FCVAR_ARCHIVE, "gore_enable")
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
   
    if GetConVar("gore_enable"):GetBool() then
        local dmg_data = {
            dmg_type = owner.dmg_type,
            dmg_pos = owner.dmg_pos,
            dmg_force = owner.dmg_force,
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
            dismember_limb(ragdoll,bone_name,dmg_data) 
        end
    end
end)

include( "gore_mod/function.lua" )
include( "gore_mod/hook.lua" )