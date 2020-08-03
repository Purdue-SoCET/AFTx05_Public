#! /usr/bin/env python2.6

import struct

# Written by Kyle and Dr S.
# Version 0.1 Kyle and Dr S.
# Version 0.2 Dr S.
# Version 0.3 Dr S.
# Version 0.4 Kyle - Added ability to specify the serial port and baud rate
# Version 0.5 Jacob Stevens - Add trace capabilites and remove alive CRC bugfix

# TODO:
# Proper logging infrastructure
# CMD line args for serial port settings
# Use exception catching to do retries if CRC badA
# Alive needs to timeout and keep on retrying until it gets it
# Create global that gets debugger version assigned and make all bugfixes depend on debugger version:
#	Endianess swap between read and write
#	CRC incorrect in Alive
#	Move the alive command into the init of the module
#	expose the debugger version on a variable
#	handle bugfixes and quirks internally based on version number
# How to handle more modern versions of the debugger that return multiple
#  bytes? simple timeout. Try to read 5 bytes for example with a timeout 
#  as a multiple of baud. Test how many. If 2 then verify the crc. If the
#  higher number verify that crc. Tada!

class serial_debugger():
    _SET_COUNT = 0x82
    _SET_ADDR = 0x83
    _READ32 = 0x84
    _WRITE32 = 0x85
    _ALIVE = 0x86
    _CORE_RST = 0x87
    _CORE_NORM = 0x88

    _CRC_WIDTH = 8
    _TOPBIT = (1 << (_CRC_WIDTH - 1))
    # 9'b101001101
    _POLYNOMIAL = 0x14D
    _crcTable = []

    def __init__(self, port='/dev/ttyUSB0', baud_rate=57600, sim_trace_file=None):
        self._crcInit()
        
        self.trace_mode = False
        self.sim_trace_file = sim_trace_file
        self.opened_trace_file = None

        if sim_trace_file is None:
            import serial
            # Create instance of the serial port only when trace file is not generated
            # Modify the serial port name based on your machine
            self._s = serial.Serial(
                port=port,
            #	baudrate = 115200,
                baudrate = baud_rate,
            #	baudrate = 230400,
                parity = serial.PARITY_NONE,
                bytesize=serial.EIGHTBITS)
        else:
            self.trace_mode = True
            self.opened_trace_file = open('../resources/' + self.sim_trace_file + ".txt", "w")
            self.expected_file = open('../resources/' + self.sim_trace_file + "_expected.txt", "w")

    def __del__(self):
        if not self.trace_mode:
            self._s.close()
        else:
            self.opened_trace_file.write('X')
            self.opened_trace_file.close()

    def _debug_transfer(self, tx_words, read_num_words, word_width):
        # Doesn't currently support 16 bit sets
        tx_data = str()
        convu8 = struct.Struct('<B')
        # Write is big endian
        convu32 = struct.Struct('>I')
        tx_data = convu8.pack(tx_words[0])
        for word in tx_words[1:]:
            if word_width == 32:
                tx_data = tx_data + convu32.pack(word)
            elif word_width == 8:
                tx_data = tx_data + convu8.pack(word)
            else:
                raise Exception("Word width not yet implemented")
        if not self.trace_mode:
            self._s.write(tx_data)
        else:
            if tx_data[0] == '\x86' or tx_data == '\x84':
                self.opened_trace_file.write("R ")
            else:
                self.opened_trace_file.write("T ")
            for data in tx_data:
                self.opened_trace_file.write(data.encode("hex").upper() + ' ')
            self.opened_trace_file.write("\n")
		# Read appropriate number of bytes
		# Read is now also big endian
        convu32 = struct.Struct('>I')
        read_num_bytes = (read_num_words*word_width/8)+1
        rx_data = None        

        if not self.trace_mode:
            while self._s.inWaiting() < read_num_bytes:
                pass
            rx_data = self._s.read(size=read_num_bytes-1)
	    
        else:
            if tx_data[0] == '\x86':
                rx_data = '\xAE'
                self.expected_file.write('ae ')
        rx_words = []
        if rx_data is not None:
            for word in range(read_num_words):
                if word_width == 32:
                    rx_words.append(convu32.unpack(rx_data[word*4:(word*4)+4])[0])
                elif word_width == 8:
                    rx_words.append(convu8.unpack(rx_data[word])[0])
                else:
                    raise Exception("Data width not yet implemented")
        
        data_crc = []
        for byte in tx_data:
            data_crc.append(convu8.unpack(byte)[0])
        if rx_data is not None:
            for byte in rx_data:
                data_crc.append(convu8.unpack(byte)[0])
        
        if not self.trace_mode:
            crc = self._s.read(size=1)
            crc = convu8.unpack(crc)[0]
            self._checkCRC(data_crc, crc)
        # ignore crc from read operations for now
        elif tx_data[0] != '\x84':
            crc = self._crcFast(data_crc)
            char_crc = hex(crc)[2:]
            char_crc = char_crc.replace('L', '')    #eliminate the L for long
            if len(char_crc) == 1:
                char_crc = '0' + char_crc
            self.expected_file.write(char_crc)
            self.expected_file.write('\n')
        
        return rx_words

		

    def _checkCRC(self, data, crc):
        crcGen = self._crcFast(data)

        if crc != crcGen:
            print("CRC Mismatch")

    def _crcFast(self, data_in):
        data = 0
        remainder = 0
        for byte in range(len(data_in)):
            data = (data_in[byte] ^ (remainder >> (self._CRC_WIDTH - 8))) & 0xFF
            remainder = self._crcTable[data] ^ (remainder << 8)
        return remainder & 0xFF

    def _crcInit(self):
        remainder = 0
        for dividend in range(256):
            remainder = dividend << (self._CRC_WIDTH - 8)
            for bit in range(8):
				
                if (remainder & self._TOPBIT):
                    remainder = (remainder << 1) ^ self._POLYNOMIAL
                else:
                    remainder = (remainder << 1)
            self._crcTable.append(remainder)

    def set_count(self, count):
        if count > 255:
            raise Exception("Count must be 255 or less")
        if self.trace_mode:
            self.opened_trace_file.write("# Setting count to {0}\n".format(hex(count)))
        arr = [self._SET_COUNT, count]
        self._debug_transfer(arr, 0, 8)

    def set_addr(self, addr):
        if self.trace_mode:
            self.opened_trace_file.write("# Setting address to {0}\n".format(hex(addr)))
        arr = [self._SET_ADDR, addr]
        self._debug_transfer(arr, 0, 32)

    def alive(self):
        if self.trace_mode:
            self.opened_trace_file.write("# Sending alive command\n")
        arr = [self._ALIVE]
        return self._debug_transfer(arr, 1, 8)

    def core_hold_reset(self):
        if self.trace_mode:
            self.opened_trace_file.write("# Holding core in reset\n")
        arr = [self._CORE_RST]
        return self._debug_transfer(arr, 0, 8)

    def core_release_reset(self):
        if self.trace_mode:
            self.opened_trace_file.write("# Releasing core from reset\n")
        arr = [self._CORE_NORM]
        return self._debug_transfer(arr, 0, 8)

    def write(self, data):
        self.set_count(len(data))
        if self.trace_mode:
            str_data = [hex(i)[2:].upper() for i in data]
            self.opened_trace_file.write("# Writing {0} to debugger\n".format(str_data))
        arr = [self._WRITE32]
        arr = arr + data
        self._debug_transfer(arr, 0, 32)

    def read(self, read_num_words):
        self.set_count(read_num_words)
        if self.trace_mode:
            self.opened_trace_file.write("# Read number of bytes set above\n")
        arr = [self._READ32]
        return self._debug_transfer(arr, read_num_words, 32)

