
-- from:https://forums.cgsociety.org/t/resizable-rollout-with-no-borders/1740749
global _user32Assembly
global _user32

fn _CreateUser32Assembly =
(
source = "using System;
"
source += "using System.Runtime.InteropServices;
"
source += "class WinGetSet
"
source += "{
"
source += " [DllImport(\"user32.dll\", EntryPoint=\"SetWindowPos\")]
"
source += " public static extern bool SetWindowPos(Int32 hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);
"
source += "	[DllImport(\"user32.dll\", EntryPoint=\"GetWindowRect\")]
"
source += "	static extern bool GetWindowRect(Int32 hWnd, out POS rect);
"
source += "	public struct POS
"
source += "	{
"
source += "		public int Left;
"
source += "		public int Top;
"
source += "		public int Right;
"
source += "		public int Bottom;
"
source += "	}
"
source += "	public int[] GetWindowPos(Int32 hWnd)
"
source += "	{
"
source += "		POS rect;
"
source += "		if (GetWindowRect(hWnd, out rect))
"
source += "		{
"
source += "			return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };
"
source += "		}
"
source += "		return null;
"
source += "	}
"
source += "}
"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

	compilerParams.ReferencedAssemblies.AddRange #("System.dll")

	compilerParams.GenerateInMemory = true
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	
	_user32Assembly = compilerResults.CompiledAssembly
	_user32 = _user32Assembly.CreateInstance "WinGetSet"

	ok
)
_CreateUser32Assembly()

try (destroydialog boardless) catch()
rollout boardless "boardless dialog" width:300 height:300
(
	local cc = dotnetclass "Cursor"
	local tc = dotnetclass "System.Windows.Forms.Cursors"
	
	local last_size = undefined

	fn getwindowrect =
	(
		if (maxversion())[1] < 16000 then
		(
			ps = _user32.getwindowpos boardless.hwnd
			box2 ps[1] ps[2] ps[3] ps[4]
		)
		else windows.getwindowpos boardless.hwnd
	)
	fn setwindowrect x y w h =
	(
		if (maxversion())[1] < 16000 then
			_user32.setwindowpos boardless.hwnd 0 x y w h 0
		else
			windows.setwindowpos boardless.hwnd x y w h on
	)
	
	spinner width_sp "Width: " type:#integer range:[138,1000,300] fieldwidth:56 align:#right offset:[4,30]
	spinner height_sp "Height: " type:#integer range:[130,1000,300] fieldwidth:56 align:#right offset:[4,0]
	
	checkbutton autoresize_bt "Auto Resize" width:120 align:#right offset:[4,0]
	button close_bt "Close" width:120 align:#right offset:[4,0]
	
	local r_controls = #(width_sp, height_sp, autoresize_bt, close_bt)
	
	fn adjustRightControls controls:r_controls = try
	(
		curr_size = getwindowrect()
		r_controls.pos.x += curr_size.w - last_size.w
		last_size = copy curr_size
	)
	catch()
	
	fn resizeType p = 
	(
		b = getwindowrect()
		print p
		
		print b
		local resizeTriggerBorder = 15
		local windowTitleBarHeight = 28
		case of
		(
			(p.x > resizeTriggerBorder and p.x < b.w - resizeTriggerBorder and p.y > resizeTriggerBorder and p.y < windowTitleBarHeight): 0
			(p.x < resizeTriggerBorder and p.y < resizeTriggerBorder): 1 --top left
			((p.x ) < resizeTriggerBorder and (p.y +windowTitleBarHeight) > (b.h - resizeTriggerBorder)): 2
			((p.x ) > (b.w - resizeTriggerBorder) and (p.y + windowTitleBarHeight) > (b.h - resizeTriggerBorder)): 3 --bottom right
			(p.x > b.w - resizeTriggerBorder and p.y < resizeTriggerBorder): 4 --top right
			(p.x < resizeTriggerBorder): 5 --left
			(p.x > b.w - resizeTriggerBorder): 6 --right
			(p.y < resizeTriggerBorder): 7 -- top
			((p.y + windowTitleBarHeight) > b.h - resizeTriggerBorder): 8 -- bottom
		default: -1
		)
	)
	fn setCursor cursorType: p: = 
	(
		if cursorType == unsupplied do cursorType = resizeType p
		s = case cursorType of
		(
			0: tc.Hand
			1: tc.SizeNWSE
			2: tc.SizeNESW
			3: tc.SizeNWSE
			4: tc.SizeNESW
			5: tc.SizeWE
			6: tc.SizeWE
			7: tc.SizeNS
			8: tc.SizeNS
	  default: setArrowCursor()
		)
		if (s != ok) and cc.Current != s do cc.Current = s
	)
		
	fn resizeDialog = 
	(
		last_size = getwindowrect()
		setwindowrect last_size.x last_size.y width_sp.value height_sp.value
	)
	
	on width_sp changed val do if autoresize_bt.state do resizeDialog()
	on height_sp changed val do if autoresize_bt.state do resizeDialog()
	on width_sp entered arg can do if not can do resizeDialog()
	on height_sp entered arg can do if not can do resizeDialog()
	
	on close_bt pressed do destroydialog boardless
	
	local last_mouse = undefined
	local dialog_pos = undefined
	local resize_mode = -1
	
	on boardless mousemove p do
	(
		--print mouse.screenpos 
		if resize_mode == -1 then setCursor p:p
		else
		(
			b = copy dialog_pos
			d = last_mouse - mouse.pos

			case resize_mode of
			(
				0: setwindowrect (b.x - d.x) (b.y - d.y) b.w b.h
				1: setwindowrect (b.x - d.x) (b.y - d.y) (b.w + d.x) (b.h + d.y)
				2: setwindowrect (b.x - d.x) b.y (b.w + d.x) (b.h - d.y)
				3: setwindowrect b.x b.y (b.w - d.x) (b.h - d.y)
				4: setwindowrect b.x (b.y - d.y) (b.w - d.x) (b.h + d.y)
				5: setwindowrect (b.x - d.x) b.y (b.w + d.x) b.h
				6: setwindowrect b.x b.y (b.w - d.x) b.h
				7: setwindowrect b.x (b.y - d.y) b.w (b.h + d.y)
				8: setwindowrect b.x b.y b.w (b.h - d.y)
			)
		)
	)
	on boardless lbuttondown p do
	(
		last_mouse = mouse.pos
		dialog_pos = getwindowrect()
		resize_mode = resizeType p
		--print resize_mode
		setCursor cursorType:resize_mode
	)
	on boardless lbuttonup p do
	(
		resize_mode = -1
	)
	
	on boardless resized size do
	(
		adjustRightControls()
	)
	on boardless open do
	(
		last_size = getwindowrect()
	)
)
createdialog boardless --style:#()