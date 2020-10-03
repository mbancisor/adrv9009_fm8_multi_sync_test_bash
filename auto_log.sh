#!/bin/bash

cd ~/adrv9009_fm8_multi_sync_test_bash
sleep 15
./log.sh 127.0.0.1 10.48.65.98 |&tee -a output.txt

