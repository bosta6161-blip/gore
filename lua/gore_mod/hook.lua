bone_name_togap = {
    ["ValveBiped.Bip01_L_Hand"] = "models/noob_dev2323/gib/l_arm.mdl",
    ["ValveBiped.Bip01_R_Hand"] = "models/noob_dev2323/gib/r_arm.mdl",
    ["ValveBiped.Bip01_L_Forearm"] = "models/noob_dev2323/gib/upperarm_l.mdl",
	["ValveBiped.Bip01_R_Forearm"] = "models/noob_dev2323/gib/upperarm_r.mdl",
	["ValveBiped.Bip01_R_Calf"] = "models/noob_dev2323/gib/r_leg_gap.mdl",
    ["ValveBiped.Bip01_L_Calf"] = "models/noob_dev2323/gib/l_leg_gap.mdl",
	["ValveBiped.Bip01_R_Foot"] = "models/noob_dev2323/gib/r_foot.mdl",
	["ValveBiped.Bip01_L_Foot"] = "models/noob_dev2323/gib/l_foot.mdl",
	["ValveBiped.Bip01_Head1"] = "models/noob_dev2323/gib/l4d/head_gore2.mdl"
} 
hook.Add( "noob_gore_gap", "do gib gap", function(ragdoll,model,bone_name)
    if bone_name_togap[bone_name] then
        bonemerge_prop(ragdoll,bone_name_togap[bone_name])
    end
end )
bone_name_togib = {
    ["valvebiped.bip01_l_upperarm"] = "models/mosi/fnv/props/gore/gorearm01.mdl",
    ["valvebiped.bip01_r_upperarm"] = "models/mosi/fnv/props/gore/gorearm01.mdl",
    ["ValveBiped.Bip01_L_Forearm"] = "models/mosi/fnv/props/gore/gorearm02.mdl",
	["ValveBiped.Bip01_R_Forearm"] = "models/mosi/fnv/props/gore/gorearm02.mdl",
	["valvebiped.bip01_l_thigh"] = "models/mosi/fnv/props/gore/goreleg03.mdl",
	["valvebiped.bip01_r_thigh"] = "models/mosi/fnv/props/gore/goreleg03.mdl",
	["ValveBiped.Bip01_R_Calf"] = "models/mosi/fnv/props/gore/goreleg02.mdl",
    ["ValveBiped.Bip01_L_Calf"] = "models/mosi/fnv/props/gore/goreleg02.mdl",
	["ValveBiped.Bip01_R_Foot"] = "models/mosi/fnv/props/gore/goreleg01.mdl",
	["ValveBiped.Bip01_L_Foot"] = "models/mosi/fnv/props/gore/goreleg01.mdl",
	["ValveBiped.Bip01_Spine4"] = "models/mosi/fnv/props/gore/goretorso03.mdl"
} 
hook.Add( "noob_gore_on_gib_destroid", "on gib destroid", function(ragdoll,bone_name,dmg_data)
    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
    if bone_name == "ValveBiped.Bip01_Head1" then
        gore_mod_make_gibs("models/mosi/fnv/props/gore/gorehead05.mdl",ragdoll:GetBonePosition(bone_id),dmg_data)  
        gore_mod_make_gibs("models/mosi/fnv/props/gore/gorehead06.mdl",ragdoll:GetBonePosition(bone_id),dmg_data)  
        gore_mod_make_gibs("models/mosi/fnv/props/gore/gorehead04.mdl",ragdoll:GetBonePosition(bone_id),dmg_data)  
        gore_mod_make_gibs("models/mosi/fnv/props/gore/gorehead03.mdl",ragdoll:GetBonePosition(bone_id),dmg_data)  
        gore_mod_make_gibs("models/mosi/fnv/props/gore/gorehead01.mdl",ragdoll:GetBonePosition(bone_id),dmg_data)  
    end
    if bone_name_togib[bone_name] then
        gore_mod_make_gibs(bone_name_togib[bone_name],ragdoll:GetBonePosition(bone_id),dmg_data)  
    end
end )

