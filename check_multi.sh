#!/bin/bash

export IIOD_MASTER=$1
export IIOD_SLAVE=$2

#LO=1228800000

LO=1000000000

samples=1024
buffers=1024


function config {
### Configure ADRVs....used for testing.
        iio_attr -u ip:$1 -c adrv9009-phy TRX_LO frequency $LO || resync || return 1
        iio_attr -u ip:$1 -c adrv9009-phy TRX_LO frequency $LO  || return 1
        iio_attr -u ip:$1 -c adrv9009-phy-b TRX_LO frequency $LO || return 1

        iio_attr -u ip:$1 -c adrv9009-phy-c TRX_LO frequency $LO || return 1
        iio_attr -u ip:$1 -c adrv9009-phy-d TRX_LO frequency $LO || return 1

        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_I_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_Q_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_I_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_Q_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_I_F1 frequency 7000000 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_Q_F1 frequency 7000000 || return 1

        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_I_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_Q_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_I_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_Q_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_I_F2 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_Q_F2 scale 0 || return 1
#Disable DDS so it doesn't affect calib
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_I_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_Q_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_I_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_Q_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_I_F1 scale 0 || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_Q_F1 scale 0 || return 1
}

function dds_on {
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_I_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX3_Q_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_I_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX5_Q_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_I_F1 scale '0.25' || return 1
        iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX7_Q_F1 scale '0.25' || return 1
}

function resync {
        # restart HMC7044 dividers (only used for test)			#
        #pause FSM before resetting clock chips
	iio_jesd204_fsm_sync -p -d adrv9009-phy -u ip:$IIOD_MASTER ip:$IIOD_SLAVE || return 1
        sleep 0.1
	iio_reg -u ip:$IIOD_MASTER hmc7044 0x1 0x61 || return 1   	#
        iio_reg -u ip:$IIOD_MASTER hmc7044-fmc 0x1 0x61	|| return 1	#
        iio_reg -u ip:$IIOD_MASTER hmc7044-car 0x1 0x01	|| return 1	#
        iio_reg -u ip:$IIOD_MASTER hmc7044-ext 0x1 0x01	|| return 1	#
									#
        iio_reg -u ip:$IIOD_SLAVE hmc7044 0x1 0x61 || return 1		#
        iio_reg -u ip:$IIOD_SLAVE hmc7044-fmc 0x1 0x61 || return 1	#
        iio_reg -u ip:$IIOD_SLAVE hmc7044-car 0x1 0x01	|| return 1	#
        sleep 0.1							#
        iio_reg -u ip:$IIOD_MASTER hmc7044-ext 0x1 0x00	|| return 1	#
        iio_reg -u ip:$IIOD_MASTER hmc7044-car 0x1 0x00	|| return 1	#
        iio_reg -u ip:$IIOD_MASTER hmc7044 0x1 0x60 || return 1		#
        iio_reg -u ip:$IIOD_MASTER hmc7044-fmc 0x1 0x60	|| return 1	#
									#
        iio_reg -u ip:$IIOD_SLAVE hmc7044-car 0x1 0x00 || return 1	#
        iio_reg -u ip:$IIOD_SLAVE hmc7044 0x1 0x60 || return 1		#
        iio_reg -u ip:$IIOD_SLAVE hmc7044-fmc 0x1 0x60 || return 1	#
	#########################################################
        sleep 0.5

        iio_jesd204_fsm_sync -d adrv9009-phy -u ip:$IIOD_MASTER ip:$IIOD_SLAVE || return 1
        iio_attr  -u ip:$IIOD_MASTER -d hmc7044-ext sysref_request 1 || return 1
        sleep 1
        iio_attr  -u ip:$IIOD_MASTER -d hmc7044-ext sysref_request 1 || return 1
}

echo "Config MASTER: (ip:$IIOD_MASTER)"
config $IIOD_MASTER
while [ $? -gt 0 ];
do
	echo "Retried Config Master"
	config $IIOD_MASTER
done

echo "Config SALVE: (ip:$IIOD_SLAVE)"
config $IIOD_SLAVE
while [ $? -gt 0 ];
do
	echo "Retried Config Slave"
	config $IIOD_SLAVE
done

resync
while [ $? -gt 0 ];
do
        echo "Retried resync"
	resync
done


dds_on $IIOD_MASTER
while [ $? -gt 0 ];
do
        echo "Retried DDS master ON"
	dds_on $IIOD_MASTER
done

dds_on $IIOD_SLAVE
while [ $? -gt 0 ];
do
        echo "Retried DDS slave ON"
	dds_on $IIOD_SLAVE
done

# ISSUE SYSREF here???

sleep 0.2
iio_attr  -u ip:$IIOD_MASTER -d hmc7044-ext sysref_request 1 || exit
#sleep 0.5
