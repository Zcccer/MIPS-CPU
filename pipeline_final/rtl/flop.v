`timescale 1ns / 1ps

// a d-flop with clk and reset signals, it can be use in pc unit and pipeline register

module flop #(parameter WIDTH = 8)(
	input wire clk,rst,
	input wire[WIDTH-1:0] in,
	output reg[WIDTH-1:0] out
    );
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			out <= 0;
		end else begin
			out <= in;
		end
	end
endmodule