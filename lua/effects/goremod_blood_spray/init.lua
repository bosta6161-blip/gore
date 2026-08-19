-- These are kinda ugly, you probably want to change them:
local particles = {
    "decals/goremod_trail",
}

-- Use these, but shaderless i guess, or maybe use more of a "stain" rather than a "splat":
local decals = {
    "decals/Blood1",
    "decals/Blood3",
    "decals/Blood4",
    "decals/Blood5",
    "decals/Blood6",
    "decals/Blood2",
    "decals/Blood3",
}

-- Particle:
local particle_length_random = {min=100,max=100}
local particle_start_lengt_mult = 0.1
local particle_scale = 0.4

local particle_gravity = 1050
local particle_force = 200
local particle_pulsate_max_force = 100
local particle_pulsate_speed_mult = 8

local particle_reps_stream = 180
local particle_reps_burst = 150

local particle_fps = 60
local particle_lifetime = 5

local stream_particle_lifetime = 5
local burst_particle_lifetime = 5

-- Decal:
local decal_scale = 0.2

-- Sound:
local drip_sounds = {
    "bloodsplashing/drip_1.wav",
    "bloodsplashing/drip_2.wav",
    "bloodsplashing/drip_3.wav",
    "bloodsplashing/drip_4.wav",
    "bloodsplashing/drip_5.wav",    
    "bloodsplashing/drips_1.wav",
    "bloodsplashing/drips_2.wav",
    "bloodsplashing/drips_3.wav",
    "bloodsplashing/drips_4.wav",
    "bloodsplashing/drips_5.wav",
    "bloodsplashing/drips_6.wav",
    "bloodsplashing/spatter_grass_1.wav",
    "bloodsplashing/spatter_grass_2.wav",
    "bloodsplashing/spatter_grass_3.wav",
    "bloodsplashing/spatter_hard_1.wav",
    "bloodsplashing/spatter_hard_2.wav",
    "bloodsplashing/spatter_hard_3.wav",
    "bloodsplashing/drip_lowpass_1.wav",
    "bloodsplashing/drip_lowpass_2.wav",
    "bloodsplashing/drip_lowpass_3.wav",
    "bloodsplashing/drip_lowpass_4.wav",
    "bloodsplashing/drip_lowpass_5.wav",
}

local sound_level = 70

local squrt_sounds = {
    "squirting/artery_squirt_1.wav",
    "squirting/artery_squirt_2.wav",
    "squirting/artery_squirt_3.wav",
    "squirting/artery_squirt_3.wav",
    "squirting/artery_squirt_2.wav",
    "squirting/artery_squirt_1.wav",
    "squirting/artery_squirt_2.wav",
    "squirting/artery_squirt_2.wav",
    "squirting/artery_squirt_3.wav",
    "squirting/artery_squirt_1.wav",
    "squirting/artery_squirt_3.wav",
    "squirting/artery_squirt_2.wav",
}
local sound_level2 = 35

-- Impact:
local impact_chance = 1 -- 1 in x

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Function to get limb multiplier (CLIENT-SIDE)
local function GetLimbMultiplier(boneName)
    if CLIENT and GetLimbMultiplierForBone then
        return GetLimbMultiplierForBone(boneName)
    end
    return 1
end

local function make_materials(tbl)
    local materials = {}

    for _,v in ipairs(tbl) do
        local imat = Material(v)
        table.insert(materials, imat)
    end
    
    return materials
end

local function SpawnCollisionParticle(pos,shitColor)
    if math.random(1,4) == 1 then return end
    local emitter = ParticleEmitter(pos)

    if not emitter then return end

    local mist = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos)
    if mist then
        mist:SetVelocity(Vector(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)))
        mist:SetDieTime(math.Rand(2.2, 2.4))
        mist:SetStartAlpha(255)
        mist:SetEndAlpha(0)
        mist:SetStartSize(10 / 2)
        mist:SetEndSize(10)
        mist:SetRoll(1)
        mist:SetRollDelta(0)
        mist:SetAirResistance(1)
        mist:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(10, -10)))
        mist:SetColor(shitColor)
        mist:SetCollide(true)
    end
    emitter:Finish()
end
                    
local blood_water_color = Color(255, 23, 2)

local min_strenght = 0.25

