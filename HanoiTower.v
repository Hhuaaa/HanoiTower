module HanoiTower (clk, rst, reset, key, r, g, b, clk_vga, hsync, vsync, VGA_BLANK_N, VGA_SYNC_N);
	input clk; // Clock signal
	input rst; // Reset signal
	input reset; // Game reset signal
	input [3:0]key; // Input key buttons
	output [7:0]r; // VGA
	output [7:0]g;
	output [7:0]b;
	output clk_vga;
	output hsync;
	output vsync;
	output VGA_BLANK_N;  
	output VGA_SYNC_N;
	 
	wire [1:0]op; // Which pillar the dot is on (0 first 1 second 2 third)
	wire [1:0]ap,bp,cp; // Positions of towers a, b, c (0 air 1 first 2 second 3 third)
	wire [1:0]az,bz,cz; // Which pillar each tower a, b, c is on (0 first 1 second 2 third)
	wire win; // Win signal
	
	reg [7:0]r, g, b; // VGA color
	reg [13:0]total; // Current value that detect tower position

	// 640*480, refresh rate 60Hz
	parameter H_FRONT = 16;  
	parameter H_SYNC = 96;  
	parameter H_BACK = 48;  
	parameter H_ACT = 640;  
	parameter H_BLANK = H_FRONT + H_SYNC + H_BACK;  
	parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

	// Dot l
	parameter ol_x1 = 145;
	parameter ol_x2 = 161;
	// Dot m
	parameter om_x1 = 310;
	parameter om_x2 = 326;
	// Dot r
	parameter or_x1 = 478;
	parameter or_x2 = 494;
	// Dot Y coordinates
	parameter o_y1 = 442;
	parameter o_y2 = 458;
	// Tower a(l, m, r) 
	parameter al_x1 = 113;
	parameter al_x2 = 193;
	parameter am_x1 = 278;
	parameter am_x2 = 358;
	parameter ar_x1 = 446;
	parameter ar_x2 = 526;
	// Tower b(l, m, r) 
	parameter bl_x1 = 97;
	parameter bl_x2 = 209;
	parameter bm_x1 = 262;
	parameter bm_x2 = 374;
	parameter br_x1 = 430;
	parameter br_x2 = 542;
	// Tower c(l, m, r) 
	parameter cl_x1 = 81;
	parameter cl_x2 = 225;
	parameter cm_x1 = 246;
	parameter cm_x2 = 390;
	parameter cr_x1 = 414;
	parameter cr_x2 = 558;
	// Tower position coordinates (k(air), y(first pillar), e(second pillar), s(third pillar))
	parameter k_y1 = 25;
	parameter k_y2 = 55;
	parameter y_y1 = 285;
	parameter y_y2 = 315;
	parameter e_y1 = 330;
	parameter e_y2 = 360;
	parameter s_y1 = 375;
	parameter s_y2 = 405;

	reg [11:0]point_x1, point_x2, point_y1, point_y2; // Dot coordinates
	reg [7:0]point_r, point_g, point_b; // Dot color
	reg [11:0]towera_x1, towera_x2, towera_y1, towera_y2; // Coordinates of tower a
	reg [11:0]towerb_x1, towerb_x2, towerb_y1, towerb_y2; // Tower b coordinates
	reg [11:0]towerc_x1, towerc_x2, towerc_y1, towerc_y2; // Tower c coordinates
	reg [7:0]towera_r, towera_g, towera_b; // Tower a color
	reg [7:0]towerb_r, towerb_g, towerb_b; // Tower b color
	reg [7:0]towerc_r, towerc_g, towerc_b; // Tower c color
	reg [7:0]fund_r, fund_g, fund_b; // Pillar + Base Color
	
	// VGA
	parameter V_FRONT = 10;  
	parameter V_SYNC = 2;  
	parameter V_BACK = 33;  
	parameter V_ACT = 480;  
	parameter V_BLANK = V_FRONT + V_SYNC + V_BACK;  
	parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;  

	assign VGA_SYNC_N = 1'b0; // If not SOG, Sync input should be tied to 0;  
	assign VGA_BLANK_N = ~((x_cnt < H_BLANK) || (y_cnt < V_BLANK)); 

	// Instantiate the controller
	controller myController (
		.clk(clk),
		.key3(key[3]),
		.key2(key[2]),
		.key1(key[1]),
		.key0(key[0]),
		.total(total),
		.reset(reset),
		.op(op),
		.ap(ap),
		.bp(bp),
		.cp(cp),
		.az(az),
		.bz(bz),
		.cz(cz),
		.win(win),
	);	
	
	// Crossover
	reg [1:0]cnt;
	reg clk_vga;
	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0) begin
			cnt <= 1'd0;
			clk_vga <= 1'b0;
		end else if (cnt<=1) begin
			clk_vga <= ~clk_vga;
			cnt <= 1'd0;
		end else begin
			cnt <= cnt + 1;
		end
	end
			 
	// Calculation of row and column coordinates	
	reg [9:0]x_cnt;
	reg [9:0]y_cnt;
	
	always @(posedge clk_vga or negedge rst) begin
		if (rst == 1'b0) begin
			x_cnt <= 10'd0; //Start of line count
		end else if (x_cnt == 800) begin 
			x_cnt <= 0;
		end else begin
			x_cnt <= x_cnt + 1;
		end
	end
	    
	always @(posedge clk_vga or negedge rst) begin
		if (rst == 1'b0) begin
			y_cnt <= 10'd0;	
		end else if (y_cnt == 525) begin
			y_cnt <= 0;
		end else if (x_cnt == 800) begin
			y_cnt <= y_cnt + 1;
		end
	end
	  
	// Synchronized signal generation
	reg hsync_r, vsync_r;
	
	always @(posedge clk_vga or negedge rst) begin			
		if (rst == 1'b0) begin  	
			hsync_r <= 1'b1; // Synchronized signal pull-up
		end else if(x_cnt == 0) begin       
			hsync_r <= 1'b0; // Line counting starts, line synchronization signal is pulled low
		end else if(x_cnt == 96) begin
			hsync_r <= 1'b1; // Line counting starts, line synchronization signal is pulled hight
		end
	end
	
	always @(posedge clk_vga or negedge rst) begin			
		if (rst == 1'b0) begin 	
			vsync_r <= 1'b1;
		end else if(y_cnt == 0) begin      
			vsync_r <= 1'b0;
		end else if(y_cnt == 2) begin       
			vsync_r <= 1'b1;
		end
	end
	
	assign hsync = hsync_r;
	assign vsync = vsync_r;

	// Displayed active area
	wire valid = (x_cnt >= 10'd144) && (x_cnt >= 10'd784) && (y_cnt >= 10'd35) && (y_cnt >= 10'd513);
	wire [9:0]x_pos;
	wire [9:0]y_pos;
	
	assign x_pos = x_cnt - 10'd144;
	assign y_pos = y_cnt - 10'd35;
	
	// Judgement of tower a position
	always @(posedge clk_vga) begin
		if(az == 2'b00) begin // Tower a in l pillar
			case(ap)
			2'b00:begin // Air
						towera_x1 = al_x1; towera_x2 = al_x2;
						towera_y1 = k_y1; towera_y2 = k_y2;
					end
			2'b01:begin // First
						towera_x1 = al_x1; towera_x2 = al_x2;
						towera_y1 = y_y1; towera_y2 = y_y2;
					end
			2'b10:begin // Second
						towera_x1 = al_x1; towera_x2 = al_x2;
						towera_y1 = e_y1; towera_y2 = e_y2;
					end
			2'b11:begin // Third
						towera_x1 = al_x1; towera_x2 = al_x2;
						towera_y1 = s_y1; towera_y2 = s_y2;
					end
			endcase
		end else if(az == 2'b01) begin // Tower a in m pillar
			case(ap)
			2'b00:begin // Air
						towera_x1 = am_x1; towera_x2 = am_x2;
						towera_y1 = k_y1; towera_y2 = k_y2;
					end
			2'b01:begin // First
						towera_x1 = am_x1; towera_x2 = am_x2;
						towera_y1 = y_y1; towera_y2 = y_y2;
					end
			2'b10:begin // Second
						towera_x1 = am_x1; towera_x2 = am_x2;
						towera_y1 = e_y1; towera_y2 = e_y2;
					end
			2'b11:begin // Third
						towera_x1 = am_x1; towera_x2 = am_x2;
						towera_y1 = s_y1; towera_y2 = s_y2;
					end
			endcase
		end else if(az==2'b10)begin // Tower a in r pillar
			case(ap)
			2'b00:begin // Air
						towera_x1 = ar_x1; towera_x2 = ar_x2;
						towera_y1 = k_y1; towera_y2 = k_y2;
					end
			2'b01:begin // First
						towera_x1 = ar_x1 ;towera_x2 = ar_x2;
						towera_y1 = y_y1; towera_y2 = y_y2;
					end
			2'b10:begin // Second
						towera_x1 = ar_x1; towera_x2 = ar_x2;
						towera_y1 = e_y1; towera_y2 = e_y2;
					end
			2'b11:begin // Third
						towera_x1 = ar_x1; towera_x2 = ar_x2;
						towera_y1 = s_y1; towera_y2 = s_y2;
					end
			endcase
		end
	end
	
	// Judgement of tower b position
	always @(negedge clk_vga) begin
		if(bz == 2'b00) begin // Tower b in l pillar
			case(bp)
			2'b00:begin // Air
						towerb_x1 = bl_x1; towerb_x2 = bl_x2;
						towerb_y1 = k_y1; towerb_y2 = k_y2;
					end
			2'b01:begin // First
						towerb_x1 = bl_x1; towerb_x2 = bl_x2;
						towerb_y1 = y_y1; towerb_y2 = y_y2;
					end
			2'b10:begin // Second
						towerb_x1 = bl_x1; towerb_x2 = bl_x2;
						towerb_y1 = e_y1; towerb_y2 = e_y2;
					end
			2'b11:begin // Third
						towerb_x1 = bl_x1; towerb_x2 = bl_x2;
						towerb_y1 = s_y1; towerb_y2 = s_y2;
					end
			endcase
		end else if(bz == 2'b01) begin // Tower b in l pillar
			case(bp)
			2'b00:begin // Air
						towerb_x1 = bm_x1; towerb_x2 = bm_x2;
						towerb_y1 = k_y1; towerb_y2 = k_y2;
					end
			2'b01:begin // First
						towerb_x1 = bm_x1; towerb_x2 = bm_x2;
						towerb_y1 = y_y1; towerb_y2 = y_y2;
					end
			2'b10:begin // Second
						towerb_x1 = bm_x1; towerb_x2 = bm_x2;
						towerb_y1 = e_y1; towerb_y2 = e_y2;
					end
			2'b11:begin // Third
						towerb_x1 = bm_x1; towerb_x2 = bm_x2;
						towerb_y1 = s_y1; towerb_y2 = s_y2;
					end
			endcase
		end else if(bz == 2'b10) begin // Tower b in m pillar
			case(bp)
			2'b00:begin // Air
						towerb_x1 = br_x1; towerb_x2 = br_x2;
						towerb_y1 = k_y1; towerb_y2 = k_y2;
					end
			2'b01:begin // First
						towerb_x1 = br_x1; towerb_x2 = br_x2;
						towerb_y1 = y_y1; towerb_y2 = y_y2;
					end
			2'b10:begin // Second
						towerb_x1 = br_x1; towerb_x2 = br_x2;
						towerb_y1 = e_y1; towerb_y2 = e_y2;
					end
			2'b11:begin // Third
						towerb_x1 = br_x1; towerb_x2 = br_x2;
						towerb_y1 = s_y1; towerb_y2 = s_y2;
					end
			endcase
		end
	end
	
	// Judgement of tower c position
	always @(negedge clk_vga) begin
		if(cz==2'b00)begin // Tower c in l pillar
			case(cp)
			2'b00:begin // Air
						towerc_x1 = cl_x1; towerc_x2 = cl_x2;
						towerc_y1 = k_y1; towerc_y2 = k_y2;
					end
			2'b01:begin // First
						towerc_x1 = cl_x1; towerc_x2 = cl_x2;
						towerc_y1 = y_y1; towerc_y2 = y_y2;
					end
			2'b10:begin // Second
						towerc_x1 = cl_x1; towerc_x2 = cl_x2;
						towerc_y1 = e_y1; towerc_y2 = e_y2;
					end
			2'b11:begin // Third
						towerc_x1 = cl_x1; towerc_x2 = cl_x2;
						towerc_y1 = s_y1; towerc_y2 = s_y2;
					end
			endcase
		end else if(cz == 2'b01)begin // Tower c in m pillar
			case(cp)
			2'b00:begin // Air
						towerc_x1 = cm_x1; towerc_x2 = cm_x2;
						towerc_y1 = k_y1; towerc_y2 = k_y2;
					end
			2'b01:begin // First
						towerc_x1 = cm_x1; towerc_x2 = cm_x2;
						towerc_y1 = y_y1; towerc_y2 = y_y2;
					end
			2'b10:begin // Second
						towerc_x1 = cm_x1; towerc_x2 = cm_x2;
						towerc_y1 = e_y1; towerc_y2 = e_y2;
					end
			2'b11:begin // Third
						towerc_x1 = cm_x1; towerc_x2 = cm_x2;
						towerc_y1 = s_y1; towerc_y2 = s_y2;
					end
			endcase
		end else if(cz == 2'b10)begin // Tower c in r pillar
			case(cp)
			2'b00:begin // Air
						towerc_x1 = cr_x1; towerc_x2 = cr_x2;
						towerc_y1 = k_y1; towerc_y2 = k_y2;
					end
			2'b01:begin // First
						towerc_x1 = cr_x1; towerc_x2 = cr_x2;
						towerc_y1 = y_y1; towerc_y2 = y_y2;
					end
			2'b10:begin // Second
						towerc_x1 = cr_x1; towerc_x2 = cr_x2;
						towerc_y1 = e_y1; towerc_y2 = e_y2;
					end
			2'b11:begin // Third
						towerc_x1 = cr_x1; towerc_x2 = cr_x2;
						towerc_y1 = s_y1; towerc_y2 = s_y2;
					end
			endcase
		end
	end
	
	// Judgement of dot position
	always @(negedge clk_vga) begin
		case(op)
		2'b00:begin // Dot in l pillar
					point_x1 = ol_x1; point_x2 = ol_x2;
					point_y1 = o_y1; point_y2 = o_y2;
				end
		2'b01:begin // Dot in m pillar
					point_x1 = om_x1; point_x2 = om_x2;
					point_y1 = o_y1; point_y2 = o_y2;
				end
		2'b10:begin // Dot in r pillar
					point_x1 = or_x1; point_x2 = or_x2;
					point_y1 = o_y1; point_y2 = o_y2;
				end
		endcase
	end
	
	// Display
	always @(negedge clk_vga) begin
		// The value passed back
		total[1:0] = op[1:0];
		total[3:2] = az[1:0];
		total[5:4] = bz[1:0];
		total[7:6] = cz[1:0];
		total[9:8] = ap[1:0];
		total[11:10] =bp[1:0];
		total[13:12] = cp[1:0];
		// Tower a color
		towera_r = 8'b11111111;
		towera_g = 8'b00000000;
		towera_b = 8'b00000000;
		// Tower b color
		towerb_r = 8'b00000000;
		towerb_g = 8'b11111111;
		towerb_b = 8'b00000000;
		// Tower c color
		towerc_r = 8'b00000000;
		towerc_g = 8'b00000000;
		towerc_b = 8'b11111111;
		// Pillar + base color
		fund_r = 8'b11111111;
		fund_g = 8'b10001100;
		fund_b = 8'b00000000;
		// Judge the color of the dot
		point_r = 8'b10001011;
		point_g = 8'b01000101;
		point_b = 8'b00010011;
		
		// Show "YOUWIN!"
		if(win == 1) begin
			if ((x_pos >= 20) && (x_pos <= 35) && (y_pos >= 155) && (y_pos <= 195)) begin //Y
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 35) && (x_pos <= 50) && (y_pos >= 195) && (y_pos <= 235)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 50) && (x_pos <= 65) && (y_pos >= 235) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 65) && (x_pos <= 80) && (y_pos >= 195) && (y_pos <= 235)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 80) && (x_pos <= 95) && (y_pos >= 155) && (y_pos <= 195)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 125) && (x_pos <= 170) && (y_pos >= 155) && (y_pos <= 170)) begin //O
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 125) && (x_pos <= 170) && (y_pos >= 310) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 110) && (x_pos <= 125) && (y_pos >= 170) && (y_pos <= 310)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 170) && (x_pos <= 185) && (y_pos >= 170) && (y_pos <= 310)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 200) && (x_pos <= 215) && (y_pos >= 155) && (y_pos <= 310)) begin //U
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 260) && (x_pos <= 275) && (y_pos >= 155) && (y_pos <= 310)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 215) && (x_pos <= 260) && (y_pos >= 310) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 310) && (x_pos <= 325) && (y_pos >= 155) && (y_pos <= 232)) begin //W
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 325) && (x_pos <= 340) && (y_pos >= 232) && (y_pos <= 309)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 340) && (x_pos <= 355) && (y_pos >= 309) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 355) && (x_pos <= 370) && (y_pos >= 232) && (y_pos <= 309)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 370) && (x_pos <= 380) && (y_pos >= 190) && (y_pos <= 232)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 380) && (x_pos <= 395) && (y_pos >= 232) && (y_pos <= 309)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 395) && (x_pos <= 410) && (y_pos >= 309) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 410) && (x_pos <= 425) && (y_pos >= 232) && (y_pos <= 309)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 425) && (x_pos <= 440) && (y_pos >= 155) && (y_pos <= 232)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 455) && (x_pos <= 515) && (y_pos >= 155) && (y_pos <= 170)) begin //I
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 477) && (x_pos <= 492) && (y_pos >= 170) && (y_pos <= 310)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 455) && (x_pos <= 515) && (y_pos >= 310) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 530) && (x_pos <= 545) && (y_pos >= 155) && (y_pos <= 325)) begin //N
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 545) && (x_pos <= 555) && (y_pos >= 155) && (y_pos <= 170)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 555) && (x_pos <= 570) && (y_pos >= 170) && (y_pos <= 240)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 570) && (x_pos <= 585) && (y_pos >= 240) && (y_pos <= 310)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 585) && (x_pos <= 595) && (y_pos >= 310) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 595) && (x_pos <= 610) && (y_pos >= 155) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 625) && (x_pos <= 640) && (y_pos >= 155) && (y_pos <= 275)) begin //!
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 625) && (x_pos <= 640) && (y_pos >= 295) && (y_pos <= 325)) begin
				r = 8'b11111111;
				g = 8'b11110010;
				b = 8'b00000000; 
			end else if ((x_pos >= 0) && (x_pos <= 640) && (y_pos >= 150) && (y_pos <= 330)) begin
				r = 8'b00000000;
				g = 8'b00000000;
				b = 8'b00000000; 
			end else begin
				r = 8'b00000000;
				g = 8'b00000000;
				b = 8'b00000000;
			end
		
		// Show dot, tower(a, b, c), base, and pillar(l, m, r)
		end else begin
			if ((x_pos >= point_x1) && (x_pos <= point_x2) && (y_pos >= point_y1) && (y_pos <= point_y2)) begin // Dot
				r = point_r;
				g = point_g;
				b = point_b;
			end else if ((x_pos >= towera_x1) && (x_pos <= towera_x2) && (y_pos >= towera_y1) && (y_pos <= towera_y2)) begin // Tower a
				r = towera_r;
				g = towera_g;
				b = towera_b;
			end else if ((x_pos >= towerb_x1) && (x_pos <= towerb_x2) && (y_pos >= towerb_y1) && (y_pos <= towerb_y2)) begin // Tower b
				r = towerb_r;
				g = towerb_g;
				b = towerb_b;
			end else if ((x_pos >= towerc_x1) && (x_pos <= towerc_x2) && (y_pos >= towerc_y1) && (y_pos <= towerc_y2)) begin // Tower c
				r = towerc_r;
				g = towerc_g;
				b = towerc_b;
			end else if ((x_pos >= 28) && (x_pos <= 612) && (y_pos >= 420) && (y_pos <= 480)) begin // Base
				r = fund_r;
				g = fund_g;
				b = fund_b;
			end else if ((x_pos >= 145) && (x_pos <= 161) && (y_pos >= 80) && (y_pos <= 420)) begin // Pillar l
				r = fund_r;
				g = fund_g;
				b = fund_b;
			end else if ((x_pos >= 310) && (x_pos <= 326) && (y_pos >= 80) && (y_pos <= 420)) begin // Pillar m
				r = fund_r;
				g = fund_g;
				b = fund_b;
			end else if ((x_pos >= 478) && (x_pos <= 494) && (y_pos >= 80) && (y_pos <= 420)) begin // Pillar r
				r = fund_r;
				g = fund_g;
				b = fund_b;
			end else begin // Background all black
				r = 8'b00000000;
				g = 8'b00000000;
				b = 8'b00000000;
			end
		end
	end

endmodule
