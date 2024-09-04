read_sdc $::env(SCRIPTS_DIR)/base.sdc

# Relax reset delays as it will not be changing while running
# This assumes we can slow down the clock while coming out of reset
set_input_delay 0.5 -clock [get_clocks $::env(CLOCK_PORT)] {rst_n}

# Override these delays because we don't care about the output from the latch on the
# clock cycle when it is set.
set_max_delay $::env(CLOCK_PERIOD) -through [ get_nets {i_mandel.l_sq.data_out*} ]
set_max_delay $::env(CLOCK_PERIOD) -through [ get_nets {i_mandel.i_xy.hc.data_out*} ]

# Override these delays because we expect config changes to be done at a time when
# the values aren't being read.
set_max_delay $::env(CLOCK_PERIOD) -through [ get_nets {i_coord.l_*.data_out*} ]
