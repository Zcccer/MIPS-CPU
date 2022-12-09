`timescale 1ns / 1ps


module datapath(
	input wire clk,rst,regwriteW,regdstE,alusrcE,memtoregW,pcsrcM,jump,
	input wire[2:0] alucontrolE,
	input wire[31:0] instr,readdataM,
	output wire zeroM,overflow,
	output wire[31:0] aluoutM,writedataM,pc,instrD
	);
	

    
	wire[31:0] pcplus4F,pcnext,pc_final;

    //IF
	wire[31:0] pcbranchM;
    pc_unit #(32) pc_unit(
	.clk(clk),
	.rst(rst),
	.in(pc_final), // pc'
	.out(pc)
    );

    adder pcplus4F_adder(
	.in0(pc),
	.in1(32'b100),
	.out(pcplus4F)
    );

	mux2 #(32) pc_firstmux(
	.d0(pcplus4F),
	.d1(pcbranchM),
	.s(pcsrcM),
	.out(pcnext)
    );

    mux2 #(32) pc_secmux(
	.d0(pcnext),
	.d1({pcplus4D[31:28],instrD[25:0],2'b00}),   //In mips, jump instruction differ from the one of arm, it use {pcplus4D[31:28],instr[25:0],2'b00} as target address
	.s(jump),                                    //After switching from single cycle to pipeline, the jump instruction is executed in the ID stage.
	.out(pc_final)
    );

    //IF-ID
    wire[31:0] pcplus4D;

    flop_clear #(32) instr_D(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(instr),
	.out(instrD)
    );

    flop_clear #(32) pcplus4_D(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(pcplus4F),
	.out(pcplus4D)
    );
	 

	//ID
	wire[31:0] srcaD,writedataD,signimmD,resultW;
    wire[4:0] writeregW;
    regfile regfile(
	.clk(clk),
	.we3(regwriteW),               
	.ra1(instrD[25:21]),
	.ra2(instrD[20:16]),
	.wa3(writeregW),  
	.wd3(resultW),         
	.rd1(srcaD),
	.rd2(writedataD)     
    );

	sign_extend sign_extend(
	.in(instrD[15:0]),
	.out(signimmD)
    );

    //ID-EX
    wire[31:0] srcaE,writedataE,signimmE,pcplus4E; 
	wire[4:0]  rtE,rdE;
	flop_clear #(32) srca_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(srcaD),
	.out(srcaE)
    );    
    
	flop_clear #(32) writedata_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(writedataD),
	.out(writedataE)
    );

	flop_clear #(5) rt_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(instrD[20:16]),
	.out(rtE)
    );

	flop_clear #(5) rd_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(instrD[15:11]),
	.out(rdE)
    );

	flop_clear #(32) signimm_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(signimmD),
	.out(signimmE)
    );

	flop_clear #(32) pcplus4_E(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(pcplus4D),
	.out(pcplus4E)
    );    

    //EX 
	wire zeroE;
	wire[31:0] aluresultE,srcbE,pcbranchE,signimmE_leftshift;
	wire[4:0] writeregE;
    mux2 #(32) srcbE_mux(
	.d0(writedataE),
	.d1(signimmE),
	.s(alusrcE),
	.out(srcbE)
    ); 

    alu alu(
	.a(srcaE),
	.b(srcbE),
	.op(alucontrolE),  
	.out(aluresultE),  
	.overflow(overflow), 
	.zero(zeroE)
    );
    
	mux2 #(5) writereg_mux(
	.d0(rtE),
	.d1(rdE),
	.s(regdstE),
	.out(writeregE)
    );

    shiftleft shiftleft_2(
	.in(signimmE),
	.out(signimmE_leftshift)
    );

	adder pcbranchE_adder(
	.in0(signimmE_leftshift),
	.in1(pcplus4E),
	.out(pcbranchE)
    );
    
	//EX-MEM
	
	wire[4:0] writeregM;
    
    flop_clear #(1) zero_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(zeroE),
	.out(zeroM)
    );
    flop_clear #(32) aluout_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(aluresultE),
	.out(aluoutM)
    );
	flop_clear #(32) writedata_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(writedataE),
	.out(writedataM)
    );
	flop_clear #(5) writereg_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(writeregE),
	.out(writeregM)
    );
	flop_clear #(32) pcbranch_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(pcbranchE),
	.out(pcbranchM)
    );

	//MEM
    wire[31:0] readdataW;

    flop_clear #(32) readdata_W(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(readdataM),
	.out(readdataW)
    );
    //MEM-WB
	wire[31:0] aluoutW;
	
    flop_clear #(32) aluout_W(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(aluoutM),
	.out(aluoutW)
    );
    
	flop_clear #(5) writereg_W(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(writeregM),
	.out(writeregW)
    );

	// WB
	mux2 #(32) resultW_mux(
	.d0(aluoutW),
	.d1(readdataW),
	.s(memtoregW),
	.out(resultW)
    );
	

	


endmodule