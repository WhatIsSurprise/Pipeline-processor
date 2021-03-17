module EX_MEM_rigister(
input wire reset,       //复位信号
input wire clk,
input wire[4:0] write_regAddress_EX,   //要写入的目的寄存器的地址
input wire is_write_EX,                      //是否写入寄存器
input wire[31:0] write_regValue_EX,    //要写入的目的寄存器的值

input wire[7:0] aluop_EX,              //执行阶段指令对应的运算子类型

input wire[31:0] mem_address_EX,          //加载/存储的地址
input wire[31:0] reg_operation2_value_EX,    //存储指令存储的数据

output reg[7:0] aluop_MEM,
output reg[31:0] mem_address_MEM,
output reg[31:0] reg_operation2_value_MEM,

output reg is_write_MEM,
output reg[4:0] write_regAddress_MEM,
output reg[31:0] write_regValue_MEM

);
	always @(posedge clk)
	begin
		if(reset == 1'b1)
		begin
			write_regAddress_MEM<=0;
			is_write_MEM<=0;
			write_regValue_MEM<=0;
		end
		else
		begin
			is_write_MEM<=is_write_EX;
			write_regAddress_MEM<=write_regAddress_EX;
			write_regValue_MEM<=write_regValue_EX;
			
			
			aluop_MEM<=aluop_EX;
			mem_address_MEM<=mem_address_EX;
			reg_operation2_value_MEM<=reg_operation2_value_EX;
			
		end
		
	end



endmodule