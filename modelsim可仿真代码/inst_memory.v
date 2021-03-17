module inst_memory(               //Ö¸Áî´æ´¢Æ÷ÊµÏÖ
input wire inst_enable,
(* dont_touch = "true"*) input wire[31:0] instAddress,
output reg[31:0] inst
);
	always @(*)
	begin
	if(inst_enable == 1'b1)
	begin
		case (instAddress[9:2])
             8'd0:    inst <= 32'h08100002;
             8'd1:    inst <= 32'h08100024;
             8'd2:    inst <= 32'h3c164000;
             8'd3:    inst <= 32'h20080000;
             8'd4:    inst <= 32'h00084820;
             8'd5:    inst <= 32'h21180190;
             8'd6:    inst <= 32'h200b0000;
             8'd7:    inst <= 32'h8ed20014;
             8'd8:    inst <= 32'h00084820;
             8'd9:    inst <= 32'h29700064;
             8'd10:    inst <= 32'h12000011;
             8'd11:    inst <= 32'h216cffff;
             8'd12:    inst <= 32'h29900000;
             8'd13:    inst <= 32'h1600000c;
             8'd14:    inst <= 32'h000c6880;
             8'd15:    inst <= 32'h012d6820;
             8'd16:    inst <= 32'h8dae0000;
             8'd17:    inst <= 32'h8daf0004;
             8'd18:    inst <= 32'h01cf802a;
             8'd19:    inst <= 32'h16000002;
             8'd20:    inst <= 32'h218cffff;
             8'd21:    inst <= 32'h0810000c;
             8'd22:    inst <= 32'hadae0004;
             8'd23:    inst <= 32'hadaf0000;
             8'd24:    inst <= 32'h218cffff;
             8'd25:    inst <= 32'h0810000c;
             8'd26:    inst <= 32'h216b0001;
             8'd27:    inst <= 32'h08100008;
             8'd28:    inst <= 32'h8ed30014;
             8'd29:    inst <= 32'h02729822;
             8'd30:    inst <= 32'hac130000;
             8'd31:    inst <= 32'h20150007;
             8'd32:    inst <= 32'haed50008;
             8'd33:    inst <= 32'h2015007f;
             8'd34:    inst <= 32'haed5000c;
             8'd35:    inst <= 32'h08100023;
             8'd36:    inst <= 32'h3c164000;
             8'd37:    inst <= 32'h20150001;
             8'd38:    inst <= 32'haed50008;
             8'd39:    inst <= 32'h20150001;
             8'd40:    inst <= 32'haed5000c;
             8'd41:    inst <= 32'h20150003;
             8'd42:    inst <= 32'haed50008;
             8'd43:    inst <= 32'h03400008;


			 default: inst<=32'h00000000;
		endcase
	end
	else
	begin
		inst <= 32'h00000000;
	end
	end
endmodule