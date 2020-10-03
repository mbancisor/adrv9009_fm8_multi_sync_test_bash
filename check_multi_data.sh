#!/bin/bash

export IIOD_MASTER=$1
export IIOD_SLAVE=$2

samples=1024
buffers=1024

function arm_DMA {

  
#arm master DMA
# ADD LIMITS on the number of retries
iio_reg -u ip:$IIOD_MASTER axi-adrv9009-rx-hpc 0x80000044 0x8 || return 1
var=$(iio_reg -u ip:$IIOD_MASTER axi-adrv9009-rx-hpc 0x80000068) || return 1
while [ $var == "0x0" ] 
do
        iio_reg -u ip:$IIOD_MASTER axi-adrv9009-rx-hpc 0x80000044 0x8 || return 1
        var=$(iio_reg -u ip:$IIOD_MASTER axi-adrv9009-rx-hpc 0x80000068) || return 1
        echo .
done
#arm slave DMA
iio_reg -u ip:$IIOD_SLAVE axi-adrv9009-rx-hpc 0x80000044 0x8 || return 1
var=$(iio_reg -u ip:$IIOD_SLAVE axi-adrv9009-rx-hpc 0x80000068) || return 1
while [ $var == "0x0" ] 
do
        iio_reg -u ip:$IIOD_SLAVE axi-adrv9009-rx-hpc 0x80000044 0x8 || return 1
        var=$(iio_reg -u ip:$IIOD_SLAVE axi-adrv9009-rx-hpc 0x80000068) || return 1
        echo .
done
}

# Delete previous sample files and create empty ones so Python shows "NaN" @ failures
if [ -f "samples_master.dat" ]; then
        rm samples_master.dat
        touch samples_master.dat
else
        touch samples_master.dat
fi
if [ -f "samples_slave.dat" ]; then
        rm samples_slave.dat
        touch samples_slave.dat
else
        touch samples_slave.dat
fi

echo "arm DMA"
arm_DMA
while [ $? -gt 0 ];
do
        echo "Retried arm_DMA"
        arm_DMA
done


echo "MASTER data: (ip:$IIOD_MASTER)"
iio_readdev -u ip:$IIOD_MASTER -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_master.dat &
pid_master=$!
echo "SALVE data: (ip:$IIOD_SLAVE)"
iio_readdev -u ip:$IIOD_SLAVE -b $buffers -s $samples -T 10000 axi-adrv9009-rx-hpc voltage0_i voltage0_q voltage2_i voltage2_q voltage4_i voltage4_q voltage6_i voltage6_q > samples_slave.dat &
pid_slave=$!

#does NOT work without this delay
sleep 1 #why is it needed?????          
iio_attr  -u ip:$IIOD_MASTER -d hmc7044-ext sysref_request 1 || exit


#wait for the data to get captured
while kill -0 $pid_master &> /dev/null ; do
        echo "Waiting for master sample data"
        sleep 1
done

while kill -0 $pid_slave &> /dev/null ; do
        echo "Waiting for slave sample data"
        sleep 1
done

echo "process samples"
python3 main.py
while [ $? -gt 0 ];
do
        echo "Retried process samples"

	# Delete previous sample files and create empty ones so Python shows "NaN" @ failures
	#python will fail if only one of the boards received data
	#Proper way to implement would be to execute all steps from this file again
	if [ -f "samples_master.dat" ]; then
        	rm samples_master.dat
        	touch samples_master.dat
	else
        	touch samples_master.dat
	fi
	if [ -f "samples_slave.dat" ]; then
        	rm samples_slave.dat
        	touch samples_slave.dat
	else
        	touch samples_slave.dat
	fi

        python3 main.py
done





