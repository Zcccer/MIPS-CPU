`timescale 1ns / 1ps



module adder(
	input wire[31:0] in0,in1,
	output wire[31:0] out
    );

	assign out = in0 + in1;
endmodule