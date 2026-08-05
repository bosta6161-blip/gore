--main options
CreateConVar("goremod_enable", "1", FCVAR_ARCHIVE, "goremod_enable")
CreateConVar("goremod_can_gib_only_npc_corpse", "1", FCVAR_ARCHIVE, "goremod_can_gib_only_npc_corpse")
CreateConVar("goremod_can_gib_ragdoll", "1", FCVAR_ARCHIVE, "goremod_can_gib_ragdoll")
CreateConVar("goremod_can_npc_explode", "1", FCVAR_ARCHIVE, "goremod_can_npc_explode")

--_multipliers
CreateConVar("goremod_limb_health_multiplier", "1", FCVAR_ARCHIVE, "goremod_limb_health_multiplier")
CreateConVar("goremod_root_bone_health_multiplier", "1", FCVAR_ARCHIVE, "goremod_root_bone_health_multiplier")


CreateConVar("goremod_DMG_CRUSH_slice_ragdoll", "1", FCVAR_ARCHIVE, "goremod_DMG_CRUSH_slice_ragdoll")
CreateConVar("goremod_Disable_ragdoll_colision", "1", FCVAR_ARCHIVE, "goremod_Disable_ragdoll_colision")
CreateConVar("goremod_gib_fade_time", "67", FCVAR_ARCHIVE, "goremod_gib_fade_time") 
CreateConVar("goremod_sliced_ragdoll_fade_time", "30", FCVAR_ARCHIVE, "goremod_sliced_ragdoll_fade_time")
CreateConVar("goremod_ragdoll_has_gap_models", "1", FCVAR_ARCHIVE, "goremod_ragdoll_has_gap_models") 

CreateConVar("goremod_sliced_ragdoll_limit", "25", FCVAR_ARCHIVE, "goremod_sliced_ragdoll_limit")
CreateConVar("goremod_gib_limit", "500", FCVAR_ARCHIVE, "goremod_gib_limit")

CreateConVar("goremod_blood", "1", FCVAR_ARCHIVE, "goremod_blood")

CreateConVar("goremod_cannibalism", "1", FCVAR_ARCHIVE, "goremod_cannibalism")
CreateConVar("goremod_debug", "0", FCVAR_ARCHIVE, "goremod_debug")
CreateConVar("goremod_live_dismenber_EXPEREMENTAL", "0", FCVAR_ARCHIVE, "goremod_live_dismenber_EXPEREMENTAL")
CreateConVar("goremod_burned_corpse_effect_EXPEREMENTAL", "0", FCVAR_ARCHIVE, "goremod_burned_corpse_effect_EXPEREMENTAL")
CreateConVar("goremod_dissolve_efect_EXPEREMENTAL", "0", FCVAR_ARCHIVE, "goremod_dissolve_efect_EXPEREMENTAL")
CreateConVar("goremod_acid_efect_EXPEREMENTAL", "0", FCVAR_ARCHIVE, "goremod_acid_efect_EXPEREMENTAL")
CreateConVar("goremod_sawblade_slice_EXPEREMENTAL", "0", FCVAR_ARCHIVE, "goremod_sawblade_slice_EXPEREMENTAL")


-- Core ConVars (Server-side, replicated to clients)
CreateConVar("goremod_blood_stream_reps_multiplier", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Multiplier for blood stream particle count (duration)")
CreateConVar("goremod_blood_sound_volume", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Blood sound volume")
CreateConVar("goremod_squirt_sound_volume", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Squirt sound volume")
CreateConVar("goremod_blood_do_decal", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Blood_do_decal")

-- NEW ConVars for customization (Server-side, replicated to clients)
CreateConVar("goremod_stream_size", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Size multiplier for blood streams (0.5 = half, 2 = double)")
CreateConVar("goremod_stream_force", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Force multiplier for blood streams (supports decimals like 0.5, 1.5, 2.3)")
CreateConVar("goremod_stream_spread", "5", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Spread/FOV angle for blood streams in degrees (0 = straight line, 15 = wide spray)")
CreateConVar("goremod_stream_density", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Frequency of blood spurts (0.1 = very frequent, 5 = slow/rare)")
