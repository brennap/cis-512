#!/usr/bin/python3.5

# import csv

file = open("/home/brennapj/Documents/SFHREOData.csv")

#csv.reader(file)
town = []
state = []

for line in file:
    if "**" not in line:
        splitline = line.split(',')
        if len(splitline[0]) < 20:
            town.append(splitline[0])
            state.append(splitline[1])

    #print splitline
print(town)