`timescale 1ns / 1ps



module flop_encl #(parameter WIDTH = 8)(
	input wire clk,rst,en,clear,
	input wire[WIDTH-1:0] in,
	output reg[WIDTH-1:0] out
    );
	always @(posedge clk) begin
		if(rst) begin
			out <= 0;
		end else if(clear) begin
			out <= 0;
		end else if(en) begin
			out <= in;
		end
	end
endmodule