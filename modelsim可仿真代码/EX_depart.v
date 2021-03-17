module EX_depart(
input wire reset,       //��λ�ź�
input wire[7:0] ALUop_i,  //ALU����������
input wire[2:0] ALUsel_i,  //ALU��������
input wire[31:0] reg_operation1_i,   //Դ������1
input wire[31:0] reg_operation2_i,   //Դ������2
input wire[4:0] write_regAddress_i,  //д���Ŀ�ļĴ����ĵ�ַ
input wire is_write_i,         //�Ƿ�д��Ŀ�ļĴ���


//ת��/�ӳٲ�
input wire is_inDelaySlot_i,      //EX�׶ε�ָ���Ƿ�λ���ӳٲ�     (�쳣��������õ�)
input wire[31:0] link_returnAddr,  //EX�׶�ת��ָ���ķ��ص�ַ

(* dont_touch = "true"*) input wire[31:0] inst_i,        //��ǰ����ִ�н׶ε�ָ��


output wire[7:0] aluop_o,       //ִ�н׶ε�ָ�������������
output wire[31:0] mem_address_o, //����/�洢�ĵ�ַ
output wire[31:0] reg_operValue_o,   //Ҫ�洢�����ݵ�ֵ


output reg[4:0] write_regAddress_o,
output reg is_write_o,
output reg[31:0] write_regValue_o    //Ҫд���Ŀ�ļĴ�����ֵ
);

    assign aluop_o = ALUop_i;
	
	//�������/�洢ָ��ĵ�ַ
	assign mem_address_o = reg_operation1_i + {{16{inst_i[15]}},inst_i[15:0]};

	//��ʱreg_operation2_iΪ�洢ָ��Ҫ�洢������
    assign reg_operValue_o = reg_operation2_i;


	reg [31:0] logicout;         //�߼�����Ľ��
	reg [31:0] shiftout;         //��λ����Ľ��
	
	wire is_ov_sum;             //�����Ƿ����
	wire regOp1_eq_regOp2;      //��¼��һ���������Ƿ���ڵڶ���������
	wire regOp1_lt_regOp2;      //��¼��һ���������Ƿ�С�ڵڶ���������
	wire[31:0] reg_operation2_select;   //MUX:�ڶ����������Ĳ���or�ڶ���������
	wire[31:0] reg_operation1_not;      //��һ��������ȡ��
	wire[31:0] sum_result;              //�ӷ���Ľ��
	
	
	
	reg[31:0] last_metic;             //������������ս��
	
	
	//����Ǽ������Ƚ����㣬�ڶ�����������Ҫȡ���룬��ֵ��reg_operation2_select����
	assign reg_operation2_select=((ALUop_i == 8'b00100010)||(ALUop_i == 8'b00100011)||(ALUop_i == 8'b00101010))?
	                                (~reg_operation2_i+1):reg_operation2_i;
	
	
	assign sum_result = reg_operation1_i+reg_operation2_select;
	
	
	//�ж��Ƿ����
	
	//����Ϊ�������Ϊ��
	//����Ϊ�������Ϊ��
	assign is_ov_sum = ((!reg_operation1_i[31] && !reg_operation2_select[31] && sum_result[31])
						|| (reg_operation1_i[31] && reg_operation2_select[31] && !sum_result[31]) );
	
	
	
	//�Ƚ�������������С
	assign regOp1_lt_regOp2 = (ALUop_i == 8'b00101010)?
								((reg_operation1_i[31] && !reg_operation2_i[31]) || (!reg_operation1_i[31] && !reg_operation2_i[31] && sum_result[31])
								  || (reg_operation1_i[31] && reg_operation2_i[31] && sum_result[31])
								):(reg_operation1_i<reg_operation2_i);
								
	//��һ��������ȡ��
	assign reg_operation1_not = ~reg_operation1_i;
	
	
	
	//�߼�����
	always @(*)
	begin
		if((reset == 1'b1) || (is_inDelaySlot_i == 1'b1))
		begin
			logicout <=0;

		end
		else
		begin
			case(ALUop_i)
				8'b00100101: logicout <= reg_operation1_i|reg_operation2_i;   //�߼������
				8'b00100100: logicout <= reg_operation1_i&reg_operation2_i;   //��
				8'b00100111: logicout <= ~(reg_operation1_i|reg_operation2_i); //���
				8'b00100110: logicout <= reg_operation1_i^reg_operation2_i;    //���
				default: 
				begin
				logicout<=0;
				end
			endcase	
		end		
	end         //always end
	
	
	
	//��λ����
	always @(*)
	begin
		if((reset == 1'b1) || (is_inDelaySlot_i == 1'b1))
		begin
			shiftout<=0;
		end
	
	    else
		begin
			case(ALUop_i)
				8'b01111100: shiftout<=reg_operation2_i<<reg_operation1_i[4:0];   //sll
				8'b00000010: shiftout<=reg_operation2_i>>reg_operation1_i[4:0];   //srl
				default: begin
					shiftout<=0;
				end
			endcase
		end
	end      //always end
	
	
	
	
	//��������
	always @(*)
	begin
		if((reset == 1'b1) || (is_inDelaySlot_i == 1'b1))
		begin
			last_metic<=0;
		end
		else
		begin
			case(ALUop_i)
			    //slt sltu
				8'b00101010,8'b00101011: last_metic<=regOp1_lt_regOp2;
				//add addi addu addiu
				8'b00100000,8'b00100001,8'b01010101,8'b01010110: last_metic<=sum_result;
				//sub subu
				8'b00100010,8'b00100011:last_metic<=sum_result;
				
				default:begin
				    last_metic<=0;
				end
			endcase
		end
		
	end
	
	
	
	
	
	
    //���ݲ�������ѡ�����
	always @(*)
	begin
		write_regAddress_o<=write_regAddress_i;
		
		
		
		
		//���add addi sub subiָ�����������д��Ĵ���
		if(((ALUop_i == 8'b00100000)||(ALUop_i == 8'b01010101) || (ALUop_i == 8'b00100010)) && (is_ov_sum == 1'b1))
		begin
			is_write_o<=1'b0;
		end
		else
		begin
			is_write_o<=is_write_i;
		end
		

		
		
		case(ALUsel_i)                          
			3'b001:  write_regValue_o<=logicout;
			3'b010:  write_regValue_o<=shiftout;
            3'b100:  write_regValue_o<=last_metic;
			3'b110:  write_regValue_o<=link_returnAddr;
			
			default
			begin
				write_regValue_o<=0;
			end
        endcase

	end

endmodule