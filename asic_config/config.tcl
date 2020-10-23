# 
# OPENLANE CONFIGURATION FILE
#

# User config
set ::env(DESIGN_NAME) mac_cluster
set ::env(PDK_VARIANT) sky130_fd_sc_hd

set src_dir $::env(OPENLANE_ROOT)/designs/250/mac_team/src

# Design config
set ::env(CLOCK_PERIOD) 30
set ::env(VERILOG_FILES) [glob $src_dir/*.v]
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

# Synthesis config
set ::env(SYNTH_STRATEGY) 1

set ::env(FP_SIZING) absolute
# I think this goes LL_X LL_Y UR_X UR_Y, where LL=lower left, UR=upper right
# Units probably microns
set ::env(DIE_AREA) [list 0 0 700 700]

# Floorplan config
#set ::env(FP_CORE_UTIL) 80
# Placement config
set ::env(PL_TARGET_DENSITY) 0.8

# CTS config
# Routing config
#set ::env(ROUTING_STRATEGY) 14 ;# run TritonRoute14
#set ::env(GLB_RT_ADJUSTMENT) 0
# Flow control config

# # threads for supporting tools
set ::env(ROUTING_CORES) 4

set ::env(PDN_CFG) $::env(DESIGN_DIR)/pdn.tcl

#set ::env(PL_SKIP_INITIAL_PLACEMENT) 1
#set ::env(CLOCK_TREE_SYNTH) 0
