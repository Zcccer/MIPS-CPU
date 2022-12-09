`timescale 1ns / 1ps

//controller = maindecoder + aludecoder
module controller(
	input wire clk,rst,
	input wire[5:0] op,funct,
	input wire zeroM,
	output wire[2:0] alucontrolE,
	output wire alusrcE,regdstE,
	output wire pcsrcM, memwriteM,
	output wire regwriteW,memtoregW,
	output wire jump
    );
	
	//ID
    wire[1:0] aluop;
    wire regwriteD,memtoregD,memwriteD,branchD,alusrcD,regdstD;
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

    //ID-EX
	wire regwriteE,memtoregE,memwriteE,branchE;

	flop_clear #(9) controlreg_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in({regwriteD,memtoregD,memwriteD,branchD,alucontrolD,alusrcD,regdstD}),
	.out({regwriteE,memtoregE,memwriteE,branchE,alucontrolE,alusrcE,regdstE})
    );

    //EX-MEM
    wire regwriteM,memtoregM,branchM;

	flop_clear #(4) controlreg_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in({regwriteE,memtoregE,memwriteE,branchE}),
	.out({regwriteM,memtoregM,memwriteM,branchM})
    );
    
	//MEM
    assign pcsrcM = branchM & zeroM;

    //MEM-WB

	flop_clear #(2) controlreg_W(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in({regwriteM,memtoregM}),
	.out({regwriteW,memtoregW})
    );




	

endmodule