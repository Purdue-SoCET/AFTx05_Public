###########################################
#initialize variables 
###########################################


source setup.tcl

setMultiCpuUsage -localCpu 8

################################################################
#Create the list of .lef files for all IP needed in this block.
################################################################
set ip_lefs [list ]
lappend ip_lefs ${PDK_PATH}/lef/soi90nm_5_1_1.lef
lappend ip_lefs ${STDLIB_PATH}/MITLL90_STDLIB_8T.lef
lappend ip_lefs ${IOLIB_PATH}/MITLL90_IOPads_5_1_1.lef
lappend ip_lefs ./scripts/ro_hope.lef
lappend ip_lefs ./scripts/polymorphic.lef


set init_lef_file $ip_lefs


#######################################################################
#Initialize gnd and power net names
#######################################################################
set gnd_nets [list ]
lappend gnd_nets {vss!}
lappend gnd_nets {VSSIO}

set pwr_nets [list ]
lappend pwr_nets {vdd!}
lappend pwr_nets {VDDIO}

set init_gnd_net $gnd_nets
set init_pwr_net $pwr_nets

#######################################
#Select the process node and corners
#initialize the design
#######################################
set process {90}
setDesignMode -process $process

set init_mmmc_file ./scripts/mmmc_aftx05_chip.view

set time_unit {1ps}
setLibraryUnit -time $time_unit


##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################


set cap_unit {1ff}
setLibraryUnit -cap $cap_unit

setGenerateViaMode -auto true

init_design

#####################################################################
#create floorplan and execute any user-specified instance placement
#####################################################################
getIoFlowFlag
setIoFlowFlag 1
floorPlan -r 1 0.5 100 100 100 100

loadIoFile -noAdjustDieSize ./scripts/top_chip.io
setIoFlowFlag 0
addIoFiller -cell {spacer_1 spacer_5 spacer_10 spacer_30 spacer_60}

uiSetTool select


################################################################################################################
#Allow users with complex power domains to override the globalNetConnect statements with a pairwise list
#globalNetConnect creates the logical connectivity between the power pins in cells and the power domains at the top level
#The default behavior simply connects by name (e.g., a cell pin named VDD will be connected to VDD)
################################################################################################################
set globalNetConnect [list ]

foreach net $pwr_nets {
    globalNetConnect $net -type pgpin -pin $net
}
foreach net $gnd_nets {
    globalNetConnect $net -type pgpin -pin $net
}

#if the library cells contain substrate or well pins, these are connected to the appropriate supply.
set substrate_nets {wafer!}
globalNetConnect vss! -type pgpin -pin wafer!
globalNetConnect vss! -type pgpin -pin VSS -all 
globalNetConnect vdd! -type pgpin -pin VDD -all

#very likely do not these lines below
globalNetConnect vss! -type pgpin -pin inh_wafer -all
globalNetConnect vss! -type pgpin -pin inh_vss -all 
globalNetConnect vdd! -type pgpin -pin inh_vdd -all



########################
#Draw the power grid
########################
set Width1x 0.160
set Pitch1x 0.320
set M1RailWidth 0.460
set M5RailWidth 0.320

setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer M5 -stacked_via_bottom_layer M1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {standardcell} -skip_via_on_wire_shape {noshape}
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer M5 -type core_rings -jog_distance 0.16 -threshold 0.16 -nets {vss!} -follow core -stacked_via_bottom_layer M1 -layer {bottom M5 top M5 right M5 left M5} -width 23 -offset 12 -spacing 10
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer M5 -type core_rings -jog_distance 0.16 -threshold 0.16 -nets {vdd!} -follow core -stacked_via_bottom_layer M1 -layer {bottom M4 top M4 right M4 left M4} -width 25 -offset 45 -spacing 10
setPlaceMode -fp false
saveDesign out/$designName.power


echo "Saved Design Power"


##################################################################################
#Assign a min/max routing layer
#If the user has specified a design specific layer, use it.
#If that fails, we assign based on provided patterns.
#Finally, if both those are undefined we fall back to the defaults for pnr_route
##################################################################################
set min_route_layer {1}
set max_route_layer {5}
setNanoRouteMode -routeBottomRoutingLayer $min_route_layer
setMaxRouteLayer $max_route_layer


#################################################
#pin constraint/assignment
###i##############################################
setPinAssignMode -minLayer [expr [getMaxRouteLayer]-1] -maxLayer [getMaxRouteLayer]
assignIoPins
setSrouteMode -viaConnectToShape {noshape}

##############
#Place design
##############
specifyScanChain scanchain_1_seg1_clk2_rising -start scan_in_1_pad -stop scan_out_1_pad
scanTrace > out/$designName.scanchain.rpt

echo "Done tracing scan chain"

