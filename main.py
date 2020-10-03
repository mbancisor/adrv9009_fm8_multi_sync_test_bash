import matplotlib.pyplot as plt
import numpy as np
import csv
import time

def measure_phase(chan0, chan1):
    assert len(chan0) == len(chan1)
    errorV = np.angle(chan0 * np.conj(chan1)) * 180 / np.pi
    error = np.mean(errorV)
    return error


with open('samples_master.dat', 'rb') as f1:
    content1 = f1.read()

with open('samples_slave.dat', 'rb') as f2:
    content2 = f2.read()


x1 = np.frombuffer(content1, dtype=np.int16)
x2 = np.frombuffer(content2, dtype=np.int16)

data1 = []
data2 = []

number_of_channels = 8 #16 channels

for i in range(number_of_channels):
    data1.append(np.array([]))
    data2.append(np.array([]))
    data1[i] = np.append(data1[i], x1[i::number_of_channels])
    data2[i] = np.append(data2[i], x2[i::number_of_channels])


rx1rx2 = measure_phase(data1[0], data1[2])
rx1rx3 = measure_phase(data1[0], data1[4])
rx3rx4 = measure_phase(data1[4], data1[6])


rx5rx6 = measure_phase(data2[0], data2[2])
rx5rx7 = measure_phase(data2[0], data2[4])
rx7rx8 = measure_phase(data2[4], data2[6])

rx1rx5 = measure_phase(data1[0], data2[0])

time_start = time.time()
fields=[time_start,rx1rx2,rx1rx3,rx3rx4,rx5rx6,rx5rx7,rx7rx8,rx1rx5]
with open(r'log.csv', 'a') as f:
    writer = csv.writer(f)
    writer.writerow(fields)

print("###########")
print("Same  SOM 1     ", rx1rx2)
print("Across  1       ", rx1rx3)
print("Same F8 1       ", rx3rx4)
print(" ")
print("Same  SOM 2     ", rx5rx6)
print("Across  2       ", rx5rx7)
print("Same F8 2       ", rx7rx8)
print(" ")
print("Across sys 1-2  ", rx1rx5)
print("###########")

if False:
	#plt.subplot(3, 3, (1, 3))
	plt.plot(data1[0][:100], label='1')
	plt.plot(data1[2][:100], label='2')
	plt.plot(data1[4][:100], label='3')
	plt.plot(data1[6][:100], label='4')

	plt.plot(data2[0][:100], label='5')
	plt.plot(data2[2][:100], label='6')
	plt.plot(data2[4][:100], label='7')
	plt.plot(data2[6][:100], label='8')

	plt.legend()
#plt.subplot(3, 3, (4, 6))
#plt.plot(data1[0], label='1')
#plt.plot(np.roll(data1[4], maxlag1), label='2')
#plt.plot(np.roll(data2[0], maxlag12), label='3')
#plt.plot(np.roll(data2[4], maxlag12+maxlag2), label='4')
#plt.legend()
#plt.subplot(3, 3, 7)
#plt.plot(lags, corr1, label='1 - 2')
#plt.legend()
#plt.subplot(3, 3, 8)
#plt.plot(lags, corr2, label='1 - 2')
#plt.legend()
#plt.subplot(3, 3, 9)
#plt.plot(lags, corr12, label='1 - 2')
#plt.legend()


	plt.show(block=False)
	plt.pause(2)
	plt.close()


