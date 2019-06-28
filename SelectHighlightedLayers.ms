(
 	
 	fn IsLayerExplorerOpen =
 	(
 		return SceneExplorerManager.ExplorerIsOpen "Layer Explorer"
 	)
 	
 	fn GetLayerExplorerHWND =
 	(
 		if IsLayerExplorerOpen() do
 		(
 			layerExplorer = (for o in (windows.getChildrenHWND 0) where o[5] == "Scene Explorer - Layer Explorer" do exit with o)[1]
 			layerExplorerControls = windows.getChildrenHWND layerExplorer
 			return dotnetobject "System.Intptr" layerExplorerControls[4][1]
 		)
 		return undefined
 	)
 	
 	fn SelectNodesLayers selectNodes:#none =
 	(
 		version = (maxversion())[1]
 		if version < 17000 do return messagebox "Unsupported 3ds Max version."
 		
 		hwnd = GetLayerExplorerHWND()
 		if hwnd == undefined do return messagebox "Layer Explorer is not open."
 
 		richSceneExplorer = (dotnetclass "System.Windows.Forms.Control").FromHandle hwnd
 
 		if version >= 18000 then
 		(
 			selected = richSceneExplorer.GetSelectedNodes false false false
 		)else(
 			selected = richSceneExplorer.GetSelectedNodes()
 		)
 
 		layerClass = dotnet.gettype "SceneExplorer.TraversalLayerBaseNode"
 		
 		done = #()
 		for j in selected do
 		(
 			parent = j.ParentNode
 			if finditem done parent == 0 do
 			(
 				if dotnet.gettype j == layerClass do parent = j
 				append done parent
 			)
 		)
 		
 		if selectNodes == #none do richSceneExplorer.ClearNodeSelection()
 		
 		for j in done do richSceneExplorer.SelectNode j
 		
 		if selectNodes == #all do for j in done do richSceneExplorer.SelectNodes j.Children
 	)
 	
 	SelectNodesLayers selectNodes:#all--[#none|#keep|#all]
 	
 )
