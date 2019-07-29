(
	global rol_test
	try(destroyDialog rol_test)catch()
	
	rollout rol_test "FFD Control points transfer"
	(
		local pointsDataFile = undefined
		local savePath = undefined
		local dNETopenFileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"

		dotNetControl btn_Browse "system.windows.forms.button" pos:[5,20] height:20 width:109
		edittext et_name "Name:" text:"example_01" width:105 pos:[5,40] labelontop:true
		dotNetControl btn_save "system.windows.forms.button" pos:[5,80] height:20 width:60

		dotNetControl btn_loadData "system.windows.forms.button" pos:[5,125] height:20 width:60
		
		checkbox chkbox_applyX "X" pos:[5,148] 
		checkbox chkbox_applyY "Y" pos:[44,148] 
		checkbox chkbox_applyZ "Z" pos:[82,148]
		
		dotNetControl btn_apply "system.windows.forms.button" pos:[5,175] height:20 width:109
		
		function DotNetButtonsStyle _btn _name =
		(
			_btn.flatStyle=(dotNetClass "System.Windows.Forms.FlatStyle").System 
			--Or
-- 			_btn.flatStyle = _btn.flatStyle.flat
			_btn.text = _name
-- 			_btn.TextAlign = (dotNetClass "System.Drawing.ContentAlignment").middleleft
			_btn.backColor = _btn.backColor.black
			_btn.foreColor = _btn.backColor.gray
		)
		
		function Btn_BrowsePressed =
		(
			savePath = getSavePath caption:"Select folder" initialDir:"$previews"
		)
		
		function Btn_saveFFDCPPressed =
		(
			infoFile = undefined	
-- 			infoFile = createFile (savePath + "\\" + et_name.text + ".dat")	
			local topMod = modpanel.getCurrentObject()
			if ( substring (topMod as string) 1 3 ) == "FFD" then
			(
				if (substring (topMod as string) 1 3) == "FFD" then
				(
					theMaster = topMod[#master]
					theCount = theMaster.numsubs
					animateAll topMod
					for i = 1 to theCount where theMaster[i].value != undefiend do
					(
						format "%
" (theMaster[i].value) to:infoFile
					)	
					close infoFile
					free infoFile
					lbl_info.text = "Saved"
				)
				else
					messagebox "The top modifier is not FFD" title:"Invalid Selection"
			)
			else
				messagebox "The selected object does not have applyed FFD modifier" title:"Invalid Selection"
		)
		
		function Btn_loadDataPressed =
		(
			result = dNETopenFileDialog.showDialog()
			result.ToString() 
			if (result.Equals result.OK) do 
			(
				pointsDataFile = (dNETopenFileDialog.fileNames)[1]
				btn_loadData.tooltip = pointsDataFile
				lbl_info02.text = "Loaded"
			)
			if (result.Equals result.Cancel) do
				pointsDataFile = undefined
		)
		
		function Btn_applyPressed =
		(
			if doesFileExist pointsDataFile do
				infoFile = openFile pointsDataFile
			local topMod = modpanel.getCurrentObject()
			if ( substring (topMod as string) 1 3 ) == "FFD" then
			(
				theMaster = topMod[#master]
				theCount = theMaster.numsubs
				animateAll topMod
				
				cnt = 0
				while not eof infoFile do
				(
					cnt += 1
					local ffdPpos = readLine infoFile
					local ffdPos = (execute ffdPpos)
					if chkbox_applyX.state == true and chkbox_applyY.state == true and chkbox_applyZ.state == true then
						(theMaster[cnt].value) = ffdPos
					else
					(
						if chkbox_applyX.state == true do
						(
							local curPos = (theMaster[cnt].value)
							curPos.x = ffdPos.x							
							(theMaster[cnt].value) = curPos
						)
						if chkbox_applyY.state == true do
						(
							local curPos = (theMaster[cnt].value)
							curPos.y = ffdPos.y							
							(theMaster[cnt].value) = curPos
						)
						if chkbox_applyZ.state == true do
						(
							local curPos = (theMaster[cnt].value)
							curPos.z = ffdPos.z							
							(theMaster[cnt].value) = curPos
						)
					)
				)
				close infoFile
				free infoFile
			)
			else
				messagebox "Invalid selection" title:"Invalid Selection"
		)
		
		on btn_Browse mouseUp senderArg arg do
		(
			if arg.button==arg.button.left do Btn_BrowsePressed()
		)
		on btn_Browse KeyUp evnt do
		(
			if evnt.KeyCode == (dotNetClass "System.Windows.Forms.Keys").Enter do print "Browse is pressed"
		)
		
		on btn_save mouseUp senderArg arg do
		(
			if arg.button==arg.button.left do Btn_saveFFDCPPressed()
		)
		on btn_save KeyUp evnt do
		(
			if evnt.KeyCode == (dotNetClass "System.Windows.Forms.Keys").Enter do print "Save is pressed"
		)
		
		on btn_loadData mouseUp senderArg arg do
		(
			if arg.button==arg.button.left do Btn_loadDataPressed()
		)
		on btn_loadData KeyUp evnt do
		(
			if evnt.KeyCode == (dotNetClass "System.Windows.Forms.Keys").Enter do print "Load is pressed"
		)
		
		on btn_apply mouseUp senderArg arg do
		(
			if arg.button==arg.button.left do Btn_applyPressed()
		)
		on btn_apply KeyUp evnt do
		(
			if evnt.KeyCode == (dotNetClass "System.Windows.Forms.Keys").Enter do print "Apply is pressed"
		)
		
		on rol_test open do
		(
			dNETopenFileDialog.title = "Select file"
			dNETopenFileDialog.Multiselect = false
			dNETopenFileDialog.Filter = "DAT (*.dat)|*.dat"
			dNETopenFileDialog.FilterIndex = 1
			dNETopenFileDialog.RestoreDirectory = true
			--	dotNet buttons
			DotNetButtonsStyle btn_Browse "Browse(save path)"
			DotNetButtonsStyle btn_save "Save FFD"
			DotNetButtonsStyle btn_loadData "Load FFD"
			DotNetButtonsStyle btn_apply "Apply"
			--
			setFocus btn_Browse
		)
	)
	createdialog rol_test 	width:119
)