`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:25:49 05/20/2022 
// Design Name: 
// Module Name:    hangman 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hangman(clk, btnR, sw, an, seg, JA, JB);
	input clk;
	input btnR;
	input [7:0] sw;
	output reg [3:0] an;
	output reg [7:0] seg;
	output reg [0:7] JA = 0; // a b c d gnd vcc
	output reg [0:7] JB = 0; // e f g cat gnd vcc
	
	reg [6:0] cur_score = 10;
	reg [1:0] digit_dis = 0;
	reg score_dis = 0;
	reg [4:0] seg_num;
	reg [4:0] seg3, seg2, seg1, seg0;
	reg [3:0] score_num;
	reg [3:0] score1, score0;
	
	wire segment_clk;
	
	clk_div #(.count_from(0), .count_to(1000)) my_segment_clk(.in(clk), .out(segment_clk));
	
	always @(posedge segment_clk) begin
		// display the next digit
		digit_dis = digit_dis + 1;
		score_dis = ~score_dis;
		
		// Display digits on the FPGA's seven-segment display
		// digits_on takes care of blinking in adjust mode
		
		an = 4'b1111;	
		// set the digit we want to display to 0
		an[digit_dis] = 0;
		
		// set the letter of each digit
		seg0 = 5'b00000; // a
		seg1 = 5'b00001; // b
		seg2 = 5'b00010; // c
		seg3 = 5'b00011; // d
		
		// set the number of each digit
		score0 = 4'b0001; // 1
		score1 = 4'b0010;  // 2
		
		case (digit_dis)
			0: seg_num = seg0;
			1: seg_num = seg1;
			2: seg_num = seg2;
			3: seg_num = seg3;
		endcase
		
		case (seg_num) // dp g f e d c b a
			0: seg = 8'b10001000;  // a
			1: seg = 8'b10000011;  // b
			2: seg = 8'b10100111;  // c
			3: seg = 8'b10100001;  // d
			4: seg = 8'b10000100;  // e
			5: seg = 8'b10001110;  // f
			6: seg = 8'b10010000;  // g
			7: seg = 8'b10001001;  // h
			8: seg = 8'b11111001;  // i
			9: seg = 8'b11100001;  // j
			11: seg = 8'b10000111; // l
			13: seg = 8'b11001000; // n
			14: seg = 8'b11000000; // o
			15: seg = 8'b10001100; // p
			16: seg = 8'b10011000; // q
			17: seg = 8'b10001111; // r
			18: seg = 8'b10010010; // s
			19: seg = 8'b11001110; // t
			20: seg = 8'b11010001; // u
			24: seg = 8'b10010001; // y
			default: seg = 8'b10111111;  // -
		endcase
		
		// score0 is left digit display
		// score1 is right digit display
		case (score_dis)
			0: score_num = score0;
			1: score_num = score1;
		endcase
		
		// 1 is led on; 0 is led off
		// 0 1 2 3 4 5 6 7
		// a b c d x x x x 
		// e f g cat x x x x 
		case (score_num)
			0: begin 
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			1: begin
				JA = 8'b10010000;
				JB = 8'b11100000;
			end
			2: begin
				JA = 8'b00100000;
				JB = 8'b01000000;
			end
			3: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			4: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			5: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			6: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			7: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			8: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			9: begin
				JA = 8'b00001101;
				JB = 8'b00000111;
			end
			default: begin
				JA = 8'b00000000;
				JB = 8'b00000000;
			end
		endcase
		
		JB[3] = score_dis;
	end

endmodule
