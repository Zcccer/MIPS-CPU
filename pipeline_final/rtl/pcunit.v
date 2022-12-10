`timescale 1ns / 1ps

// a copy from flop-en


module pc_unit #(parameter WIDTH = 8)(
	input wire clk,rst,en,
	input wire[WIDTH-1:0] in,
	output reg[WIDTH-1:0] out
    );
	always @(posedge clk,posedge rst) begin
		if(rst) begin
			out <= 0;
		end else if(en) begin
			out <= in;
		end
	end
endmodule