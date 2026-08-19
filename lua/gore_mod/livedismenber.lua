-- Lambda Gore
-- Sistema de desmembramento de NPCs vivos.
-- Mantém os nomes originais das funções para não quebrar o restante do addon.

util.AddNetworkString("noob_gore_gib_npc_bone")

-- Faz o NPC sangrar pelo osso atingido.
function goremod_DoBleed(ent, bone, attacker) --coloca um script melhor para o npc tomar dano
    timer.Create("Bleed_Timer_" .. ent:EntIndex(),0.1,200, function()
        if ent:IsValid()then
            local dmg = DamageInfo() -- Create a server-side damage information class
            dmg:SetDamage(ent:Health()/50+0.05)
            dmg:SetAttacker(attacker)
            dmg:SetDamagePosition(ent:GetPos())

            dmg:SetDamageType(DMG_NEVERGIB)
            ent:TakeDamageInfo( dmg )
        end
    end)
end

-- Verifica se o NPC possui o bone.
local function goremod_HasBone(ent, boneName)
    if not IsValid(ent) then return false end
    if not boneName then return false end

    local boneID = ent:LookupBone(boneName)

    return boneID ~= nil and boneID >= 0
end

-- Desmembra um membro de um NPC vivo.
function destroy_npc_limb(npc, bonename, dmg_data)
    if not IsValid(npc) then return end
    if not goremod_HasBone(npc, bonename) then return end

    local boneID = npc:LookupBone(bonename)

    if not boneID or boneID < 0 then return end

    -- Impede que o mesmo membro seja destruído várias vezes.
    npc.goremod_destroyed_limbs = npc.goremod_destroyed_limbs or {}

    if npc.goremod_destroyed_limbs[bonename] then
        return
    end

    npc.goremod_destroyed_limbs[bonename] = true

    -- Dano de corte pode criar um ragdoll separado.
    if table.HasValue(gore_mod_slice_damege or {}, dmg_data.dmg_type) then
        gore_mod_decap_ragdoll(npc, bonename, dmg_data)
    else
        make_npc_gibs(npc, bonename, dmg_data)
    end

    -- Avisa o cliente para esconder o membro correspondente.
    net.Start( "noob_gore_gib_npc_bone" )
		net.WriteEntity(npc) 
		net.WriteInt(npc:LookupBone(bonename), 8 ) --bone to get cut
    net.Broadcast()
    npc:DropWeapon()
end

-- Cria os gibs relacionados ao bone destruído.
function make_npc_gibs(npc, bone_name, dmg_data)
    if not IsValid(npc) then return end
    if not goremod_HasBone(npc, bone_name) then return end

    local boneID = npc:LookupBone(bone_name)

    if not boneID or boneID < 0 then return end

    -- Executa o sistema de gibs personalizado.
    hook.Call(
        "noob_gore_on_gib_destroid",
        nil,
        npc,
        bone_name,
        dmg_data
    )

    -- Procura os bones filhos.
    local children = npc:GetChildBones(boneID)

    if not children then return end

    for _, childID in ipairs(children) do
        local childName = npc:GetBoneName(childID)

        if childName and childName ~= "__INVALIDBONE__" then
            make_npc_gibs(npc, childName, dmg_data)
        end
    end
end

-- Processa dano em NPC vivo.
hook.Add("EntityTakeDamage", "LambdaGore_LivingNPCDamage", function(npc, dmginfo)
    if not IsValid(npc) then return end
    if not npc:IsNPC() then return end
    -- Apenas NPCs com rig compatível.
    if not goremod_HasBone(npc, "ValveBiped.Bip01_Spine") then
        return
    end
    local dmg_data = {
        dmg_type = dmginfo:GetDamageType(),
        dmg_pos = dmginfo:GetDamagePosition(),
        dmg_force = dmginfo:GetDamageForce(),
        dmg_dir = dmginfo:GetDamageForce():Angle(),
        dmg_total_damege = dmginfo:GetDamage(),
        slice = false 
    }

    if dmg_data.dmg_total_damege <= 0 then return end

    local damagePos = dmginfo:GetDamagePosition()

    if damagePos == vector_origin then
        damagePos = npc:WorldSpaceCenter()
    end

    local attacker = dmginfo:GetAttacker()

    local bones_dismenber_gore = {
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_L_Forearm",
	}
	for _, bonename in ipairs(bones_dismenber_gore) do  --no more shit code
        local boneID = npc:LookupBone(bonename)
        local bonePos = npc:GetBonePosition(boneID)

        if bonePos and bonePos:Distance(damagePos) < 18 then
            goremod_DoBleed(npc, boneID, attacker)

            hook.Call("noob_gore_gap",nil,npc,npc:GetModel(),bonename) --call the hook to spawn a model in ragdoll
            hook.Call("noob_gore_make_limb_blood",nil,npc,bonename) -- call this hook to spawn blood efect
            hook.Call( "noob_gore_make_gore_sound", nil,npc,bone_name) --call this hook to make sound on bone name location
            destroy_npc_limb(npc, bonename, dmg_data)
        end
	end
end)