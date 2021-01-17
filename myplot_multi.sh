export IIOD_MASTER=$1
export IIOD_SLAVE=$2

samples=1024
buffers=1024

LO=1000000000

function config {
### Configure ADRVs....used for testing.
	iio_attr -u ip:$1 -c adrv9009-phy TRX_LO frequency $LO || resync || exit
	iio_attr -u ip:$1 -c adrv9009-phy TRX_LO frequency $LO  || exit
	iio_attr -u ip:$1 -c adrv9009-phy-b TRX_LO frequency $LO || exit

	iio_attr -u ip:$1 -c adrv9009-phy-c TRX_LO frequency $LO || exit
	iio_attr -u ip:$1 -c adrv9009-phy-d TRX_LO frequency $LO || exit

	iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F1 frequency 15000000 || exit
	iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F1 frequency 15000000 || exit

	iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_I_F2 scale 0 || exit
	iio_attr -u ip:$1 -c axi-adrv9009-tx-hpc TX1_Q_F2 scale 0 || exit
}

function resync {
	iio_jesd204_fsm_sync -d adrv9009-phy -u ip:$IIOD_MASTER ip:$IIOD_SLAVE || exit
	iio_attr  -u ip:$IIOD_MASTER -d hmc7044-ext sysref_request 1 || exit
}

echo "Config MASTER: (ip:$IIOD_MASTER)"
config $IIOD_MASTER
echo "Config SALVE: (ip:$IIOD_SLAVE)"
config $IIOD_SLAVE

resync

while [ 1 ]
do
	echo "MASTER: (ip:$IIOD_MASTER)"
	iio_readdev -u ip:$IIOD_MASTER -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_master.dat  || exit

	sleep 0.05
	python3 main.py

	iio_readdev -u ip:$IIOD_MASTER -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_master.dat  || exit

	sleep 0.05
	python3 main.py

	echo
	echo "SALVE: (ip:$IIOD_SLAVE)"
	iio_readdev -u ip:$IIOD_SLAVE -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_master.dat || exit

	sleep 0.05
	python3 main.py

	iio_readdev -u ip:$IIOD_SLAVE -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_master.dat || exit

	sleep 0.05
	python3 main.py

	resync

	sleep 2
done
