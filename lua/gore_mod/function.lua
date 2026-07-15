util.AddNetworkString( "noob_gore_sigma_matrix" )
util.AddNetworkString( "noob_gore_benemerge" )
gore_mod_slice_damege = {
	1,
	4,
	1024
}
function GetClosestPhysBone(ragdoll,pos)
	local closest_distance = -1
	local closest_bone = -1

	if !ragdoll.gib_bone then
		ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll)
	end
	for i=0, ragdoll:GetPhysicsObjectCount()-1 do
		local bone = ragdoll:TranslatePhysBoneToBone(i)
		
		if bone and ragdoll.gib_bone[i] ~= i then 
			local phys = ragdoll:GetPhysicsObjectNum(i)
			
			if IsValid(phys) and pos then
				local distance = phys:GetPos():Distance(pos)
				
				if (distance < closest_distance || closest_distance == -1) then
					closest_distance = distance
					closest_bone = i
				end
			end
		end
	end
	return closest_bone
end
function colideBone(ragdoll,phys_bone)
	local colide = ragdoll:GetPhysicsObjectNum( phys_bone ) --get bone id
	colide:EnableCollisions(false)
	colide:SetMass(0)
	colide:EnableDrag(false )
	colide:SetMaterial("gmod_silent")
	colide:Sleep()
	colide:EnableMotion(false)
	colide:SetBuoyancyRatio(0)
	colide:AddGameFlag(1024) 
	colide:EnableGravity(false)
end
function gib_PhysBone(ragdoll,bone_name,dmg_data)
    if ragdoll:LookupBone(bone_name) == nil or ragdoll:LookupBone(bone_name) == 0 then return end
    if !ragdoll.gib_bone then ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll) end

    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name

	ragdoll:ManipulateBoneScale(bone_id,Vector(0,0,0)) --scale the bone
    local PhysBone = ragdoll:TranslateBoneToPhysBone(bone_id)
    local ObjectNum = ragdoll:GetPhysicsObjectNum(PhysBone)
			
	if dmg_data.slice == false and ragdoll.gib_bone[PhysBone] ~= PhysBone then
		hook.Call( "noob_gore_on_gib_destroid", nil,ragdoll,bone_name,dmg_data) --call this hook to make gibs based on bone name
	end
    if ObjectNum:IsValid() and ragdoll.gib_bone[PhysBone] ~= PhysBone then --check if the object is valid
        ragdoll:RemoveInternalConstraint(PhysBone)
        ragdoll.gib_bone[PhysBone] = PhysBone
		--print(PhysBone.."is gib")
        colideBone(ragdoll,PhysBone)
    end
    local children = ragdoll:GetChildBones(bone_id)
    for k, v in pairs(children) do --no more shit code
		local bone_children_name = ragdoll:GetBoneName( v )
        gib_PhysBone(ragdoll,bone_children_name,dmg_data)
    end
end
function noob_gore_TransferBones( ragdoll1, ragdoll2 ) -- Transfers the bones of one entity to a ragdoll's physics bones (modified version of some of RobotBoy655's code)
	if !IsValid( ragdoll1 ) or !IsValid( ragdoll2 ) then return end
	for i = 0, ragdoll2:GetPhysicsObjectCount() - 1 do
		local bone = ragdoll2:GetPhysicsObjectNum( i )
		if ( IsValid( bone ) ) then
			local pos, ang = ragdoll1:GetBonePosition( ragdoll2:TranslatePhysBoneToBone( i ) )
			if ( pos ) then bone:SetPos( pos,true ) end
			if ( ang ) then bone:SetAngles( ang ) end
		end
	end
end

function gore_mod_make_gibs(model,position,dmg_data,meat)
	local gib = ents.Create( "gore_mod_gib_chunk" )
	gib:SetModel(model)
	gib:SetPos(position)
	gib:SetAngles(Angle(math.Rand(-180, 180), math.Rand(-180, 180), math.Rand(-180, 180))) 

	gib:Spawn()	
    local phys = gib:GetPhysicsObject()

    if IsValid(phys) then 
		phys:AddVelocity(Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(150, 250)) + (dmg_data.dmg_force / 18))
		phys:AddAngleVelocity(Vector(math.Rand(-200, 200), math.Rand(-200, 200), math.Rand(-200, 200)))
	end   
	if meat == true then gib:SetMaterial( "models/flesh" ) end
	
end 

