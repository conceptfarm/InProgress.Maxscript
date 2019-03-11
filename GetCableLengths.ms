for o in objects where classof o == Line do
(
	print (o.name +": " + units.formatValue (curveLength o 1) )
)