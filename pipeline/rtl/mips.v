`timescale 1ns / 1ps

//mips = contorller + datapath

module mips(
	input wire clk,rst,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire memwrite,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata 
    );
	
	wire memtoreg,alusrc,regdst,regwrite,jump,pcsrc,zero,overflow;
	wire[2:0] alucontrol;
	
	controller c(
	.op(instr[31:26]),
	.funct(instr[5:0]),
	.zero(zero),
	.memtoreg(memtoreg),
	.memwrite(memwrite),
	.pcsrc(pcsrc),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.jump(jump),
	.alucontrol(alucontrol)
    );

    datapath datapath(
	.clk(clk),
	.rst(rst),
	.regwrite(regwrite),
	.regdst(regdst),
	.alusrc(alusrc),
	.memtoreg(memtoreg),
	.pcsrc(pcsrc),
	.jump(jump),
	.alucontrol(alucontrol),
	.instr(instr),
	.readdata(readdata),
	.zero(zero),
	.overflow(overflow),
	.aluresult(aluout),
	.writedata(writedata),
	.pc(pc)
	);

endmodule