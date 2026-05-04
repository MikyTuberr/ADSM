## Clock signal (Cmod A7 ma zegar 12MHz na pinie L17)
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports { clk }];

## Buttons
# Używamy przycisku BTN0 (Pin A18) jako reset_n
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { reset_n }];

## LEDs
# Używamy zielonej diody LED0 (Pin A17) jako detection_hit
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { detection_hit }];