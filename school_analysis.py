#!/usr/bin/python3.5

#file = open("/home/brennapj/Downloads/Most+Recent+Cohorts+(Scorecard+Elements).csv")

#header = file.next().strip().split(",")

#for line in file:

import csv
import numpy as np
import matplotlib.pyplot as plt

myFile = open("/home/brennapj/Downloads/testFile.csv", "rt")
reader = csv.reader(myFile)
myList = []
for row in reader:
    myList.append(row)

myFile.close()

#print(myList)

myArray = np.asarray(myList)
bugsIn= np.flatnonzero(myArray[0,:] == 'bugs')
#print(myArray[0,:] == 'bugs')
bugs = myArray[1:, bugsIn].astype(np.float)
#print(bugs)
#print(bugs.squeeze())

frogIn= np.flatnonzero(myArray[0,:] == 'frog')
#print(myArray[0,:] == 'frog')
frog = myArray[1:, frogIn].astype(np.float)
#print(frog)

myFit = np.polyfit(bugs.squeeze(),frog.squeeze(),1,None,True,None,True)
frogPred = myFit[0][0]*bugs+myFit[0][1]

fig_myFit = plt.figure()
ax_myFit = fig_myFit.add_subplot(111)
ax_myFit.plot(bugs,frog,'o',color = 'r',label = 'Original Data')
linearFit = ax_myFit.plot(bugs,frogPred,color = 'k',label = 'Linear Fit')
ax_myFit.grid(True)
ax_myFit.set_xlabel('bug units')
ax_myFit.set_ylabel('frog units')
ax_myFit.set_title('bugs vs. frog')
ax_myFit.legend()

plt.show()