function EFFECT:Init(data)
    local ent = data:GetEntity()
    
    if not IsValid(ent) then return end

    local flags = data:GetFlags()
    
    if flags == 1 then --it's just works :)
        local particles = {
            "decals/goremod_trail_yellow",
        }
        local decals = {
            "decals/yblood1",
            "decals/yblood2",
            "decals/yblood3",
            "decals/yblood4",
            "decals/yblood5",
            "decals/yblood6",
        }
        blood_water_color = Color(255, 255,0)
        decal_mats = make_materials(decals)
        particle_mats = make_materials(particles)
    else
                decal_mats = make_materials(decals)
        particle_mats = make_materials(particles)
    end

    -- Apply reps multiplier to particle count
    local reps_multiplier = math.max(0, GetConVar("goremod_blood_stream_reps_multiplier"):GetFloat())
    self.reps = math.Clamp(math.floor((particle_reps_stream or 0) * reps_multiplier), 1, 180)

    -- Get customizable values as LOCAL variables so they're captured in timer closure
    local size_mult = GetConVar("goremod_stream_size"):GetFloat()
    local force_mult = GetConVar("goremod_stream_force"):GetFloat()
    local spread_angle = GetConVar("goremod_stream_spread"):GetFloat()
    local density = math.max(0.1, GetConVar("goremod_stream_density"):GetFloat())
    
    -- NEW: Get bone name for limb multiplier
    local boneName = ""
    if IsValid(ent) and ent.bloodstream_lastdmgbone then
        boneName = ent:GetBoneName(ent.bloodstream_lastdmgbone)
    end
    local limb_mult = GetLimbMultiplier(boneName)
    
    -- Apply limb multiplier ONLY to force and density (frequency)
    force_mult = force_mult * limb_mult
    density = density / limb_mult -- Divide density so higher multiplier = more frequent spurts
    
    -- Density now controls how often spurts happen (lower = more frequent)
    -- Convert density to delay: density 1 = normal, density 0.1 = very frequent, density 5 = very slow
    local spurt_delay = math.Rand(0.75, 2.5) / math.max(1, particle_fps * density)

    self.StartTime = CurTime()
    self.CurrentPos = ent:GetPos()
    self.CurrentStrenght = 1
    self:UpdateExtraForce()

    -- Create unique timer name to prevent conflicts in multiplayer
    self.timername = "NextGen4BloodStreamTimer_" .. ent:EntIndex() .. "_" .. CurTime()
    local emitter = ParticleEmitter(self.CurrentPos, false)

    if not emitter or self.reps <= 0 then
        if emitter then emitter:Finish() end
        return
    end

    -- Play squirt sound
    sound.Play(table.Random(squrt_sounds), ent:GetPos(), sound_level2, math.Rand(95, 105), GetConVar("goremod_squirt_sound_volume"):GetFloat())

    -- Store self reference for timer callback
    local effect_self = self
    local reps = self.reps
    local sound_every = math.max(1, math.floor(reps / 12))
    local rep_index = 0

    timer.Create(self.timername, spurt_delay, reps, function()
        if not IsValid(ent) or not emitter then
            if emitter then emitter:Finish() end
            timer.Remove(effect_self.timername)
            return
        end
        rep_index = rep_index + 1
        if rep_index == 1 or rep_index % sound_every == 0 then
            sound.Play(table.Random(squrt_sounds), ent:GetPos(), sound_level2, math.Rand(95, 105), GetConVar("goremod_squirt_sound_volume"):GetFloat())
        end

        ent.CurrentPos = ent:GetPos()

        local length = math.Rand(particle_length_random.min, particle_length_random.max)

        local particle = emitter:Add(table.Random(particle_mats), ent.CurrentPos)
            
            -- Use default particle lifetime
            particle:SetDieTime(particle_lifetime * effect_self.CurrentStrenght)
            
            -- Apply size multiplier to particle size (NO limb multiplier)
            particle:SetStartSize(math.Rand(1.9, 3.8) * particle_scale * size_mult)
            particle:SetEndSize(0)
            particle:SetStartLength(length * particle_scale * particle_start_lengt_mult * size_mult)
            particle:SetEndLength(length * particle_scale * size_mult)
            
            particle:SetGravity(Vector(0, 0, -particle_gravity))
            
            -- Calculate base velocity with force multiplier (includes limb_mult)
            local base_velocity = ent:GetForward() * -(particle_force + effect_self.ExtraForce) * effect_self.CurrentStrenght * force_mult
            
            -- Add spread/FOV to velocity
            if spread_angle > 0 then
                local spread_rad = math.rad(spread_angle)
                local random_pitch = math.Rand(-spread_rad, spread_rad)
                local random_yaw = math.Rand(-spread_rad, spread_rad)
                
                -- Create spread direction
                local forward = ent:GetForward()
                local right = ent:GetRight()
                local up = ent:GetUp()
                
                -- Apply random angles for spread
                local spread_dir = forward + (right * math.sin(random_yaw)) + (up * math.sin(random_pitch))
                spread_dir:Normalize()
                
                -- Apply spread direction to velocity
                local velocity_magnitude = base_velocity:Length()
                base_velocity = spread_dir * -velocity_magnitude
            end
            
            particle:SetVelocity(base_velocity)
            
            particle:SetCollide(true)
            particle:SetCollideCallback(function(_, pos, normal,hitnormal)
                if bit.band(util.PointContents(pos),CONTENTS_WATER) == CONTENTS_WATER and GetConVar("goremod_blood_do_decal"):GetBool() then
                    SpawnCollisionParticle(particle:GetPos(),blood_water_color)
                    particle:SetDieTime(0)
                elseif math.random(1, impact_chance) == 1 and (effect_self.CurrentStrenght or min_strenght) > 0.2 and GetConVar("goremod_blood_do_decal"):GetBool() == true then
                    -- Play blood drip sound
                    sound.Play(table.Random(drip_sounds), pos, sound_level, math.Rand(95, 105), GetConVar("goremod_blood_sound_volume"):GetFloat())
                    
                    -- Apply size multiplier to decal size (NO limb multiplier)
                    local decal_size = decal_scale * size_mult
                    util.DecalEx(table.Random(decal_mats), Entity(0), pos, normal, Color(255, 255, 255), decal_size, decal_size)
                end
            end)

        if timer.RepsLeft(effect_self.timername) == 0 then emitter:Finish() end
    end)
end

function EFFECT:UpdateExtraForce()
    self.ExtraForce = particle_pulsate_max_force * (1 + math.sin(CurTime() * particle_pulsate_speed_mult))
end

function EFFECT:Think()
	if not self.timername then return false end

    if timer.Exists(self.timername) then
        local lifetime = CurTime() - self.StartTime
        local dietime = math.max(0.05, self.reps * (1 / particle_fps))
        self.CurrentStrenght = math.Clamp(1 - (lifetime / dietime) * (1 - min_strenght), 0, 1)

        self:UpdateExtraForce()
        return true
    else
        return false
    end
end

function EFFECT:Render() end

