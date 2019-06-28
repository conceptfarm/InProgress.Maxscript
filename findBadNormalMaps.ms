(

	fn findNM mat = 
	(
		print (classof mat)
		if (classof mat == VRayMtl) then 
		(
			print mat.name
			if classof mat.texmap_bump == Normal_Bump then
			(
				local newtex = VrayNormalMap()
				newtex.normal_map = mat.texmap_bump.normal_map
				mat.texmap_bump = newtex
				print "found"
			)
		)
		else if (classof mat == MultiMaterial ) then
		(
			--print (classof mat)
			for i = 1 to mat.numsubs do
			(
				print ( "searching " + ((classof mat) as string) + "  number of subs " + (mat.numsubs) as string)
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