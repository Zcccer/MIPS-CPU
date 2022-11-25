`timescale 1ns / 1ps

//shift left 2

module sl2(
	input wire[31:0] a,
	output wire[31:0] y
    );

	assign y = {a[29:0],2'b00};
endmodule