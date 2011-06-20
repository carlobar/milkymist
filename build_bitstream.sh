#!/bin/bash

source setup.inc
BASEDIR=`pwd`
LOGFILEHOST=$BASEDIR/tools.log
LOGFILE=$BASEDIR/synthesis.log
export  XIL_PLACE_ALLOW_LOCAL_BUFG_ROUTING=1

echo "================================================================================"
echo "Building Milkymist bitstream file"
echo ""
echo "Synthesis tool: $SYNTOOL"
echo "Board:          $BOARD"
echo "Log file:       $LOGFILE"
echo "================================================================================"
echo ""
rm -f $LOGFILE
echo -n "Building host utilities..."
cd $BASEDIR/tools
echo >> $LOGFILEHOST
date >> $LOGFILEHOST
make >> $LOGFILEHOST 2>&1
if [ "$?" != 0 ] ; then
        echo "FAILED"
	exit 1
else
        echo "OK"
fi

echo -n "Building FPGA bitstream..."
echo >> $LOGFILE
date >> $LOGFILE
cd $BASEDIR/boards/$BOARD/synthesis && make -f Makefile.$SYNTOOL >> $LOGFILE 2>&1
if [ "$?" != 0 ] ; then
        echo "FAILED"
	exit 1
else
        echo "OK"
fi

cd $BASEDIR

echo "Build complete!"
