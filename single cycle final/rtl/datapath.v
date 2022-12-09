`timescale 1ns / 1ps


module datapath(
	input wire clk,rst,regwrite,regdst,alusrc,memtoreg,pcsrc,jump,
	input wire[2:0] alucontrol,
	input wire[31:0] instr,readdata,
	output wire zero,overflow,
	output wire[31:0] aluresult,writedata,pc
	);
	

    wire[4:0] writereg;
	wire[31:0] pcplus4,pcbranch,pcnext,pc_final;
	wire[31:0] signimm,signimm_leftshift,srca,srcb,result;

    //IF
    pc_unit #(32) pc_unit(
	.clk(clk),
	.rst(rst),
	.in(pc_final), // pc'
	.out(pc)
    );

    adder pcplus4_adder(
	.in0(pc),
	.in1(32'b100),
	.out(pcplus4)
    );

	mux2 #(32) pc_firstmux(
	.d0(pcplus4),
	.d1(pcbranch),
	.s(pcsrc),
	.out(pcnext)
    );

    mux2 #(32) pc_secmux(
	.d0(pcnext),
	.d1({pcplus4[31:28],instr[25:0],2'b00}),   //In mips, jump instruction differ from the one of arm, it use {pcplus4[31:28],instr[25:0],2'b00} as target address
	.s(jump),
	.out(pc_final)
    );

	//ID
    regfile regfile(
	.clk(clk),
	.we3(regwrite),               
	.ra1(instr[25:21]),
	.ra2(instr[20:16]),
	.wa3(writereg),  
	.wd3(result),         
	.rd1(srca),
	.rd2(writedata)     
    );

	sign_extend sign_extend(
	.in(instr[15:0]),
	.out(signimm)
    );

    //EX 
    mux2 #(32) srcb_mux(
	.d0(writedata),
	.d1(signimm),
	.s(alusrc),
	.out(srcb)
    ); 

    alu alu(
	.a(srca),
	.b(srcb),
	.op(alucontrol),  
	.out(aluresult),  
	.overflow(overflow), 
	.zero(zero)
    );
    
	mux2 #(5) writereg_mux(
	.d0(instr[20:16]),
	.d1(instr[15:11]),
	.s(regdst),
	.out(writereg)
    );

    shiftleft shiftleft_2(
	.in(signimm),
	.out(signimm_leftshift)
    );

	adder pcbranch_adder(
	.in0(signimm_leftshift),
	.in1(pcplus4),
	.out(pcbranch)
    );
    
	//MEM

	// WB
	mux2 #(32) result_mux(
	.d0(aluresult),
	.d1(readdata),
	.s(memtoreg),
	.out(result)
    );
	

	


endmodule