`timescale 1ns / 1ps


//IF_ID�μĴ�����ʵ��
module IF_ID_rigister(
input wire clk,
input wire reset,
input wire[31:0] IF_PC,         //IF�׶ζ�Ӧ��ָ���ַ
input wire[31:0] IF_instruction,    //IF�׶ζ�Ӧ��ָ��

(* dont_touch = "true"*)input wire[5:0] stall,

output reg[31:0] ID_PC,         //ID�׶ζ�Ӧ��ָ���ַ
(* dont_touch = "true"*)output reg[31:0] ID_instruction     //ID�׶ζ�Ӧ��ָ��
    );
always @(posedge clk)
begin
   if(reset == 1'b1)
       begin
         ID_PC <= 0 ;
         ID_instruction <= 0;
       end
   else if(stall[1] == 1'b1 && stall[2] == 1'b0)
      begin
		 ID_PC <= 0 ;
         ID_instruction <= 0;
      end
    else if(stall[1] == 1'b0)
      begin
	    ID_PC <=IF_PC;
        ID_instruction<=IF_instruction;	
      end
end
   
endmodule
