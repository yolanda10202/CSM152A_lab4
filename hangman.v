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
	
	reg [3:0] cur_score = 10;
	reg [1:0] setButton = 0;
	reg send = 0;
	reg [6:0] total_score = 0;
	reg [1:0] digit_dis = 0;
	reg score_dis = 0;
	reg [4:0] seg_num;
	reg [4:0] seg3, seg2, seg1, seg0;
	reg [3:0] score_num;
	reg [3:0] score1, score0;
	reg [19:0] word = 20'b11010110101101011010;
	reg [2:0] i = 0;
	reg [1:0][19:0] solutions = {{20'b00110011100111000011},
								 {20'b00001000000101101011}}; // good, ball
	reg [19:0] solution;
	reg [4:0] char;
	reg win = 1;
	reg complete = 0;
	
	wire segment_clk;
	
	clk_div #(.count_from(0), .count_to(1000)) my_segment_clk(.in(clk), .out(segment_clk));
	
	always @(posedge send) begin
		// if user sends
		if (!complete) begin
			char = sw[4:0];
			solution = solutions[i];
			if (solution[4:0] == char) begin
				word[4:0] = char;
			end
			else if (solution[9:5] == char) begin
				word[9:5] = char;
			end
			else if (solution[14:10] == char) begin
				word[14:10] = char;
			end
			else if (solution[19:15] == char) begin
				word[19:15] = char;
			end
			else begin
				//word = 20'b00000000010001000011;
				cur_score = cur_score - 1;
			end
			
			// if lost
			if (cur_score == 0) begin
				win = 0;
			end
			
			// if guess every letter correctly
			if(win && word == solution) begin
				total_score = total_score + cur_score;
				word = 20'b00000000010001000011;
				cur_score = 10;
				i = i + 1;
			end
			
			// if all rounds are played
			if (i == 2) begin
				complete = 1;
				word = 20'b00000000010001000010;
			end
		end
	end
	
	always @(posedge segment_clk) begin
		// display the next digit
		digit_dis = digit_dis + 1;
		score_dis = ~score_dis;
				
		setButton = setButton >> 1;
		if (btnR == 1) begin
			setButton[1] = 1;
		end
		if (setButton == 3) begin
			send = 1;
		end
		else begin
			send = 0;
		end
		
		if(!win) begin
			word = 20'b00000000010001000000;
		end
		
		// Display digits on the FPGA's seven-segment display
		// digits_on takes care of blinking in adjust mode
		an = 4'b1111;	
		// set the digit we want to display to 0
		an[digit_dis] = 0;
		
		// set the letter of each digit
		seg0 = word[4:0];
		seg1 = word[9:5];
		seg2 = word[14:10];
		seg3 = word[19:15];
		
		
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
		
		// set the number of each digit
		if(!win || complete) begin
			score1 = total_score % 10; 
			score0 = total_score / 10;
		end
		else begin
			score1 = cur_score % 10; 
			score0 = cur_score / 10;
		end
		
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
				JB = 8'b11011111;
			end
			1: begin
				JA = 8'b00000000;
				JB = 8'b11000000;
			end
			2: begin
				JA = 8'b11011111;
				JB = 8'b10111111;
			end
			3: begin
				JA = 8'b10010000;
				JB = 8'b11100000;
			end
			4: begin
				JA = 8'b00101111;
				JB = 8'b11111111;
			end
			5: begin
				JA = 8'b10111111;
				JB = 8'b01111111;
			end
			6: begin
				JA = 8'b11111111;
				JB = 8'b00111111;
			end
			7: begin
				JA = 8'b00011111;
				JB = 8'b11011111;
			end
			8: begin
				JA = 8'b11111111;
				JB = 8'b11111111;
			end
			9: begin
				JA = 8'b10111101;
				JB = 8'b11100111;
			end
			default: begin
				JA = 8'b00000000;
				JB = 8'b00000000;
			end
		endcase
		JB[3] = score_dis;
		
		
	end

endmodule
