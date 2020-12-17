# User config
set ::env(DESIGN_NAME) mac_cluster

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1

# Fill this
set ::env(CLOCK_PERIOD) "60"
set ::env(CLOCK_PORT) "clk"

set ::env(SYNTH_MAX_FANOUT) 8
set ::env(FP_CORE_UTIL) 35
set ::env(PL_TARGET_DENSITY) 0.365

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

