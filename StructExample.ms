struct aBox
(
	aWidth,aHeight,aLength,obj,
	fn aVol = return (aWidth*aHeight*aLength),
	fn printVol = print (aVol() as string)
)

struct allaBox
(
	all = #()
)


aB = allabox all:(for o in objects where classof o == box collect aBox aWidth:o.width aHeight:o.height aLength:o.length obj:o)


struct modCams
(
	--firstFrame,lastFrame,
	cam, animID,
	fn getFrameRange = (setProperty cam.modifiers[#MultiCam_Attribute] #getFrameRange_btn true),
	fn useHideLayers state = (setproperty cam.modifiers[#MultiCam_Attribute] #useHideLayers_chb state),
	fn clearLayers state = (setproperty cam.modifiers[#MultiCam_Attribute] #clearLayers_btn state),
	fn useSunpoints state = (setproperty cam.modifiers[#MultiCam_Attribute] #useSunpoints_chb state),
	fn useHeightWidth state = (setproperty cam.modifiers[#MultiCam_Attribute] #useHeightWidth_chb state)
)

struct allModCams
(
	
	all = #()
)

aC = allModCams all:(for o in objects where (superclassof o == camera and o.modifiers[#MultiCam_Attribute] != undefined) collect modCams cam:o animID:(GetHandleByAnim o))
ac.all[1].getFrameRange()
ac.all[1].useHideLayers true
ac.all[1].useHeightWidth true