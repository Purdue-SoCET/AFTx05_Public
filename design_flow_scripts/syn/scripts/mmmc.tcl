# Version:1.0 MMMC View Definition File
# Do Not Remove Above Line

##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################



source ./scripts/setup.tcl
########################################################################
#Create a list of all the .lib files available for each IP specified
#Only IP that is listed under [stepname][iplist] will be included. 
#(defaults to [pnr_synthesis])
########################################################################
set ip_libs [list ]
lappend ip_libs ${STDLIB_PATH}/MITLL90_STDLIB_8T.tt1p2v25c.lib
set pvt_list [list ]
lappend pvt_list {tt1p2v25c}

#For extraction at each PVT, we need to reference the corresponding min/max/nominal cap table
set tt1p2v25c.captbl ${PDK_PATH}/MITLL090nm/mitll090nm_T1M5.capTbl

set ip_lefs [list ]
lappend ip_lefs ${PDK_PATH}/lef/soi90nm_5_0.lef
lappend ip_lefs ${STDLIB_PATH}/MITLL90_STDLIB_8T.lef
#lappend ip_lefs ~/SoCET_Public/design_flow_scripts/PnR_x05/polymorphic.lef


###############################################################################
#Define the sets of IP library files and RC extract decks for each PVT corner
###############################################################################
foreach pvt $pvt_list {
    #Create a list of .lib files for each PVT 
    set pvtlibs [list ]
    foreach lib $ip_libs {
	foreach ip $ip_list {
	    if {[regexp $pvt $lib] && [regexp $ip $lib]} {
		lappend pvtlibs $lib
	    }
	}
    }
    create_library_set -name $pvt -timing $pvtlibs
    
    regexp {([Nm]?\d+)[cC]} $pvt -> T
    regexp {([p\.\d]+)[vV]} $pvt -> V
    set T [string map {N -} $T]
    set T [string map {m -} $T]
    set V [string map {p .} $V]

    #Warning: TCL derefencing voodoo to follow
    set captable_ptr $pvt.captbl
    set captable [set $captable_ptr]

    #Genus uses slightly different MMMC syntax than other Cadence tools.
    if { $env(stage) == "pnr" } {

   	create_rc_corner -name $pvt -T $T -cap_table $captable -preRoute_res {1.0} -preRoute_cap {1.0} -preRoute_clkres {0.0} -preRoute_clkcap {0.0} -postRoute_res {1.0} -postRoute_cap {1.0} -postRoute_xcap {1.0} -postRoute_clkres {0.0} -postRoute_clkcap {0.0}
   
   	create_op_cond -name $pvt -P 1.0 -V $V -T $T -library_file $pvtlibs
   	create_delay_corner -name $pvt -rc_corner $pvt -library_set $pvt -opcond $pvt
   	create_constraint_mode -name $pvt -sdc_files $OUT_DIR/$DESIGN_NAME.sdc_gen
   	create_analysis_view -name $pvt -constraint_mode $pvt -delay_corner $pvt

    } else {

    create_rc_corner -name $pvt -temperature $T -cap_table $captable -pre_route_res {1.0} -pre_route_cap {1.0} -pre_route_clock_res {0.0} -pre_route_clock_cap {0.0} -post_route_res {1.0} -post_route_cap {1.0} -post_route_cross_cap {1.0} -post_route_clock_res {0.0} -post_route_clock_cap {0.0}
  
  	create_opcond -name $pvt -process 1.0 -voltage $V -temperature $T 
  	create_timing_condition -name $pvt -library_sets $pvt -opcond $pvt
  	create_delay_corner -name $pvt -timing_condition $pvt -rc_corner $pvt 
  	create_constraint_mode -name $pvt -sdc_files $SDC_PATH/$DESIGN_NAME.sdc
  	create_analysis_view -name $pvt -constraint_mode $pvt -delay_corner $pvt
}
#	#if a slash is found, we assume this is a valid path.
#	create_rc_corner -name $pvt -temperature $T -cap_table $captable -pre_route_res {1.0} -pre_route_cap {1.0} -pre_route_clock_res {0.0} -pre_route_clock_cap {0.0} -post_route_res {1.0} -post_route_cap {1.0} -post_route_cross_cap {1.0} -post_route_clock_res {0.0} -post_route_clock_cap {0.0}
# 
#	create_delay_corner -name $pvt -library_set $pvt -rc_corner $pvt
#	create_constraint_mode -name $pvt -sdc_files $SDC_PATH/$DESIGN_NAME.sdc
#	create_analysis_view -name $pvt -constraint_mode $pvt -delay_corner $pvt
}

set MaxViews [list ]
set MinViews [list ]

#If no min or max views were provided, try to infer based on the pvt names.
if { [llength $MaxViews] == 0 && [llength $MinViews] == 0 } {
    foreach pvt $pvt_list {
	if { [regexp {ff|_min} $pvt] } {
	    lappend MinViews $pvt
	} elseif { [regexp {ss|_max} $pvt] } {
	    lappend MaxViews $pvt
	} else {
	    lappend MinViews $pvt
	    lappend MaxViews $pvt
	}
    }
}

set_analysis_view -setup $MaxViews -hold $MinViews
