module MEM_depart(
input wire reset,

//ִ�н׶ε���Ϣ
input wire[4:0] write_regAddress_i,
input wire is_write_i,
input wire[31:0] write_regValue_i,

input wire[7:0] aluop_i,
input wire[31:0] mem_address_i,
input wire[31:0] reg_operation2_value_i,


//�������ݴ洢������Ϣ
input wire[31:0] mem_data_i,


//�ô�׶εĽ���ͳ�
output reg is_write_o,
output reg[4:0] write_regAddress_o,
output reg[31:0] write_regValue_o,


//�����ⲿ�洢������Ϣ
output reg[31:0] mem_address_o,    //��ַ
output reg[31:0] mem_data_o,       //Ҫд�������
output reg is_write_mem_o,        //�Ƿ���д����
output wire mem_enable_o        //ʹ���ź�

);

	reg mem_enable;
	assign mem_enable_o = mem_enable;






	always @(*)
	begin
		if(reset == 1'b1)
		begin
			is_write_o<=0;
			write_regAddress_o<=0;
			write_regValue_o<=0;
			
			mem_address_o<=0;
			mem_data_o<=0;
			is_write_mem_o<=1'b0;
			mem_enable<=0;
		end
		else
		begin
			is_write_o<=is_write_i;
			write_regAddress_o<=write_regAddress_i;
			write_regValue_o<=write_regValue_i;
			
			mem_address_o<=0;
			mem_data_o<=0;
			is_write_mem_o<=1'b0;
			mem_enable<=0;
			
			case(aluop_i)
				8'b11100011:                        //lw insrtuction
					begin
						mem_address_o<=mem_address_i;
						write_regValue_o<=mem_data_i;
						is_write_mem_o<=1'b0;
						mem_enable<=1'b1;
					end
				8'b11101011:                      //sw instruction
					begin
						mem_address_o<=mem_address_i;
						mem_data_o<=reg_operation2_value_i;
						is_write_mem_o<=1'b1;
						mem_enable<=1'b1;
					end
				default: begin
				end
			endcase
		end
	end
endmodule