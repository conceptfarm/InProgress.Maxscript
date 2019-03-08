(	
	-- add callback on selectionChanged: to untick or tick selection boxes
	-- http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_7C91D285_5683_4606_9F7C_B8D3A7CA508B_htm
	
	-- use .currentcell
	
	-- consider freezing select and name columns
	
	global DataGridViewTest
	global DataGridViewTestOpen = false
	try (destroydialog DataGridViewTest) catch()
	
	local prevSelectedRows = #()
	local dgvRowHeight = 26
	local dgvHeaderRowHeight = 36
	local dgvMaxHeight = 600
	local dgvRefreshing = false
	
	-- Name, Type, Width
	local defList = #(
		#("Select","check",41), 
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
		#("ID","text",42))
		
	
	fn getRowsFromSelection dgvObject = 
	(
		local result = #()
		for i = 0 to dgvObject.SelectedCells.count-1 do
		(
			appendifUnique result dgvObject.SelectedCells.item[i].rowindex
		)
		result
	)
	
	rollout DataGridViewTest "DataGridView" width:1196 height:800
	(  		 
		button btn "refresh"
		dotnetcontrol dgv "DataGridView"  align:#center width:1196 height:600 offset:[0,20]
		
		on btn pressed do
		(
			dgvRefreshing = true
			for i = (dgv.rows.count-1) to 0 by -1 do dgv.Rows.Remove  dgv.rows.item[i]
			
			local allCams = for o in objects where superclassof o == camera collect o
			
			for i = 0 to i = (allCams.count - 1) do 
  			(
				local o = allCams[i+1]
				row=dgv.rows.item[dgv.rows.add()]
				row.height = dgvRowHeight
  				rowCells=row.cells
				
				row.cells.item[0].value = false
				row.cells.item[1].value = o.name
				row.cells.item[2].value = 0
				row.cells.item[3].value = 2
				row.cells.item[4].value = "Get"
				row.cells.item[4].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[5].ReadOnly = true
				
				row.cells.item[6].value = false
				row.cells.item[7].value = "Clear All"
				row.cells.item[7].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[8].value = "Add Hidden"
				row.cells.item[8].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[9].ReadOnly = true
				
				row.cells.item[10].value = false
				row.cells.item[11].value = false
				row.cells.item[12].value = "Get from Sun"
				row.cells.item[12].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[13].value = "Move Sun"
				row.cells.item[13].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[14].ReadOnly = true
				
				row.cells.item[15].value = false
				row.cells.item[16].value = 1920
				row.cells.item[17].value = 1080
				row.cells.item[18].value = "Get Res."
				row.cells.item[18].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[19].ReadOnly = true
				
				row.cells.item[20].value = false
				row.cells.item[21].value = "None"
				row.cells.item[21].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[22].value = false
				row.cells.item[23].value = "Edit"
				row.cells.item[23].flatstyle = (dotnetclass "FlatStyle").Flat
 				row.cells.item[24].value = (GetHandleByAnim o) as string
				row.cells.item[24].ReadOnly = true
			)
			
			---dgv.autoresizecolumns()
			dgv.height = (dgvRowHeight*(allCams.count)) + dgvHeaderRowHeight + (0.2* (allCams.count))
			
						if dgv.height > dgvMaxHeight then 
			(
				dgv.height = dgvMaxHeight
				dgv.width = 1212
				DataGridViewTest.width = 1212
			)
			else
			(
				dgv.width = 1196
				DataGridViewTest.width = 1196
			)	
				
			dgv.AllowUserToAddRows = false
			dgv.AllowUserToDeleteRows = false
			--dgv.rows.removeat((objects.count))
			dgv.ClearSelection()
			dgvRefreshing = false
			
			
		)
		
		
		on DataGridViewTest open do
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
			
			local allCams = for o in objects where superclassof o == camera collect o
			
			for i = 0 to i = (allCams.count - 1) do
  			(
				local o = allCams[i+1]
				row=dgv.rows.item[dgv.rows.add()]
				row.height = dgvRowHeight
  				rowCells=row.cells
				
				row.cells.item[0].value = false
				row.cells.item[1].value = o.name
				row.cells.item[2].value = 0
				row.cells.item[3].value = 2
				row.cells.item[4].value = "Get"
				row.cells.item[4].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[5].ReadOnly = true
				
				row.cells.item[6].value = false
				row.cells.item[7].value = "Clear All"
				row.cells.item[7].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[8].value = "Add Hidden"
				row.cells.item[8].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[9].ReadOnly = true
				
				row.cells.item[10].value = false
				row.cells.item[11].value = false
				row.cells.item[12].value = "Get from Sun"
				row.cells.item[12].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[13].value = "Move Sun"
				row.cells.item[13].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[14].ReadOnly = true
				
				row.cells.item[15].value = false
				row.cells.item[16].value = 1920
				row.cells.item[17].value = 1080
				row.cells.item[18].value = "Get Res."
				row.cells.item[18].flatstyle = (dotnetclass "FlatStyle").Flat
				
				row.cells.item[19].ReadOnly = true
				
				row.cells.item[20].value = false
				row.cells.item[21].value = "None"
				row.cells.item[21].flatstyle = (dotnetclass "FlatStyle").Flat
				row.cells.item[22].value = false
				row.cells.item[23].value = "Edit"
				row.cells.item[23].flatstyle = (dotnetclass "FlatStyle").Flat
 				row.cells.item[24].value = (GetHandleByAnim o) as string
				row.cells.item[24].ReadOnly = true
			)
			
			---dgv.autoresizecolumns()
			dgv.height = (dgvRowHeight*(allCams.count)) + dgvHeaderRowHeight + (0.5 * (allCams.count))
			
			if dgv.height > dgvMaxHeight then 
			(
				dgv.height = dgvMaxHeight
				dgv.width = 1212
				DataGridViewTest.width = 1212
			)
			else
			(
				dgv.width = 1196
				DataGridViewTest.width = 1196
			)
			
			dgv.AllowUserToAddRows = false
			dgv.AllowUserToDeleteRows = false
			--dgv.rows.removeat((objects.count))
			dgv.ClearSelection()
			DataGridViewTestOpen = true
		)
		

		on DataGridViewTest close do
		(
			DataGridViewTestOpen =  false	
		)
		
		
		on dgv cellMouseDown val do
		(
			prevSelectedRows = getRowsFromSelection dgv
		)
		
		on dgv CellMouseUp val do
		(
			
			dgv.commitEdit (dotNetClass "DataGridViewDataErrorContexts").commit
			
			if val.RowIndex >= 0 then
			(
				case val.ColumnIndex of
				(					
					4:(
							local obj = GetAnimByHandle ((dgv.rows.item[val.RowIndex].cells.item[24].value) as integerPtr)
							Messagebox (obj.name)
							--obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
					)
				)
			)
		)
				
		-- ISSUE: this triggers after the active cell is changed and another cell becomes active
		-- use CellMouseUp to trigger a commit otherwise the even won't know there was a change
		-- and not trigger
		on dgv CellValueChanged val do
		(
			if DataGridViewTestOpen == true and dgvRefreshing == false then
			(
				case val.ColumnIndex of
				(
					0:( 
						--local selectedRows = getRowsFromSelection dgv
						for o in prevSelectedRows do 
						(
							dgv.rows.item[o].cells.item[val.ColumnIndex].value = dgv.currentCell.value
							
						)
						clearSelection()
						local objToSelect = ( for i = 0 to (dgv.rows.count - 1) where ( (dgv.rows.item[i].cells.item[0].value)  == true ) collect (GetAnimByHandle ((dgv.rows.item[i].cells.item[24].value) as integerPtr)))
						select objToSelect
					)
					
					1:(
							--print "something"
							--print val.RowIndex
							--print val.ColumnIndex
							--print (val as string)
							local obj = GetAnimByHandle ((dgv.rows.item[val.RowIndex].cells.item[24].value) as integerPtr)
							obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
							--dgv.autoresizecolumns()
						)
						
					2:(
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local nextValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex + 1].value) as integer
						
						if thisValue !=undefined and nextValue != undefined then
						(	
							if (thisValue > nextValue) then 
							(
								Messagebox ("First frame number can't be grater than last frame number.")
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = nextValue
							)
							else dgv.currentCell.value = dgv.currentCell.value as integer
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0
						)
					)
					
					3:(
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local prevValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex - 1].value) as integer
						
						if thisValue !=undefined and prevValue != undefined then
						(	
							if (thisValue < prevValue) then 
							(
								Messagebox ("Last frame number can't be smaller than first frame number.")
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevValue
							)
							else dgv.currentCell.value = dgv.currentCell.value as integer
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0
						)
					)
					

					
					
				)
			)
		)
  	 )
	 
	try(destroydialogDataGridViewTest )catch()
	createDialog DataGridViewTest
)