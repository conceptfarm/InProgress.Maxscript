struct aBox
(
	aWidth,aHeight,aLength,
	fn aVol = return (aWidth*aHeight*aLength),
	fn printVol = print (aVol() as string)
)

struct allaBox
(
	all = #()
)

aB = allabox all:(for o in objects where classof o == box collect aBox aWidth:o.width aHeight:o.height aLength:o.length)