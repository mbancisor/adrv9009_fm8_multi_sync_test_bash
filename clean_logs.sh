#!/bin/bash
slave_IP=$1

rm nr_runs.txt log.csv log_dmesg.txt log_jesd.txt log_dmesg_slave.txt log_jesd_slave.txt output.txt 

sshpass -p 'analog' ssh $slave_IP rm log_dmesg.txt log_jesd.txt 

