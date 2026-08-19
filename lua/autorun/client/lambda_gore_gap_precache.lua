-- Lambda Gore client model precache.
-- Gap models are local addon assets, but explicitly precaching them avoids
-- first-use stalls when a limb is spawned for the first time.
local LambdaGoreGapModels = {
    "models/noob_dev2323/gib/l4d/common_infected_w_neck.mdl",
    "models/noob_dev2323/gib/l4d/half_bottom.mdl",
    "models/noob_dev2323/gib/common_infected_w_r_arm_shoulder.mdl",
    "models/noob_dev2323/gib/common_infected_w_l_arm_shoulder.mdl",
    "models/noob_dev2323/gib/r_leg_gap.mdl",
    "models/noob_dev2323/gib/l_leg_gap.mdl",
    "models/noob_dev2323/gib/l4d/gib.mdl",
    "models/noob_dev2323/gib/l_arm67.mdl",
    "models/noob_dev2323/gib/r_arm67.mdl",
    "models/noob_dev2323/gib/l4d/upper_leg_l.mdl",
    "models/noob_dev2323/gib/l4d/upper_legr.mdl",
    "models/noob_dev2323/gib/l4d/half2.mdl",
    "models/noob_dev2323/gib/l4d/headcap.mdl",

    -- Common detached gore models used by the generic gib table.
    "models/gore/head_headbitbackleft.mdl",
    "models/gore/head_headbitbackright.mdl",
    "models/gore/head_headbitfrontleft.mdl",
    "models/gore/head_headbitfrontright.mdl",
    "models/gore/head_headbittopleft.mdl",
    "models/gore/head_headbittopright.mdl",
    "models/gore/head_jawlo.mdl",
    "models/gore/uppertorso_upperrightbones.mdl",
    "models/gore/uppertorso_boneslowerleft.mdl",
    "models/gore/uppertorso_lowerrightribs.mdl",
    "models/gore/larm_armgoreupperl.mdl",
    "models/gore/rarm_armgoreupperr.mdl",
    "models/gore/rarm_armgorelowerr.mdl",
    "models/gore/larm_armgorehandl.mdl",
    "models/gore/rarm_armgorehandr.mdl",
    "models/gore/lleg_legpartmidl.mdl",
    "models/gore/rleg_legpartmidr.mdl",
    -- Requested Vortigaunt gore model.
    "models/noob_dev2323/gib/l4d/vortigount.mdl",
}

hook.Add("InitPostEntity", "LambdaGore_PrecacheGapModels", function()
    if GetConVar("goremod_client_gap_models") and not GetConVar("goremod_client_gap_models"):GetBool() then
        return
    end

    for _, model in ipairs(LambdaGoreGapModels) do
        util.PrecacheModel(model)
    end
end)
