local function gore_mod_sigma_children_gib(ragdoll, bone_name)
    if not IsValid(ragdoll) then return end

    local boneID = ragdoll:LookupBone(bone_name)
    if boneID == nil or boneID < 0 then return end

    local sigma = ragdoll:GetChildBones(boneID) or {}
    for _, childID in ipairs(sigma) do
        local childName = ragdoll:GetBoneName(childID)
        for _, child in ipairs(ragdoll:GetChildren()) do
            if IsValid(child) and child.bonename_parent == childName then
                child:Remove()
            end
        end

        gore_mod_sigma_children_gib(ragdoll, childName)
    end
end
hook.Add("noob_gore_gap", "do gib gap", function(ragdoll, model, bone_name)
    -- Gap models are optional and can be disabled globally.
    if not GetConVar("goremod_ragdoll_has_gap_models"):GetBool() then return end
    if not IsValid(ragdoll) or ragdoll.nogap then return end

    -- Never trust a caller's model blindly. The ragdoll is the source of truth.
    model = ragdoll:GetModel()
    if not isstring(model) then return end
    if goremod_model_gap_blacklist[model] then return end

    local gib_data = bone_name_togap[bone_name]
    if not gib_data then return end

    local bone_id = ragdoll:LookupBone(bone_name)
    if bone_id == nil or bone_id < 0 then return end

    local bone_parent = ragdoll:GetBoneParent(bone_id)
    if bone_parent == nil or bone_parent < 0 then bone_parent = bone_id end

    local bonepos, bone_rotation = ragdoll:GetBonePosition(bone_parent)
    if not bonepos then return end

    -- Per-NPC/per-bone models override the generic gore model.
    local customGapModel = goremod_GetNPCSpecificGapModel(model, bone_name)
    local selectedGapModel = customGapModel or gib_data.model
    if not isstring(selectedGapModel) then return end

    if gib_data.bonemerge == true then
        gore_mod_bonemerge_prop(ragdoll, selectedGapModel, bone_name)
        gore_mod_sigma_children_gib(ragdoll, bone_name)
        return
    end

    local offset = gib_data.offset or vector_origin
    local capScale = gib_data.capScale or Vector(1, 1, 1)
    local localAng = gib_data.localAng or angle_zero

    if gib_data.fem_offset and string.find(string.lower(model), "female", 1, true) then
        offset = gib_data.fem_offset
    end

    local gap = ents.Create("prop_dynamic")
    if not IsValid(gap) then return end

    gap:SetModel(selectedGapModel)
    gap:Spawn()
    gap:SetNotSolid(true)
    gap:DrawShadow(false)
    gap:ManipulateBoneScale(0, capScale)
    gap:FollowBone(ragdoll, bone_parent)

    local parentPos, parentAng = ragdoll:GetBonePosition(bone_parent)
    if parentPos and parentAng then
        local lpos = WorldToLocal(bonepos, bone_rotation, parentPos, parentAng)
        gap:SetLocalPos(lpos + offset)
    else
        gap:SetLocalPos(offset)
    end

    gap:SetLocalAngles(localAng)
    gap.bonename_parent = bone_name
    gap.is_gap = true

    if ragdoll.goremod_bloodColor_is_YELLOW then
        gap:SetColor(Color(255, 255, 0, 255))
    end

    gore_mod_sigma_children_gib(ragdoll, bone_name)
end)

hook.Add("noob_gore_gap_limb", "do gib gap limb", function(ragdoll, model, bone_name)
    if not GetConVar("goremod_ragdoll_has_gap_models"):GetBool() then return end
    if not IsValid(ragdoll) or ragdoll.nogap then return end

    model = ragdoll:GetModel()
    if goremod_model_gap_blacklist[model] then return end

    local genericModel = bone_name_togaplimb[bone_name]
    if not genericModel then return end

    -- A specific NPC model can override the default detached-limb model.
    local customGapModel = goremod_GetNPCSpecificGapModel(model, bone_name)
    gore_mod_bonemerge_prop(ragdoll, customGapModel or genericModel, bone_name)
end)

