module ctrl(                  //流水线暂停模块
input wire reset,
input wire stallreq_from_id,
output reg[5:0] stall

);
	always @(*)
	begin
		if(reset == 1'b1)
		begin
			stall<=6'b000000;
		end
		else if(stallreq_from_id == 1'b1)
		begin
			stall<=6'b000111;
		end
		else
		begin
			stall<=6'b000000;
		end
	end
	
	
endmodule
