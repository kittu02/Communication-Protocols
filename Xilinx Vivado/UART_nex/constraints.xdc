## Clock signal (100 MHz on Nexys4 DDR)
set_property PACKAGE_PIN E3 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
create_clock -add -name sys_clk_pin -period 10.0 -waveform {0 5} [get_ports clk_100mhz]

## Reset button (btnC - central button)
set_property PACKAGE_PIN C12 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## Switches
set_property PACKAGE_PIN J15 [get_ports {switches_in[0]}]
set_property PACKAGE_PIN L16 [get_ports {switches_in[1]}]
set_property PACKAGE_PIN M13 [get_ports {switches_in[2]}]
set_property PACKAGE_PIN R15 [get_ports {switches_in[3]}]
set_property PACKAGE_PIN R17 [get_ports {switches_in[4]}]
set_property PACKAGE_PIN T18 [get_ports {switches_in[5]}]
set_property PACKAGE_PIN U18 [get_ports {switches_in[6]}]
set_property PACKAGE_PIN R13 [get_ports {switches_in[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports switches_in[*]]

## TX Start Button (btnU for example)
set_property PACKAGE_PIN U11 [get_ports btn_start_tx]
set_property IOSTANDARD LVCMOS33 [get_ports btn_start_tx]

## LEDs
set_property PACKAGE_PIN H17 [get_ports {leds_out[0]}]
set_property PACKAGE_PIN K15 [get_ports {leds_out[1]}]
set_property PACKAGE_PIN J13 [get_ports {leds_out[2]}]
set_property PACKAGE_PIN N14 [get_ports {leds_out[3]}]
set_property PACKAGE_PIN R18 [get_ports {leds_out[4]}]
set_property PACKAGE_PIN V17 [get_ports {leds_out[5]}]
set_property PACKAGE_PIN U17 [get_ports {leds_out[6]}]
set_property PACKAGE_PIN U16 [get_ports {leds_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports leds_out[*]]

## Data valid LED (use LD9 as example)
set_property PACKAGE_PIN V11 [get_ports led_data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports led_data_valid]

## UART TX (to PMOD/USB-UART bridge)
set_property PACKAGE_PIN A18 [get_ports fpga_tx_out]
set_property IOSTANDARD LVCMOS33 [get_ports fpga_tx_out]

## UART RX (from PMOD/USB-UART bridge)
set_property PACKAGE_PIN B18 [get_ports fpga_rx_in]
set_property IOSTANDARD LVCMOS33 [get_ports fpga_rx_in]
