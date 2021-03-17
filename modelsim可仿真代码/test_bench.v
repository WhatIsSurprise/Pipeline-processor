`timescale 1ns/1ps
module test_bench();
  reg clk_test;
  reg reset;
  wire[6:0] digitial_o;
  wire[6:0] leds_o;
  wire[3:0] anns_o;
  
  
  
  initial 
  begin     
  clk_test = 1'b0;    
  reset = 1'b0;  
  forever #5 clk_test = ~clk_test;
  end
  _connect connect0(.clk(clk_test),.reset(reset),.digitial_o(digitial_o),.leds_o(leds_o),.anns_o(anns_o));
  

endmodule