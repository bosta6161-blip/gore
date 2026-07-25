local ENT = FindMetaTable("Entity")
util.AddNetworkString( "noob_gore_gib_npc_bone" )
util.AddNetworkString( "noob_gore_benemerge" )
util.AddNetworkString( "noob_gore_aids" )
gib_PhysBone_RAGDOLLS = {}
gore_mod_slice_damege = {
	1,
	4,
	1024
}
function GetClosestPhysBone(ragdoll,dmg_data)
	if !ragdoll.gib_bone then
		ragdoll.gib_bone = {} table.insert(gib_PhysBone_RAGDOLLS, ragdoll)
	end
    local tr = util.TraceLine({
        start = dmg_data.dmg_pos,
        endpos = dmg_data.dmg_pos + dmg_data.dmg_force:GetNormalized() * 256,
        mask = MASK_SHOT
    })
	return tr
end
function GetClosestPhysBone_on_ragdoll(ragdoll,pos)
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
		local bone2 = ragdoll1:GetPhysicsObjectNum( i )
		if ( IsValid( bone ) ) then
			local pos, ang = ragdoll1:GetBonePosition( ragdoll2:TranslatePhysBoneToBone( i ) )
			if ( pos ) then bone:SetPos( pos,true ) end
			if ( ang ) then bone:SetAngles( ang ) end
			if bone2 ~= nil then
				bone:AddVelocity(bone2:GetVelocity())	
			end
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

    if IsValid(phys) and dmg_data then 
		phys:AddVelocity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(10, 150)) + (dmg_data.dmg_force / 20))
		phys:AddAngleVelocity(Vector(math.Rand(-200, 200), math.Rand(-200, 200), math.Rand(-200, 200)))
	end   
	if dmg_data.bloodColor_is_YELLOW then
		gib.bloodColor_is_YELLOW = true 
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
		print(ragdollGIB)
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

		ragdollGIB.gib_bone = {}
		table.insert(gib_PhysBone_RAGDOLLS,ragdollGIB)
		if ragdoll.gib_bone then
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
		end
		hook.Call( "noob_gore_gap_limb", nil,ragdollGIB,ragdollGIB:GetModel(),bone_name) --call this hook to make cap based on bone name
		ApplyCorpseEffects(ragdollGIB) 
		timer.Simple(GetConVar("sliced_ragdoll_fade_time"):GetFloat(), function()
			if IsValid(ragdollGIB) then
				ragdollGIB:Remove()
			end
		end)
	end
end 




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
timer.Create( "limb_bone_timer",0.1, 0, function() 
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
function goremod_make_dust(ragdoll)
	local startPos = ragdoll:GetBonePosition(0)
    local downTrace = util.TraceLine({
        start = startPos,
        endpos = startPos - Vector(0, 0, 200),
        filter = ragdoll
    })

    if downTrace.Hit then
        local gib = ents.Create("prop_dynamic")
        gib:SetModel("models/mosi/fnv/props/effects/ashpile.mdl")
		gib:SetPos(downTrace.HitPos - Vector(0,0,0.7)) 
        local ang = downTrace.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
		gib:SetAngles(ang)
        gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        gib:Spawn()
		

        timer.Simple(GetConVar("gib_fade_time"):GetFloat(), function()
			if IsValid(gib) then
				gib:Remove()
			end
		end)
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
		bloodeffect:SetColor(100)
		bloodeffect:SetScale(50)
		util.Effect("goremod_blood_smoke",bloodeffect)
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
	ragdoll.bonemerge_prop = ents.Create("prop_dynamic") 
	ragdoll.bonemerge_prop:SetModel(model)
	ragdoll.bonemerge_prop:SetLocalPos(ragdoll:GetPos())
	ragdoll.bonemerge_prop:SetParent(ragdoll)
	ragdoll.bonemerge_prop:Fire("SetParentAttachment",Attachment)
	ragdoll.bonemerge_prop:Spawn()
	ragdoll.bonemerge_prop:Activate()
	ragdoll.bonemerge_prop:SetSolid(SOLID_NONE)
	ragdoll.bonemerge_prop:AddEffects(EF_BONEMERGE)
	ragdoll:DeleteOnRemove(ragdoll.bonemerge_prop)
end

concommand.Add( "ngm_debug_print_ragdoll_table", function( ply, cmd, args )
    PrintTable(gib_PhysBone_RAGDOLLS)
end )
function dismember_limb(ragdoll,bone_name,dmg_data)
	local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
	if dmg_data.slice == true then
		decap_ragdoll(ragdoll,bone_name,dmg_data)
	else
		ParticleEffect("blood_impact_red_01_goop", ragdoll:GetBonePosition(bone_id), ragdoll:GetAngles(), self)
	end
	gib_PhysBone(ragdoll,bone_name,dmg_data)



	hook.Call( "noob_gore_gap", nil,ragdoll,ragdoll:GetModel(),bone_name) --call this hook to make cap based on bone name
end

function ApplyCorpseEffects(ragdoll)
    if ragdoll.destructible_Corpse then
        return 
    end
    local root_health_mult = GetConVar("root_bone_health_multiplier"):GetFloat()
    local health_mult = GetConVar("limb_health_multiplier"):GetFloat()

	ragdoll.destructible_Corpse = true
    ragdoll.gore_mod_boneHealth = {}
	ragdoll.gib_start_delay = CurTime() + 1
    for i = 0, ragdoll:GetPhysicsObjectCount()-1 do
        ragdoll.gore_mod_boneHealth[i] = ragdoll:GetPhysicsObjectNum(i):GetSurfaceArea()*0.25 * (( i == 0 && root_health_mult ) or health_mult)
    end
	local surfaceProp = ragdoll:GetBoneSurfaceProp(0)
	if surfaceProp == "alienflesh" or surfaceProp == "antlion" or surfaceProp == "zombieflesh" then
		ragdoll.goremod_bloodColor_is_YELLOW = true 
	end	
	ragdoll:CallOnRemove("Remove_ragdoll_from_the_table_shit", function()
        table.RemoveByValue(gib_PhysBone_RAGDOLLS, ragdoll) --remove ragdoll on the table
    end)
end
