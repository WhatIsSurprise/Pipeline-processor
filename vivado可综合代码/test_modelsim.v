`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module test_modelsim(
input wire clk,
input wire reset,
input wire SW0,
output wire[6:0] digitial_o,
output wire[6:0] leds_o,
output wire[3:0] anns_o
);

   _connect connect0(.clk(clk),.reset(reset),.is_show_number(SW0),.digitial_o(digitial_o),.leds_o(leds_o),.anns_o(anns_o));
endmodule
