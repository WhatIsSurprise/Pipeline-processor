module EX_MEM_rigister(
input wire reset,       //��λ�ź�
input wire clk,
input wire[4:0] write_regAddress_EX,   //Ҫд���Ŀ�ļĴ����ĵ�ַ
input wire is_write_EX,                      //�Ƿ�д��Ĵ���
input wire[31:0] write_regValue_EX,    //Ҫд���Ŀ�ļĴ�����ֵ

input wire[7:0] aluop_EX,              //ִ�н׶�ָ���Ӧ������������

input wire[31:0] mem_address_EX,          //����/�洢�ĵ�ַ
input wire[31:0] reg_operation2_value_EX,    //�洢ָ��洢������

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