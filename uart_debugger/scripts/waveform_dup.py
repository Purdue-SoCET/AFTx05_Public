#!/usr/bin/python

"""
Name:                 Chuan Yean Tan
ECN Login:            mg296
PUID:                 0024209781
Email:                tan56@purdue.edu
Description: 	      Copy waveforms from an existing testbench and creating a 
		      similar testbench
"""


import os
import sys
import string
import re

if len(sys.argv) < 4: 
	print "[Error]	: Too few arguments. \n[Usage]	: ./waveform_dup.py [waveform].do [old testbench] [new testbench]"
else:
	pre_waveform 	= sys.argv[1]	#dot do file that is copied from
	old_testbench 	= sys.argv[2]	
	new_testbench 	= sys.argv[3]
	
	testbench_name = "%s.do" %(sys.argv[3])

	#Read from old waveform
	try: 
		fp = open(pre_waveform,"r")
	except IOError: 
		print "[Error]	: Could not open file %s. \n[Usage]	: ./waveform_dup.py [waveform].do" %(pre_waveform)
		sys.exit()
	
	#Edit new waveform
	try: 
		fp2 = open(testbench_name,"w")
	except IOError: 
		print "[Error]	: Could not open file %s. \n[Usage]	: ./waveform_dup.py [waveform].do" %(new_testbench)
		sys.exit()
	
	print "Old testbench : %s" %old_testbench 
	print "New testbench : %s" %new_testbench


	for line in fp:
		if re.search(old_testbench,line):
			#Replace old testbench's name with new test bench's name
			line = line.replace(old_testbench, new_testbench)
			fp2.write(line)
		else:
			fp2.write(line)

	fp.close()
	fp2.close()
	sys.exit()
