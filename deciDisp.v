module deciDisp (
	input wire clk,
	input wire [7:0] accumulator,
	output wire change,
	output wire [3:0] disp2, disp1, disp0,
	output wire [7:0] disp3
);

wire [7:0] hex3;
reg gtNinetyNine,gtNine, update, flag, a, b, flagRedge;
reg [3:0] hundreds, tens, hex2, hex1, hex0;
reg [7:0] acc, acc0, acc1;

assign hex3 = (accumulator[7]) ? 8'hbf : 8'hff;
assign disp3 = hex3;
assign disp2 = hex2;
assign disp1 = hex1; 
assign disp0 = hex0;
assign change = flagRedge;

// check if accumulator has been updated
always @ (posedge clk) begin
	acc0 <= accumulator;
	acc1 <= acc0;
end

always @ (*) begin
	update = acc1 != acc0;
end

// check if accumulator is greater than one hundred and also greater than ten
always @ (*) begin
	gtNinetyNine = acc > 8'h63;
	gtNine = acc > 8'h09;
end

// convert from binary to signed decimal
always @ (posedge clk) begin
	case (update)
		1'b1: begin
			flag = 1'b0;
			hundreds <= 4'h0;
			tens <= 4'h0;
			acc <= (accumulator[7]) ? (8'h80-{1'b0,accumulator[6:0]}) : accumulator;
		end 
		default: begin
			case (gtNinetyNine)
				1'b1: begin
					flag = 1'b0;
					acc <= acc - 8'h64;
					hundreds <= hundreds + 4'h1;
					tens <= tens;
				end
				default: begin
					case (gtNine)
						1'b1: begin
							flag = 1'b0;
							acc <= acc - 8'h0a;
							hundreds <= hundreds;
							tens <= tens + 4'h1;
						end
						default: begin
							flag = 1'b1;
							acc <= acc;
							hundreds <= hundreds;
							tens <= tens;
						end
					endcase
				end
			endcase
		end
	endcase
end

// assign values to hex displays once calculations are complete
always @ (*) begin
	case (acc < 4'ha)
		1'b1: begin	
			hex2 = hundreds;
			hex1 = tens;
			hex0 = acc;
		end
		default: begin
			hex2 = 4'h0;
			hex1 = 4'h0;
			hex0 = 4'h0;
		end
	endcase
end

// flag rising edge detector
always @ (posedge clk) begin
	a <= flag;
	b <= a;
end

always @ (*) begin
	flagRedge = a & ~b;
end

endmodule 