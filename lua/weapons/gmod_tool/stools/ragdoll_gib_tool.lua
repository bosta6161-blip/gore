
-- IMPORTANT
-- =========
-- Set this to your file name without the ".lua" on the end
-- Sandbox tools use the filename for storing information and translations
local FileName = "bone_tool.lua"

TOOL.Name = "ragdoll gib tool"

TOOL.Category = "Poser"
if CLIENT then

	TOOL.Information = {

		{ name = "info"},
		{ name = "left" },
		{ name = "right" },
	}
	language.Add("tool.ragdoll_gib_tool.name", "Ragdoll gib tool")
	language.Add("tool.ragdoll_gib_tool.desc", "can break ragdoll joints")
	language.Add("tool.ragdoll_gib_tool.0", "click to dismenber ragdoll")
	language.Add( "tool.ragdoll_gib_tool.left", "destroy ragdoll limb" )
	language.Add( "tool.ragdoll_gib_tool.right", "slice ragdoll limb" )
end
if SERVER then

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	if ent:IsNPC() or ent:IsNextBot() then 
		ent:EmitSound('phx/hmetal'..math.random(1,3)..'.wav', 75, 100, 0.4) --make metal sound
		return
	end
	if IsValid(ent) and ent:IsRagdoll() then
		local dmg_data = {
			dmg_force = Vector(0,0,0),
			slice = false 
		}
		local hitposition = trace.HitPos --get HitPos from trace
		local hit = GetClosestPhysBone(ent,hitposition)
		local bone = ent:TranslatePhysBoneToBone(hit)
		local bone_name = ent:GetBoneName( bone ) 	
		dismember_limb(ent,bone_name,dmg_data)
		ent:EmitSound('garrysmod/save_load'..math.random(1,3)..'.wav', 75, 100, 0.4) --make funny sound
	end
end

function TOOL:RightClick(trace)
	local ent = trace.Entity
	if ent:IsNPC() or ent:IsNextBot() then 
		ent:EmitSound('phx/hmetal'..math.random(1,3)..'.wav', 75, 100, 0.4) --make metal sound
		return
	end
	if IsValid(ent) and ent:IsRagdoll() then
		local dmg_data = {
			dmg_force = Vector(0,0,0),
			slice = true  
		}
		local hitposition = trace.HitPos --get HitPos from trace
		local hit = GetClosestPhysBone(ent,hitposition)
		local bone = ent:TranslatePhysBoneToBone(hit)
		local bone_name = ent:GetBoneName( bone ) 	
		dismember_limb(ent,bone_name,dmg_data)
		ent:EmitSound('garrysmod/save_load'..math.random(1,3)..'.wav', 75, 100, 0.4) --make funny sound
	end
end

end

-- This controls the part of the UI which shows options for this tool
function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
		Text = "I don't know what to put here",
		Description = "I don't know what to put here"
	}) 
end
function destroy_ragdoll_joints( ply, ent, data )
	if ( CLIENT ) then return end
    for k, v in pairs(data) do --no more shit code
		ent:RemoveInternalConstraint(v)
    end
	duplicator.StoreEntityModifier( ent, "RemoveInternalConstraint", data )
end