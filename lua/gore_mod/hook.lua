goremod_Customgapgapgapsahur = {
    ["ValveBiped.Bip01_Head1"] = {
        model = "models/noob_dev2323/gib/l4d/common_infected_w_neck.mdl",
        localAng = Angle(180,110,90),
        offset = Vector(-0.812,-2.608,0),
        capScale = Vector(1, 1, 1),
        fem_offset = Vector(-2.912,-2.608,0) 
    },
    ["ValveBiped.Bip01_Spine2"] = {
        model = "models/torsopartial/abdomenvar.mdl",
        localAng = Angle(0, 90, 90),
        offset = Vector(-4,2,0),
        capScale = Vector(1.1, 1.1, 1.1) 
    },
    ["ValveBiped.Bip01_R_UpperArm"] = {
        model = "models/noob_dev2323/gib/l4d/common_infected_w_r_arm_shoulder.mdl",
        localAng = Angle(93.847,110,0),
        offset = Vector(5.195, -4.284, -2.097),
        capScale = Vector(1.1, 1.1,1.1),
    },
    ["ValveBiped.Bip01_L_UpperArm"] = {
        model = "models/noob_dev2323/gib/l4d/common_infected_w_l_arm_shoulder.mdl",
        localAng = Angle(-75.366,-69.060,0),
        offset = Vector(5.579,-4.392,2.039),
        capScale = Vector(1.1, 1.1,1.1),
    }
}
hook.Add( "noob_gore_gap", "do gib gap", function(ragdoll,model,bone_name)
    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
    local bone_parent = ragdoll:GetBoneParent(bone_id)
    local bonepos,bone_rotation = ragdoll:GetBonePosition(bone_parent)

    local model = ragdoll:GetModel()
    local capScale = Vector(1, 1, 1)
    local localAng = Angle(0, 0, 0)
    local offset = Vector(0,0,0)

    if goremod_Customgapgapgapsahur[bone_name] and not goremod_model_gap_blacklist[model] then
        local gib_data = goremod_Customgapgapgapsahur[bone_name]
        print(gib_data.model)
        local gap = ents.Create("prop_dynamic")
        local lpos, lang = WorldToLocal(bonepos,bone_rotation, ragdoll:GetBonePosition(bone_parent))

        if gib_data.fem_offset then
            local lower = string.lower(model)
            if string.find(string.lower(model), "female") then
                gib_data.offset = gib_data.fem_offset
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
        gap:SetLocalPos(lpos + gib_data.offset)
    end
end )
hook.Add( "noob_gore_gap_limb", "do gib gap limb", function(ragdoll,model,bone_name)
    if not goremod_model_gap_blacklist[model] and bone_name_togaplimb[bone_name] then
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
    elseif not dmg_data.no_tiny_gibs then
        if dmg_data.bloodColor_is_YELLOW then
            gore_mod_make_gibs(table.Random(BasicGib_Models),ragdoll:GetBonePosition(bone_id),dmg_data) 
        else
            for i = 1,math.random(1,3) do
                gore_mod_make_gibs("models/props_junk/watermelon01_chunk02a.mdl",ragdoll:GetBonePosition(bone_id),dmg_data,true) 
            end
        end
    end 
end )
