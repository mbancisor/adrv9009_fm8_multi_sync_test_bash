import matplotlib
#matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from numpy import genfromtxt
my_data = genfromtxt('log.csv', delimiter=',')
rx1rx2 = my_data[:,1]
rx1rx3 = my_data[:,2]
rx3rx4 = my_data[:,3]

rx5rx6 = my_data[:,4]
rx5rx7 = my_data[:,5]
rx7rx8 = my_data[:,6]

rx1rx5 = my_data[:,7]

#data = np.loadtxt("1.txt", delimiter="\n")
#jesd = np.reshape(data,(-1,16))

plt.figure(1)
plt.plot(rx1rx2, label="Same SOM 1")
plt.plot(rx1rx3, label="Across 1")
plt.plot(rx3rx4, label="Same F8 1")

plt.legend()
plt.draw()
plt.figure(2)
plt.plot(rx5rx6, label="Same  SOM 2")
plt.plot(rx5rx7, label="Across 2")
plt.plot(rx7rx8, label="Same  F8 2 ")

plt.legend()
plt.draw()
plt.figure(3)
plt.plot(rx1rx5, label="Across Systems 1-2")


plt.legend()
plt.draw()









#plt.plot(jesd[:,0], label="SOM A 0")
#plt.plot(jesd[:,2], label="SOM A 1")
#plt.plot(jesd[:,4], label="SOM A 2")
#plt.plot(jesd[:,6], label="SOM A 3")
#plt.plot(jesd[:,8], label="SOM B 0")
#plt.plot(jesd[:,10], label="SOM B 1")
#plt.plot(jesd[:,12], label="SOM B 2")
#plt.plot(jesd[:,14], label="SOM B 3")

#plt.legend()
#plt.draw()
#plt.figure(3)

#plt.plot(jesd[:,1], label="SOM A 0")
#plt.plot(jesd[:,3], label="SOM A 1")
#plt.plot(jesd[:,5], label="SOM A 2")
#plt.plot(jesd[:,7], label="SOM A 3")
#plt.plot(jesd[:,9], label="SOM B 0")
#plt.plot(jesd[:,11], label="SOM B 1")
#plt.plot(jesd[:,13], label="SOM B 2")
#plt.plot(jesd[:,15], label="SOM B 3")
#plt.legend()
#plt.draw()
plt.show()

