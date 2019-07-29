(
	global someRollout
	try(destroydialog someRollout)catch(print "????")
	
	local pics =#("C:\\temp\\img\\01.jpg","C:\\temp\\img\\02.jpg","C:\\temp\\img\\03.jpg","C:\\temp\\img\\04.jpg","C:\\temp\\img\\05.jpg")
	
	rollout someRollout "test" width:500 height:500
	(
		--button btn "something"
		--dotnetcontrol pb "PictureBox" width:1 height:1
		dotnetcontrol fl "FlowLayoutPanel" width:someRollout.width height:someRollout.height pos:[0,0]
		
		fn whenButtonIsPressed a b = 
		(
 			local mat = VrayMtl()
 			local bT = bitmapTexture()
 			bT.fileName = ((a.ImageLocation))
 			mat.texmap_diffuse = bT
			setMeditMaterial 1 mat
			try(destroydialog someRollout)catch(print "????")
		)
		
		fn paintEvent a b =
		(
			print a
			print b
			
		)
		
		on someRollout open do
		(
			local oddColor=(dotnetclass "system.drawing.color").fromARGB 68 68 68  	
			for f in pics do
			(
				local gB = (dotnetobject "System.Windows.Forms.GroupBox")
				gb.FlatStyle = (dotnetclass "System.Windows.Forms.FlatStyle").Flat;
				gb.Height = 128;
				gb.Width = someRollout.width-30;
				gb.text = f
				gb.BackColor = oddColor
				gb.ForeColor = (dotnetclass "system.drawing.color").fromARGB 255 255 255
				--gb.font = (dotnetClass "System.Drawing.Font").size 12
				--gb.font.size = 12
				local pb = dotnetobject "PictureBox"
				pb.BackColor = oddColor
				pb.SizeMode = (dotnetclass "PictureBoxSizeMode").Zoom
				pb.Height = 108;
				pb.Width = someRollout.width-30;
				pb.imageLocation =  f
				pb.Dock = pb.Dock.Bottom
				
				--dotNet.addEventHandler gb "paint" paintEvent
				dotNet.addEventHandler pb "click" whenButtonIsPressed
				gB.controls.add pb
				fl.controls.add gB
			)
			
			fl.AutoScroll = true;
			fl.BackColor = oddColor
			fl.BorderStyle = (dotnetclass "System.Windows.Forms.BorderStyle").Fixed3D;
			fl.CausesValidation = false;
			fl.Dock = (dotnetclass "System.Windows.Forms.DockStyle").Fill;
			
			--fl.AutoScaleDimensions = (dotnetclass "System.Drawing.SizeF") [6.0, 13.0]
			--fl.AutoScaleMode = (dotnetclass "System.Windows.Forms.AutoScaleMode").Font
			--fl.AutoValidate = (dotnetclass "System.Windows.Forms.AutoValidate").EnableAllowFocusChange
			--fl.BackColor = (dotnetclass "System.Drawing.SystemColors").ControlLightLight
			--fl.DoubleBuffered = true
			--pb.Name = "ImageViewer"
			
			--fl.Location = new System.Drawing.Point(0, 0);
			fl.Name = "flowLayoutPanelMain";
			--fl.Size = new System.Drawing.Size(611, 451);
			fl.TabIndex = 0;
			
			
			
			
			/*
			PictureBox imageViewer = new PictureBox();
			imageViewer.Image = Image.FromFile(imageFilename);
			imageViewer.SizeMode = PictureBoxSizeMode.Zoom;
			imageViewer.Dock = DockStyle.Bottom;
			imageViewer.Height = 128;
			imageViewer.Width = 128;
			flowLayoutPanelMain.Controls.Add(imageViewer);
			*/
		)
	)
	createDialog someRollout
)
