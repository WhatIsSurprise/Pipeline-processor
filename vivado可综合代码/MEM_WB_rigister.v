module MEM_WB_rigister(
input wire reset,
input wire clk,

//�ô�׶εĽ��
input wire[4:0] write_regAddress_MEM,
input wire[31:0] write_regValue_MEM,
input wire is_writeReg_MEM,


//�͵���д�׶ε���Ϣ
output reg[4:0] write_regAddress_WB,
output reg is_write_WB,
output reg[31:0] write_regValue_WB
);
	always @(posedge clk)                //ʱ��������д��
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