import argparse
import os
import subprocess
import binascii
import re

SRC_ADDR = None
SRC_FILE = None
SRC_BASENAME = None

OUTPUT_FOLDER = "./out/"
ELF_FOLDER = OUTPUT_FOLDER + "elfs/"
ELF_ADDR = None
INTELHEX_ADDR = OUTPUT_FOLDER + "meminit.hex"
ROM_DATA_ADDR = OUTPUT_FOLDER + "rom.txt"
SOC_ROM_ADDR = OUTPUT_FOLDER + "SOC_ROM.sv"
SIM_SRC = "~/SoCET_Public/sram_controller/src/"

RESOURCE_FOLDER = "./res/"
LINKER_ADDR = RESOURCE_FOLDER + "link.ld"
ROM_PRE_ADDR = RESOURCE_FOLDER + "rom_pre.txt"
ROM_POST_ADDR = RESOURCE_FOLDER + "rom_post.txt"

WORD_SIZE = 4
ROM_START_ADDR = 0x200
ROM_END_ADDR = 0x7FFF

def parse_arguments():
    global SRC_ADDR
    global SRC_FILE
    global SRC_BASENAME
    
    global OUTPUT_FOLDER
    global ELF_ADDR
    global INTELHEX_ADDR
    global ROM_DATA_ADDR
    global SOC_ROM_ADDR
    
    global RESOURCE_FOLDER
    global LINKER_ADDR
    global ROM_PRE_ADDR
    global ROM_POST_ADDR
    
    global WORD_SIZE
    global ROM_START_ADDR
    global ROM_END_ADDR
    
    parser = argparse.ArgumentParser(description="Converts source files (asm or C) to intel hex files")
    parser.add_argument('src_addr', type=str, help="path to asm or C source file that needs to be converted")

    args = parser.parse_args()
    SRC_ADDR = args.src_addr
    SRC_FILE = SRC_ADDR.split('/')[-1]
    SRC_BASENAME = SRC_FILE.split('.')[0]
    ELF_ADDR = ELF_FOLDER + SRC_BASENAME + ".elf"

    extension = SRC_FILE.split('.')[1]
    if extension != 'S' and extension != 'c':
        print "ERROR: Not an ASM or C file"
        return -1

    if not os.path.isfile(SRC_ADDR):
        print "ERROR: " + SRC_ADDR + " does not exist!"
        return -1

    return 0

def source_to_elf():
    print(SRC_ADDR + " source_to_elf " + ELF_ADDR)
    cmd_arr = ['riscv64-unknown-elf-gcc',
               '-march=rv32i',
               '-mabi=ilp32',
               '-lgcc',
               '-static',
               '-static',
               '-mcmodel=medany',
               '-fvisibility=hidden',
               '-nostartfiles',
               '-T', LINKER_ADDR,
               SRC_ADDR, '-o', ELF_ADDR,
               #'./lib_apb/common.c', './lib_apb/gpio.c', './lib_apb/pwm.c', './lib_apb/crc.c',
               '-O']

    failure = subprocess.call(cmd_arr)

def get_elf_size(): # probably not the best way of doing this
    os.system("riscv64-unknown-elf-objdump -p {} > {}temp.txt".format(ELF_ADDR, OUTPUT_FOLDER))
    elf_info_file = open("{}temp.txt".format(OUTPUT_FOLDER), 'r')
    elf_info = elf_info_file.read()
    elf_info_file.close()
    os.system("rm {}temp.txt".format(OUTPUT_FOLDER))
    search_str = "filesz (0x[\\d\\w]{{{}}})".format(WORD_SIZE*2)
    return int(re.search(search_str, elf_info).group(1), 16)

# Returns the string representation of the checksum for the given hex_str
# hex_str: {byte count, addr, record type, data} (look up intelhex encoding for more info)
def calculate_checksum_str(hex_str):
    checksum = 0
    for hexbyte in range(len(hex_str)//2):
        new_byte = int(hex_str[hexbyte*2:(hexbyte+1)*2], 16)
        checksum += new_byte 
    checksum = (~checksum) + 1
    return "{:02x}".format(checksum & 0xff)

def elf_to_intelhex():
    print(ELF_ADDR + " elf_to_intelhex " + INTELHEX_ADDR)
    elf_size = get_elf_size()
    elf_bin = open(ELF_ADDR, 'rb')
    instrs = elf_bin.read()
    instrs = binascii.hexlify(instrs)
    instrs = [instrs[i:i+WORD_SIZE*2] for i in range(0, len(instrs), WORD_SIZE*2)]
    elf_bin.close()
    
    intelhex = open(INTELHEX_ADDR, 'w+')
    addr = ROM_START_ADDR
    for instr in instrs[ROM_START_ADDR//WORD_SIZE:elf_size//WORD_SIZE]:
        hexline = ":{:02x}".format(WORD_SIZE) + "{:04x}".format(addr//WORD_SIZE) + "00" + instr
        hexline = hexline + calculate_checksum_str(hexline[1:]) + '\n'
        intelhex.write(hexline)
        addr += WORD_SIZE
    intelhex.write(':00000001FF')
    intelhex.close()


def intelhex_to_rom():
    print(INTELHEX_ADDR + " intelhex_to_rom " + SOC_ROM_ADDR)
    # hex to ROM
    intelhex = open(INTELHEX_ADDR, 'r')
    intelhex_lines = intelhex.readlines()
    intelhex.close()
    
    byte_addr = 0
    rom = open(ROM_DATA_ADDR, 'w+')
    for line in intelhex_lines[:-1]:
        start_code = line[0]
        byte_count = line[1:3]
        word_addr = line[3:7]
        byte_addr = int(line[3:7], 16) * WORD_SIZE
        record_type = line[7:9]
        data = line[9:9+WORD_SIZE*2]
        checksum = line[-3:-1]
        
        if byte_addr >= ROM_START_ADDR and byte_addr <= ROM_END_ADDR - (WORD_SIZE - 1):
            rom.write("          16'h{} : blkif.rom_rdata <= {}'h{};\n".format(word_addr, WORD_SIZE*8, data))
    
    while byte_addr >= ROM_START_ADDR and byte_addr <= ROM_END_ADDR - (WORD_SIZE - 1):
        rom.write("          16'h{:04x} : blkif.rom_rdata <= {}'h{};\n".format(byte_addr/WORD_SIZE, WORD_SIZE*8, "00000000"))
        byte_addr += WORD_SIZE

    rom.close();
    os.system("cat {} {} {} > {}".format(ROM_PRE_ADDR, ROM_DATA_ADDR, ROM_POST_ADDR, SOC_ROM_ADDR))
    os.system("cp {} {}".format(SOC_ROM_ADDR, SIM_SRC))


if __name__ == "__main__":
    failure = parse_arguments()
    if failure != -1:
        source_to_elf()
        elf_to_intelhex()
        intelhex_to_rom()