##############
#Place design
##############
placeDesign
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { M1(1) M5(5) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { M1(1) M5(5) } -nets {vss! vdd! VDDIO VSSIO} -allowLayerChange 1 -blockPin useLef -targetViaLayerRange {M1(1) M5(5) }


##########################
#insert tiehi/tielow cells
##########################
set tiecells {tielo_1x tiehi_1x}
if {! [regexp {\[.*\]} $tiecells] } {
    setTieHiLoMode -maxDistance 50 -maxFanout 8 -cell $tiecells
    addTieHiLo
}

checkPinAssignment -ignore {pin_on_track pin_spacing_routeBlk}
checkPlace -ignoreOutOfCore

suspend
echo "Checked Pin Assignment and Place"
##########################
#Post-place optimization
##########################
setOptMode -fixFanoutLoad true -maxLength 700
optDesign -preCTS

saveDesign out/$designName.place

echo "Saved Placement"

############################
#Clock tree synthesis setup
############################
create_ccopt_clock_tree_spec -file ./out/ccopt.spec
source ./out/ccopt.spec
set_ccopt_mode -cts_buffer_cells { \
buf_2x \
buf_4x \
buf_8x \
buf_16x }
set_ccopt_mode -cts_inverter_cells { \
inv_2x \
inv_4x \
inv_8x \
inv_16x }
set_ccopt_mode -cts_clock_gating_cells { \
 }
set_ccopt_property max_fanout 16




#############################
#Run CTS
#Generate clock tree reports
#############################
ccopt_design -cts
report_ccopt_clock_trees -list_special_pins > out/$designName.postCTS.clock_trees.rpt
report_ccopt_skew_groups > out/$designName.postCTS.clock_skew_groups.rpt
optDesign -postCTS
optDesign -postCTS -hold 
timeDesign -postCTS
saveDesign out/$designName.cts

echo "Saved CTS and reports"
#

#########################
#Route the design
#########################
routeDesign -globalDetail


##################################################################################################
#Setup RC parasitic extraction engine - UNCOMMENT TO RUN PARASITIC EXTRACTION (TAKES A LONG TIME)
##################################################################################################
#setExtractRCMode -engine postRoute -effortLevel low
#set SIAware {false}
#setDelayCalMode -SIAware $SIAware


##################################
#Design optimization
##################################
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both

optDesign -postRoute
optDesign -postRoute -hold


#############################
#Generate post-route reports
#############################
timeDesign -postRoute
report_ccopt_clock_trees -list_special_pins > out/$designName.postRoute.clock_trees.rpt
report_ccopt_skew_groups > out/$designName.postRoute.clock_skew_groups.rpt
saveDesign out/$designName.postroute

echo "Saved Post-Route"

#################################
#Filler cell insertion
#################################
addFiller -cell {fill_1x fill_2x fill_4x fill_8x fill_16x} -area 361.40 361.40 2630.84 2629.56
setMetalFill -layer M1 -opcActiveSpacing 0.160 -borderSpacing 361.4 -windowSize {250 250} -preferredDensity 0.4
setMetalFill -layer M2 -opcActiveSpacing 0.160 -borderSpacing 361.4 -windowSize {250 250} -preferredDensity 0.4
setMetalFill -layer M3 -opcActiveSpacing 0.160 -borderSpacing 361.4 -windowSize {250 250} -preferredDensity 0.4
setMetalFill -layer M4 -opcActiveSpacing 0.160 -borderSpacing 361.4 -windowSize {250 250} -preferredDensity 0.4
#setMetalFill -layer M5 -opcActiveSpacing 0.160 -borderSpacing 361.4 -windowSize {250 250} -prefferredDensity 0.4
addMetalFill -layer { M1 M2 M3 M4 } -area 361.40 361.40 2630.84 2629.56
ecoRoute


#############################
#Generate post-fill reports
#############################
checkRoute > out/$designName.connectivity.rpt
verifyConnectivity >> out/$designName.connectivity.rpt


clearDrc
verify_drc > out/$designName.drc.rpt
report_area  > out/$designName.area.rpt
reportCongestion -hotSpot -overflow > out/$designName.congestion.rpt
set defOutLefVia 1
defOut -floorplan -netlist -usedVia -routing out/$designName.def


##################################################################################
#.gds streamout
##################################################################################
set ip_gds [ list ]
lappend ip_gds ${STDLIB_PATH}/MITLL90_STDLIB_8T.gds
streamOut -units 1000 -mapFile ${PDK_PATH}/lef/soi90nm_5_1_1.innovus.streamout.map out/$designName.gds -merge $ip_gds
lappend ip_gds ../../../MITLL_90_Dec2019/MITLL90_IOPads_5_1_1/2020.01.27/MITLL90_IOPads_5_1_1.gds
lappend ip_gds ./scripts/dig_poly_NAND_NOR2_x1.gds
lappend ip_gds ./scripts/dig_poly_XOR_BUF2_x1.gds
lappend ip_gds ./scripts/ro.gds

streamOut -units 1000 -mapFile ${PDK_PATH}/lef/soi90nm_5_1_1.innovus.streamout.map out/$designName.full.gds -merge $ip_gds -uniquifyCellNames


###############################################
#Verilog generation
#create versions with/without power grid
###############################################
saveNetlist out/$designName.pr.v -excludeLeafCell -includePowerGround
saveNetlist out/$designName.nopower.v -excludeLeafCell
saveNetlist out/$designName.prwithleaf.v -includePowerGround
saveNetlist out/$designName.nopowerwithleaf.v
saveNetlist out/$designName.final_routed_LVS.v -phys -excludeLeafCell -excludeCellInst { diode }
 





################################################
#Delay (.sdf) and parasitics (.spef) generation
################################################
write_sdf -ideal_clock_network -view AnalysisTypical -version 2.1 out/$designName.ideal.sdf
write_sdf -view AnalysisTypical -version 2.1 out/$designName.sdf



####################################
#.lef generation
####################################
verifyProcessAntenna
write_lef_abstract out/$designName.lef -specifyTopLayer M5 -stripePin -PgPinLayers [list M1 M5] -extractBlockPGPinLayers [list M1 M5]

set enc_save_portable_design 1
saveDesign out/$designName.restore



write_do_lec -revised_design out/$designName.v  > out/LEC/$designName.lec_PnRrtl2final_dofile
write_do_lec -golden_design  out/$designName.mapped.v -revised_design out/$designName.v  > out/LEC/$designName.lec_PnRmapped2final_dofile

echo "Script done"

