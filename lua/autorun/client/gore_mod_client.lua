
-- Copy visual state from the source ragdoll/NPC. Skin + material + bodygroups
-- are what preserve the "face" and clothing appearance on a detached limb.
local function LambdaGoreCopyVisualState(source, target)
    if not IsValid(source) or not IsValid(target) then return end

    target:SetSkin(source:GetSkin())
    target:SetColor(source:GetColor())
    target:SetMaterial(source:GetMaterial())

    for i = 0, source:GetNumSubMaterials() - 1 do
        target:SetSubMaterial(i, source:GetSubMaterial(i))
    end

    for _, group in ipairs(source:GetBodyGroups()) do
        target:SetBodygroup(group.id, source:GetBodygroup(group.id))
    end

    -- Flex weights are useful for face/body expressions on models that use
    -- facial flexes instead of a skin texture.
    for i = 0, math.min(source:GetFlexNum() - 1, target:GetFlexNum() - 1) do
        target:SetFlexWeight(i, source:GetFlexWeight(i))
    end
end

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

    if IsValid(ragdoll_parent) then
        LambdaGoreCopyVisualState(ragdoll_parent, ragdoll)
    end
    if IsValid(ent) then
        -- The source gap entity can carry a newer material/bodygroup state.
        LambdaGoreCopyVisualState(ent, ragdoll)
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
			sigma_children2(ragdoll,ragdoll:LookupBone(bonename))

			ragdoll:AddCallback("BuildBonePositions",GibCallback)
		end
	end)	
end )

-- hook.Add("CreateClientsideRagdoll", "CreateClientsideRagdoll_Ent", function( ent, rag )
-- 	local main_bone = 6
-- 	rag.is_a_ragdoll_gib = true 
--     rag.slice_gib = {} 
-- 	rag.main_bone = main_bone
-- 	rag.slice_gib[main_bone] = main_bone
--     sigma_children2(rag,main_bone)
--     local PhysBone = rag:TranslateBoneToPhysBone(main_bone)
-- 	for i=0, rag:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
-- 		local bone = rag:TranslatePhysBoneToBone(i)
-- 		if rag.slice_gib[bone] ~= bone then
-- 
-- 		end
-- 	end
-- 	rag:AddCallback("BuildBonePositions",GibCallback)
-- 	--rag:Remove()
-- end)

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
            local mat = myself:GetBoneMatrix(i)
            if not mat then continue end

            local Pos = myself:GetBoneMatrix(myself.main_bone):GetTranslation()
            mat:Scale(vector_origin)
            mat:SetTranslation(Pos)
            myself:SetBoneMatrix(i, mat)
        elseif myself.main_bone ~= nil then
            -- Keep finger bones physically posed instead of leaving them in
            -- the source animation pose when an arm is detached.
            local boneName = string.lower(myself:GetBoneName(i) or "")
            if string.find(boneName, "finger", 1, true) or string.find(boneName, "thumb", 1, true) then
                local mat = myself:GetBoneMatrix(i)
                if mat then
                    mat:RotateAroundAxis(mat:GetRight(), 18)
                    myself:SetBoneMatrix(i, mat)
                end
            end
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