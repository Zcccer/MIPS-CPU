`timescale 1ns / 1ps

// a copy from flop

module pc_unit #(parameter WIDTH = 8)(
	input wire clk,rst,
	input wire[WIDTH-1:0] in,
	output reg[WIDTH-1:0] out
    );
	always @(negedge clk or posedge rst) begin
		if(rst) begin
			out <= 0;
		end else begin
			out <= in;
		end
	end
endmodule