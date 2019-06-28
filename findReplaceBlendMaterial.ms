(

	--list all classes for material	
	--apropos "material:MaxClass"
-- get material
-- get m.nusubs
-- for each numsubs do
-- superclassof ns 
-- if superclassof ns is maxobject then  if superclassof ns.value is material
	-- recurse with material
-- else if superclassof ns is material
	-- recurse with material
-- 



	fn findNM mat = 
	(
		--print (classof mat)
		
		if (classof mat == Blend) then 
		(
			print "found"
			local m1 = mat.map1
			local m2 = mat.map2
			local mMask = mat.mask
			
			local newBlend = VrayBlendMtl()
			newBlend.name = mat.name
			newBlend.baseMtl = m1
			newBlend.coatMtl_enable[1] = true
			newBlend.coatmtl[1] = m2
			newBlend.texmap_blend[1] = mMask
			replaceInstances mat newBlend
		)
		else if (classof mat == MultiMaterial ) then
		(
			--print (classof mat)
			for i = 1 to mat.numsubs do
			(
				--print ( "searching " + ((classof mat) as string) + "  number of subs " + (mat.numsubs) as string)
				findNM mat[i]
			)
		)
		else if (classof mat == VrayBlendMtl) then
		(
			--print (classof mat)
			for i = 1 to mat.numsubs do
			(
				--print ( "searching " + ((classof mat) as string) + "  number of subs " + (mat.numsubs) as string)
				findNM mat[i].value
			)
		)
	)
	
	
	local sm = sceneMaterials
	/*
	for m in sm where classof m == VRayMtl do
	(
		if classof m.texmap_bump == VrayNormalMap then
		(
			if classof m.texmap_bump.normal_map == Normal_Bump then
			(
				if  classof m.texmap_bump.normal_map.normal_map == Bitmaptexture then
				(
					m.texmap_bump.normal_map = m.texmap_bump.normal_map.normal_map
				)
			)
		)
	)
	*/
	

	
	for m in sm do
	(
		--print m.name
		findNM m
	)
)