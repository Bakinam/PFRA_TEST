#A script to  just run hecras as is
sim_name=$1

RAS_BIN_PATH="/home/ubuntu/bin-v508"
export LD_LIBRARY_PATH=$RAS_BIN_PATH;$LD_LIBRARY_PATH
$RAS_BIN_PATH/rasUnsteady64 $sim_name.c01 b01 
#mv $sim_name.p01.tmp.hdf $sim_name.p01.hdf

