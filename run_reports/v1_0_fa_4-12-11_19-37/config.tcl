# User config
set ::env(DESIGN_NAME) mac_cluster

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(OPENLANE_ROOT)/designs/mac_cluster/src/*.v]
set ::env(SYNTH_READ_BLACKBOX_LIB) 1


# Fill this
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
set ::env(SYNTH_MAX_FANOUT) 6
set ::env(FP_CORE_UTIL) 65
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)-10) / 100.0 ]


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(PDK_VARIANT)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}


