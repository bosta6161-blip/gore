net.Receive( "noob_gore_gib_npc_bone", function()
    local ent = net.ReadEntity()
    local bone_id = net.ReadInt( 8 ) -- use the same number of bits that were written.
	print(bone_id)
	if not ent:IsValid() then
		return 
	end
	gib_npc_Bone_cl(ent,ent:GetBoneName(bone_id))
	local bone_parent = ent:GetBoneParent(bone_id)
	print(bone_parent)

	ent:AddCallback( "BuildBonePositions", function( ent, numbones )
		for i = 0, numbones - 1 do
			if ent.gib_bone_to_hide[i] == i then
        		local mat = ent:GetBoneMatrix( i )
           		if ( !mat ) then continue end
				local Pos = ent:GetBoneMatrix(bone_parent):GetTranslation()
    
        		mat:Scale( vector_origin ) //vector_origin = Vector( 0, 0, 0 )
        		mat:SetTranslation( Pos )
        		ent:SetBoneMatrix( i, mat )
			end
		end
	end )
end )
function gib_npc_Bone_cl(npc,bone_name)
    if npc:LookupBone(bone_name) == nil or npc:LookupBone(bone_name) == 0 then return end
    if npc:LookupBone("ValveBiped.Bip01_Spine") == nil then return end --check if npc is a valve rig
	if !npc.gib_bone_to_hide then npc.gib_bone_to_hide = {} end
    local bone_id = npc:LookupBone(bone_name) --get bone id from bone name
			
	npc.gib_bone_to_hide[bone_id] = bone_id
    local children = npc:GetChildBones(bone_id)
    for k, v in pairs(children) do --no more shit code
		local bone_children_name = npc:GetBoneName( v )
        gib_npc_Bone_cl(npc,bone_children_name)
    end
end

