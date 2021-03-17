module _connect(
input wire clk,
input wire reset,
input wire is_show_number,
output wire[6:0] digitial_o,
output wire[6:0] leds_o,
output wire[3:0] anns_o
);


	//连接指令存储器
	wire[31:0] inst_address;
	wire[31:0] inst;
	wire instMem_enable;
	
	
	//连接数据存储器
	wire[31:0] ram_address;
	wire[31:0] ram_data_input;
	wire[31:0] ram_data_output;
	wire is_write_ram;
	wire ram_enable;
	wire req_interrupt_ram;
	
	
	//连接ctrl模块
	wire[5:0] stall_ctrl;
	wire id_isReqStall;
	
	
	//实例化
	mips_cpu cpu0(
	.clk(clk),
	.reset(reset),
	.inst_fromROM_i(inst),
	.data_fromRAM_i(ram_data_output),
	.stall_ctrl(stall_ctrl),
	.req_interrupt_timer(req_interrupt_ram),
	
	//output
	.instAddress_toROM_o(inst_address),
	.instMemory_enable_o(instMem_enable),
		//连接到数据存储器
	.ram_address_o(ram_address),
	.ram_data_o(ram_data_input),
	.is_write_ram(is_write_ram),
	.ram_enable(ram_enable),
	.id_is_reqStall(id_isReqStall)
	);
	
	inst_memory instmem0(                 //指令rom
	.inst_enable(instMem_enable),
	.instAddress(inst_address),
	.inst(inst)
	);
	
	data_ram dataram0(
	.clk(clk),
	.ram_enable(ram_enable),
	.is_write_i(is_write_ram),
	.data_i(ram_data_input),
	.address(ram_address),
	.is_show_number(is_show_number),
	.data_o(ram_data_output),
	.is_interrupt_timer(req_interrupt_ram),
	.digitial_o(digitial_o),
	.anns_o(anns_o),
	.leds_o(leds_o)
	);
	
	
	ctrl ctrl0(
	.reset(reset),
	.stallreq_from_id(id_isReqStall),
	.stall(stall_ctrl)
	);
	
	
endmodule