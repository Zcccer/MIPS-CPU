`timescale 1ns / 1ps

//controller = maindecoder + aludecoder
module controller(
	input wire[5:0] op,funct,
	input wire zero,
	output wire memtoreg,memwrite,
	output wire pcsrc,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[2:0] alucontrol
    );
	wire[1:0] aluop;
	wire branch;
    
	maindec  md(
	.op(op),
    .memtoreg(memtoreg),
	.memwrite(memwrite),
	.branch(branch),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.jump(jump),
	.aluop(aluop)
    );
    aludec dc(
	.funct(funct),
	.aluop(aluop),
	.alucontrol(alucontrol)
    );
	assign pcsrc = branch & zero;

endmodule