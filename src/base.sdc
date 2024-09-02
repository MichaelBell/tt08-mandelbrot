read_sdc $::env(SCRIPTS_DIR)/base.sdc

# Override these delays because we don't care about the output from the latch on the
# clock cycle when it is set.
set_max_delay $::env(CLOCK_PERIOD) -through [ get_nets {i_mandel.l_sq.data_out*} ]
set_max_delay $::env(CLOCK_PERIOD) -through [ get_nets {i_mandel.i_xy.hc.data_out*} ]

# Might as well override these delays because time borrowing confuses stuff
set_max_delay [expr $::env(CLOCK_PERIOD) - 1] -to [ get_pins {i_mandel.l_sq.*.state/D} ]
set_max_delay [expr $::env(CLOCK_PERIOD) - 1] -to [ get_pins {i_mandel.i_xy.hc.*.state/D} ]
set_min_delay 0.5 -to [ get_pins {i_mandel.l_sq.*.state/D} ]
set_min_delay 0.5 -to [ get_pins {i_mandel.i_xy.hc.*.state/D} ]
