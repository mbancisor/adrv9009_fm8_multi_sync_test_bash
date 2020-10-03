#!/bin/bash

echo "jesd_log"
file="log_jesd.txt"
test=$(($1/3))

echo >>$file
echo >>$file
echo "test_nr: $test sample_nr: $1">>$file

cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/status>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane0_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane1_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane2_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane3_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane4_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane5_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane6_info>>$file
cat /sys/devices/platform/fpga-axi\@0/84a50000.axi-jesd204-rx/lane7_info>>$file

echo >>$file
echo "***talise temperatures:">>$file
iio_attr -c adrv9009-phy temp0 input>>$file
iio_attr -c adrv9009-phy-b temp0 input>>$file
iio_attr -c adrv9009-phy-c temp0 input>>$file
iio_attr -c adrv9009-phy-d temp0 input>>$file
 
echo >>$file
echo "***HMC7044 VCO regs som fm8 car:">>$file
iio_reg hmc7044 0x8c>>$file
iio_reg hmc7044-fmc 0x8c>>$file
iio_reg hmc7044-car 0x8c>>$file
iio_reg hmc7044-ext 0x8c>>$file

echo >>$file
echo "***talise LOs:">>$file
iio_attr -c adrv9009-phy TRX_LO frequency>>$file
iio_attr -c adrv9009-phy-b TRX_LO frequency>>$file
iio_attr -c adrv9009-phy-c TRX_LO frequency>>$file
iio_attr -c adrv9009-phy-d TRX_LO frequency>>$file

echo >>$file
echo "***talise reg 0x181:">>$file
iio_reg adrv9009-phy 0x181>>$file
iio_reg adrv9009-phy-b 0x181>>$file
iio_reg adrv9009-phy-c 0x181>>$file
iio_reg adrv9009-phy-d 0x181>>$file