function decap_ragdoll(ragdoll,bone_name,dmg_data)
    if ragdoll:LookupBone(bone_name) == nil or ragdoll:LookupBone(bone_name) == 0 then return end
    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name

	local ragdollGIB = ents.Create("prop_ragdoll")
    if IsValid(ragdollGIB) and IsValid(ragdoll) then
    	ragdollGIB:SetModel(ragdoll:GetModel())
    	ragdollGIB:SetPos(ragdoll:GetPos()) 
        ragdollGIB:SetSkin( ragdoll:GetSkin() )
    	ragdollGIB:Spawn()
		ragdollGIB:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		for i = 1, #ragdoll:GetBodyGroups() do
			ragdollGIB:SetBodygroup(i, ragdoll:GetBodygroup(i))
		end

		slice_gib(ragdollGIB,bone_name)
		sigma_scale(ragdollGIB)
		noob_gore_TransferBones( ragdoll, ragdollGIB )
		ragdollGIB:SetNoDraw(true )
		ragdollGIB:DrawShadow(false )
		timer.Simple(0, function()
		net.Start( "noob_gore_benemerge" )
			net.WriteEntity(ragdoll) --the original ragdoll
			net.WriteInt(bone_id, 8 ) --bone to get cut
			net.WriteEntity(ragdollGIB)--the ragdoll limb
		net.Broadcast()
		end)
		if dmg_data then
			local PhysBone = ragdollGIB:TranslateBoneToPhysBone(bone_id)
			local PhysicsObject = ragdollGIB:GetPhysicsObjectNum( PhysBone )
			PhysicsObject:AddVelocity(dmg_data.dmg_force/18)	
		end
		ragdollGIB.gib_bone = {}
		table.insert(gib_PhysBone_RAGDOLLS,ragdollGIB)
		for phys, v in pairs(ragdoll.gib_bone) do
			local boneid = ragdoll:TranslatePhysBoneToBone(phys)
			local bone_name2 = ragdoll:GetBoneName(boneid)
			local main_bone = ragdollGIB:TranslateBoneToPhysBone(ragdollGIB.main_bone_sigma)
			if phys ~= main_bone then
							print(bone_name2)
				local dmg_data = {
                	slice = true  
            	}
				gib_PhysBone(ragdollGIB,bone_name2,dmg_data)
				hook.Call( "noob_gore_gap", nil,ragdollGIB,ragdollGIB:GetModel(),bone_name2) --call this hook to make cap based on bone name
			end
		end

		timer.Simple(GetConVar("sliced_ragdoll_fade_time"):GetFloat(), function()
			if IsValid(ragdollGIB) then
				ragdollGIB:Remove()
			end
		end)
	end
end 

/*
function decap_ragdoll(ragdoll,bone_name)
    if ragdoll:LookupBone(bone_name) == nil or ragdoll:LookupBone(bone_name) == 0 then return end
    local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
	net.Start( "noob_gore_sigma_matrix" )
		net.WriteEntity(ragdoll)
		net.WriteInt(bone_id, 8 )
	net.Broadcast()
end 
*/



function slice_gib(ragdoll,bone_name)
	local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name

	if !ragdoll.slice_gib then ragdoll.slice_gib = {} end
	if ragdoll.slice_gib[bone_id] == bone_id then
		return 
	end
	ragdoll.slice_gib[bone_id] = bone_id
	ragdoll.main_bone_sigma = bone_id
	sigma_children(ragdoll,bone_id)

	local PhysBone = ragdoll:TranslateBoneToPhysBone(bone_id)
	ragdoll:RemoveInternalConstraint(PhysBone) --remove ragdoll Constraint
	for i=0, ragdoll:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
		local bone = ragdoll:TranslatePhysBoneToBone(i)
		if ragdoll.slice_gib[bone] ~= bone then
			ragdoll:RemoveInternalConstraint(i) --remove ragdoll Constraint
			ForcePhysBonePos2(ragdoll)
			colideBone(ragdoll,i)
		end
	end
end
function sigma_children(ragdoll,bone_id)
	local sigma = ragdoll:GetChildBones(bone_id)
    for k, v in pairs(sigma) do --no more shit code
		local PhysBone = ragdoll:TranslateBoneToPhysBone(v)
		local ObjectNum = ragdoll:GetPhysicsObjectNum(PhysBone)
				
		if ObjectNum:IsValid() then --check if the object is valid
			ragdoll.slice_gib[v] = v
			sigma_children(ragdoll,v)
		end
    end
end

function sigma_scale(ragdoll)
	for i = 0, ragdoll:GetBoneCount()-1 do
		if ragdoll.slice_gib[i] ~= i then
			ragdoll:ManipulateBoneScale(i,Vector(0,0,0)) --scale the bone	
		end
	end
end
gib_PhysBone_RAGDOLLS = {}

