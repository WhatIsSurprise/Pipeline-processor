
module ID_depart(
input wire reset,       //��λ�ź�
input wire[31:0] pc_i,  //����׶ζ�Ӧ��ָ���ַ
input wire[31:0] instruction_i,  //��ȡ����ָ��

//��rigister file�Ķ��˿ڶ�ȡ����ֵ
input wire[31:0] read_dataValue1_i,
input wire[31:0] read_dataValue2_i,



//ִ�н׶�ָ��ļ�����
input wire ex_iswriteReg,
input wire[31:0] ex_writeRegData,
input wire[4:0] ex_writeRegAddr,

input wire[7:0] ex_aluop_i,    //����EX�׶ε������������


//�ô�׶�ָ��ļ�����
input wire mem_iswriteReg,
input wire[31:0] mem_writeRegData,
input wire[4:0] mem_writeRegAddr,



input wire is_inDelaySlot_i,      //��ǰָ���ǲ����ӳٲ�ָ���Դ��ID/EX�εķ���



//���ɵ�rigisterfile�Ķ�ʹ���ź�
output reg reg_isread1_o,
output reg reg_isread2_o,


//Ҫ��ȡ��rigisterfile�ļĴ�����ַ
output reg[4:0] read_regAddress1_o,
output reg[4:0] read_regAddress2_o,


//����ִ�н׶ε���Ϣ
output reg[7:0] ALUop_o,   //alu���м����������
output reg[2:0] ALUsel_o,  //alu���м��������


output reg[31:0] reg_operation1_o,  //Դ������1��ֵ
output reg[31:0] reg_operation2_o,  //Դ������2��ֵ
output reg[4:0] write_regAddress_o,  //Ҫд���Ŀ��Ĵ�����ַ
output reg  is_write_o,           //�Ƿ�Ҫд��Ŀ��Ĵ���



//ת��ָ��Ҫ���ӵ�����ӿ�
output reg is_branch_o,
output reg[31:0] branch_targetAddr_o,
output reg nextIs_inDelaySlot_o,       //�ж���һ��ָ���ǲ����ӳٲ�ָ����ݵ�ǰָ���ǲ���ת��/��ָ֧���ж�
output reg is_inDelaySlot_o,          //��ǰָ���ǲ����ӳٲ�ָ��������һ�����ں�����ָʾEX�׶ε�ָ���ǲ����ӳٲ�ָ��
output reg[31:0] link_returnAddr,


output wire[31:0] instruction_o,     //��ǰ��������׶ε�ָ�������ȥ

output wire stallrequest,             //�Ƿ���������

output wire req_abnormal             //�Ƿ������쳣����

);

   assign instruction_o = instruction_i;
   
   
   

   reg reg1_loadrelate;    //Ҫ��ȡ�ļĴ���1�Ƿ�����һ��ָ�����load���
   reg reg2_loadrelate;   //Ҫ��ȡ�ļĴ���2�Ƿ�����һ��ָ�����load���
   
   wire pre_inst_isLoad;   //��ʾ��һ��ָ���Ƿ��Ǽ���ָ��
   assign pre_inst_isLoad = (ex_aluop_i == 8'b11100011)? 1'b1:1'b0;
   

   
   
   
   



   reg instvaild;    //ָʾָ���Ƿ���Ч
   reg[31:0] immediate;  //ָ����Ҫ��������
   
   wire[31:0] pc_plus8;    //pc+8
   wire[31:0] pc_plus4;    //pc+4
   assign pc_plus8 = pc_i+32'h00000008;
   assign pc_plus4 = pc_i+32'h00000004;
   
   
   wire[31:0] immediate_offsetExtern;//offset������λ���ٽ��з�����չ���ֵ
   assign immediate_offsetExtern = {{14{instruction_i[15]}},instruction_i[15:0],2'b00};
   
   
   
   
   
   
   
   
   
   wire[5:0] op=instruction_i[31:26];
   wire[4:0] op2 = instruction_i[10:6];
   wire[5:0] op3 = instruction_i[5:0];
   wire[4:0] op4 = instruction_i[20:16];
   
   //δ����ָ���쳣�����õ�
   reg is_case_op;
   reg is_case_op2;
   reg is_case_op3;
   reg is_case_op4;
   
   assign req_abnormal = ~(is_case_op & is_case_op2 & is_case_op3 & is_case_op4);
   
   
   initial
   begin
		is_case_op<=1'b1;
		is_case_op2<=1'b1;
		is_case_op3<=1'b1;
		is_case_op4<=1'b1;
   end
   
   
   
   
   
   
always @(*)
   begin
		if((reset == 1'b1)||(is_inDelaySlot_i == 1'b1))          //�����reset���ߵ�ǰָ�����ӳٲ�ָ��
		begin
			reg_isread1_o<=0;
			reg_isread2_o<=0;
			ALUop_o<=0;
			ALUsel_o<=0;
			read_regAddress1_o<=0;
			read_regAddress2_o<=0;
			write_regAddress_o<=0;
			is_write_o<=0;
			instvaild<=0;
			immediate<=0;
			
			is_branch_o<=0;
			branch_targetAddr_o<=0;
			nextIs_inDelaySlot_o<=0;
			link_returnAddr<=0;
			
		end
		
		else
		begin
			ALUop_o  <= 0;
			ALUsel_o <= 0;
			write_regAddress_o <=instruction_i[15:11];
			is_write_o <= 0;
			instvaild <= 1'b0;
			reg_isread1_o <= 0;
			reg_isread2_o <= 0;
			read_regAddress1_o <= instruction_i[25:21];
			read_regAddress2_o <= instruction_i[20:16];
			immediate <= 0;
			
			is_branch_o<=0;
			branch_targetAddr_o<=0;
			nextIs_inDelaySlot_o<=0;
			link_returnAddr<=0;
			
			
			case(op)
				6'b000000: 
					begin
					case(op2) 
						5'b00000:begin
									case(op3)
										6'b100101: begin                  //or instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100101;
													ALUsel_o<=3'b001;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
												   end
										6'b100100: begin                  //and instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100100;
													ALUsel_o<=3'b001;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;				
												   end
										6'b000100: begin                  //sllv instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00000100;
													ALUsel_o<=3'b010;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100110: begin                  //xor instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100110;
													ALUsel_o<=3'b001;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100111: begin                  //nor instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100111;
													ALUsel_o<=3'b001;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
												   
										6'b101010: begin                  //slt instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00101010;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b101011: begin                  //sltu instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00101011;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100000: begin                  //add instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100000;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100001: begin                  //addu instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100001;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100010: begin                  //sub instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100010;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b100011: begin                  //subu instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00100011;
													ALUsel_o<=3'b100;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b1;
													instvaild<=1'b1;
									 		       end
										6'b001000: begin                  //jr instruction
													is_write_o<=1'b0;
													ALUop_o<=8'b00001000;
													ALUsel_o<=3'b110;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b0;
													instvaild<=1'b1;
													is_branch_o<=1'b1;
													link_returnAddr<=0;
													nextIs_inDelaySlot_o<=1'b1;
													branch_targetAddr_o<=reg_operation1_o;
									 		       end   
										6'b001001: begin                  //jalr instruction
													is_write_o<=1'b1;
													ALUop_o<=8'b00001001;
													ALUsel_o<=3'b110;
													reg_isread1_o<=1'b1;
													reg_isread2_o<=1'b0;
													write_regAddress_o <=instruction_i[15:11];
													instvaild<=1'b1;
													is_branch_o<=1'b1;
													link_returnAddr<=pc_plus8;
													nextIs_inDelaySlot_o<=1'b1;
													branch_targetAddr_o<=reg_operation1_o;
									 		       end  
												   
												   
									    default:   begin
														is_case_op3<=1'b0;
									               end
									endcase          //end case(op3) 
						         end
						default: begin
									is_case_op2<=1'b0;
								 end
					endcase	                         //end case(op2)
					end
				6'b001010:                           //slti instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b00101010;
						ALUsel_o<=3'b100;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={{16{instruction_i[15]}},instruction_i[15:0]};   //�з�������չ
						write_regAddress_o<=instruction_i[20:16];
						instvaild<=1'b1;
					end
				6'b001011:                           //sltiu instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b01011000;
						ALUsel_o<=3'b100;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={{16{instruction_i[15]}},instruction_i[15:0]};   //�з�������չ
						write_regAddress_o<=instruction_i[20:16];
						instvaild<=1'b1;
					end
				6'b001000:                           //addi instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b01010101;
						ALUsel_o<=3'b100;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={{16{instruction_i[15]}},instruction_i[15:0]};   //�з�������չ
						write_regAddress_o<=instruction_i[20:16];
						instvaild<=1'b1;
					end
				6'b001001:                           //addiu instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b01010110;
						ALUsel_o<=3'b100;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={{16{instruction_i[15]}},instruction_i[15:0]};   //�з�������չ
						write_regAddress_o<=instruction_i[20:16];
						instvaild<=1'b1;
					end
				6'b001100:             //andi instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b00100100;
						ALUsel_o<=3'b001;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={16'h0,instruction_i[15:0]};
						instvaild<=1'b1;
						write_regAddress_o<=instruction_i[20:16];
					end
				6'b001111:             //lui instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b00100101;
						ALUsel_o<=3'b001;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={instruction_i[15:0],16'h0};
						instvaild<=1'b1;
						write_regAddress_o<=instruction_i[20:16];
					end
				6'b001101:             //ori instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b00100101;
						ALUsel_o<=3'b001;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={16'h0,instruction_i[15:0]};
						instvaild<=1'b1;
						write_regAddress_o<=instruction_i[20:16];
					end
				6'b001110:             //xori instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b00100110;
						ALUsel_o<=3'b001;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						immediate<={16'h0,instruction_i[15:0]};
						instvaild<=1'b1;
						write_regAddress_o<=instruction_i[20:16];
					end
				6'b000010:             //j instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b01001111;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b0;
						reg_isread2_o<=1'b0;
						instvaild<=1'b1;
						link_returnAddr<=0;
						is_branch_o<=1'b1;
						nextIs_inDelaySlot_o<=1'b1;
						branch_targetAddr_o<={pc_plus4[31:28],instruction_i[25:0],2'b00};
					end
				6'b000011:             //jal instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b01010000;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b0;
						reg_isread2_o<=1'b0;
						instvaild<=1'b1;
						write_regAddress_o<=5'b11111;        //д��31�żĴ���
						link_returnAddr<=pc_plus8;          
						is_branch_o<=1'b1; 
						nextIs_inDelaySlot_o<=1'b1;
						branch_targetAddr_o<={pc_plus4[31:28],instruction_i[25:0],2'b00};
					end
				6'b000100:             //beq instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b01010001;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b1;
						instvaild<=1'b1;
						if(reg_operation1_o == reg_operation2_o)
						begin
							is_branch_o<=1'b1;
							branch_targetAddr_o<=pc_plus4+immediate_offsetExtern;
							nextIs_inDelaySlot_o<=1'b1;
							link_returnAddr<=0;
						end
					end
				6'b000101:             //bne instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b01010010;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b1;
						instvaild<=1'b1;
						if(reg_operation1_o != reg_operation2_o)
						begin
							is_branch_o<=1'b1;
							branch_targetAddr_o<=pc_plus4+immediate_offsetExtern;
							nextIs_inDelaySlot_o<=1'b1;
							link_returnAddr<=0;
						end
					end
				6'b000110:             //blez instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b01010011;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						instvaild<=1'b1;
						if((reg_operation1_o[31] == 1'b1)||(reg_operation1_o == 0))
						begin
							is_branch_o<=1'b1;
							branch_targetAddr_o<=pc_plus4+immediate_offsetExtern;
							nextIs_inDelaySlot_o<=1'b1;
							link_returnAddr<=0;
						end
					end
				6'b000111:             //bgtz instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b01010100;
						ALUsel_o<=3'b110;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						instvaild<=1'b1;
						if((reg_operation1_o[31] == 1'b0)&&(reg_operation1_o != 0))
						begin
							is_branch_o<=1'b1;
							branch_targetAddr_o<=pc_plus4+immediate_offsetExtern;
							nextIs_inDelaySlot_o<=1'b1;
							link_returnAddr<=0;
						end
					end
					
				6'b100011:             //lw instruction
					begin
						is_write_o<=1'b1;
						ALUop_o<=8'b11100011;
						ALUsel_o<=3'b111;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b0;
						instvaild<=1'b1;
						write_regAddress_o<=instruction_i[20:16];
					end
					
				6'b101011:             //sw instruction
					begin
						is_write_o<=1'b0;
						ALUop_o<=8'b11101011;
						ALUsel_o<=3'b111;
						reg_isread1_o<=1'b1;
						reg_isread2_o<=1'b1;
						instvaild<=1'b1;
					end
					
					
				6'b000001:             //bltz instruction
					begin
						case(op4)
							5'b00000:
								begin
									is_write_o<=1'b0;
									ALUop_o<=8'b01000000;
									ALUsel_o<=3'b110;
									reg_isread1_o<=1'b1;
									reg_isread2_o<=1'b0;
									instvaild<=1'b1;
									if(reg_operation1_o[31] == 1'b1)
									begin
										is_branch_o<=1'b1;
										branch_targetAddr_o<=pc_plus4+immediate_offsetExtern;
										nextIs_inDelaySlot_o<=1'b1;
										link_returnAddr<=0;
									end
								end
							default: begin
										is_case_op4<=1'b0;
							end
						endcase	    //endcase op4	
					end
					
		        default:begin
						is_case_op<=1'b0;
				end
			endcase             //end  case(op)
			if(instruction_i[31:21] == 11'b00000000000) begin
				if(op3 == 6'b000000) begin               //sll instruction
					is_write_o<=1'b1;
					ALUop_o<=8'b01111100;
					ALUsel_o<=3'b010;
					reg_isread1_o<=1'b0;
					reg_isread2_o<=1'b1;
					immediate[4:0] <=instruction_i[10:6];
					write_regAddress_o<=instruction_i[15:11];
					instvaild<=1'b1;
				end
				else if(op3 == 6'b000010) begin         //srl instruction
					is_write_o<=1'b1;
					ALUop_o<=8'b00000010;
					ALUsel_o<=3'b010;
					reg_isread1_o<=1'b0;
					reg_isread2_o<=1'b1;
					immediate[4:0] <=instruction_i[10:6];
					write_regAddress_o<=instruction_i[15:11];
					instvaild<=1'b1;
				end
				
			end

		end            //if end
   
   end                 //always end
   
   //���is_inDelaySlot_oָʾ��ǰָ���Ƿ����ӳٲ�ָ��
   always @(*)
   begin
		if(reset == 1'b1)
		begin
			is_inDelaySlot_o<=1'b0;
		end
		else
		begin
			is_inDelaySlot_o<=is_inDelaySlot_i;
		end
		
   end
   
   
   
   
   
   
   
   
   
   
   
   
   
   
always @(*)
   begin
		if(reset == 1'b1)
		begin
			reg_operation1_o<=0;
			reg1_loadrelate<=0;
		end
		else 
		begin
		if((pre_inst_isLoad == 1'b1)&&(ex_writeRegAddr == read_regAddress1_o)&&(reg_isread1_o == 1'b1))
		   begin
			  reg1_loadrelate<=1'b1;
			  reg_operation1_o<=0;
		   end
		//forwarding
		else if((reg_isread1_o == 1'b1)&&(ex_iswriteReg == 1'b1)&&(ex_writeRegAddr == read_regAddress1_o)) 
		begin
		    reg_operation1_o<=ex_writeRegData;
		    reg1_loadrelate<=0;
		end
		else if ((reg_isread1_o == 1'b1)&&(mem_iswriteReg == 1'b1)&&(mem_writeRegAddr == read_regAddress1_o)) begin
			reg_operation1_o<=mem_writeRegData;
			reg1_loadrelate<=0;
		end
		

		else if(reg_isread1_o == 1'b1)
		begin
			reg_operation1_o <= read_dataValue1_i;
			reg1_loadrelate<=0;
		end
		else if(reg_isread1_o == 1'b0)
		begin
			reg_operation1_o<=immediate;
			reg1_loadrelate<=0;
		end
		else
		begin
			reg_operation1_o<=0;
			reg1_loadrelate<=0;
		end
		end
   end
   

always @(*)
   begin
		if(reset == 1'b1)
		begin
			reg_operation2_o<=0;
			reg2_loadrelate<=1'b0;
		end
		else if((pre_inst_isLoad == 1'b1)&&(ex_writeRegAddr == read_regAddress2_o)&&(reg_isread2_o == 1'b1))
		begin
		    reg_operation2_o<=0;
			reg2_loadrelate<=1'b1;
		end
		
		//forwarding
		else if((reg_isread2_o == 1'b1)&&(ex_iswriteReg == 1'b1)&&(ex_writeRegAddr == read_regAddress2_o)) begin
		    reg_operation2_o<=ex_writeRegData;
		    reg2_loadrelate<=1'b0;
		end
		else if ((reg_isread2_o == 1'b1)&&(mem_iswriteReg == 1'b1)&&(mem_writeRegAddr == read_regAddress2_o)) begin
			reg_operation2_o<=mem_writeRegData;
			reg2_loadrelate<=1'b0;
		end
				
		else if(reg_isread2_o == 1'b1)
		begin
			reg_operation2_o <= read_dataValue2_i;
			reg2_loadrelate<=1'b0;
		end
		else if(reg_isread2_o == 1'b0)
		begin
			reg_operation2_o<=immediate;
			reg2_loadrelate<=1'b0;
		end
		else
		begin
			reg_operation2_o<=0;
			reg2_loadrelate<=1'b0;
		end
   end
    
   assign stallrequest = reg1_loadrelate|reg2_loadrelate;     //�����Ƕ��˿�1���Ƕ��˿�2����load_use��أ���Ҫ��ͣ��ˮ��
	
endmodule