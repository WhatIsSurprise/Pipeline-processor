module ID_EX_rigister(
input wire reset,
input wire clk,
input wire[2:0] ID_ALUsel,       //ID阶段的指令运算类�?
input wire[7:0] ID_ALUop,        //ID阶段指令运算的子类型
input wire[31:0] reg_operation1_ID,  //ID阶段传过来的源操作数1
input wire[31:0] reg_operation2_ID,  //ID阶段传过来的源操作数2
input wire[4:0]  write_regAddress_ID,   //ID阶段要写入的寄存器地�?
input wire is_write_ID,                              //是否写入目的寄存�?

//ID阶段延迟�?
input wire id_is_inDelaySlot,
input wire[31:0] id_link_returnAddr,
input wire id_next_instIsInDelaySlot_i,


//来源于ID阶段的指�?
input wire[31:0] id_instruction,

(* dont_touch = "true"*)input wire[5:0] stall,             //阻塞指令添加

output reg ex_is_inDelaySlot,         //EX阶段的指令是否是延迟槽指令，根据打入的id_is_inDelaySlot判断
output reg[31:0] ex_link_returnAddr,
output reg is_in_delaySlot_o,      //处于译码阶段的指令是否是延迟槽指令，根据打入的id_next_instIsInDelaySlot_i判断并反馈给ID�?

//将要传到EX阶段的信�?
output reg[2:0] EX_ALUsel,
output reg[7:0] EX_ALUop,
output reg[31:0] reg_operation1_EX,
output reg[31:0] reg_operation2_EX,
output reg[4:0] write_regAddress_EX,
output reg is_write_EX,

(* dont_touch = "true"*)output reg[31:0] ex_instruction
);
	always @(posedge clk)
	begin
		if(reset == 1'b1)
		begin
			EX_ALUsel<=0;
			EX_ALUop<=0;
			reg_operation1_EX<=0;
			reg_operation2_EX<=0;
			write_regAddress_EX<=0;
			is_write_EX<=0;
			
			ex_is_inDelaySlot<=0;
			ex_link_returnAddr<=0;
			is_in_delaySlot_o<=0;
			ex_instruction<=0;
		end
		else if((stall[2] == 1'b1)&&(stall[3] == 1'b0))
		begin
			EX_ALUsel<=3'b000;
			EX_ALUop<=8'b00000000;
			reg_operation1_EX<=0;
			reg_operation2_EX<=0;
			write_regAddress_EX<=0;
			is_write_EX<=0;
			
			ex_is_inDelaySlot<=0;
			ex_link_returnAddr<=0;
			is_in_delaySlot_o<=0;
			ex_instruction<=0;
		end
		
		
		
		else if(stall[2] == 1'b0)
		begin
			EX_ALUsel<=ID_ALUsel;
			EX_ALUop<=ID_ALUop;
			reg_operation1_EX<=reg_operation1_ID;
			reg_operation2_EX<=reg_operation2_ID;
			write_regAddress_EX<=write_regAddress_ID;
			is_write_EX<=is_write_ID;
			
			ex_is_inDelaySlot<=id_is_inDelaySlot;
			ex_link_returnAddr<=id_link_returnAddr;
			is_in_delaySlot_o<=id_next_instIsInDelaySlot_i;
			ex_instruction<=id_instruction;

		end
			
	end


endmodule