hook.Add("Think", "ForcePhysbonePositions_Think_sigma", function()
    for _,ragdoll in ipairs( gib_PhysBone_RAGDOLLS ) do
		if not ragdoll:IsValid() then
			table.RemoveByValue(gib_PhysBone_RAGDOLLS, ragdoll) --remove ragdoll on the table
		end
		if ragdoll.gib_bone then
			ForcePhysBonePos(ragdoll) 
		end

	end
end)
timer.Create( "limb_bone_timer",0.5, 0, function() 
	--print("inside") 
	for _,ragdoll in ipairs( gib_PhysBone_RAGDOLLS ) do
		if not ragdoll:IsValid() then
			table.RemoveByValue(gib_PhysBone_RAGDOLLS, ragdoll) --remove ragdoll on the table
		end
		if ragdoll.slice_gib then
			ForcePhysBonePos2(ragdoll) 
		end
	end
end )
function ForcePhysBonePos(ragdoll)
	for bone, v in pairs(ragdoll.gib_bone) do
		local bone_parent = ragdoll:TranslateBoneToPhysBone(ragdoll:GetBoneParent(ragdoll:TranslatePhysBoneToBone(bone)))
		local gibbed_physobj = ragdoll:GetPhysicsObjectNum(bone)
		local parent_physobj = ragdoll:GetPhysicsObjectNum(bone_parent)
		gibbed_physobj:SetPos( parent_physobj:GetPos(),true)
		gibbed_physobj:SetAngles( parent_physobj:GetAngles() )
	end
end
function ForcePhysBonePos2(ragdoll)
	for i=0, ragdoll:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity

		local boneid = ragdoll:TranslatePhysBoneToBone(i)

		local phys = ragdoll:GetPhysicsObjectNum(i)
			
		if IsValid(phys) and ragdoll.slice_gib[boneid] ~= boneid then
			local main_bone = ragdoll:TranslateBoneToPhysBone(ragdoll.main_bone_sigma)
		
			local gibbed_physobj = ragdoll:GetPhysicsObjectNum(i)
			local parent_physobj = ragdoll:GetPhysicsObjectNum(main_bone)
			gibbed_physobj:SetPos( parent_physobj:GetPos()+Vector( 0, 0, 200 ),true)
		end
	end
end
function gib_ragdolll(ragdoll,force,Particle)
	if !ragdoll.gib_bone then
		ragdoll.gib_bone = {}
	end
	for i=0, ragdoll:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
		local boneid = ragdoll:TranslatePhysBoneToBone(i)
		local bone_name = ragdoll:GetBoneName(boneid)
		local phys = ragdoll:GetPhysicsObjectNum(i)
		
		if force == nil then
			force = Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(150, 250))
		end

		local dmg_data = {
            dmg_force = force/2
        }

		if ragdoll:GetManipulateBoneScale(boneid) ~= Vector(0.000000,0.000000,0.000000) then
			hook.Call( "noob_gore_on_gib_destroid", nil,ragdoll,bone_name,dmg_data) --call this hook to make gibs based on bone name
		end

	end
	if Particle then
		local bloodeffect = EffectData()
		bloodeffect:SetOrigin(ragdoll:GetPos() +ragdoll:OBBCenter())
		bloodeffect:SetColor(VJ_Color2Byte(Color(130,19,10)))
		bloodeffect:SetScale(50)
		util.Effect("VJ_Blood1",bloodeffect)
	end

	ragdoll:Remove()
end

function bonemerge_prop(ragdoll,model)
	local npc_model = ragdoll:GetModel()
	local attachments = ragdoll:GetAttachments()
	local Attachment = nil
    for _, att in pairs( attachments ) do 
		Attachment = att.name 	
	end
	if Attachment == nil then
		return
	end
	ragdoll.bonemerge_prop = ents.Create("prop_physics") 
	ragdoll.bonemerge_prop:SetModel(model)
	ragdoll.bonemerge_prop:SetLocalPos(ragdoll:GetPos())
	ragdoll.bonemerge_prop:SetParent(ragdoll)
	ragdoll.bonemerge_prop:Fire("SetParentAttachment",Attachment)
	ragdoll.bonemerge_prop:Spawn()
	ragdoll.bonemerge_prop:Activate()
	ragdoll.bonemerge_prop:SetSolid(SOLID_NONE)
	ragdoll.bonemerge_prop:AddEffects(EF_BONEMERGE)
end
concommand.Add( "ngm_debug_print_ragdoll_table", function( ply, cmd, args )
    PrintTable(gib_PhysBone_RAGDOLLS)
end )
function dismember_limb(ragdoll,bone_name,dmg_data)

	if dmg_data.slice == true then
		decap_ragdoll(ragdoll,bone_name,dmg_data)
	end
	gib_PhysBone(ragdoll,bone_name,dmg_data)
	hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),bone_name) --call this hook to make cap based on bone name

end
