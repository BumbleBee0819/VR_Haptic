# -*- coding: utf-8 -*-
"""
Wenyan Bi

This is a temporary script file.
"""

import random
import csv
import os


dir_path = os.path.dirname(os.path.realpath(__file__))
repeat = 1
material = ["Wool", "ShinyCopper", "Marble", "Foam", "Wood", "WickerBasket", "Cloth", "CorrodedMetal"]
mass = [0.1, 0.3, 0.5, 0.7, 1.0]
scale =[[0.5, 0.5, 0.5], [0.75, 0.75, 0.75], [1.0, 1.0, 1.0]]

n_material = len(material)
n_mass = len(mass)
n_scale = len(scale)
n_total = n_material * n_mass * n_scale

dicts = {}
i = 0
for j in material:
    for k in mass:
        for m in scale:
            dicts[i] = [[j], [k], m]
            i += 1
                
                
# random number
random_list = []
for i in range(repeat):
    random_tmp = range(n_total)
    random_list += random_tmp
    
    
random.shuffle(random_list)
    

    
# output mass
output_mass = [0] * n_total * repeat
# output scale
output_scale = [0] * n_total * repeat
# output material
output_material = [0] * n_total * repeat
    
    
for i in range(n_total * repeat):
    output_material[i] = dicts[random_list[i]][0]
    output_mass[i] = dicts[random_list[i]][1]
    output_scale[i] = dicts[random_list[i]][2]
    
    

# # to generate for chair_diffuse
# chair_list = ['2', '3']
# for i in range(len(output_material)):
#     if output_material[i][0] == 'Chair_diffuse': 
#         output_material[i][0] = output_material[i][0] + random.choice(chair_list)
    
    
##
outputname_material = "cup_material.txt"
myfile = open (os.path.join(dir_path, '') + outputname_material, 'w')
with myfile:
    writer = csv.writer(myfile, delimiter=" ", lineterminator='\n')
    writer.writerows(output_material)


##
outputname_mass = "cup_mass.txt"
myfile = open (os.path.join(dir_path, '') + outputname_mass, 'w')
with myfile:
    writer = csv.writer(myfile, delimiter=" ", lineterminator='\n')
    writer.writerows(output_mass)
    
##
outputname_scale = "cup_scale.txt"
myfile = open (os.path.join(dir_path, '') + outputname_scale, 'w')
with myfile:
	writer = csv.writer(myfile, delimiter=" ", lineterminator='\n')
	writer.writerows(output_scale)



    
