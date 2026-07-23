/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
/*--------------------------------------
	-- Common Blood Types --
	Red 		= Color(130, 19, 10)
	Yellow 		= Color(255, 221, 35)

	-- Example --
	effectBlood:SetColor(VJ.Color2Byte(Color(130, 19, 10)))
--------------------------------------*/
local color_red = Color(185, 40, 27)
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Init(data)
	local origin = data:GetOrigin()
	local scale = data:GetScale()
	local ent data:GetEntity()

	local head_bone = ent:LookupBone( "ValveBiped.Bip01_Head1" )
	if head_bone == nil then return end
	
	local Position = ent:GetBonePosition(head_bone+math.random(-5,5),math.random(-5,5),math.random(-5,5))

	local Position_sigma = ent:GetBonePosition(head_bone)

	local emitter = ParticleEmitter(origin)
	
	-- Blood mist
	for _ = 0, 34 do
		local mist = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), Position_sigma)
		if mist then
			Particle:SetDieTime( 60 )

			Particle:SetStartAlpha( math.random( 200, 255 ) )
			Particle:SetColor( 255, 0, 0 )
			Particle:SetStartSize( math.random( 1, 2,5 ) )

			Particle:SetEndAlpha( 0 )
			Particle:SetEndSize( 1 )
			Particle:SetVelocityScale(true)
			Particle:SetLighting( true)

			Particle:SetGravity( Vector( 0, 0, -350 ) )
			Particle:SetVelocity(Vector( math.random(-40,40), math.random(-40,40), math.random(50,140) ))
			Particle:SetCollide( true )	
		end
	end
	emitter:Finish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() return false end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end -- Avoid "ERROR" from appearing for single a tick