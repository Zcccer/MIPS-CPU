`timescale 1ns / 1ps

//top = mips + instruction memory + data memory , I used ip core instead of LUT to implement the memory,
//single port ram for data memory and single port rom for instruction memory
module top(
	input wire clk,rst,
	output wire[31:0] writedata,dataadr,
	output wire memwrite
    );

	wire[31:0] pc,instr,readdata;
    
    mips mips(
	.clk(clk),
    .rst(rst),
	.pc(pc),
	.instr(instr),
	.memwriteM(memwrite),
	.aluout(dataadr),
    .writedata(writedata),
	.readdata(readdata) 
    );
	
    instruction_mem instruction_mem (
   .clka(~clk),    // input wire clka
   .addra(pc[7:2]),  // input wire [5 : 0] addra
   .douta(instr)  // output wire [31 : 0] douta
   );

    data_mem data_mem (
   .clka(~clk),    // input wire clka
   .wea({4{memwrite}}),      // input wire [3 : 0] wea
   .addra(dataadr[9:0]),  // input wire [9 : 0] addra
   .dina(writedata),    // input wire [31 : 0] dina
   .douta(readdata)  // output wire [31 : 0] douta
   );

endmodule