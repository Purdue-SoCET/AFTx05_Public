# Find all instances including the test bench
set all_insts [find instances /*]
set all_insts [lrange $all_insts 0 [expr {[llength $all_insts] - 2}]]
set all_insts [concat $all_insts [find instances *]]
set instances [list]
foreach inst $all_insts {
    regexp {^([/\w]+)\s.*$} $inst full_match inst_name
    regexp {^.*/(\w+)$} $inst_name full_match mod_name
    add wave -divider "$mod_name Signals"
    add wave "$inst_name/*"
    
    foreach sig [find signals "$inst_name/*"] {
        if {[string length [exa $sig]] == 32} then {
            property wave -radix hex $sig
        }
    }
}

# Make the box wide enough to see all the signals
configure wave -namecolwidth 275
