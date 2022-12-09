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
	
	wire memtoregW,alusrcE,regdstE,regwriteW,jump,pcsrcM,zeroM,overflow;
	wire[2:0] alucontrolE;
	wire[31:0] instrD;

	controller controller(
	.clk(clk),
	.rst(rst),
	.op(instrD[31:26]),
	.funct(instrD[5:0]),
	.zeroM(zeroM),
	.alucontrolE(alucontrolE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.pcsrcM(pcsrcM),
	.memwriteM(memwriteM),
	.regwriteW(regwriteW),
	.memtoregW(memtoregW),
    .jump(jump)
    );

    datapath datapath(
	.clk(clk),
	.rst(rst),
	.regwriteW(regwriteW),
	.regdstE(regdstE),
	.alusrcE(alusrcE),
	.memtoregW(memtoregW),
	.pcsrcM(pcsrcM),
	.jump(jump),
	.alucontrolE(alucontrolE),
	.instr(instr),
	.readdataM(readdata),
	.zeroM(zeroM),
	.overflow(overflow),
	.aluoutM(aluout),
	.writedataM(writedata),
	.pc(pc),
	.instrD(instrD)
	);

endmodule