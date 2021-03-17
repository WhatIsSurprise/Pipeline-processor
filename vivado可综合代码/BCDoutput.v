module BCDoutput(
input wire[3:0] din_num,
input wire[3:0] din_anns,

output wire[6:0] dout,
output wire[3:0] dout_ann 
);
    assign dout_ann = din_anns;
	assign	dout =
	         (din_num == 4'h0)?7'b1000000:
             (din_num == 4'b0001)?7'b1111001:
             (din_num == 4'b0010)?7'b0100100:
             (din_num == 4'b0011)?7'b0110000:
             (din_num == 4'b0100)?7'b0011001:
             (din_num == 4'b0101)?7'b0010010:
             (din_num == 4'b0110)?7'b0000010:
             (din_num == 4'b0111)?7'b1111000:
             (din_num == 4'b1000)?7'b0000000:
             (din_num == 4'b1001)?7'b0010000:
             (din_num == 4'b1010)?7'b0001000:			 
             (din_num == 4'b1011)?7'b0000000:
             (din_num == 4'b1100)?7'b1000110:
             (din_num == 4'b1101)?7'b1000000:
             (din_num == 4'b1110)?7'b0000110:
             (din_num == 4'b1111)?7'b0001110:7'b1111111;
endmodule