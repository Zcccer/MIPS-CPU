`timescale 1ns / 1ps

//top = mips + instruction memory + data memory , I used ip core instead of LUT to implement the memory,
//single port ram for data memory and single port rom for instruction memory
module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite
    );

	wire[31:0] pc,instr,readdata;

	mips mips(clk,rst,pc,instr,memwrite,dataadr,writedata,readdata);
	inst_mem imem(clk,pc[7:2],instr);
	data_mem dmem(~clk,memwrite,dataadr,writedata,readdata);
endmodule