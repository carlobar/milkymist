# Synthesis tool. Options are "xst", "synplify" and "precision"
if [ -z "$SYNTOOL" ]
then
	SYNTOOL=xst
fi

# Board name (name of the subfolder of the "boards" folder)
if [ -z "$BOARD" ]
then
	BOARD=digilent-xc3s500e
fi

