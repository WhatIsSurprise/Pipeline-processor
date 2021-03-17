module EX_depart(
input wire reset,       //复位信号
input wire[7:0] ALUop_i,  //ALU计算子类型
input wire[2:0] ALUsel_i,  //ALU计算类型
input wire[31:0] reg_operation1_i,   //源操作数1
input wire[31:0] reg_operation2_i,   //源操作数2
input wire[4:0] write_regAddress_i,  //写入的目的寄存器的地址
input wire is_write_i,         //是否写入目的寄存器


//转移/延迟槽
input wire is_inDelaySlot_i,      //EX阶段的指令是否位于延迟槽     (异常处理过程用到)
input wire[31:0] link_returnAddr,  //EX阶段转移指令保存的返回地址

(* dont_touch = "true"*) input wire[31:0] inst_i,        //当前处于执行阶段的指令


output wire[7:0] aluop_o,       //执行阶段的指令的运算子类型
output wire[31:0] mem_address_o, //加载/存储的地址
output wire[31:0] reg_operValue_o,   //要存储的数据的值


output reg[4:0] write_regAddress_o,
output reg is_write_o,
output reg[31:0] write_regValue_o    //要写入的目的寄存器的值
);

    assign aluop_o = ALUop_i;
	
	//计算加载/存储指令的地址
	assign mem_address_o = reg_operation1_i + {{16{inst_i[15]}},inst_i[15:0]};

	//此时reg_operation2_i为存储指令要存储的数据
    assign reg_operValue_o = reg_operation2_i;


	reg [31:0] logicout;         //逻辑运算的结果
	reg [31:0] shiftout;         //移位运算的结果
	
	wire is_ov_sum;             //保存是否溢出
	wire regOp1_eq_regOp2;      //记录第一个操作数是否等于第二个操作数
	wire regOp1_lt_regOp2;      //记录第一个操作数是否小于第二个操作数
	wire[31:0] reg_operation2_select;   //MUX:第二个操作数的补码or第二个操作数
	wire[31:0] reg_operation1_not;      //第一个操作数取反
	wire[31:0] sum_result;              //加法后的结果
	
	
	
	reg[31:0] last_metic;             //算术运算的最终结果
	
	
	//如果是减法、比较运算，第二个操作数则要取补码，赋值给reg_operation2_select运算
	assign reg_operation2_select=((ALUop_i == 8'b00100010)||(ALUop_i == 8'b00100011)||(ALUop_i == 8'b00101010))?
	                                (~reg_operation2_i+1):reg_operation2_i;
	
	
	assign sum_result = reg_operation1_i+reg_operation2_select;
	
	
	//判断是否溢出
	
	//两者为负，相加为正
	//两者为正，相加为负
	assign is_ov_sum = ((!reg_operation1_i[31] && !reg_operation2_select[31] && sum_result[31])
						|| (reg_operation1_i[31] && reg_operation2_select[31] && !sum_result[31]) );
	
	
	
	//比较两个操作数大小
	assign regOp1_lt_regOp2 = (ALUop_i == 8'b00101010)?
								((reg_operation1_i[31] && !reg_operation2_i[31]) || (!reg_operation1_i[31] && !reg_operation2_i[31] && sum_result[31])
								  || (reg_operation1_i[31] && reg_operation2_i[31] && sum_result[31])
								):(reg_operation1_i<reg_operation2_i);
								
	//第一个操作数取反
	assign reg_operation1_not = ~reg_operation1_i;
	
	
	
	//逻辑运算
	always @(*)
	begin
		if((reset == 1'b1) || (is_inDelaySlot_i == 1'b1))
		begin
			logicout <=0;

		end
		else
		begin
			case(ALUop_i)
				8'b00100101: logicout <= reg_operation1_i|reg_operation2_i;   //逻辑或计算
				8'b00100100: logicout <= reg_operation1_i&reg_operation2_i;   //与
				8'b00100111: logicout <= ~(reg_operation1_i|reg_operation2_i); //或非
				8'b00100110: logicout <= reg_operation1_i^reg_operation2_i;    //异或
				default: 
				begin
				logicout<=0;
				end
			endcase	
		end		
	end         //always end
	
	
	
	//移位运算
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
	
	
	
	
	//算术运算
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
	
	
	
	
	
	
    //根据操作类型选择输出
	always @(*)
	begin
		write_regAddress_o<=write_regAddress_i;
		
		
		
		
		//如果add addi sub subi指令结果溢出，则不写入寄存器
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