bone_name_togap = {
    ["ValveBiped.Bip01_L_Hand"] = "models/noob_dev2323/gib/l_arm.mdl",
    ["ValveBiped.Bip01_R_Hand"] = "models/noob_dev2323/gib/r_arm.mdl",
    ["ValveBiped.Bip01_L_Forearm"] = "models/noob_dev2323/gib/upperarm_l.mdl",
	["ValveBiped.Bip01_R_Forearm"] = "models/noob_dev2323/gib/upperarm_r.mdl",
	["ValveBiped.Bip01_R_Calf"] = "models/noob_dev2323/gib/r_leg_gap.mdl",
    ["ValveBiped.Bip01_L_Calf"] = "models/noob_dev2323/gib/l_leg_gap.mdl",
	["ValveBiped.Bip01_R_Foot"] = "models/noob_dev2323/gib/r_foot.mdl",
	["ValveBiped.Bip01_L_Foot"] = "models/noob_dev2323/gib/l_foot.mdl",
	["ValveBiped.Bip01_Head1"] = "models/noob_dev2323/gib/l4d/head_gore2.mdl",
	["ValveBiped.Bip01_Spine2"] = "models/noob_dev2323/gib/l4d/half1.mdl",
	["ValveBiped.head"] = "models/noob_dev2323/gib/l4d/vortigount.mdl"
} 

goremod_CustomGibs = {
    ["ValveBiped.Bip01_Head1"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorehead05.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorehead06.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorehead04.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorehead03.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorehead01.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_Spine2"] = {
        -- Chest spawns ribs and a spine peice:
        gibs = {
            {
                model = "models/Gibs/HGIBS_spine.mdl",
                scale = 1.25,
            },
            {
                model = "models/Gibs/HGIBS_rib.mdl",
                random_angle = true,
                random_pos = true,
                scale = {0.5, 0.67},
                count = {2, 4},
            },
        },
    },
    ["valvebiped.bip01_l_upperarm"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorearm01.mdl",
            },
        },
    },
    ["valvebiped.bip01_r_upperarm"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorearm01.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Forearm"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorearm02.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorearm01.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Forearm"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/gorearm02.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/gorearm01.mdl",
            },
        },
    },
    ["valvebiped.bip01_l_thigh"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg03.mdl",
            },
        },
    },
    ["valvebiped.bip01_r_thigh"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg03.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Calf"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg02.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Calf"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg02.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Foot"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg01.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Foot"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/goreleg01.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_Pelvis"] = {
        gibs = {
            {
                model = "models/gore/pelvis.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_Spine2"] = {
        gibs = {
            {
                model = "models/gore/uppertorso.mdl",
            },
        },
    },
}
bone_name_togaplimb = {
    ["ValveBiped.Bip01_Spine2"] = "models/noob_dev2323/gib/l4d/half2.mdl",
	["ValveBiped.Bip01_Head1"] = "models/noob_dev2323/gib/l4d/headcap.mdl"
} 
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
        if !goremod_CustomGibs[bone_name] then return {}, 1 end
        return goremod_CustomGibs[bone_name].gibs or 1
    end
    local custom_gibs = get_custom_gibs(bone_name)
    for _,v in ipairs(custom_gibs) do
        for i = 1, ( v.count && ( istable(v.count) && math.random(v.count[1], v.count[2]) ) or v.count ) or 1 do
            gore_mod_make_gibs(v.model,ragdoll:GetBonePosition(bone_id),dmg_data)  
        end
    end
end )
