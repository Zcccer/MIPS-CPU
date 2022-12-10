`timescale 1ns / 1ps


module datapath(
	input wire clk,rst,regwriteM,regwriteW,regdstE,alusrcE,memtoregE,memtoregW,pcsrcD,jump,branchD,regwriteE,memtoregM,
	input wire[2:0] alucontrolE,
	input wire[31:0] instr,readdataM,
	output wire equalD,zeroM,overflow,flushE,
	output wire[31:0] aluoutM,writedataM,pc,instrD
	);
	

    
	wire[31:0] pcplus4F,pcnext,pc_final;

    //IF
	wire[31:0] pcbranchD;
    pc_unit #(32) pc_unit(
	.clk(clk),
	.rst(rst),
	.en(~stallF),
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
	.d1(pcbranchD),
	.s(pcsrcD),
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

    flop_encl #(32) instr_D(
	.clk(clk),
	.rst(rst),
	.en(~stallD),
	.clear(pcsrcD),
	.in(instr),
	.out(instrD)
    );

    flop_encl #(32) pcplus4_D(
	.clk(clk),
	.rst(rst),
	.en(~stallD),
	.clear(pcsrcD),
	.in(pcplus4F),
	.out(pcplus4D)
    );
	 

	//ID
	wire[31:0] equal1D,equal2D,srcaD,writedataD,signimmD,signimmD_leftshift,resultW;
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

	mux2 #(32) IDforward_firmux(
	.d0(srcaD),
	.d1(aluoutM),
	.s(forwardaD),
	.out(equal1D)
    );
	mux2 #(32) IDforward_secmux(
	.d0(writedataD),
	.d1(aluoutM),
	.s(forwardbD),
	.out(equal2D)
    );

	compare compare(
	.in0(equal1D),
	.in1(equal2D),
	.out(equalD)
    );

	sign_extend sign_extend(
	.in(instrD[15:0]),
	.out(signimmD)
    );

	shiftleft shiftleft_2(
	.in(signimmD),
	.out(signimmD_leftshift)
    );

	adder pcbranchD_adder(
	.in0(signimmD_leftshift),
	.in1(pcplus4D),
	.out(pcbranchD)
    );

    //ID-EX
    wire[31:0] srcaE,writedataE1,writedataE2,signimmE,rd1E; 
	wire[4:0]  rsE,rtE,rdE;
	flop_clear #(32) srca_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(srcaD),
	.out(rd1E)
    );    
    
	flop_clear #(32) writedata_E1(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(writedataD),
	.out(writedataE1)
    );

	flop_clear #(5) rs_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(instrD[25:21]),
	.out(rsE)
    );

	flop_clear #(5) rt_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(instrD[20:16]),
	.out(rtE)
    );

	flop_clear #(5) rd_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(instrD[15:11]),
	.out(rdE)
    );

	flop_clear #(32) signimm_E(
	.clk(clk),
	.rst(rst),
	.clear(flushE),
	.in(signimmD),
	.out(signimmE)
    );


    //EX 
	wire zeroE;
	wire[31:0] aluresultE,srcbE;
	wire[4:0] writeregE;

	mux3 #(32) srcaE_mux(
	.d0(rd1E),
	.d1(resultW),
	.d2(aluoutM),
	.s(forwardaE),
	.out(srcaE)
    );
    
	mux3 #(32) writedataE2_mux(
	.d0(writedataE1),
	.d1(resultW),
	.d2(aluoutM),
	.s(forwardbE),
	.out(writedataE2)
    ); 

    mux2 #(32) srcbE_mux(
	.d0(writedataE2),
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
	.in(writedataE2),
	.out(writedataM)
    );
	flop_clear #(5) writereg_M(
	.clk(clk),
	.rst(rst),
	.clear(1'b0),
	.in(writeregE),
	.out(writeregM)
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
	
    // hazard unit
    wire forwardaD,forwardbD,forwardaE,forwardbE,stallF,stallD;

	hazard_unit hazard_unit(
	.rsD(instrD[25:21]),
	.rtD(instrD[21:16]),
	.rsE(rsE),
	.rtE(rtE),
	.writeregE(writeregE),
	.writeregM(writeregM),
	.writeregW(writeregW),
	.memtoregE(memtoregE),
    .regwriteM(regwriteM),
	.regwriteW(regwriteW),
	.branchD(branchD),
	.regwriteE(regwriteE),
	.memtoregM(memtoregM),
	.forwardaD(forwardaD),
	.forwardbD(forwardbD),
    .forwardaE(forwardaE),
	.forwardbE(forwardbE),
	.stallF(stallF),
	.stallD(stallD),
	.flushE(flushE)
    ); 

	


endmodule