#!/bin/bash
master_IP=$1
slave_IP=$2

pwd
cd ~/adrv9009_fm8_multi_sync_test_bash
pwd
acq_per_run=3

if [ -f "nr_runs.txt" ]; then
    prev_runs=$(cat nr_runs.txt)
    echo "continuing $prev_runs"
else 
    echo "new test"
    prev_runs=1
fi
#export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages
total_runs=$prev_runs
for i in {1..3}
do

	echo "run $((total_runs)) times"
	echo "$(((total_runs)*acq_per_run)) samples"

        ./check_multi.sh $master_IP $slave_IP
        wait
	./jesd_status.sh $(((total_runs)*acq_per_run))
	sshpass -p 'analog' ssh root@$slave_IP 'bash -s' < ./jesd_status.sh $(((total_runs)*acq_per_run))
	sshpass -p 'analog' scp root@$slave_IP:log_jesd.txt ./log_jesd_slave.txt 
	wait
	./dmesg_status.sh $(((total_runs)*acq_per_run))
	sshpass -p 'analog' ssh root@$slave_IP 'bash -s' < ./dmesg_status.sh $(((total_runs)*acq_per_run))
	sshpass -p 'analog' scp root@$slave_IP:log_dmesg.txt ./log_dmesg_slave.txt 
	wait
	./check_multi_data.sh $master_IP $slave_IP
	wait
        ./check_multi_data.sh $master_IP $slave_IP
        wait
        ./check_multi_data.sh $master_IP $slave_IP
        wait

	total_runs=$((i+prev_runs))
	echo $total_runs>nr_runs.txt
done

sshpass -p 'analog' ssh root@$slave_IP poweroff
#python3 PDU.py 10.48.65.107 1 delayedReboot
#python3 PDU.py 10.48.65.107 2 delayedReboot
#python3 PDU.py 10.48.65.107 3 delayedReboot
python3 PDU.py 10.48.65.107 5 delayedReboot
python3 PDU.py 10.48.65.107 6 delayedReboot
python3 PDU.py 10.48.65.107 7 delayedReboot
poweroff
#reboot
