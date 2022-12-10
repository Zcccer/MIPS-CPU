`timescale 1ns / 1ps

//controller = maindecoder + aludecoder
module controller(
	input wire clk,rst,
	input wire[5:0] op,funct,
	input wire equalD,flushE,
	output wire[2:0] alucontrolE,
	output wire alusrcE,regdstE,memtoregE,
	output wire pcsrcD, memwriteM,regwriteM,
	output wire regwriteW,memtoregW,
	output wire jump,branchD,regwriteE,memtoregM
    );
	
	//ID
    wire[1:0] aluop;
    wire regwriteD,memtoregD,memwriteD,alusrcD,regdstD;
    wire[2:0] alucontrolD;
	
	maindec  maindec(
	.op(op),
    .memtoreg(memtoregD),
	.memwrite(memwriteD),
	.branch(branchD),
	.alusrc(alusrcD),
	.regdst(regdstD),
	.regwrite(regwriteD),
	.jump(jump),
	.aluop(aluop)
    );

    aludec aludec(
	.funct(funct),
	.aluop(aluop),
	.alucontrol(alucontrolD)
    );

	assign pcsrcD = branchD & equalD;

    //ID-EX
	wire memwriteE;

	flop_clear #(8) controlreg_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in({regwriteD,memtoregD,memwriteD,alucontrolD,alusrcD,regdstD}),
	.out({regwriteE,memtoregE,memwriteE,alucontrolE,alusrcE,regdstE})
    );

    //EX-MEM

	flop_clear #(3) controlreg_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in({regwriteE,memtoregE,memwriteE}),
	.out({regwriteM,memtoregM,memwriteM})
    );
    
	//MEM
    

    //MEM-WB

	flop_clear #(2) controlreg_W(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in({regwriteM,memtoregM}),
	.out({regwriteW,memtoregW})
    );

endmodule