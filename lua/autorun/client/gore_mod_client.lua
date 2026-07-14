net.Receive( "noob_gore_benemerge", function()
    local ent = net.ReadEntity()
    local main_bone = net.ReadInt( 8 ) -- use the same number of bits that were written.
	local ragdoll_parent = net.ReadEntity()
	if not ent:IsValid() then
		return 
	end

    local ragdoll = ClientsideRagdoll( ent:GetModel() )		-- Create a ragdoll using the player's model
	ragdoll:SetRagdollPos( ent:GetPos() )
	ragdoll:SetNoDraw( false )
	ragdoll:DrawShadow( true )
	ragdoll:SetSkin( ent:GetSkin() )
	ragdoll:SetParent(ragdoll_parent)
	ragdoll:AddEffects(EF_BONEMERGE)
	ragdoll:SetLOD(0)
	ragdoll.is_a_ragdoll_gib = true 
    ragdoll.slice_gib = {} 
	ragdoll.main_bone = main_bone
	ragdoll.slice_gib[main_bone] = main_bone
	for i = 1, #ent:GetBodyGroups() do
		ragdoll:SetBodygroup(i, ent:GetBodygroup(i))
	end
    sigma_children2(ragdoll,main_bone)
    local PhysBone = ragdoll:TranslateBoneToPhysBone(main_bone)
	for i=0, ragdoll:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
		local bone = ragdoll:TranslatePhysBoneToBone(i)
		if ragdoll.slice_gib[bone] ~= bone then
			colideBone2(ragdoll,i)
		end
	end
	PrintTable(ragdoll.slice_gib)
	ragdoll:SnatchModelInstance(ent)
    ragdoll:AddCallback("BuildBonePositions",GibCallback)
end )
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
	local sigma = ragdoll:GetChildBones(bone_id)
    for k, v in pairs(sigma) do --no more shit code
		local PhysBone = ragdoll:TranslateBoneToPhysBone(v)
		local ObjectNum = ragdoll:GetPhysicsObjectNum(PhysBone)
				
		if ObjectNum:IsValid() then --check if the object is valid
			ragdoll.slice_gib[v] = v
			sigma_children2(ragdoll,v)
		end
    end
end
local csRag = FindMetaTable( "CSEnt" )
-- csRag:SetPos() doesn't work for C_ClientRagdoll entities.
function csRag:SetRagdollPos(pos)
	
	for i = 0, self:GetPhysicsObjectCount() - 1 do 
		-- Get the physics object (PhysBone)
		local phys = self:GetPhysicsObjectNum(i)
		-- Get the position of the physics object relative to the ragdoll's position
		local localPos = self:WorldToLocal( phys:GetPos() )
		-- Set the physics object's location to the new position using the relative position to it's previous position
		phys:SetPos( pos + localPos )
		
	end
	
end
function SetRagdollPos69(ent,ent2)
	
	for i = 0, ent2:GetPhysicsObjectCount() - 1 do 
        local myPhys = ent2:GetPhysicsObjectNum(i)
        local phys = ent:GetPhysicsObjectNum(i)
        phys:SetPos(myPhys:GetPos())
        phys:SetAngles(myPhys:GetAngles())
		
	end
	
end
function GibCallback(myself, boneCount)
	if not myself:GetParent():IsValid() then
		myself:Remove()
		print("aids")
	end
    for i = 0, boneCount - 1 do
        if myself.slice_gib[i] ~= i then
            local mat = myself:GetBoneMatrix( i )
            if ( !mat ) then continue end
            local Pos = myself:GetBoneMatrix(myself.main_bone):GetTranslation()
    
            mat:Scale( vector_origin ) //vector_origin = Vector( 0, 0, 0 )
            mat:SetTranslation( Pos )
            myself:SetBoneMatrix( i, mat )
        end
    end
end

hook.Add("PreCleanupMap", "Ragdoll_GibsCleanup", function()
	for _, ragdoll in ipairs(ents.GetAll()) do
        if ragdoll.is_a_ragdoll_gib then
			ragdoll:Remove()
        end
    end
end)

hook.Add("HUDPaint", "DrawBonePositions", function()
	if GetConVar("gore_debug"):GetBool() then
    for _, ragdoll in ipairs(ents.GetAll()) do
		if ragdoll.is_a_ragdoll_gib then  

    	for i = 0, ragdoll:GetBoneCount() - 1 do
        	if ragdoll.slice_gib[i] == i then
            	local pos = ragdoll:GetBonePosition(i)

            	if i ~= -1 then
                	local screen = pos:ToScreen()

                	draw.SimpleTextOutlined(
            	        ragdoll:GetBoneName(i),
            	        "DermaDefault",
            	        screen.x,
            	        screen.y,
            	        Color(255, 255, 255),
        	            TEXT_ALIGN_CENTER,
        	            TEXT_ALIGN_CENTER,
        	            1,
        	            Color(0, 0, 0)
        	        )
        	    end
        	end
		end
	end
    end
	end
end)