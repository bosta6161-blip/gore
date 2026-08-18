local goremod_player_death_info = {}

-- Cache last damage info for each player
hook.Add("EntityTakeDamage", "GoreMod_CachePlayerDamage", function(target, dmginfo)
    if target:IsPlayer() and GetConVar("goremod_enable"):GetBool() then
        local dmgpos = dmginfo:GetDamagePosition()
        local dmgforce = dmginfo:GetDamageForce()

        -- falldamage..
        if bit.band(dmginfo:GetDamageType(), DMG_FALL) > 0 then
            dmgpos = target:GetPos()
            dmgforce = target:GetVelocity()
            if dmgforce:LengthSqr() < 1 then
                dmgforce = Vector(0, 0, -400) -- velocity already zeroed
            end
        end

        goremod_player_death_info[target] = {
            dmgtype = dmginfo:GetDamageType(),
            hitgroup = target:LastHitGroup(),
            dmgpos = dmgpos or target:GetPos(),
            attacker = dmginfo:GetAttacker(),
            inflictor = dmginfo:GetInflictor(),
            amount = dmginfo:GetDamage(),
            dmg_force = dmgforce,
            dmg_dir = dmgforce:Angle(),
            time = CurTime()
        }
    end
end)

local function IsPlayerRagdoll(owner, ragdoll)
    return IsValid(owner) and owner:IsPlayer() and IsValid(ragdoll) and ragdoll:GetClass() == "prop_ragdoll"
end

hook.Add("CreateEntityRagdoll", "GoreMod_ApplyToPlayerRagdoll", function(owner, ragdoll)
    -- the hook requires both of these to be turned on now
    if not GetConVar("goremod_rd_bridge_enable"):GetBool() or not GetConVar("goremod_enable"):GetBool() then
        return
    end
    if not IsPlayerRagdoll(owner, ragdoll) then
        return
    end

    -- fix for enhanced death animations
    ragdoll:CallOnRemove("GoreMod_ClearStalePlayerORagID", function()
        if IsValid(owner) and owner:GetNW2Int("PlayerORagID", 0) == ragdoll:EntIndex() then
                owner:SetNW2Int("PlayerORagID", 0)
        end
    end)

    -- for ragdoll death v2
    local info = goremod_player_death_info[owner]
    local isFreshDeath = info and info.time and (CurTime() - info.time) < 3

    if isFreshDeath then
        local dmg_data = {
            dmg_type = info.dmgtype,
            dmg_pos = info.dmgpos,
            dmg_force = info.dmg_force,
            dmg_dir = info.dmg_dir,
            dmg_total_damege = info.amount,
            is_player = true,
            slice = false 
        }
        gore_mod_ApplyCorpseEffects(ragdoll)
        goremod_do_ragdoll_gib_on_deafh(ragdoll,owner,dmg_data)
        goremod_player_death_info[owner] = nil
    end
end)
--noob gore-ragdoll death bridge made by Defrektif (that's me hello)
