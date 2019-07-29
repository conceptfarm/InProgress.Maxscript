
global HelloWorld 
(
	struct HelloWorldStruct
	(
	private
		pos = [800,200],
		size = [200,20],
		menuname = "Hello &World",
		opened = off,
	public
		dialog = 
		(
			rollout dialog "Hello World"
			(
				on dialog open do HelloWorld.open()
				on dialog close do HelloWorld.close()
			)
		),
		fn isOpen = (iskindof dialog RolloutClass and opened),
		fn open = 
		(
			opened = on
			createdialog dialog pos:pos width:size.x height:size.y
			updateToolbarButtons()
		),
		fn close = 
		(
			opened = off
			destroydialog dialog
			updateToolbarButtons()
		),
		fn toggle = if isOpen() then close() else open(),
		
		action =
		(
			macroScript Macro_HelloWorld 
				category:"HelloWorld" 
				tooltip:"Hello World"
				buttonText:"Hi WORLD"
				silentErrors:off
			(
				local d
				fn enabled = isstruct (d = HelloWorld)
				on isEnabled do enabled()
				on isChecked do enabled() and d.isOpen()
				on execute do if enabled() do d.toggle()
			)
		),
		fn createMenu = 
		(
			local menu = menuMan.getMainMenuBar()
			local n = 0, m 
			for k=1 to menu.numitems() where (m = menu.getitem k).getTitle() == menuname do exit with menu.removeitem m
				
			for k=1 to menu.numitems() while n == 0 where (m = menu.getitem k).getTitle() == "&Help" do n = k
			if n != 0 do
			(
				m = menuMan.createMenu menuname
				menu.additem (menuMan.createSubMenuItem menuname m) n

				a = menuMan.createActionItem "Macro_HelloWorld" "HelloWorld"
				a.setUseCustomTitle on
				a.setTitle "Display"
				
				m.addItem a 1
			)
			menuMan.updateMenuBar()
		),
		on create do
		(
			if isstruct HelloWorld do HelloWorld.close()
			createMenu()
			updateToolbarButtons()
		)
	)
	HelloWorld = HelloWorldStruct()
	ok
)