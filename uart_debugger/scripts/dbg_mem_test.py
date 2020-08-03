#! /usr/bin/env python2.6

import purdue_serial_debugger

# Written by Kyle and Dr S.
# Version 0.1
# Version 0.2

# TODO:
# Proper logging infrastructure
# CMD line args for serial port settings
# Clean up CRC
# Turn debugger into and object (see clean up CRC)
# Use exception catching to do retries if CRC badA
# Alive needs to timeout and keep on retrying until it gets it
# Create global that gets debugger version assigned and make all bugfixes depend on debugger version:
#	Endianess swap between read and write
#	CRC incorrect in Alive
# Turn into a python lib that can be imported to be used by different debugging programs

	
if __name__ == "__main__":

	d = purdue_serial_debugger.serial_debugger(sim_trace_file="dbg_mem_test_trace")
	
	d.alive()
	
	test_patterns = [0xFFFFFFFF,0x00000000,0x55555555,0xAAAAAAAA]

	num_blocks = 1024 * 256 / 128
	errors = 0

	#Incrementing numbers
	incr = 0
	for i in range(num_blocks):
		base_addr = i*128*4
		#print "Increment: 0x{0:08X} Block: {1:04}/{2:04} Address: 0x{3:08X} Errors: {4}".format(incr, i,num_blocks, base_addr, errors)
		d.set_addr(base_addr)
		test_pattern = range(incr*128, (incr*128)+128)
		d.write(test_pattern)
		d.set_addr(base_addr)
		content = d.read(128)
		#if test_pattern != content:
			#print "Memory mismatch"
			#print "Test"
			#print test_pattern
			#print "Content:"
			#print content
			#errors = errors+1			
		incr = incr+1


	for test_pattern in test_patterns:
		for i in range(num_blocks):
			base_addr = i*128*4
			#print "Pattern:   0x{0:08X} Block: {1:04}/{2:04} Address: 0x{3:08X} Errors: {4}".format(test_pattern, i,num_blocks, base_addr, errors)
			d.set_addr(base_addr)
			d.write([test_pattern] * 128)
			d.set_addr(base_addr)
			content = d.read(128)
			#if [test_pattern] * 128 != content:
				#print "Memory mismatch"
				#print "Test"
				#print [test_pattern] * 128
				#print "Content:"
				#print content
				#errors=errors+1







		
		


