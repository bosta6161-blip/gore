bone_name_togap = {
    ["ValveBiped.Bip01_Head1"] = {
        model = "models/noob_dev2323/gib/l4d/common_infected_w_neck.mdl",
        localAng = Angle(180,110,90),
        offset = Vector(-0.812,-2.608,0),
        capScale = Vector(1, 1, 1),
        fem_offset = Vector(-2.912,-2.608,0) 
    },
    ["ValveBiped.Bip01_Spine2"] = {
        model = "models/noob_dev2323/gib/l4d/half_bottom.mdl",
        localAng = Angle(0, 90, 90),
        offset = Vector(-2,2,0),
        capScale = Vector(1.1, 1.1, 1.1) 
    },
    ["ValveBiped.Bip01_R_UpperArm"] = {
        bonemerge = true,
        model = "models/noob_dev2323/gib/common_infected_w_r_arm_shoulder.mdl"
    },
    ["ValveBiped.Bip01_L_UpperArm"] = {
        bonemerge = true,
        model = "models/noob_dev2323/gib/common_infected_w_l_arm_shoulder.mdl",
    },
    ["ValveBiped.Bip01_R_Calf"] = {
        model = "models/noob_dev2323/gib/l4d/leg.mdl",
        localAng = Angle(-90,0,0),
        offset = Vector(12.127,2.926,0.554),
        capScale = Vector(1, 1, 1),
    },
    ["ValveBiped.Bip01_L_Calf"] = {
        model = "models/noob_dev2323/gib/l4d/leg.mdl",
        localAng = Angle(-90,-12.281,0),
        offset = Vector(14.854,2.772,-0.734),
        capScale = Vector(0.919, 1, 1),
        fem_offset = Vector(12.176,2.772,-0.734) 
    },
    ["ValveBiped.Bip01_L_Foot"] = {
        model = "models/noob_dev2323/gib/l4d/gib.mdl",
        localAng = Angle(-83.277,0,0),
        offset = Vector(13.290,0,-0.549),
        capScale = Vector(0.478,0.478,0.478),
    },
    ["ValveBiped.Bip01_R_Foot"] = {
        model = "models/noob_dev2323/gib/l4d/gib.mdl",
        localAng = Angle(-96.600,0,0),
        offset = Vector(13.447,0,-0.009),
        capScale = Vector(0.478,0.478,0.478),
    },
    ["ValveBiped.Bip01_L_Forearm"] = {
        bonemerge = true,
        model = "models/noob_dev2323/gib/l4d/common_infected_w_arm.mdl",
    },
    ["ValveBiped.Bip01_R_Forearm"] = {
        bonemerge = true,
        model = "models/noob_dev2323/gib/r_arm.mdl",
    }, 
    ["ValveBiped.Bip01_R_Hand"] = {
        model = "models/noob_dev2323/gib/l4d/gib.mdl",
        localAng = Angle(-90,0,0),
        offset = Vector(8.319,0,0.530),
        capScale = Vector(0.366,0.366,0.258),
    },
    ["ValveBiped.Bip01_L_Hand"] = {
        model = "models/noob_dev2323/gib/l4d/gib.mdl",
        localAng = Angle(-90,0,0),
        offset = Vector(8.319,0,-0.530),
        capScale = Vector(0.366,0.366,0.258),
    },
    ["ValveBiped.Bip01_L_Thigh"] = {
        model = "models/noob_dev2323/gib/l4d/upper_leg_l.mdl",
        localAng = Angle(-52.21,13.08,-103.5),
        offset = Vector(3.4,-0.98,-1.01),
        capScale = Vector(1, 1, 1),
    },
    ["ValveBiped.Bip01_R_Thigh"] = {
        model = "models/noob_dev2323/gib/l4d/upper_leg_l.mdl",
        localAng = Angle(-133.26,13.4,14.42),
        offset = Vector(3.01,-1.94,-2.88),
        capScale = Vector(1, 1, 1),
    },
}
goremod_CustomGibs = {
    ["ValveBiped.Bip01_Head1"] = {
        gibs = {
            {
                model = "models/gore/head_headbitbackleft.mdl",
            },
            {
                model = "models/gore/head_headbitbackright.mdl",
            },
            {
                model = "models/gore/head_headbitfrontleft.mdl",
            },
            {
                model = "models/gore/head_headbitfrontright.mdl",
            },
            {
                model = "models/gore/head_headbittopleft.mdl",
            },
            {
                model = "models/gore/head_headbittopright.mdl",
            },
            {
                model = "models/gore/head_jawlo.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_Spine2"] = {
        gibs = {
            {
                model = "models/gore/uppertorso_upperrightbones.mdl",
            },
            {
                model = "models/gore/uppertorso_boneslowerleft.mdl",
            },
            {
                model = "models/gore/uppertorso_lowerrightribs.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_UpperArm"] = {
        gibs = {
            {
                model = "models/gore/larm_armgoreupperl.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_UpperArm"] = {
        gibs = {
            {
                model = "models/gore/rarm_armgoreupperr.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Forearm"] = {
        gibs = {
            {
                model = "models/gore/rarm_armgorelowerr.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Forearm"] = {
        gibs = {
            {
                model = "models/gore/rarm_armgorelowerr.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Hand"] = {
        gibs = {
            {
                model = "models/gore/rarm_armgorehandr.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Hand"] = {
        gibs = {
            {
                model = "models/gore/larm_armgorehandl.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Thigh"] = {
        gibs = {
            {
                model = "models/gore/lleg_meatbit001l.mdl",
            },
            {
                model = "models/gore/lleg_meatbit002l.mdl",
            },
            {
                model = "models/gore/lleg_meatbit003l.mdl",
            },
            {
                model = "models/gore/lleg_meatbit004l.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Thigh"] = {
        gibs = {
            {
                model = "models/gore/rleg_meatbit001r.mdl",
            },
            {
                model = "models/gore/rleg_meatbit002r.mdl",
            },
            {
                model = "models/gore/rleg_meatbit004r.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Calf"] = {
        gibs = {
            {
                model = "models/gore/rleg_legpartmidr.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Calf"] = {
        gibs = {
            {
                model = "models/gore/lleg_legpartmidl.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_R_Foot"] = {
        gibs = {
            {
                model = "models/gore/rleg_legpartfootr001.mdl",
            },
        },
    },
    ["ValveBiped.Bip01_L_Foot"] = {
        gibs = {
            {
                model = "models/gore/lleg_legpartfootl001.mdl",
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
    ["ValveBiped.head"] = {
        gibs = {
            {
                model = "models/mosi/fnv/props/gore/insectbit01.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/insectbit02.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/insectbit03.mdl",
            },
            {
                model = "models/mosi/fnv/props/gore/insectbit06.mdl",
            },
        },
    },
}
bone_name_togaplimb = {
    ["ValveBiped.Bip01_Spine2"] = "models/noob_dev2323/gib/l4d/half2.mdl",
	["ValveBiped.Bip01_Head1"] = "models/noob_dev2323/gib/l4d/headcap.mdl"
} 
BasicGib_Models = { 
    "models/mosi/fnv/props/gore/insectbit01.mdl", 
    "models/mosi/fnv/props/gore/insectbit02.mdl",
    "models/mosi/fnv/props/gore/insectbit03.mdl",
    "models/mosi/fnv/props/gore/insectbit04.mdl", 
    "models/mosi/fnv/props/gore/insectbit06.mdl", 
    "models/mosi/fnv/props/gore/insectbit07.mdl"
}
goremod_model_gap_blacklist = {
    ["models/stalker.mdl"] = true,  
    ["models/player/vengeance/skeleton_with_hands/skeleton_with_hands.mdl"] = true,  
    ["models/akuld/hl1dmskel/dm_skel.mdl"] = true,  
    ["models/combine_strider.mdl"] = true,  
    ["models/humans/infoplayerstart.mdl"] = true,  
    ["models/player/infoplayerstart.mdl"] = true,  
    ["models/player/skeleton.mdl"] = true,  
    ["models/player/zombie_fast.mdl"] = true,  
    ["models/ratdock/squidwod_tennicles.mdl"] = true,  
    ["models/zombie/fast.mdl"] = true,  
    ["models/player/quinton_olson.mdl"] = true,  
    ["models/player/charple.mdl"] = true,  
    ["models/skeleton/skeleton_bleached.mdl"] = true,  
    ["models/skeleton/skeleton_bloody.mdl"] = true,  
    ["models/skeleton/skeleton_decomp.mdl"] = true,  
    ["models/vj_nullbody_npc.mdl"] = true,  
}