net.Receive( "noob_gore_benemerge", function()
    local ent = net.ReadEntity()
    local bonename = net.ReadString()
	local ragdoll_parent = net.ReadEntity()
	if not ragdoll_parent:IsValid() then
		return 
	end
	local ragdoll = ClientsideModel( ragdoll_parent:GetModel() )		-- Create a ragdoll using the player's model
	ragdoll:SetNoDraw(true)
	ragdoll:DrawShadow( true )

	if IsValid(ent) then
		ragdoll:SetSkin( ent:GetSkin() )
		ragdoll:SetColor(ent:GetColor())
	end
	ragdoll:SetLOD(0)
	--ragdoll:SnatchModelInstance(ent)
	ragdoll:SetupBones()
	timer.Simple(0, function()
		if IsValid(ragdoll_parent) and IsValid(ragdoll) then
			ragdoll:SetParent(ragdoll_parent)
			ragdoll:SetNoDraw(false)
			ragdoll:AddEffects(EF_BONEMERGE)
			ragdoll.is_a_ragdoll_gib = true 
			ragdoll.slice_gib = {} 
			ragdoll.main_bone = ragdoll:LookupBone(bonename)
			ragdoll.slice_gib[ragdoll.main_bone] = ragdoll.main_bone
			for i = 1, #ragdoll_parent:GetBodyGroups() do
				ragdoll:SetBodygroup(i, ragdoll_parent:GetBodygroup(i))
			end
			sigma_children2(ragdoll,ragdoll:LookupBone(bonename))

			ragdoll:AddCallback("BuildBonePositions",GibCallback)
			--gore_mod_bonemerge_client_test(ragdoll,"ValveBiped.Bip01_Head1","models/props_junk/watermelon01.mdl")
		end
	end)	
end )
adsadaddsa = { --esse valor e de teste
    ["ValveBiped.Bip01_Head1"] = {
        model = "models/props_junk/watermelon01.mdl",
        localAng = Angle(180,110,90),
        offset = Vector(-0.812,-2.608,0),
        capScale = Vector(1, 1, 1),
    },
}
function gore_mod_bonemerge_client_test(ragdoll,bone_name,model) --tentativa de colocar modelos no client
	local model = ragdoll:GetModel()
	local capScale = Vector(1, 1, 1)
	local localAng = Angle(0, 0, 0)
	local offset = Vector(0,0,0)

	if adsadaddsa[bone_name] and not ragdoll.nogap then

		local bone_id = ragdoll:LookupBone(bone_name) --get bone id from bone name
		local bone_parent = ragdoll:GetBoneParent(bone_id)
		local bonepos,bone_rotation = ragdoll:GetBonePosition(bone_parent)

		local gib_data = adsadaddsa[bone_name]
		offset = gib_data.offset
		local gap = ClientsideModel("models/props_junk/watermelon01.mdl")
		local lpos, lang = WorldToLocal(bonepos,bone_rotation, ragdoll:GetBonePosition(bone_parent))




		if not IsValid(gap) then return end

		gap:SetModel(gib_data.model)               
		gap:Spawn()
		gap:SetNotSolid(true)
		gap:DrawShadow(false)

		gap:ManipulateBoneScale(0, gib_data.capScale) --gap scale
		gap:FollowBone(ragdoll, bone_parent)

		gap:SetLocalAngles(gib_data.localAng)
		gap:SetLocalPos(lpos + offset)
		gap.bonename_parent = bone_name
		gap.is_gap = true 
		if ragdoll.goremod_bloodColor_is_YELLOW then
			gap:SetColor( Color( 255, 255, 0, 255 ))--add ugly piss efect
		end
		print(gap)
	end
end

/*
hook.Add("CreateClientsideRagdoll", "CreateClientsideRagdoll_Ent", function( ent, rag )
	local main_bone = 6
	rag.is_a_ragdoll_gib = true 
    rag.slice_gib = {} 
	rag.main_bone = main_bone
	rag.slice_gib[main_bone] = main_bone
    sigma_children2(rag,main_bone)
    local PhysBone = rag:TranslateBoneToPhysBone(main_bone)
	for i=0, rag:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
		local bone = rag:TranslatePhysBoneToBone(i)
		if rag.slice_gib[bone] ~= bone then

		end
	end
	rag:AddCallback("BuildBonePositions",GibCallback)
	--rag:Remove()
end)
*/

function colideBone2(ragdoll,phys_bone)
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
function sigma_children2(ragdoll,bone_id) --get children bones
	local children = ragdoll:GetChildBones(bone_id)
	for _, child in ipairs(children) do  --no more shit code

		ragdoll.slice_gib[child] = child
		sigma_children2(ragdoll,child)
	end
end

function GibCallback(myself, boneCount)
	for i = 0, boneCount - 1 do
		if myself.slice_gib[i] ~= i and myself.main_bone ~= nil then
			local mat = myself:GetBoneMatrix( i )
			if ( !mat ) then continue end
			local Pos = myself:GetBoneMatrix(myself.main_bone):GetTranslation()
	
			mat:Scale( vector_origin ) //vector_origin = Vector( 0, 0, 0 )
			mat:SetTranslation( Pos )
			myself:SetBoneMatrix( i, mat )
		end
	end
	if not myself:GetParent():IsValid() then
		myself:SetNoDraw(false)
		myself:Remove() 
		return 
	end
end

hook.Add("PreCleanupMap", "Ragdoll_GibsCleanup", function()
	for _, ragdoll in ipairs(ents.GetAll()) do
        if ragdoll.is_a_ragdoll_gib then
			ragdoll:Remove()
        end
    end
end)