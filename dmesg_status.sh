#!/bin/bash

echo "dmesg_log"
file="log_dmesg.txt"
test=$(($1/3))

echo >>$file
echo >>$file
echo "test_nr: $test sample_nr: $1">>$file

echo >>$file
echo "***dmesg:">>$file

dmesg >>$file
dmesg -C
#dmesg |tail -20 |grep -v axi>>$file
