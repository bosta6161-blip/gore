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

	local emitter = ParticleEmitter(origin)
	
	-- Blood mist
	for _ = 0, 8 do
		local mist = emitter:Add("particle/smokesprites_0009" .. math.random(1, 9), origin)
		if mist then
			mist:SetVelocity(Vector(math.random(-20, 20), math.random(-20, 20), math.random(-30, 30)))
			mist:SetDieTime(math.Rand(2.2, 2.4))
			mist:SetStartAlpha(150)
			mist:SetEndAlpha(0)
			mist:SetStartSize(scale / 2)
			mist:SetEndSize(scale)
			mist:SetRoll(1)
			mist:SetRollDelta(0)
			mist:SetAirResistance(1)
			mist:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(10, -10)))
			mist:SetColor(color_red)
			mist:SetCollide(true)
		end
	end
	emitter:Finish()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Think() return false end
---------------------------------------------------------------------------------------------------------------------------------------------
function EFFECT:Render() end -- Avoid "ERROR" from appearing for single a tick