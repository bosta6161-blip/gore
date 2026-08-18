local function gore_mod_sigma_children_gib(ragdoll,bone_name)
    local sigma = ragdoll:GetChildBones(ragdoll:LookupBone(bone_name))
    for k, v in pairs(sigma) do --no more shit code
        for _,child in ipairs( ragdoll:GetChildren() ) do
            if child.bonename_parent == ragdoll:GetBoneName(v) then
                child:Remove()
            end
        end
        gore_mod_sigma_children_gib(ragdoll,ragdoll:GetBoneName(v))
    end
end
hook.Add( "noob_gore_gap", "do gib gap", function(ragdoll,model,bone_name)
    if GetConVar("goremod_ragdoll_has_gap_models"):GetBool() then
        local model = ragdoll:GetModel()
        local capScale = Vector(1, 1, 1)
        local localAng = Angle(0, 0, 0)
        local offset = Vector(0,0,0)

        if bone_name_togap[bone_name] and not goremod_model_gap_blacklist[model] and not ragdoll.nogap then

            local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
            local bone_parent = ragdoll:GetBoneParent(bone_id)
            local bonepos,bone_rotation = ragdoll:GetBonePosition(bone_parent)

            local gib_data = bone_name_togap[bone_name]
            if gib_data.bonemerge == true then 
                gore_mod_bonemerge_prop(ragdoll,gib_data.model,bone_name)
                gore_mod_sigma_children_gib(ragdoll,bone_name)
            else
                offset = gib_data.offset
                local gap = ents.Create("prop_dynamic")
                local lpos, lang = WorldToLocal(bonepos,bone_rotation, ragdoll:GetBonePosition(bone_parent))

                if gib_data.fem_offset then
                    local lower = string.lower(model)
                    if string.find(string.lower(model), "female") then
                        offset = gib_data.fem_offset
                    end
                end

 
                if not IsValid(gap) then return end
                gap:SetModel(gib_data.model)               
                gap:Spawn()
                gap:SetNotSolid(true)
                gap:DrawShadow(false)

                gap:ManipulateBoneScale(0, gib_data.capScale) --gap scale
                gap:FollowBone(ragdoll, bone_parent)

                gap:SetLocalAngles(gib_data.localAng)
                gap:SetLocalPos(lpos + offset)
                gap.bonename_parent = bone_name
                gap.is_gap = true 
                if ragdoll.goremod_bloodColor_is_YELLOW then
                    gap:SetColor( Color( 255, 255, 0, 255 ))--add ugly piss efect
                end
                gore_mod_sigma_children_gib(ragdoll,bone_name)
            end
        end
    end
end )
hook.Add( "noob_gore_gap_limb", "do gib gap limb", function(ragdoll,model,bone_name)
    if GetConVar("goremod_ragdoll_has_gap_models"):GetBool() then
        if not goremod_model_gap_blacklist[model] and bone_name_togaplimb[bone_name] then
            gore_mod_bonemerge_prop(ragdoll,bone_name_togaplimb[bone_name],bone_name)
        end
    end
end )
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
    local function get_custom_gibs( bone_name )
        if !goremod_CustomGibs[bone_name] then return nil end
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
        if not surfaceProp == "metal" then
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