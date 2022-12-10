`timescale 1ns / 1ps



module regfile(
	input wire clk,
	input wire we3,               //write enable
	input wire[4:0] ra1,ra2,wa3,  //adderess
	input wire[31:0] wd3,         //write data
	output wire[31:0] rd1,rd2     //read data
    );

	reg [31:0] rf[31:0];

	always @(posedge clk) begin     //Regfiles are written along the descending edge of the clock, always written first and then read.
		if(we3) begin               //This ensures that reads and writes in the same clock cycle do not result in a data hazzard.
			 rf[wa3] <= wd3;
		end
	end

	assign rd1 = (ra1 != 0) ? rf[ra1] : 0;   //In mips, register 0 is the XZR register in arm,
	assign rd2 = (ra2 != 0) ? rf[ra2] : 0;   //which guarantees that its read-output value will always be 0.
endmodule