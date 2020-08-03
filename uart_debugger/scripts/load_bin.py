#! /usr/bin/env python2.6

import purdue_serial_debugger
import os 
import sys 
import struct
import time

# Written by Dr S.
# Version 0.1
# Version 0.2 Kyle - Added usage check and file check

# TODO:
# Migrate "verified read" into serial_debugger object and add pretty print as hex into it as useful

	
if __name__ == "__main__":
	# Check for valid usage
	if len(sys.argv) > 4 or len(sys.argv) < 2:
		print("Usage: load_bin.py <file.bin> [port] [baud rate]")
		sys.exit(1)
	
	if not os.path.exists(sys.argv[1]):
		print("No such file: "+sys.argv[1])
		sys.exit(2)
	
	# Assign the appropriate parameters
	binFile = sys.argv[1]
	port_name = "/dev/ttyS1"
	baud_rate = 115200
	if len(sys.argv) == 4:
		port_name = sys.argv[2]
		baud_rate = sys.argv[3]
	elif len(sys.argv) == 3:
		port_name = sys.argv[2]
	
	d = purdue_serial_debugger.serial_debugger(port=port_name, baud_rate=baud_rate)
	
	d.alive()
	d.core_hold_reset()
	
	f = open(binFile, "rb")
	image = f.read()

	num_blocks = len(image) / (128*4)
	remainder = len(image) - num_blocks * 128
	convu32 = struct.Struct('<I')

	errors = 0
	#Incrementing numbers
	for i in range(num_blocks+1):
		base_addr = i*128*4
		print "Block: {0:04}/{1:04} Address: 0x{2:08X} Errors: {3}".format(i,num_blocks, base_addr, errors)
		d.set_addr(base_addr)
		if i < num_blocks+1:
			raw_image_block = image[i*128*4:(i+1)*128*4]
		else:
			raw_image_block = image[i*128*4:-1]
		image_block = []
		for j in range(len(raw_image_block)/4):
			image_block.append(convu32.unpack(raw_image_block[j*4:(j+1)*4])[0])
		#print ', '.join("0x{0:08X}".format(b) for b in image_block)
		#print len(image_block)
		d.write(image_block)
		d.set_addr(base_addr)
		content = d.read(len(image_block)+8)
		if image_block != content[:-8]:
			print "Memory mismatch"
			print "Test"
			print image_block
			print "Content:"
			print content
			errors = errors+1			


	d.core_release_reset()
	time.sleep(1)
	#d.core_hold_reset()
	d.set_addr(0x5f8)
	dump = d.read(255)
	print ', '.join("0x{0:08X}".format(b) for b in dump)
	#Dump from top of stack 0x400000
	d.set_addr(0x400000-255)
	dump = d.read(255)
	print ', '.join("0x{0:08X}".format(b) for b in dump)
	

