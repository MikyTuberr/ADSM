## --- PRZYCISKI (Buttons) ---
# Przycisk BTN0
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }];
# Przycisk BTN1
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }];

## --- ZWYKŁE DIODY ZIELONE (Standard LEDs) ---
# Dioda LED0
set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
# Dioda LED1
set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];

## --- DIODA RGB (RGB LED - LD2) ---
# Każdy kolor to osobny pin. Sterowanie '1' zapala kolor.
# LD2 - Czerwony (Red)
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33 } [get_ports { led_rgb_r }];
# LD2 - Zielony (Green)
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { led_rgb_g }];
# LD2 - Niebieski (Blue)
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { led_rgb_b }];