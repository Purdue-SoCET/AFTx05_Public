#! /usr/bin/python

"""
Name		: Andrew Brito
ECN Login	: mg295
PUID		: 0022761088
Email		: abrito@purdue.edu
Description	: Compile all files related to the debugger project
		  by envoking the 'make new_sim_source' command from
		  the Makefile. Then, automatically open the ModelSim
		  simulation of the design.
"""

import subprocess

#Envoke the "make new_sim_source" command
command = ['make', 'new_sim_source']
make_command = subprocess.Popen(command, stdout=subprocess.PIPE)

#Save the output of this command to a variable
make_output = make_command.communicate()[0]
print make_output

#Split each line and save these in a list variable
line_list = make_output.split('\n')

#Save the "#@vsim" line into a new variable
counter = 0
for line in line_list:
	if "vsim" in line:
		sim_line = line_list[counter].split()
		break
	counter += 1

#Change the first word to "vsim" instead of "#@vsim"
sim_line[0] = "vsim"

#Envoke the ModelSim command
subprocess.Popen(sim_line)
print ""
