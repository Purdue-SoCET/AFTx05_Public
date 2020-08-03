import sff_serial_debugger as p
s = p.serial_debugger(sim_trace_file="test")
s.alive()
s.set_addr(0x8)
s.write([0xAABBCCDD, 0xDDCCBBAA])
s.core_hold_reset()
s.core_release_reset()
s.set_addr(0x8)
s.read(1)
s.alive()
