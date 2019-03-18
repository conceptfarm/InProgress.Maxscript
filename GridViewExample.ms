---------------------------------------------------------------------------------------
-- MultiCamLister.ms
-- By Ilya Floussov (ilya@conceptfarm.ca)
-- Dec 16th 2018
-- Lists all Vray Cameras and their porperties MultiCam Attribute properties
---------------------------------------------------------------------------------------
macroScript MultiCamLister
category:"ilya_s Scripts"
tooltip:"MCL"
buttontext:"MCL"
Icon:#("Lights",7)
(
	-- add callback on selectionChanged: to untick or tick selection boxes
	-- http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_7C91D285_5683_4606_9F7C_B8D3A7CA508B_htm
	
	-- use .currentcell
	
	-- consider freezing select and name columns
	
	global MultiCamLister
	global MultiCamListerOpen = false
		
	local prevSelectedRows = #()
	local prevSelectedRowsLessSelf = #()
	local prevSelectedRowsPlusSelf = #()
	local dgvRowHeight = 26
	local dgvHeaderRowHeight = 36
	local dgvMaxHeight = 600
	local dgvRefreshing = false
	local disabledColor = (dotnetclass "system.drawing.color").fromARGB 128 128 128
	local enabledColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
	local enabledStyle = dotnetobject "DataGridViewCellStyle"
	enabledStyle.forecolor = enabledColor
	local disabledStyle = dotnetobject "DataGridViewCellStyle"
	disabledStyle.forecolor = disabledColor
	
	-- Name, Type, Width
	local defList = #(
		#("Select","button",41), 
		#("Camera Name","text",101), 
		#("First Frame","number",40), 
		#("Last Frame","number",37), 
		#("Get Range","button",56),  
		#(" ","text",11),  
		#("Use Hide Layers","check",55),
		#("Clear All","button",56), 
		#("Add Hidden","button",72),
		#(" ","text",11),  
		#("Use Sunpoints","check",58),
		#("Show Sunpoints","check",58), 
		#("Get From Sun","button",80),
		#("Move Sun","button",80),
		#(" ","text",11),  
		#("Use Resolution","check",57), 
		#("Width","number",46), 
		#("Height","number",46), 
		#("Get Res.","button",56),
		#(" ","text",11),  
		#("Use HDRI","check",42),  
		#("HDRI Map","button",56),
		#("Link HDRI","check",56),
		#("Edit Map","button",56),
		#("ID","text",42),
		#("ID","text",42))
		
	
	fn getVraySunInScene = 
	(
		local result = undefined
		local allSuns = for o in objects where classof o == VraySun collect o

		if (allSuns.count == 1 ) then
		(
			result = allSuns[1]
		)
		else if (allSuns.count > 1) then 
		(
			--MessageBox ("There are " + allSuns.count as string + " in the scene.\nThere can only be one!")
			result = undefined
		)
		else
		(
			--MessageBox ("No VraySun in the scene.")
			result = undefined
		)
		return result
	)
	
	fn getRowsFromSelection dgvObject subtract:true cell:unsupplied = 
	(
		local result = #()
		for i = 0 to dgvObject.SelectedCells.count-1 do
		(
			appendifUnique result dgvObject.SelectedCells.item[i].rowindex
		)
		if cell != unsupplied then
		(
			--print cell
			if subtract then 
			(
				if (findItem result cell) != 0 then 
				(
					local itemToDelete = (findItem result cell)
					--print ("item to delete " + itemtodelete as string)
					deleteItem result itemToDelete
					--print ("result is " + result as string)
				)
			)
			else if not subtract then
			(
				appendifUnique result cell
			)
		)
		result
	)
	
	fn checkSelectedCells dgvObject val  = 
	(
		for row in prevSelectedRows do 
		(
			if dgvObject.rows.item[row].cells.item[val.ColumnIndex].readonly != true then
			(
				dgvObject.rows.item[row].cells.item[val.ColumnIndex].value = dgvObject.currentCell.value
			)
		)
	)
	
	fn getObjectByRow dgvObject row = 
	(
		local obj = GetAnimByHandle ((dgvObject.rows.item[row].cells.item[24].value) as integerPtr)
		return obj		
	)
	
	fn getObjectsFromChecked dgvObject col = 
	(
		local objToSelect = (for i = 0 to (dgvObject.rows.count - 1) where ( (dgvObject.rows.item[i].cells.item[col].value)  == true ) collect (GetAnimByHandle ((dgvObject.rows.item[i].cells.item[24].value) as integerPtr)))
		return objToSelect
	)
	
	fn changeControlStatus dgvObject row val arr = 
	(
		for cell in arr do
		(
			--here we change the whole style rather than just forecolor, bug in max or dotnet?
			dgvObject.rows.item[row].cells.item[cell].ReadOnly = not val
			if val == true then
			(
				dgvObject.rows.item[row].cells.item[cell].style = enabledStyle
			)
			else
			(
				dgvObject.rows.item[row].cells.item[cell].style = disabledStyle
			)
		)
	)
	
	fn populateDGV dgvObject = 
	(
		local allCams = for o in objects where (superclassof o == camera and o.modifiers[#MultiCam_Attribute] != undefined) collect o
			
		for i = 0 to i = (allCams.count - 1) do
		(
			local o = allCams[i+1]
			row=dgvObject.rows.item[dgvObject.rows.add()]
			row.height = dgvRowHeight
			rowCells=row.cells
			
			row.cells.item[0].value = ""
			row.cells.item[0].flatstyle = (dotnetclass "FlatStyle").Flat
			
			row.cells.item[1].value = o.name
			row.cells.item[2].value = o.modifiers[#MultiCam_Attribute].firstFrame_sp
			row.cells.item[3].value = o.modifiers[#MultiCam_Attribute].lastFrame_sp
			row.cells.item[4].value = "Get"
			row.cells.item[4].flatstyle = (dotnetclass "FlatStyle").Flat
				
			row.cells.item[5].ReadOnly = true
			
			row.cells.item[6].value = o.modifiers[#MultiCam_Attribute].useHideLayers_chb
			row.cells.item[7].value = "Clear All"
			row.cells.item[7].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[7].ReadOnly = not row.cells.item[6].value
			row.cells.item[8].value = "Add Hidden"
			row.cells.item[8].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[8].ReadOnly = not row.cells.item[6].value
			if row.cells.item[6].value == false then
			(
				row.cells.item[7].style = disabledStyle
				row.cells.item[8].style = disabledStyle
			)
			
			row.cells.item[9].ReadOnly = true
			
			row.cells.item[10].value = o.modifiers[#MultiCam_Attribute].useSunpoints_chb
			row.cells.item[11].value = o.modifiers[#MultiCam_Attribute].showSunPoint_btn
			row.cells.item[11].ReadOnly = not row.cells.item[10].value
			row.cells.item[12].value = "Get from Sun"
			row.cells.item[12].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[12].ReadOnly = not row.cells.item[10].value
			row.cells.item[13].value = "Move Sun"
			row.cells.item[13].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[13].ReadOnly = not row.cells.item[10].value
			if row.cells.item[10].value == false then
			(
				row.cells.item[11].style = disabledStyle
				row.cells.item[12].style = disabledStyle
				row.cells.item[13].style = disabledStyle
			)
			
			row.cells.item[14].ReadOnly = true
			
			row.cells.item[15].value = o.modifiers[#MultiCam_Attribute].useHeightWidth_chb
			row.cells.item[16].value = o.modifiers[#MultiCam_Attribute].imgWidth_sp
			row.cells.item[16].ReadOnly = not row.cells.item[15].value
			row.cells.item[17].value = o.modifiers[#MultiCam_Attribute].imgHeight_sp
			row.cells.item[17].ReadOnly = not row.cells.item[15].value
			row.cells.item[18].value = "Get Res."
			row.cells.item[18].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[18].ReadOnly = not row.cells.item[15].value
			if row.cells.item[15].value == false then
			(
				row.cells.item[16].style = disabledStyle
				row.cells.item[17].style = disabledStyle
				row.cells.item[18].style = disabledStyle
			)
			
			row.cells.item[19].ReadOnly = true
			
			row.cells.item[20].value = o.modifiers[#MultiCam_Attribute].useHDRIMap_chb
			row.cells.item[21].value = if (o.modifiers[#MultiCam_Attribute].hdriMap_btn != undefined) then (o.modifiers[#MultiCam_Attribute].hdriMap_btn.name) else ("None")
			row.cells.item[21].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[21].ReadOnly = not row.cells.item[20].value
			row.cells.item[22].value = o.modifiers[#MultiCam_Attribute].hdriMapLink_chb
			row.cells.item[22].ReadOnly = not row.cells.item[20].value
			row.cells.item[23].value = "Edit"
			row.cells.item[23].flatstyle = (dotnetclass "FlatStyle").Flat
			row.cells.item[23].ReadOnly = not row.cells.item[20].value
			if row.cells.item[20].value == false then
			(
				row.cells.item[21].style = disabledStyle
				row.cells.item[22].style = disabledStyle
				row.cells.item[23].style = disabledStyle
			)
			
			
			
			row.cells.item[24].value = (GetHandleByAnim o) as string
			row.cells.item[24].ReadOnly = true
			row.cells.item[25].value = if (o.modifiers[#MultiCam_Attribute].hdriMap_btn != undefined) then ((GetHandleByAnim o.modifiers[#MultiCam_Attribute].hdriMap_btn) as string) else ("None")
			row.cells.item[25].ReadOnly = true
		)
		
		---dgv.autoresizecolumns()
		dgvObject.height = 	ceil ((dgvRowHeight*(allCams.count)) + dgvHeaderRowHeight + (0.6* (allCams.count)))

		if dgvObject.height > dgvMaxHeight then 
		(
			dgvObject.height = dgvMaxHeight
			dgvObject.width = 1212
			MultiCamLister.width = 1212
		)
		else
		(
			dgvObject.width = 1196
			MultiCamLister.width = 1196
		)
		
		dgvObject.AllowUserToAddRows = false
		dgvObject.AllowUserToDeleteRows = false
		--dgv.rows.removeat((objects.count))
		dgvObject.ClearSelection()
	)
	
	
	rollout MultiCamLister "DataGridView" width:1196 height:800
	(  		 
		button btn "Refresh"
		dotnetcontrol dgv "DataGridView"  align:#center width:1196 height:600 offset:[0,20]
		
		on btn pressed do
		(
			dgvRefreshing = true
			for i = (dgv.rows.count-1) to 0 by -1 do dgv.Rows.Remove  dgv.rows.item[i]
			
			populateDGV dgv
			
			dgvRefreshing = false
		)
		
		
		on MultiCamLister open do
		(
			 
  			dgv.Dock=dgv.Dock.Fill
  			dgv.RowHeadersVisible=false
			
			for o in defList do
			(
				local col = undefined 
				case o[2] of 
				(
					"text":(
									col = (dotnetobject "DataGridViewTextBoxColumn")
								)
					"button": (
									col =  (dotnetobject "DataGridViewButtonColumn")
									col.sortmode = (dotnetclass "DataGridViewColumnSortMode").NotSortable
								)
					"number": (
									col = (dotnetobject "DataGridViewTextBoxColumn")
									--Not a good idea to set column to integer mode, harder to handle non-number entries
									--col.valueType = (dotnetclass "type").gettype "System.Int32"
								)
					"check":(
									col = (dotnetobject "DataGridViewCheckBoxColumn")
								)
				)
				col.DataPropertyName = "Name"
				col.Name = o[1]
				col.width = o[3]
				if o[1] == "ID" then col.visible = false
				dgv.Columns.Add (col)
			)
		
			--Colour and Styling
  			oddColor=(dotnetclass "system.drawing.color").fromARGB 32 32 32
			evenColor= (dotnetclass "system.drawing.color").fromARGB 68 68 68  			
			dgv.defaultCellStyle.backColor=evenColor
			dgv.AlternatingRowsDefaultCellStyle.backColor=oddColor	
			dgv.BackgroundColor = (dotnetclass "system.drawing.color").fromARGB 68 68 68			
			dgv.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
			dgv.DefaultCellStyle.SelectionBackColor = (dotnetclass "system.drawing.color").fromARGB 80 200 69
			dgv.ColumnHeadersDefaultCellStyle.backcolor = (dotnetclass "system.drawing.color").fromARGB 100 100 100
			dgv.ColumnHeadersDefaultCellStyle.forecolor = (dotnetclass "system.drawing.color").fromARGB 255 255 255 
			dgv.enableheadersvisualstyles = false
			dgv.CellBorderStyle = (dotnetclass "DataGridViewCellBorderStyle").None
			dgv.RowHeadersBorderStyle =  (dotnetclass "DataGridViewHeaderBorderStyle").Single
			dgv.ColumnHeadersBorderStyle =(dotnetclass  "DataGridViewHeaderBorderStyle").Single
			dgv.ColumnHeadersHeight=dgvHeaderRowHeight
			dgv.AllowUserToResizeColumns = false
			dgv.ColumnHeadersHeightSizeMode = (dotnetclass "DataGridViewColumnHeadersHeightSizeMode").DisableResizing
			dgv.AllowUserToResizeRows = false
			dgv.RowHeadersWidthSizeMode = (dotnetclass "DataGridViewRowHeadersWidthSizeMode").DisableResizing
			
			
			--dgv.SelectionMode=(dotNetClass "System.Windows.Forms.DataGridViewSelectionMode").FullRowSelect
			populateDGV dgv
			
			MultiCamListerOpen = true
		)
		

		on MultiCamLister close do
		(
			MultiCamListerOpen =  false	
		)
		
		on dgv CellLeave val do
		(
			--show val
		)
		
		on dgv cellMouseDown val do
		(
			prevSelectedRows = getRowsFromSelection dgv
			prevSelectedRowsLessSelf = getRowsFromSelection dgv cell:val.RowIndex
			prevSelectedRowsPlusSelf = getRowsFromSelection dgv cell:val.RowIndex subtract:false
						
			if (prevSelectedRows.count == 0 or prevSelectedRows.count == 1) then 
			(
				prevSelectedRows = #(val.rowIndex)
				prevSelectedRowsLessSelf = #(val.rowIndex)
				prevSelectedRowsPlusSelf = #(val.rowIndex)
			)
			
			--print ("prevSelectedRows" + prevSelectedRows as string)
			--print ("prevSelectedRowsLessSelf" + prevSelectedRowsLessSelf as string)
		)
		
		on dgv CellMouseClick val do
		(
			if val.RowIndex >= 0 then
			(
				case val.ColumnIndex of
				(					
					4:(--Get FrameRange
						for row in prevSelectedRowsPlusSelf do 
						(
							local obj = getObjectByRow dgv row
							setProperty obj.modifiers[#MultiCam_Attribute] #getFrameRange_btn true
							dgv.rows.item[row].cells.item[2].value = obj.modifiers[#MultiCam_Attribute].firstFrame_sp
							dgv.rows.item[row].cells.item[3].value = obj.modifiers[#MultiCam_Attribute].lastFrame_sp
						)
					)--end 4
					
					7:(--Clear All
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[7].readonly != true then
							(
								local obj = getObjectByRow dgv row
								setProperty obj.modifiers[#MultiCam_Attribute] #clearLayers_btn true
							)
						)
					)--end 7
					
					8:(--Add Hidden
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[8].readonly != true then
							(
								local obj = getObjectByRow dgv row
								setProperty obj.modifiers[#MultiCam_Attribute] #addLayers_btn true
							)
						)
					)--end 8
									
					12:(--Get From Sun
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[12].readonly != true then
							(
								local obj = getObjectByRow dgv row
								setProperty obj.modifiers[#MultiCam_Attribute] #readSunPos_btn true
							)
						)
					)--end 12
					
					13:(--Move Sun
							if dgv.rows.item[val.RowIndex].cells.item[13].readonly != true then
							(
								local obj = getObjectByRow dgv val.RowIndex
								setProperty obj.modifiers[#MultiCam_Attribute] #moveSunToPos_btn true
							)
					)--end 13
										
					18:(--Get Res
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[18].readonly != true then
							(
								local obj = getObjectByRow dgv row
								setProperty obj.modifiers[#MultiCam_Attribute] #getImgFrame_btn true
								dgv.rows.item[row].cells.item[16].value = obj.modifiers[#MultiCam_Attribute].imgWidth_sp
								dgv.rows.item[row].cells.item[17].value = obj.modifiers[#MultiCam_Attribute].imgHeight_sp
							)
						)
					)--end 18
					
					21:(--HDRI Map
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[21].readonly != true then
							(
								local obj = getObjectByRow dgv row
								if (obj.modifiers[#MultiCam_Attribute].hdriMap_btn == undefined) then
								(
									local map = VrayHDRI()
									map.name = "HDRI for " + obj.name
									setProperty obj.modifiers[#MultiCam_Attribute] #hdriMap_btn map
									dgv.rows.item[row].cells.item[25].value = (GetHandleByAnim map) as string
									dgv.rows.item[row].cells.item[21].value = map.name
								)
								else
								(
									local qb = QueryBox "There is already a VrayHDRI map assigned. Overwrite with new?"
									if qb == true then
									(
										local map = VrayHDRI()
										map.name = "HDRI for " + obj.name
										setProperty obj.modifiers[#MultiCam_Attribute] #hdriMap_btn map
										dgv.rows.item[row].cells.item[25].value = (GetHandleByAnim map) as string
										dgv.rows.item[row].cells.item[21].value = map.name
									)
								)
							)								
						)
					)--end 21
					
					23:(--Edit Map
							if dgv.rows.item[val.RowIndex].cells.item[23].readonly != true then
							(
								local obj = getObjectByRow dgv val.RowIndex
								setProperty obj.modifiers[#MultiCam_Attribute] #hdriMapEdit_btn true
							)
					)--end 23
					
				)--end case
			)--end if
		)--end on Click
		
		on dgv CellMouseUp val do
		(
			dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
			
			if val.RowIndex >= 0 then
			(
				case val.ColumnIndex of
				(					
					0:( --Selection
						clearSelection()
						local objToSelect = #()
						local rows = getRowsFromSelection dgv
						for row in rows do 
						(
							local obj = getObjectByRow dgv row
							append objToSelect obj
						)
						select objToSelect
					)
					
					22:(dgv.endEdit())
				)--end case
			)--end if
		)--end on mouseUp
				
		-- ISSUE: this triggers after the active cell is changed and another cell becomes active
		-- use CellMouseUp to trigger a commit otherwise the even won't know there was a change
		-- and not trigger
		on dgv CellValueChanged val do
		(
			if MultiCamListerOpen == true and dgvRefreshing == false then
			(
				case val.ColumnIndex of
				(

					1:(--Camera Name
						local obj = getObjectByRow dgv val.RowIndex
						obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
					)--end 1
						
					2:(--First Frame
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local nextValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex + 1].value) as integer
						local obj = getObjectByRow dgv val.RowIndex
						
						if thisValue !=undefined and nextValue != undefined then
						(	
							if (thisValue > nextValue) then 
							(
								Messagebox ("First frame number can't be grater than last frame number.")
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = nextValue
								obj.modifiers[#MultiCam_Attribute].firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							)
							else
							(
								dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								obj.modifiers[#MultiCam_Attribute].firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							)
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0
							obj.modifiers[#MultiCam_Attribute].firstFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
						)
					)--end 2
					
					3:(--Last Frame
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local prevValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex - 1].value) as integer
						local obj = getObjectByRow dgv val.RowIndex
						
						if thisValue !=undefined and prevValue != undefined then
						(	
							if (thisValue < prevValue) then 
							(
								Messagebox ("Last frame number can't be smaller than first frame number.")
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevValue
								obj.modifiers[#MultiCam_Attribute].lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							)
							else
							(
								dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
								obj.modifiers[#MultiCam_Attribute].lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
							)
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0
							obj.modifiers[#MultiCam_Attribute].lastFrame_sp = dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value as integer
						)
					)--end 3
					
					6:(--Use Layers
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(7,8)
						)
						local obj = getObjectByRow dgv val.RowIndex
						setProperty obj.modifiers[#MultiCam_Attribute] #useHideLayers_chb thisValue
					)--end 6
						
					10:(--Use Sunpoints
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(11, 12, 13)
						)
						local obj = getObjectByRow dgv val.RowIndex
						setProperty obj.modifiers[#MultiCam_Attribute] #useSunpoints_chb thisValue
					)--end 10
					
					11:(--Show Sunpoints
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						
						local obj = getObjectByRow dgv val.RowIndex
						setProperty obj.modifiers[#MultiCam_Attribute] #showSunPoint_btn thisValue
					)--end 11
						
					15:(--Use Resolution
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(16, 17, 18)
						)
						local obj = getObjectByRow dgv val.RowIndex
						setProperty obj.modifiers[#MultiCam_Attribute] #useHeightWidth_chb thisValue
					)--end 15
						
					20:(--Use HDRI
						checkSelectedCells dgv val
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							changeControlStatus dgv row thisValue #(21, 22, 23)
						)	
						local obj = getObjectByRow dgv val.RowIndex
						setProperty obj.modifiers[#MultiCam_Attribute] #useHDRIMap_chb thisValue
					)--end 20
						
					22:(--Link HDRI
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
						for row in prevSelectedRowsPlusSelf do 
						(
							if dgv.rows.item[row].cells.item[22].readonly != true then
							(				
								local obj = getObjectByRow dgv row
								setProperty obj.modifiers[#MultiCam_Attribute] #hdriMapLink_chb thisValue
								dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value =  obj.modifiers[#MultiCam_Attribute].hdriMapLink_chb
							)
						)
					)--end 22
					
				)--end case
			)--end if
		)--end on Change
  	)--end rollout
	 
	try(destroydialog MultiCamLister )catch()
	createDialog MultiCamLister
)

-- dgv = MultiCamLister.dgv