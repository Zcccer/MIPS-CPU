`timescale 1ns / 1ps

// a d-flop with clear signal

module flop_clear #(parameter WIDTH = 8)(
	input wire clk,rst,clear,
	input wire[WIDTH-1:0] in,
	output reg[WIDTH-1:0] out
    );

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			out <= 0;
		end else if (clear)begin
			out <= 0;
		end else begin 
			out <= in;
		end
	end
endmodule
