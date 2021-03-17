module data_ram(
input wire clk,
input wire ram_enable,     //存储器使能
input wire is_write_i,     //是否写入
input wire[31:0] data_i,   //要写入的数据
input wire[31:0] address,  //访问的地址
input wire is_show_number,

output reg[31:0] data_o,    //输出数据
output wire is_interrupt_timer,   //定时器是否请求处理中断
output wire[6:0] digitial_o,
output wire[3:0] anns_o,
output wire[6:0] leds_o
);
	parameter RAM_SIZE = 512;
	parameter RAM_SIZE_BIT = 8;
	integer count_digi;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];     //数据存储器
	
	
    //外设存储空间
	reg[31:0] TH;
	reg[31:0] TL;
	reg[2:0] TCON;
	reg[6:0]  leds;
	reg[11:0] digitalTube;
	(* dont_touch = "true"*)reg[31:0] systick;
	wire[31:0] systick_o;
	assign systick_o = systick;
	
	assign is_interrupt_timer = TCON[0] & TCON[1] & TCON[2];
	
	assign leds_o = leds;                 //输出led灯
	
	integer i;
	reg[31:0] number_show;
    initial
	begin
	    i<=0;
	    number_show<=0;
	    leds<=7'b0000000;
	    count_digi<=0;
		systick<=0;
		digitalTube<=0;
		TL<=0;
		TH<=0;
		RAM_data[500]<=32'h00000000;
