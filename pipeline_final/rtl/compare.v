`timescale 1ns / 1ps

//Used to determine equality for the beq instruction at the ID stage

module compare(
	input wire [31:0] in0,in1,
	output wire out
    );
    
	assign out = (in0 == in1) ? 1 : 0;
endmodule