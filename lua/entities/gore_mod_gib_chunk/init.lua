AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()		
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS ) 
    self:SetUseType( SIMPLE_USE )

    local phys = self:GetPhysicsObject()

    if not IsValid(phys) then return end
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.gib_Health = 40
	self.damage_Start_delay = CurTime() + 1
	self.fucked = false  

    table.insert(goremod_gib_count, self)
end
function ENT:Use(ply)
    if not IsValid(ply) then return end
	local Position = ply:GetEyeTrace()
	if GetConVar("goremod_cannibalism"):GetBool() then
		local health = ply:Health()
		ply:SetHealth( health + 5 )
		local bloodspray = EffectData()
		bloodspray:SetOrigin(Position.HitPos)
		bloodspray:SetScale(8)
		bloodspray:SetFlags(3)
		bloodspray:SetColor(0)
		util.Effect("BloodImpact",bloodspray)
		self:EmitSound('noob_dev2323/bsmod/eat'..math.random(1,4)..'.wav', 75, 100, 0.4)
		self:Remove()
	end
end
function ENT:Think()
    local limit = math.max(0, GetConVar("goremod_gib_limit"):GetInt())
    while #goremod_gib_count > limit do
        local oldest = table.remove(goremod_gib_count, 1)
        if IsValid(oldest) then
            oldest:Remove()
        end
    end

    if self.gore_fade_scheduled then
        return
    end

    local fade = GetConVar("goremod_gib_fade_time"):GetFloat()
    if fade < 998 and fade >= 0 then
        self.gore_fade_scheduled = true
        timer.Simple(fade, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    else
        self.gore_fade_scheduled = true
    end
end

function ENT:OnRemove()
    for i = #goremod_gib_count, 1, -1 do
        if goremod_gib_count[i] == self then
            table.remove(goremod_gib_count, i)
            break
        end
    end
end
function ENT:PhysicsCollide(data, physobj)
	if math.random(1, 8) == 1 then
		sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1,4) .. ".wav", self:GetPos(), 75, 100, 1)
		if	not (self:GetModel() == "models/props_junk/watermelon01_chunk02a.mdl") or (self:GetModel() == "models/mosi/fnv/props/gore/gorehead01.mdl") then
			local blood = "Blood"
			if self.bloodColor_is_YELLOW then
				blood = "YellowBlood"
    		end
			util.Decal(blood, self:GetPos(), self:GetPos() - Vector(math.random(-16,16), math.random(-16,16), 9999))
		end
	end
	if data.Speed > 30 and data.DeltaTime > 0.1 then
		if self.bloodColor_is_YELLOW then
			ParticleEffect("blood_impact_antlion_worker_01", self:GetPos(), self:GetAngles(), self)
		else
			ParticleEffect("blood_impact_red_01_goop", self:GetPos(), self:GetAngles(), self)
    	end
	end
end
function ENT:OnTakeDamage( dmginfo )
	if CurTime() > self.damage_Start_delay then
		local dmg_pos = dmginfo:GetDamagePosition()
		ParticleEffect("blood_impact_red_01_goop", dmg_pos, self:GetAngles(), self)
		self.gib_Health = self.gib_Health - dmginfo:GetDamage()
		if self.gib_Health <= 0 and self.fucked == false   then
			self.fucked = true 
			if not (self:GetModel() == "models/props_junk/watermelon01_chunk02a.mdl") then
				local bloodspray = EffectData()
				bloodspray:SetOrigin(self:GetPos())
				bloodspray:SetScale(8)
				bloodspray:SetFlags(3)
				bloodspray:SetColor(0)
				util.Effect("BloodImpact",bloodspray)
				local dmg_data = {
					dmg_force = dmginfo:GetDamageForce()
				}
				gore_mod_make_gibs("models/props_junk/watermelon01_chunk02a.mdl",self:GetPos(),dmg_data,true) 
			end
			self:Remove() 
		end
	end

end