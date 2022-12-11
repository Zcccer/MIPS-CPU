`timescale 1ns / 1ps



module hazard_unit(
	//IF
	output wire stallF,
	//ID
	output wire stallD,forwardaD,forwardbD,
	input wire branchD,
	input wire[4:0] rsD,rtD,
	//EX
	output wire flushE,
	output reg[1:0] forwardaE,forwardbE,
	input wire[4:0] rsE,rtE,writeregE,
	input wire memtoregE,regwriteE,
	//MEM
	input wire[4:0] writeregM,
	input wire regwriteM,memtoregM,
	//EX
	input wire[4:0] writeregW,
	input wire regwriteW
    ); 
    
    // forward unit
	//EX-data hazrd 
    always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end 
			else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end 
			else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end
	//ID-contol hazrd
    assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);

    // stall unit
	// stall in data hazard
	wire data_stall;
	assign #1 data_stall = memtoregE & (rtE == rsD | rtE == rtD);
	//stall in control hazrd
	wire ctr_stall;
	assign #1 ctr_stall = branchD &
				(regwriteE & (writeregE == rsD | writeregE == rtD) |
				 memtoregM &(writeregM == rsD | writeregM == rtD));
    // stall in data hazard | stall in control hazard
    assign #1 stallD = data_stall | ctr_stall;
    assign #1 stallF = stallD;
    assign #1 flushE = stallD;

	
endmodule