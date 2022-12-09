`timescale 1ns / 1ps



module alu(
	input wire[31:0] a,b,
	input wire[2:0] op,  // ALUControl
	output reg[31:0] out,  // ALUResult
	output reg overflow, 
	output wire zero
    );

	wire[31:0] sum,b_com;             // One's complement of b

	assign b_com = op[2] ? ~b : b;    //op[2] = 1 means sub or slt instruction 
	assign sum = a + b_com + op[2];   //(Two's complement of b) + a
	
	always @(*) begin
		case (op[1:0])
			2'b00: out <= a & b_com;    //000 for and
			2'b01: out <= a | b_com;    //001 for or
			2'b10: out <= sum;          //010 for add, lw; 110 for sub, beq
			2'b11: out <= sum[31];      //111 for slt
			default : out <= 32'b0;
		endcase	
	end

	assign zero = (out == 32'b0);       //judging whether x is 0 for beq

	always @(*) begin
		case (op[2:1])
			2'b01:overflow <= a[31] & b[31] & ~sum[31] |     //001 and 110 means overflow,invert the last bit, then 000 and 111 means overflow
							~a[31] & ~b[31] & sum[31];       //These two cases can be bitwise AND to get 1 when they are unchanged or fully reversed.
			2'b11:overflow <= a[31] & ~b[31] & ~sum[31] |
							~a[31] & b[31] & sum[31];
			default : overflow <= 1'b0;
		endcase	
	end
endmodule