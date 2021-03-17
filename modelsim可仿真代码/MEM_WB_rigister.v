module MEM_WB_rigister(
input wire reset,
input wire clk,

//访存阶段的结果
input wire[4:0] write_regAddress_MEM,
input wire[31:0] write_regValue_MEM,
input wire is_writeReg_MEM,


//送到回写阶段的信息
output reg[4:0] write_regAddress_WB,
output reg is_write_WB,
output reg[31:0] write_regValue_WB
);
	always @(posedge clk)                //时钟上升沿写入
	begin
		if(reset == 1'b1)
		begin
			write_regAddress_WB<=0;
			is_write_WB<=0;
			write_regValue_WB<=0;
				
		end
		else
		begin
			write_regAddress_WB<=write_regAddress_MEM;
			is_write_WB<=is_writeReg_MEM;
			write_regValue_WB<=write_regValue_MEM;
				
		end
	end
	
endmodule