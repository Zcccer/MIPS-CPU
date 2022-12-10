`timescale 1ns / 1ps



module mux2 #(parameter WIDTH = 8)(
	input wire[WIDTH-1:0] d0,d1,
	input wire s,
	output wire[WIDTH-1:0] out
    );
	
	assign out = s ? d1 : d0;
endmodule