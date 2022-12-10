`timescale 1ns / 1ps

//mips = contorller + datapath

module mips(
	input wire clk,rst,
	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire memwriteM,
	output wire[31:0] aluout,writedata,
	input wire[31:0] readdata 
    );
	
	wire flushE,memtoregE,alusrcE,regdstE,regwriteM,regwriteW,memtoregW,jump,pcsrcD,equalD,zeroM,overflow,branchD,regwriteE,memtoregM;
	wire[2:0] alucontrolE;
	wire[31:0] instrD;

	controller controller(
	.clk(clk),
	.rst(rst),
	.op(instrD[31:26]),
	.funct(instrD[5:0]),
	.equalD(equalD),
	.flushE(flushE),
	.alucontrolE(alucontrolE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.memtoregE(memtoregE),
	.pcsrcD(pcsrcD),
	.memwriteM(memwriteM),
	.regwriteM(regwriteM),
	.regwriteW(regwriteW),
	.memtoregW(memtoregW),
    .jump(jump),
	.branchD(branchD),
	.regwriteE(regwriteE),
	.memtoregM(memtoregM)
    );

    datapath datapath(
	.clk(clk),
	.rst(rst),
	.regwriteM(regwriteM),
	.regwriteW(regwriteW),
	.regdstE(regdstE),
	.alusrcE(alusrcE),
	.memtoregE(memtoregE),
	.memtoregW(memtoregW),
	.pcsrcD(pcsrcD),
	.jump(jump),
	.branchD(branchD),
	.regwriteE(regwriteE),
	.memtoregM(memtoregM),
	.alucontrolE(alucontrolE),
	.instr(instr),
	.readdataM(readdata),
	.equalD(equalD),
	.zeroM(zeroM),
	.overflow(overflow),
	.flushE(flushE),
	.aluoutM(aluout),
	.writedataM(writedata),
	.pc(pc),
	.instrD(instrD)
	);

endmodule