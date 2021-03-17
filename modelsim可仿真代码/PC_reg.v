module PC_reg(

input wire clk,
input wire reset, 
input wire is_branch_i,              //是否发生转移
input wire[31:0] branch_targetAdd_i,   //转移的目标地址
(* dont_touch = "true"*)input wire[5:0] stall,
input wire req_interrupt_timer,   //来自定时器的中断信号
input wire req_abnormal,       //异常信号
output reg inst_enable,    //指令存储器使能信号
output reg[31:0] pc,
(* dont_touch = "true"*)output reg[31:0] returnAddr    //中断或异常处理完成后返回的地址
);
    
	(* dont_touch = "true"*)reg jump_interrupt_enable;
	(* dont_touch = "true"*)reg jump_abnormal_enable;
	(* dont_touch = "true"*)reg reset_jump_inte_abn;
	initial
	begin
		returnAddr <= 0;
		jump_interrupt_enable<=0;
		jump_abnormal_enable<=0;
		reset_jump_inte_abn<=1'b0;               //作用相当于PC[31] 置0允许中断 置1禁止
	end
    
   
   
    always @(posedge req_interrupt_timer or posedge reset_jump_inte_abn)
	begin	
	   if(reset_jump_inte_abn == 1'b0)
		begin
		   jump_interrupt_enable<=1'b1;
		end
		
		else begin
		   jump_interrupt_enable<=1'b0;
		end
	end
	
	
	
    always @(posedge req_abnormal or posedge reset_jump_inte_abn)
	begin	
	   if(reset_jump_inte_abn == 1'b0)
		begin
		   jump_abnormal_enable<=1'b1;
		end
		
		else begin
		   jump_abnormal_enable<=1'b0;
		end
	end

	
	
	always @(posedge clk)
	begin
	
	if(reset == 1'b1)
	begin
		inst_enable<=0;
	end
	else
	begin
		inst_enable<=1'b1;
	end
	
	end
	
	always @(posedge clk)
	begin
	
	if(inst_enable == 1'b1)
		begin
			if(stall[0] == 1'b0)	
				begin
					if(is_branch_i == 1'b1)
					begin
						pc <= branch_targetAdd_i;
					end
					
					else if((req_interrupt_timer == 1'b1) && (jump_interrupt_enable == 1'b1))
					begin
    					returnAddr = pc-4;
			            pc = 32'h00000004;   //跳到中断入口
			            reset_jump_inte_abn = 1'b1;    //内核态
					end
					
					
					
					
					else if((req_abnormal == 1'b1) && (jump_abnormal_enable == 1'b1))
					begin
    					returnAddr = pc-4;
			            pc = 32'h00000008;   //跳到异常入口
			            reset_jump_inte_abn = 1'b1;    //内核态
					end
					
					
					
					
					
					else
					begin
						pc<=pc+4'h4;
					end
				end
			else begin
			pc<=pc;
			end
			
		end
	else
		begin
			pc<=32'h00000000;
		end
	
	end
	
	
endmodule