hook.Add( "noob_gore_make_limb_blood", "do limb_blood", function(ragdoll,bone_name)
    if GetConVar("goremod_blood"):GetBool() then
        timer.Simple(0, function()
            if not ragdoll:IsValid() then
                return 
            end
            local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name

            if bone_id == 0 then
                return 
            end
            if ragdoll.goremod_is_ragdoll_limb then
                return 
            end
            local bone_parent = ragdoll:GetBoneParent(bone_id)
            local bonepos,bone_rotation = ragdoll:GetBonePosition(bone_id)
            

            if bone_parent == 0 then
                bone_parent = bone_id
            end
            local aids,bone_rotation67 = ragdoll:GetBonePosition(bone_parent)
            

            local lpos, lang = WorldToLocal(bonepos,bone_rotation67, ragdoll:GetBonePosition(bone_parent))

            local meme = ents.Create("prop_dynamic")
            if not IsValid(meme) then return end 
            
            meme:SetModel("models/props_junk/GlassBottle01a.mdl")               
            meme:Spawn()
            meme:SetModelScale(0)
            meme:SetNotSolid(true)
            meme:DrawShadow(false)
        
            SafeRemoveEntityDelayed(meme, 15)
        
            meme:FollowBone(ragdoll, bone_parent)
        
            meme:SetLocalAngles(lang + Angle(180,0,0))
            meme:SetLocalPos(lpos + lang:Forward()*-8)
            
            local effectdata = EffectData()
            effectdata:SetEntity(meme)
            if ragdoll.goremod_bloodColor_is_YELLOW then
                effectdata:SetFlags(1) 
            else
                effectdata:SetFlags(0)
            end
            util.Effect("goremod_blood_spray", effectdata)
        end)
    end
end )
hook.Add( "noob_gore_make_gore_sound", "do gib gap limb", function(ragdoll,bone_name)
    ragdoll:EmitSound("goremod_gib_sound")
end )
hook.Add( "noob_gore_on_gib_destroid", "on gib destroid", function(ragdoll,bone_name,dmg_data)
    if ragdoll.no_gibs then return end
    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
    local function get_custom_gibs(bone_name)
        -- Model-specific gibs are optional. Generic bone gibs remain the fallback.
        local modelGibs = goremod_npc_specific_gibs and goremod_npc_specific_gibs[ragdoll:GetModel()]
        if GetConVar("goremod_vortigaunt_gore_model"):GetBool()
            and ragdoll:GetModel() == "models/vortigaunt.mdl"
            and istable(modelGibs)
            and istable(modelGibs[bone_name]) then
            return modelGibs[bone_name]
        end

        if not goremod_CustomGibs[bone_name] then return nil end
        return goremod_CustomGibs[bone_name].gibs or 1
    end
    if ragdoll.goremod_bloodColor_is_YELLOW then
        dmg_data.bloodColor_is_YELLOW = true
    end

    local custom_gibs = get_custom_gibs(bone_name)
    if custom_gibs ~= nil then
        for _,v in ipairs(custom_gibs) do
            for i = 1, ( v.count && ( istable(v.count) && math.random(v.count[1], v.count[2]) ) or v.count ) or 1 do
                gore_mod_make_gibs(v.model,ragdoll:GetBonePosition(bone_id),dmg_data)  
            end
        end
    elseif not dmg_data.no_tiny_gibs then
        local surfaceProp = ragdoll:GetBoneSurfaceProp(0)
        if surfaceProp ~= "metal" then
            if dmg_data.bloodColor_is_YELLOW then
                gore_mod_make_gibs(table.Random(BasicGib_Models),ragdoll:GetBonePosition(bone_id),dmg_data) 
            else
                for i = 1,math.random(1,3) do
                    gore_mod_make_gibs("models/props_junk/watermelon01_chunk02a.mdl",ragdoll:GetBonePosition(bone_id),dmg_data,true) 
                end
            end
        end
    end 
end )