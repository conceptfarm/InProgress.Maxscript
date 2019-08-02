pA = $pointA
pb = $pointB
pC = $pointC
pMid = $PointMid
pNorm = $PointNorm

pA1 = $pointA001
pB1 = $pointB001
pC1 = $pointC001
pMid1 = $PointMid001
pNorm1 = $PointNorm1

pMid.pos = (pB.pos - pC.pos)/2.0 +  pC.pos
pMid1.pos = (pB1.pos - pC1.pos)/2.0 +  pC1.pos

triSize = distance pMid.pos pA.pos
triSize1 = distance pMid1.pos pA1.pos

scaleDif = triSize/triSize1

g = group #($Line006, $Line005, $Line004, $PointMid001, $PointA001, $PointC001, $PointB001) name:"newGroup"
g.pivot = pA1.pos
--g.scale = g.scale * scaleDif
--g.pos = pA.pos

norm = cross (pb.pos-pa.pos) (pc.pos-pa.pos)
norm = normalize norm
norm1 = cross (pb1.pos-pa1.pos) (pc1.pos-pa1.pos)
norm1 = normalize norm1
pNorm.pos = pa.pos + norm
pNorm1.pos = pa1.pos + norm1

--http://help.autodesk.com/view/3DSMAX/2016/ENU/?guid=__files_GUID_1193B0E7_10DF_4D3F_A89F_29FF0A291646_htm
--vector perpendicular to triangle length
norm1B = normalize (cross norm1 (pa1.pos - pmid1.pos))



fn alignUVGizmo theObj theFace =
(
-- First get the face normal vector.
-- It is shown in BLUE on the image
faceNormal = in coordsys theObj (getFaceNormal theObj theFace)

-- This is the desired up vector in world space
-- It is shown in YELLOW on the image
worldUpVector = [0,0,1]

-- Now get the cross-product of the face normal and the up vector.
-- This will give you a vector that is perpendicular to the plane defined
-- by the normal and the up vector. Normalize it to get a normal vector
-- pointing to the right.
-- It is shown in RED on the image
rightVector = normalize (cross worldUpVector faceNormal)

-- Now using the face normal and the new vector,
-- get a vector that is perpendicular to the plane defined by the two.
-- This is the "local up vector", the vector that is the projection of
-- the world up vector on the face you selected. This one is perpendicular
-- to both the face normal and the right vector, and you have 3 normals now
-- that define the X, Y and Z of your new orthogonal coordinate system
-- for the UVW gizmo!
-- Note that this new vector can be seen as the SHADOW of the World Up vector
-- on the face of the object in the above image.
-- It is now displayed in green in the image below:
upVector = normalize ( cross rightVector faceNormal )

-- Using the 3 vectors, define a matrix3 value which represents the
-- coordinate system of the gizmo. The face normal is the Z axis,
-- the right vector is the X axis, and the local up vector is the Y axis:
theMatrix = matrix3 rightVector upVector faceNormal [0,0,0]

theMap = Uvwmap()
modPanel.addModToSelection theMap ui: on
theMap.gizmo.transform = theMatrix
)