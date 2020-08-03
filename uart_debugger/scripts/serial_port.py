#! /usr/bin/env python2.6
import serial, time
import binascii

def alive():
	print "Alive: "
        ser.write('\x86')  
        rx = bytearray()
        rx = ser.read(size=1)
        print "RX: " + rx.encode("hex") 
	rx = ser.read(size=1)
	print "CRC: " + rx.encode("hex")
	

def set_count():
	print "Set Count: "
        ser.write(chr(0x82))
        ser.write(chr(count))
	rx = bytearray()
        rx = ser.read(size=1)
        print "CRC: " + rx.encode("hex")

def set_addr():
	print "Set Addr: "
        ser.write('\x83')
	for byte in addr:
        	ser.write(byte)
        rx = bytearray()
        rx = ser.read(size=1)
        print "CRC: " + rx.encode("hex")

def write():
	print "Write: "
        ser.write('\x85')
	for i in range(count):
		for byte in data[i]:
			ser.write(byte)
	rx = bytearray()
        rx = ser.read(size=1)
        print "CRC: " + rx.encode("hex")

def read():
	print "Read: "
        ser.write('\x84')
	for i in range(count):
	        rx = ser.read(size=4)
        	print "RX:" + rx.encode("hex")
	rx = ser.read(size=1) 
	print "CRC: " + rx.encode("hex")


ser = serial.Serial(port='/dev/ttyS0',baudrate = 115200, parity = serial.PARITY_NONE, bytesize=serial.EIGHTBITS)   #modify the serial port name based on your machine
print ser.name


count = 2
addr = ['\x00','\x00','\x00','\x10']
data = [['\xDE','\xAD','\xBE','\xEF'],['\xAA','\xAB','\xCB','\xEF']]
alive()
set_count()
set_addr()
write()
set_addr()
read()
