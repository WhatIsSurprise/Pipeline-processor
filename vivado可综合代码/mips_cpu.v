
module mips_cpu(
input wire clk,
input wire reset,
input wire[31:0] inst_fromROM_i,   //从指令存储器取得的指令
input wire[31:0] data_fromRAM_i,   //从数据存储器取得的数据
input wire[5:0] stall_ctrl,
input wire req_interrupt_timer,


output wire[31:0] instAddress_toROM_o,  //输出到指令存储器的地址
output wire instMemory_enable_o,    //指令存储器使能信号

//连接数据存储器
output wire[31:0] ram_address_o,
output wire[31:0] ram_data_o,       //写入数据存储器的数据
output wire is_write_ram,
output wire ram_enable,

output wire id_is_reqStall     //ID阶段是否请求stall
);
	wire[31:0] pc,id_pc_i,id_instruction_i;  //连接IF/ID模块与ID模块的变量
	
	
	//连接ID与ID/EX模块的变量
	wire[7:0] id_aluop_o;
	wire[2:0] id_alusel_o;
	wire[31:0] id_reg_operation1_o,id_reg_operation2_o;
	wire id_iswrite_o;
	wire[4:0]  id_write_regAddress_o;
	
	wire id_is_in_delayslot_o;
	wire[31:0] id_link_returnAddr_o;
	wire[31:0] id_instruction_o;
	
	//连接ID/EX与EX模块的变量
	wire[7:0] ex_aluop_i;
	wire[2:0] ex_alusel_i;
	wire[31:0] ex_reg_operation1_i,ex_reg_operation2_i;
	wire ex_iswrite_i;
	wire[4:0] ex_write_regAddress_i;
	
	wire ex_is_in_delayslot_i;
	wire[31:0] ex_link_address_i;
	wire[31:0] ex_instruction_i;
	
	
	//连接EX与EX/MEM模块的变量
	wire ex_iswrite_o;
	wire[4:0] ex_write_regAddress_o;
	wire[31:0] ex_write_regValue_o;
	
			//与数据存储器相关
	wire[7:0] ex_aluop_o;
	wire[31:0] ex_mem_address_o;
	wire[31:0] ex_reg_operValue_o;
	
	//连接EX/MEM与MEM的变量
	
	wire mem_iswrite_i;
	wire[4:0] mem_write_regAddress_i;
	wire[31:0] mem_write_regValue_i;
	
		//与数据存储器相关
	wire[7:0] MEM_aluop_i;
	wire[31:0] MEM_mem_address_i;
	wire[31:0] MEM_reg_operValue_o;
	
	
	
	//连接MEM模块与MEM/WB模块的变量
	wire mem_iswrite_o;
	wire[4:0] mem_write_regAddress_o;
	wire[31:0] mem_write_regValue_o;
	
	//连接MEM/WB模块与回写阶段的变量
	wire wb_iswrite_i;
	wire[4:0] wb_write_regAddress_i;
	wire[31:0] wb_write_regValue_i;
	
	
	//连接ID模块与寄存器堆rigister file的变量
	wire reg_isread1;
	wire reg_isread2;
	wire[31:0] Read_dataValue1,Read_dataValue2;
	wire[4:0] Read_regAddress1,Read_regAddress2;
	
	//连接PC与rigisterfile
	wire[31:0] return_addr_i;
	wire req_abnormal;
	
	
	wire is_in_delayslot_i;
	//wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire id_branch_flag_o;
	wire[31:0] branch_target_address;
	
	
	//pc_reg例化
	PC_reg reg0(.clk(clk),.reset(reset),
	.is_branch_i(id_branch_flag_o),
	.branch_targetAdd_i(branch_target_address),
	.stall(stall_ctrl),
	.req_interrupt_timer(req_interrupt_timer),
	.req_abnormal(req_abnormal),
	//output
	.inst_enable(instMemory_enable_o),
	.pc(pc),
	.returnAddr(return_addr_i)
	);
	assign instAddress_toROM_o = pc;//输出到指令存储器的地址就是pc的值
	
	
	
	//IF/ID模块的实例化
	IF_ID_rigister if_id_rigister0(.clk(clk),.reset(reset),
	.IF_PC(pc),
	.IF_instruction(inst_fromROM_i),
	.stall(stall_ctrl),
	.ID_PC(id_pc_i),
	.ID_instruction(id_instruction_i));
	
	
	
	//ID模块的实例化
	ID_depart id_depart0(.reset(reset),.pc_i(id_pc_i),.instruction_i(id_instruction_i),
		//来自rigister file的输入
	    .read_dataValue1_i(Read_dataValue1),
		.read_dataValue2_i(Read_dataValue2),
		
		
		
		
		//forwarding
		.ex_iswriteReg(ex_iswrite_o),
		.ex_writeRegData(ex_write_regValue_o),
		.ex_writeRegAddr(ex_write_regAddress_o),
		.ex_aluop_i(ex_aluop_o),
		.mem_iswriteReg(mem_iswrite_o),
		.mem_writeRegData(mem_write_regValue_o),
		.mem_writeRegAddr(mem_write_regAddress_o),
		
		
		.is_inDelaySlot_i(is_in_delayslot_i),
		
		
		
		//outputs
		//送入rigister file的信息
		.reg_isread1_o(reg_isread1),
		.reg_isread2_o(reg_isread2),
		
		.read_regAddress1_o(Read_regAddress1),
		.read_regAddress2_o(Read_regAddress2),
		
		//送入ID/EX模块的信息
		.ALUop_o(id_aluop_o),
		.ALUsel_o(id_alusel_o),
		
		.reg_operation1_o(id_reg_operation1_o),
		.reg_operation2_o(id_reg_operation2_o),
		.write_regAddress_o(id_write_regAddress_o),
		.is_write_o(id_iswrite_o),
		
		.is_branch_o(id_branch_flag_o),
		.branch_targetAddr_o(branch_target_address),
		.nextIs_inDelaySlot_o(next_inst_in_delayslot_o),
		.is_inDelaySlot_o(id_is_in_delayslot_o),
		.link_returnAddr(id_link_returnAddr_o),
		.instruction_o(id_instruction_o),
		.stallrequest(id_is_reqStall),
		.req_abnormal(req_abnormal)
	     );
		 
		 
		 
		 
	//RegisterFile的实例化
	RegisterFile rigisterfile0(
	.reset(reset),
	.clk(clk),
	.reg_iswrite_enable(wb_iswrite_i),
	.reg_isread1_enable(reg_isread1),
	.reg_isread2_enable(reg_isread2),
	.Read_regAddress1(Read_regAddress1),
	.Read_regAddress2(Read_regAddress2),
	.Write_regAddress(wb_write_regAddress_i),
	.Write_dataValue(wb_write_regValue_i),
	.returnAddr_pc(return_addr_i),
	//output
	.Read_dataValue1(Read_dataValue1),
	.Read_dataValue2(Read_dataValue2)
	);
	
	//ID/EX模块实例化
	ID_EX_rigister id_ex_teg0(
	.reset(reset),
	.clk(clk),
	.ID_ALUsel(id_alusel_o),
	.ID_ALUop(id_aluop_o),
	.reg_operation1_ID(id_reg_operation1_o),
	.reg_operation2_ID(id_reg_operation2_o),
	.write_regAddress_ID(id_write_regAddress_o),
	.is_write_ID(id_iswrite_o),
	
	.id_is_inDelaySlot(id_is_in_delayslot_o),
	.id_link_returnAddr(id_link_returnAddr_o),
	.id_next_instIsInDelaySlot_i(next_inst_in_delayslot_o),
	
	.id_instruction(id_instruction_o),
	.stall(stall_ctrl),
	
	//output 
	.ex_is_inDelaySlot(ex_is_in_delayslot_i),
	.ex_link_returnAddr(ex_link_address_i),
	.is_in_delaySlot_o(is_in_delayslot_i),
	
	
	//传递到EX阶段的信息
	.EX_ALUsel(ex_alusel_i),
	.EX_ALUop(ex_aluop_i),
	.reg_operation1_EX(ex_reg_operation1_i),
	.reg_operation2_EX(ex_reg_operation2_i),
	.write_regAddress_EX(ex_write_regAddress_i),
	.is_write_EX(ex_iswrite_i),
	
	.ex_instruction(ex_instruction_i)
	);
	
	//EX模块的实例化
	EX_depart ex_depart0(
	.reset(reset),
	.ALUop_i(ex_aluop_i),
	.ALUsel_i(ex_alusel_i),
	.reg_operation1_i(ex_reg_operation1_i),
	.reg_operation2_i(ex_reg_operation2_i),
	.write_regAddress_i(ex_write_regAddress_i),
	.is_write_i(ex_iswrite_i),
	
	//延迟槽判断、转移指令写入返回地址
	.is_inDelaySlot_i(ex_is_in_delayslot_i),   //从ID/EX模块传入，判断当前处于ID阶段的指令是不是延迟槽指令（异常处理用到）
	.link_returnAddr(ex_link_address_i),
	
	.inst_i(ex_instruction_i),
	
	
	//output
	.aluop_o(ex_aluop_o),
	.mem_address_o(ex_mem_address_o),
	.reg_operValue_o(ex_reg_operValue_o),
	
	
	.write_regAddress_o(ex_write_regAddress_o),
	.is_write_o(ex_iswrite_o),
	.write_regValue_o(ex_write_regValue_o)
	);
	
	//EX/MEM模块的实例化
	
	EX_MEM_rigister ex_mem_reg0(
	.reset(reset),
	.clk(clk),
	.write_regAddress_EX(ex_write_regAddress_o),
	.is_write_EX(ex_iswrite_o),
	.write_regValue_EX(ex_write_regValue_o),
	
	.aluop_EX(ex_aluop_o),
	.mem_address_EX(ex_mem_address_o),
	.reg_operation2_value_EX(ex_reg_operValue_o),
	
	
	//output
	.aluop_MEM(MEM_aluop_i),
	.mem_address_MEM(MEM_mem_address_i),
	.reg_operation2_value_MEM(MEM_reg_operValue_o),
	
	
	.is_write_MEM(mem_iswrite_i),
	.write_regAddress_MEM(mem_write_regAddress_i),
	.write_regValue_MEM(mem_write_regValue_i)
	);
	
	//MEM模块的实例化
	
	MEM_depart mem_depart0(
	.reset(reset),
	.write_regAddress_i(mem_write_regAddress_i),
	.is_write_i(mem_iswrite_i),
	.write_regValue_i(mem_write_regValue_i),
	
	.aluop_i(MEM_aluop_i),
	.mem_address_i(MEM_mem_address_i),
	.reg_operation2_value_i(MEM_reg_operValue_o),
	
	//来自数据存储器的信息
	.mem_data_i(data_fromRAM_i),
	
	
	//output
	.is_write_o(mem_iswrite_o),
	.write_regAddress_o(mem_write_regAddress_o),
	.write_regValue_o(mem_write_regValue_o),
	
	
	.mem_address_o(ram_address_o),
	.mem_data_o(ram_data_o),
	.is_write_mem_o(is_write_ram),
	.mem_enable_o(ram_enable)
	);
	
	//MEM/WB模块的实例化
	MEM_WB_rigister mem_wb_reg0(
	.reset(reset),
	.clk(clk),
	.write_regAddress_MEM(mem_write_regAddress_o),
	.write_regValue_MEM(mem_write_regValue_o),
	.is_writeReg_MEM(mem_iswrite_o),
	.write_regAddress_WB(wb_write_regAddress_i),
	.is_write_WB(wb_iswrite_i),
	.write_regValue_WB(wb_write_regValue_i)
	
	);
	
endmodule