//随机数
RAM_data[0]<=32'h00007593;
RAM_data[1]<=32'h00008977;
RAM_data[2]<=32'h00007347;
RAM_data[3]<=32'h00005567;
RAM_data[4]<=32'h00003971;
RAM_data[5]<=32'h00004123;
RAM_data[6]<=32'h00002965;
RAM_data[7]<=32'h00002737;
RAM_data[8]<=32'h00009501;
RAM_data[9]<=32'h00009931;
RAM_data[10]<=32'h00002745;
RAM_data[11]<=32'h00008174;
RAM_data[12]<=32'h00003117;
RAM_data[13]<=32'h00001153;
RAM_data[14]<=32'h00002749;
RAM_data[15]<=32'h00009814;
RAM_data[16]<=32'h00002793;
RAM_data[17]<=32'h00002295;
RAM_data[18]<=32'h00006590;
RAM_data[19]<=32'h00002057;
RAM_data[20]<=32'h00005849;
RAM_data[21]<=32'h00004027;
RAM_data[22]<=32'h00007443;
RAM_data[23]<=32'h00003412;
RAM_data[24]<=32'h00008412;
RAM_data[25]<=32'h00006869;
RAM_data[26]<=32'h00008574;
RAM_data[27]<=32'h00008315;
RAM_data[28]<=32'h00001891;
RAM_data[29]<=32'h00007117;
RAM_data[30]<=32'h00008920;
RAM_data[31]<=32'h00005403;
RAM_data[32]<=32'h00001394;
RAM_data[33]<=32'h00004489;
RAM_data[34]<=32'h00009253;
RAM_data[35]<=32'h00001531;
RAM_data[36]<=32'h00004363;
RAM_data[37]<=32'h00005715;
RAM_data[38]<=32'h00003376;
RAM_data[39]<=32'h00005820;
RAM_data[40]<=32'h00005186;
RAM_data[41]<=32'h00009567;
RAM_data[42]<=32'h00006007;
RAM_data[43]<=32'h00003864;
RAM_data[44]<=32'h00001451;
RAM_data[45]<=32'h00009331;
RAM_data[46]<=32'h00007828;
RAM_data[47]<=32'h00003025;
RAM_data[48]<=32'h00008958;
RAM_data[49]<=32'h00002208;
RAM_data[50]<=32'h00008929;
RAM_data[51]<=32'h00004511;
RAM_data[52]<=32'h00007568;
RAM_data[53]<=32'h00002114;
RAM_data[54]<=32'h00003434;
RAM_data[55]<=32'h00001057;
RAM_data[56]<=32'h00002435;
RAM_data[57]<=32'h00004875;
RAM_data[58]<=32'h00002085;
RAM_data[59]<=32'h00007767;
RAM_data[60]<=32'h00006424;
RAM_data[61]<=32'h00006437;
RAM_data[62]<=32'h00004069;
RAM_data[63]<=32'h00008663;
RAM_data[64]<=32'h00003374;
RAM_data[65]<=32'h00006042;
RAM_data[66]<=32'h00006088;
RAM_data[67]<=32'h00006212;
RAM_data[68]<=32'h00008556;
RAM_data[69]<=32'h00009141;
RAM_data[70]<=32'h00003958;
RAM_data[71]<=32'h00002495;
RAM_data[72]<=32'h00005205;
RAM_data[73]<=32'h00008341;
RAM_data[74]<=32'h00005669;
RAM_data[75]<=32'h00005926;
RAM_data[76]<=32'h00004408;
RAM_data[77]<=32'h00003756;
RAM_data[78]<=32'h00008830;
RAM_data[79]<=32'h00008789;
RAM_data[80]<=32'h00002329;
RAM_data[81]<=32'h00001722;
RAM_data[82]<=32'h00006490;
RAM_data[83]<=32'h00006064;
RAM_data[84]<=32'h00001788;
RAM_data[85]<=32'h00003334;
RAM_data[86]<=32'h00009186;
RAM_data[87]<=32'h00009758;
RAM_data[88]<=32'h00003667;
RAM_data[89]<=32'h00005289;
RAM_data[90]<=32'h00006581;
RAM_data[91]<=32'h00004791;
RAM_data[92]<=32'h00006225;
RAM_data[93]<=32'h00004424;
RAM_data[94]<=32'h00006607;
RAM_data[95]<=32'h00002409;
RAM_data[96]<=32'h00008292;
RAM_data[97]<=32'h00009595;
RAM_data[98]<=32'h00001463;
RAM_data[99]<=32'h00001461;

	
	end
	
	//读取存储器的值
	always @(*)
	begin
	if(ram_enable) 
	begin
		if(address == 32'h40000000) begin
			data_o <=TH;
		end else if(address == 32'h40000004) begin
		    data_o <=TL;
		end else if(address == 32'h40000008) begin
		    data_o <={29'b0,TCON};
		end else if(address == 32'h4000000c) begin
			data_o <={24'b0,leds};
		end else if(address == 32'h40000010) begin
			data_o <={20'b0,digitalTube};
		end else if(address == 32'h40000014) begin
			data_o <=systick;
		end else if(address <32'h40000000) begin
			data_o <=RAM_data[address[RAM_SIZE_BIT + 1:2]];
		end else begin
			data_o<=32'h00000000;
		end
	end
	else
	begin
	   data_o<=32'h00000000;
	end
	end
	
	
	//写入存储器
	always @(posedge clk)
	begin
	   systick = systick+1;
	   if(is_write_i)
	    begin
		  case(address)
			 32'h40000008:   TCON <= data_i[2:0];
			 32'h4000000c:	leds <= data_i[6:0];
			 default: RAM_data[address[RAM_SIZE_BIT + 1:2]] <= data_i;
		  endcase
		 end
     end

	
	
	
	//定时器
	always @(posedge clk)
	begin
		
		if(TCON[0] == 1'b1)
		begin
			if(TL == 32'hffffffff) begin 
				TL<=TH;
			end	
			else
			begin
				TL<=TL+1;
			end
		end
	
	end
	
	
	
	//数码管显示

	
	reg [31:0] pass_rigisterfile;
    //wire count;
    //count_show count_show1(clk,count);
    always @(posedge is_show_number)
    begin
          pass_rigisterfile<=RAM_data[number_show];
          number_show = number_show+1;
    end
    
	
    wire [3:0] thousand;
    wire [3:0] hundred;
    wire [3:0] ten;
    wire [3:0] one;
	
	reg[3:0] pass_number;
	reg[3:0] pass_ann;

    wire scanning_sig;
    signalinput_show signalinput_show1(clk,scanning_sig);
	
    assign thousand[3:0]=pass_rigisterfile[15:12];
    assign hundred[3:0]=pass_rigisterfile[11:8];
    assign ten[3:0]=pass_rigisterfile[7:4];
    assign one[3:0]=pass_rigisterfile[3:0];

	always @(posedge scanning_sig)
	begin
		if(count_digi == 0)
			begin
			
				pass_number<=one;
				pass_ann<=4'b1110;
				count_digi=count_digi+1;
			end
		else if(count_digi == 1)
			begin
				pass_number<=ten;
				pass_ann<=4'b1101;
				count_digi=count_digi+1;
			end
		else if(count_digi == 2)
			begin
				pass_number<=hundred;
				pass_ann<=4'b1011;
				count_digi=count_digi+1;
			end
		else if(count_digi == 3)
			begin
				pass_number<=thousand;
				pass_ann<=4'b0111;
				count_digi=count_digi+1;
			end
		else if(count_digi == 4)
		begin
			count_digi<=0;
		end
	end
	

	
	BCDoutput BCDoutput0(       //转换成数码管显示
	.din_num(pass_number),
	.din_anns(pass_ann),
	.dout(digitial_o),
	.dout_ann(anns_o)
	);
endmodule