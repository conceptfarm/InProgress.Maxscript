(	
	-- add callback on selectionChanged: to untick or tick selection boxes
	-- http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_7C91D285_5683_4606_9F7C_B8D3A7CA508B_htm
	
	-- use .currentcell
	
	-- consider freezing select and name columns
	
	global DataGridViewTest
	global DataGridViewTestOpen = false
	
	local prevSelectedRows = #()
	try (destroydialog DataGridViewTest) catch()
	change_color=(dotnetclass "system.drawing.color").fromARGB 12 128 232
	
	fn getRowsFromSelection dgvObject = 
	(
		local result = #()
		for i = 0 to dgvObject.SelectedCells.count-1 do
		(
			appendifUnique result dgvObject.SelectedCells.item[i].rowindex
		)
		return result
	)
	
	--getRowsFromSelection dgv
	
	-- Name, Type, Width
	local defList = #(
		#("Select","check"), 
		#("Camera Name","text"), 
		#("First Frame","number"), 
		#("Last Frame","number"), 
		#("Get Range","button"),  
		#("  ","text"),  
		#("Use Hide Layers","check"),
		#("Clear All","button"), 
		#("Add Hidden","button"),
		#("  ","text"),  
		#("Use Sunpoints","check"),
		#("Show Sunpoints","check"), 
		#("Get From Sun","button"),
		#("Move Sun","button"),
		#("  ","text"),  
		#("Use Resolution","check"), 
		#("Width","number"), 
		#("Height","number"), 
		#("Get Res.","button"),
		#("  ","text"),  
		#("Use HDRI","check"),  
		#("HDRI Map","button"),
		#("Link","check"),
		#("Edit Map","button"),
		#("ID","text"))
	
	rollout DataGridViewTest "DataGridView" width:800 height:800
	(  		 
		dotnetcontrol dgv "DataGridView"  pos:[0,0] align:#center width:800 height:600
		
		button btn_change_color_01 "Change Color 01" pos:[105,325] width:110 height:25 
		button btn_change_color_02 "Change Color 02" pos:[105,365] width:110 height:25 
		button btn_change_color_03 "Change Color 03" pos:[105,405] width:110 height:25 
			
		on DataGridViewTest open do
		(
			 
  			dgv.Dock=dgv.Dock.Fill
  			dgv.RowHeadersVisible=false
			dgv.AllowUserToResizeRows = false
			
			for o in defList do
			(
				local col = undefined 
				if o[2] == "text" then col = (dotnetobject "DataGridViewTextBoxColumn")
				else if o[2] == "button" then col =  (dotnetobject "DataGridViewButtonColumn")
				else if (o[2] == "number") then (col = (dotnetobject "DataGridViewTextBoxColumn"); col.valueType = (dotnetclass "type").gettype "System.Int32")
				else col = (dotnetobject "DataGridViewCheckBoxColumn")
				--local a = (dotnetobject "DataGridViewTriState.True")
				--col.Resizable = (dotnetobject "DataGridViewTriState.True")
				col.DataPropertyName = "Name"
				col.Name = o[1]
				dgv.Columns.Add (col)
			)

  			--for i=0 to dgv.Columns.count-1 do dgv.Columns.Item[i].width=145
  			numCells=dgv.Columns.count-1
			
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
			
			--dgv.SelectionMode=(dotNetClass "System.Windows.Forms.DataGridViewSelectionMode").FullRowSelect
			
			local allCams = for o in objects where superclassof o == camera collect o
			
			for i = 0 to i = (allCams.count - 1) do
  			(
				local o = allCams[i+1]
				row=dgv.rows.item[dgv.rows.add()]
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
			
			dgv.autoresizecolumns()
			
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
			
			case val.ColumnIndex of
			(					
				4:(
						local obj = GetAnimByHandle ((dgv.rows.item[val.RowIndex].cells.item[24].value) as integerPtr)
						Messagebox (obj.name)
						--obj.name = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value)
				)
			)
		)
		
		-- ISSUE: this triggers after the active cell is changed and another cell becomes active
		-- use CellMouseUp to trigger a commit otherwise the even won't know there was a change
		-- and not trigger
		on dgv CellValueChanged val do
		(
			if DataGridViewTestOpen == true then
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
							dgv.autoresizecolumns()
						)
						
					2:(
						local thisValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) as integer
						local nextValue = (dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex + 1].value) as integer
						
						if thisValue !=undefined and nextValue != undefined then
						(	
							if (thisValue > nextValue) then 
							(
								Messagebox ("First frame number can't be grater than last frame number.")
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = nextValue as string
							)
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0 as string
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
								(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = prevValue as string
							)
						)
						else
						(
							Messagebox ("Frame number must be an number.")
							(dgv.rows.item[val.RowIndex].cells.item[val.ColumnIndex].value) = 0 as string
						)
					)
					

					
					
				)
			)
		)
		
		/*
		Fn Clear_color=
		(
			for j=0 to 3 do			
			(
				for i=0 to (dgv.rows.count-1) do
				(
					dgv.rows.item[i].cells.item[j].Style.BackColor=undefined
				)
			)
		)
		
		on btn_change_color_01 pressed do
		(
			Clear_color()
			for j=0 to 3 do
			(
				for i=1 to 3 do
				(
					dgv.rows.item[i].cells.item[j].Style.BackColor=change_color
				)
			)	
		)
		on btn_change_color_02 pressed do
		(		
			Clear_color()	
			for j=0 to 3 do
			(
				for i=3 to 5 do
				(
					dgv.rows.item[i].cells.item[j].Style.BackColor=change_color
				)
			)	
		)
		on btn_change_color_03 pressed do
		(
			Clear_color()
			for j=0 to 3 do
			(
				for i=5 to 8 do
				(
					dgv.rows.item[i].cells.item[j].Style.BackColor=change_color
				)
			)	
		)
		*/
  	 )
	 
	try(destroydialogDataGridViewTest )catch()
	createDialog DataGridViewTest
)