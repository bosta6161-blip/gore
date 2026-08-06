

    local player_death_info = {}

    -- Cache last damage info for each player
    hook.Add("EntityTakeDamage", "GoreMod_CachePlayerDamage", function(target, dmginfo)
        if target:IsPlayer() then
            player_death_info[target] = {
                dmgtype = dmginfo:GetDamageType(),
                hitgroup = target:LastHitGroup(),
                dmgpos = dmginfo:GetDamagePosition() or target:GetPos(),
                attacker = dmginfo:GetAttacker(),
                inflictor = dmginfo:GetInflictor(),
                amount = dmginfo:GetDamage(),
                dmg_force = dmginfo:GetDamageForce(),
                dmg_dir = dmginfo:GetDamageForce():Angle()
            }
        end
    end)

    local function IsPlayerRagdoll(owner, ragdoll)
        return IsValid(owner) and owner:IsPlayer() and IsValid(ragdoll) and ragdoll:GetClass() == "prop_ragdoll"
    end

    hook.Add("CreateEntityRagdoll", "GoreMod_ApplyToPlayerRagdoll", function(owner, ragdoll)
        if not GetConVar("goremod_rd_bridge_enable"):GetBool() then
            return
        end
        if not IsPlayerRagdoll(owner, ragdoll) then
            return
        end
        if not ragdoll.GravGunPunt then
            local info = player_death_info[owner] or {}
            local dmg_data = {
                dmg_type = info.dmgtype,
                dmg_pos = info.dmgpos,
                dmg_force = info.dmg_force,
                dmg_dir = info.dmg_dir,
                dmg_total_damege = info.amount,
                is_player = true,
                slice = false 
            }


            goremod_do_ragdoll_gib_on_deafh(ragdoll,owner,dmg_data)
        end

    end)
--noob gore-ragdoll death bridge made by Defrektif 