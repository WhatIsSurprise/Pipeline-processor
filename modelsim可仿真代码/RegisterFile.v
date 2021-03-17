
module RegisterFile(reset, clk, reg_iswrite_enable,reg_isread1_enable,reg_isread2_enable, Read_regAddress1, Read_regAddress2, Write_regAddress, Write_dataValue, returnAddr_pc,
Read_dataValue1, Read_dataValue2);
	input wire reset, clk;      //时钟以及复位信号
	input wire reg_iswrite_enable,reg_isread1_enable,reg_isread2_enable;    //读使能，写使能信号
	input wire [4:0] Read_regAddress1, Read_regAddress2, Write_regAddress; //要操作的寄存器地址  
	input wire [31:0] Write_dataValue;                     //要写入的数据  
	input wire[31:0] returnAddr_pc;                  //写入$26  中断或者异常用到
	output reg[31:0] Read_dataValue1, Read_dataValue2;          //要读取的数据            
	
	(* dont_touch = "true"*)reg [31:0] RF_data[0:31];
	initial
	begin
		RF_data[0]<=0;
	end


    //读端口1
	always@(*) 
	begin
	    if(reset == 1'b1) 
	    begin
			Read_dataValue1 <= 0;
		end 
		else if(Read_regAddress1 == 5'b00000) begin
			Read_dataValue1<=0;
		end 
		else if((Read_regAddress1 == Write_regAddress)&&(reg_iswrite_enable == 1'b1)&&(reg_isread1_enable == 1'b1)) begin
			Read_dataValue1<=Write_dataValue;
		end 
		else if(reg_isread1_enable == 1'b1) begin
			Read_dataValue1<=RF_data[Read_regAddress1];
		end 
		else 
		begin
			Read_dataValue1<=0;
		end
		end
	
	
	//读端口2
	always@(*) begin
	    if(reset == 1'b1) 
	    begin
			Read_dataValue2 <= 0;
		end 
		else if(Read_regAddress2 == 5'b00000) begin
			Read_dataValue2<=0;
		end 
		else if((Read_regAddress2 == Write_regAddress)&&(reg_iswrite_enable == 1'b1)&&(reg_isread2_enable == 1'b1)) begin
			Read_dataValue2<=Write_dataValue;
		end 
		else if(reg_isread2_enable == 1'b1) begin
			Read_dataValue2<=RF_data[Read_regAddress2];
		end 
		else 
		begin
			Read_dataValue2<=0;
		end
		end

	
	//写操作
	always @(posedge clk)
    begin
	
	
    if(reset == 1'b0)
	begin
		if (reg_iswrite_enable && (Write_regAddress != 5'b00000)&&(Write_regAddress!=5'b11010))
		begin
			RF_data[Write_regAddress] <= Write_dataValue;
		end
		
		else if(returnAddr_pc!=0)
		begin
		    RF_data[26] <=returnAddr_pc;
		end
	end
	
	
	end

endmodule
			