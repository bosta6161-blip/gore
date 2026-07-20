hook.Add( "noob_gore_gap", "do gib gap", function(ragdoll,model,bone_name)
    if bone_name_togap[bone_name] then
        bonemerge_prop(ragdoll,bone_name_togap[bone_name])
    end
end )
hook.Add( "noob_gore_gap_limb", "do gib gap limb", function(ragdoll,model,bone_name)
    if bone_name_togaplimb[bone_name] then
        bonemerge_prop(ragdoll,bone_name_togaplimb[bone_name])
    end
end )
hook.Add( "noob_gore_on_gib_destroid", "on gib destroid", function(ragdoll,bone_name,dmg_data)
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
    else
        if dmg_data.bloodColor_is_YELLOW then
            gore_mod_make_gibs(table.Random(BasicGib_Models),ragdoll:GetBonePosition(bone_id),dmg_data) 
        else
            for i = 1, 6 do
                gore_mod_make_gibs("models/props_junk/watermelon01_chunk02a.mdl",ragdoll:GetBonePosition(bone_id),dmg_data,true) 
            end
        end
    end 
end )
