module controller (
    input clk, // Clock signal
	 input key3, // Keyboard input, for directions, reset, or error
	 input key2,
	 input key1,
    input key0,
    input [13:0] total, // Current value
    input reset, // Game reset flag, 1 for reset, 0 for no reset

    output reg [1:0] op,  // Which pillar the dot is on
    output reg [1:0] ap, bp, cp,  // Positions of towers a, b, c
    output reg [1:0] az, bz, cz,  // Which pillar each tower a, b, c is on
    output reg win  // Game success flag, 1 for success, 0 for not successful
);

	reg [1:0] inop;
	reg [1:0] inaz, inbz, incz;
	reg [1:0] inap, inbp, incp;

	always @(posedge clk) begin
		inop <= total[1:0];
		inaz <= total[3:2];
		inbz <= total[5:4];
		incz <= total[7:6];
		inap <= total[9:8];
		inbp <= total[11:10];
		incp <= total[13:12];

		if (reset == 1'b0) begin
			az <= 2'b00; bz <= 2'b00; cz <= 2'b00;
			ap <= 2'b01; bp <= 2'b10; cp <= 2'b11;
			op <= 2'b00;
			win <= 1'b0;
		end else begin
			if (inaz == 2'b10 && inbz == 2'b10 && incz == 2'b10 && inap == 2'b01 && inbp == 2'b10 && incp == 2'b11) begin
				win <= 1'b1;
			end else begin
				// up key
				if (key3  == 1'b0) begin  // Upward movement
					if (inop == 2'b00) begin  // Dot on the first pole
						// a is on the first pole, b and c are not in the air
						if (inaz == 2'b00 && inbp != 2'b00 && incp != 2'b00) begin
							inap <= 2'b00;  // Move a into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						
						end else if (inbz == 2'b00 && inaz != 2'b00 && inap != 2'b00 && incp != 2'b00) begin
							// b is on the first pole and a is not on the first pole, and a, c are not in the air
							inbp <= 2'b00;  // Move b into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						end else if (incz == 2'b00 && inaz != 2'b00 && incp != 2'b00 && inap != 2'b00 && inbp != 2'b00) begin
							// c is on the first pole and a, b are not on the first pole, and a, b are not in the air
							incp <= 2'b00;  // Move c into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						end else begin
							// Other cases are considered errors
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end
						
					end else if (inop == 2'b01) begin  // Dot is on the second pillar
						if (inaz == 2'b01 && inbp != 2'b00 && incp != 2'b00) begin // a is on the second pillar
							inap <= 2'b00;  // Move a into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is on the second pillar and a is not on the second pillar
						end else if (inbz == 2'b01 && inaz != 2'b01 && inap != 2'b00 && incp != 2'b00) begin
							inbp <= 2'b00;  // Move b into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is on the second pillar and a, b are not on the second pillar
						end else if (incz == 2'b01 && inaz != 2'b01 && inbz != 2'b01 && inap != 2'b00 && inbp != 2'b00) begin
							incp <= 2'b00;  // Move c into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// Other cases are considered errors
						end else begin
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end

					end else if (inop == 2'b10) begin  // Dot is on the third pillar
						// a is on the third pillar
						if (inaz == 2'b10 && inbp != 2'b00 && incp != 2'b00) begin
							inap <= 2'b00;  // Move a into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is on the third pillar and a is not on the third pillar
						end else if (inbz == 2'b10 && inaz != 2'b10 && inap != 2'b00 && incp != 2'b00) begin
							inbp <= 2'b00;  // Move b into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is on the third pillar and a, b are not on the third pillar
						end else if (incz == 2'b10 && inaz != 2'b10 && inbz != 2'b10 && inap != 2'b00 && inbp != 2'b00) begin
							incp <= 2'b00;  // Move c into the air
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// Other cases are considered errors
						end else begin
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end
						
					end else begin  // Other cases, considered as errors
						// Assign outputs
						az <= inaz; bz <= inbz; cz <= incz;
						ap <= inap; bp <= inbp; cp <= incp;
						op <= inop;
					end

				end else if (key2  == 1'b0) begin  // Downward movement
					if (inop == 2'b00) begin // Dot is on the first pillar
						if (inaz == 2'b00 && inap == 2'b00) begin // a is above the first pillar
							if (inbz != 2'b00 && incz != 2'b00) begin // b, c are not on the first pillar
									inap <= 2'b11;  // Move a to position 3 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							end else if (inbz == 2'b00 && incz != 2'b00) begin
									// b is on the first pillar, c is not
									inap <= 2'b10;  // Move a to position 2 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							end else if (inbz != 2'b00 && incz == 2'b00) begin
									// c is on the first pillar, b is not
									inap <= 2'b10;  // Move a to position 2 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							end else if (inbz == 2'b00 && incz == 2'b00) begin
									// b, c are both on the first pillar
									inap <= 2'b01;  // Move a to position 1 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							end else begin
									// Other cases are considered errors
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end

						end else if (inbz == 2'b00 && inbp == 2'b00) begin  // b is above the first pillar
							if (inaz != 2'b00 && incz != 2'b00) begin // a, c are not on the first pillar
									inbp <= 2'b11;  // Move b to position 3 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// a is not on the first pillar, c is on the first pillar
							end else if (inaz != 2'b00 && incz == 2'b00) begin
									inbp <= 2'b10;  // Move b to position 2 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// Other cases are considered errors
							end else begin
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end

						end else if (incz == 2'b00 && incp == 2'b00) begin  // c is above the first pillar
							if (inaz != 2'b00 && inbz != 2'b00) begin // a, b are not on the first pillar
									incp <= 2'b11;  // Move c to position 3 on the first pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// Other cases are considered errors
							end else begin
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end
						end

					end else if (inop == 2'b01) begin  // Dot is on the second pillar   
						if (inaz == 2'b01 && inap == 2'b00) begin // a is above the second pillar
							if (inbz != 2'b01 && incz != 2'b01) begin // b, c are not on the second pillar
									inap <= 2'b11;  // Move a to position 3 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// b is on the second pillar, c is not
							end else if (inbz == 2'b01 && incz != 2'b01) begin
									inap <= 2'b10;  // Move a to position 2 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// c is on the second pillar, b is not
							end else if (inbz != 2'b01 && incz == 2'b01) begin
									inap <= 2'b10;  // Move a to position 2 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// b, c are both on the second pillar
							end else if (inbz == 2'b01 && incz == 2'b01) begin
									inap <= 2'b01;  // Move a to position 1 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// Other cases are considered errors
							end else begin
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end

						end else if (inbz == 2'b01 && inbp == 2'b00) begin // b is above the second pillar
							if (inaz != 2'b01 && incz != 2'b01) begin // a, c are not on the second pillar
									inbp <= 2'b11; // Move b to position 3 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// a is not on the second pillar, c is on the second pillar
							end else if (inaz != 2'b01 && incz == 2'b01) begin
									inbp <= 2'b10; // Move b to position 2 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// Other cases are considered errors
							end else begin
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end

						end else if (incz == 2'b01 && incp == 2'b00) begin // c is above the second pillar
							if (inaz != 2'b01 && inbz != 2'b01) begin // a, b are not on the second pillar
									incp <= 2'b11;  // Move c to position 3 on the second pillar
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;

							// Other cases are considered errors
							end else begin
									// Assign outputs
									az <= inaz; bz <= inbz; cz <= incz;
									ap <= inap; bp <= inbp; cp <= incp;
									op <= inop;
							end
						end

					end else if (inop == 2'b10) begin // Dot is on the third pillar
						if (inaz == 2'b10 && inap == 2'b00) begin // a is above the third pillar
							if (inbz != 2'b10 && incz != 2'b10) begin // b, c are not on the third pillar
								inap <= 2'b11;  // Move a to position 3 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// b is on the third pillar, c is not
							end else if (inbz == 2'b10 && incz != 2'b10) begin
								inap <= 2'b10;  // Move a to position 2 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// c is on the third pillar, b is not
							end else if (inbz != 2'b10 && incz == 2'b10) begin
								inap <= 2'b10;  // Move a to position 2 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// b, c are both on the third pillar
							end else if (inbz == 2'b10 && incz == 2'b10) begin
								inap <= 2'b01;  // Move a to position 1 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// Other cases are considered errors
							end else begin
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;
							end

						end else if (inbz == 2'b10 && inbp == 2'b00) begin // b is above the third pillar
							if (inaz != 2'b10 && incz != 2'b10) begin // a, c are not on the third pillar
								inbp <= 2'b11;  // Move b to position 3 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// a is not on the third pillar, c is on the third pillar
							end else if (inaz != 2'b10 && incz == 2'b10) begin
								inbp <= 2'b10;  // Move b to position 2 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// Other cases are considered errors
							end else begin
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;
							end

						end else if (incz == 2'b10 && incp == 2'b00) begin // c is above the third pillar
							if (inaz != 2'b10 && inbz != 2'b10) begin // a, b are not on the third pillar
								incp <= 2'b11;  // Move c to position 3 on the third pillar
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;

							// Other cases are considered errors
							end else begin
								// Assign outputs
								az <= inaz; bz <= inbz; cz <= incz;
								ap <= inap; bp <= inbp; cp <= incp;
								op <= inop;
							end
						end
					end

				end else if (key1  == 1'b0) begin // Keyboard leftward movement
					if (inop == 2'b00) begin // Dot is on the first pillar, considered an error
						az <= inaz; bz <= inbz; cz <= incz;
						ap <= inap; bp <= inbp; cp <= incp;
						op <= inop;

					// Dot is on the second pillar
					end else if (inop == 2'b01) begin
						if (inap != 2'b00 && inbp != 2'b00 && incp != 2'b00) begin // No tower is in the air
							inop <= 2'b00;  // Move dot to the first pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// a is in the air above the second pillar
						end else if (inap == 2'b00 && inaz == 2'b01 && inbp != 2'b00 && incp != 2'b00) begin
							inop <= 2'b00; inaz <= 2'b00;  // Move dot and a to the first pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is in the air above the second pillar
						end else if (inbp == 2'b00 && inbz == 2'b01 && inap != 2'b00 && incp != 2'b00) begin
							inop <= 2'b00; inbz <= 2'b00;  // Move dot and b to the first pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is in the air above the second pillar
						end else if (incp == 2'b00 && incz == 2'b01 && inap != 2'b00 && inbp != 2'b00) begin
							inop <= 2'b00; incz <= 2'b00;  // Move dot and c to the first pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end

					end else if (inop == 2'b10) begin // Dot is on the third pillar
						if (inap != 2'b00 && inbp != 2'b00 && incp != 2'b00) begin // No tower is in the air
							inop <= 2'b01;  // Move dot to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// a is in the air above the third pillar
						end else if (inap == 2'b00 && inaz == 2'b10 && inbp != 2'b00 && incp != 2'b00) begin
							inop <= 2'b01; inaz <= 2'b01;  // Move dot and a to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is in the air above the third pillar
						end else if (inbp == 2'b00 && inbz == 2'b10 && inap != 2'b00 && incp != 2'b00) begin
							inop <= 2'b01; inbz <= 2'b01;  // Move dot and b to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is in the air above the third pillar
						end else if (incp == 2'b00 && incz == 2'b10 && inap != 2'b00 && inbp != 2'b00) begin
							inop <= 2'b01; incz <= 2'b01;  // Move dot and c to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end
					end

				end else if (key0 == 1'b0) begin // Keyboard rightward movement
					if (inop == 2'b00) begin // Dot is on the first pillar
						if (inap != 2'b00 && inbp != 2'b00 && incp != 2'b00) begin // No tower is in the air
							inop <= 2'b01;  // Move dot to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// a is in the air above the first pillar
						end else if (inap == 2'b00 && inaz == 2'b00 && inbp != 2'b00 && incp != 2'b00) begin
							inop <= 2'b01; inaz <= 2'b01;  // Move dot and a to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is in the air above the first pillar
						end else if (inbp == 2'b00 && inbz == 2'b00 && inap != 2'b00 && incp != 2'b00) begin
							inop <= 2'b01; inbz <= 2'b01;  // Move dot and b to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is in the air above the first pillar
						end else if (incp == 2'b00 && incz == 2'b00 && inap != 2'b00 && inbp != 2'b00) begin
							inop <= 2'b01; incz <= 2'b01;  // Move dot and c to the second pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end

					end else if (inop == 2'b01) begin // Dot is on the second pillar
						if (inap != 2'b00 && inbp != 2'b00 && incp != 2'b00) begin // No tower is in the air
							inop <= 2'b10;  // Move dot to the third pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// a is in the air above the second pillar
						end else if (inap == 2'b00 && inaz == 2'b01 && inbp != 2'b00 && incp != 2'b00) begin
							inop <= 2'b10; inaz <= 2'b10;  // Move dot and a to the third pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// b is in the air above the second pillar
						end else if (inbp == 2'b00 && inbz == 2'b01 && inap != 2'b00 && incp != 2'b00) begin
							inop <= 2'b10; inbz <= 2'b10;  // Move dot and b to the third pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;

						// c is in the air above the second pillar
						end else if (incp == 2'b00 && incz == 2'b01 && inap != 2'b00 && inbp != 2'b00) begin
							inop <= 2'b10; incz <= 2'b10;  // Move dot and c to the third pillar
							// Assign outputs
							az <= inaz; bz <= inbz; cz <= incz;
							ap <= inap; bp <= inbp; cp <= incp;
							op <= inop;
						end
					end else if (inop == 2'b10) begin // Dot is on the third pillar - considered an error
						// Assign outputs without any change
						az <= inaz; bz <= inbz; cz <= incz;
						ap <= inap; bp <= inbp; cp <= incp;
						op <= inop;
					end
				end else begin // Error condition for specific keyboard input
					// Maintain current state without any change
					az <= inaz; bz <= inbz; cz <= incz;
					ap <= inap; bp <= inbp; cp <= incp;
					op <= inop;
				end
			end
		end
	end
endmodule
