module calc_work (
	input wire CLOCK_50,
	input wire [1:0] KEY,
	inout wire [39:0] GPIO,
	output wire [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	output wire [9:0] LEDR
);

wire SE, RShift, up, flag, roll, tx;
wire [1:0] st;
wire [3:0] d0, d1, d2, d3, d4;
wire [7:0] d5, d10, d11;
reg fedge, fedge1, rst, ld, a1, b1, c1, txRst, ldWord;
reg [1:0] a, b, c;
reg [3:0] pulses;
reg [5:0] txPulses;
reg [7:0] accumulator, d6, d7, d8, d9, currentWord;
reg [9:0] shiftReg;

assign HEX4 = 8'hff;
assign LEDR[9:0] = 10'h000;
assign GPIO[39:2] = 38'h0000000000;

// synchronize the input signals KEY and SW
always @ (posedge CLOCK_50) begin
	a <= KEY;
	b <= a;
	c <= b;
	a1 <= GPIO[0];
	b1 <= a1;
	c1 <= b1;
end

// falling edge detector on KEY1 and GPIO[0]
always @ (*) begin
	fedge = c[1] & ~b[1];
	fedge1 = c1 & ~b1;
end

// timer reset 
always @ (*) begin
	case (fedge1)
		1'b1: rst = (st == 2'b00) ? 1'b1 : 1'b0;
		default: rst = 1'b0;
	endcase
end

// shift register
always @ (posedge CLOCK_50) begin
	case (RShift) 
		1'b1: shiftReg <= {c1,shiftReg[9:1]};
		default: shiftReg <= shiftReg;
	endcase
end

// go high when UART word is fully received
always @ (*) begin
	ld = (pulses == 4'ha) ? 1'b1 : 1'b0;
end

// pulse counter
always @ (posedge CLOCK_50) begin
	if (rst) begin
		pulses <= 4'h0;
	end
	else begin
		case (RShift)
			1'b1: pulses <= (pulses < 4'ha) ? (pulses + 4'h1) : 4'h0;
			default: pulses <= pulses;
		endcase
	end
end

// accumulator logic
always @ (posedge CLOCK_50) begin
	case (fedge)
		1'b1: accumulator <= 8'h00;
		default: begin
			case (d0)
				4'h1: accumulator <= (up) ? ({1'b0,accumulator[7:1]}) : accumulator;
				4'h2: accumulator <= (up) ? ({accumulator[6:0],1'b0}) : accumulator;
				4'h4: accumulator <= (up) ? (accumulator - d1) : accumulator;
				4'h8: accumulator <= (up) ? (accumulator + d1) : accumulator;
				default: accumulator <= accumulator;
			endcase
		end
	endcase
end

// pulse generator modules
pulse_gen U0 (.clk(CLOCK_50), .load(rst), .Sample_Enable(SE), .st(st), .RShift(RShift));
timer_434us U1 (.clk(CLOCK_50), .reset(rst), .rollover(SE));

// uart translation
uart_translator U2 (.clk(CLOCK_50), .ld(ld), .word(shiftReg[8:1]), .update(up), .cmd(d0), .char(d1));

// display accumulator and last command
cmdDisp U3 (.deci(1'b0), .lastCmd(d0), .dispOut(HEX5));
deciDisp U4 (.clk(CLOCK_50), .accumulator(accumulator), .change(flag), .disp3(d5), .disp2(d4), .disp1(d3), .disp0(d2));
assign HEX3 = d5;
hex_disp U5 (.deci(1'b0), .hexVal(d4), .hexDisp(HEX2));
hex_disp U6 (.deci(1'b0), .hexVal(d3), .hexDisp(HEX1));
hex_disp U7 (.deci(1'b0), .hexVal(d2), .hexDisp(HEX0));

// transmit to uart module
uart_tx U8 (.clk(CLOCK_50), .load(ldWord), .enable(roll), .reload(currentWord), .out(tx));
timer_868us U9 (.clk(CLOCK_50), .reset(txRst), .rollover(roll));
assign GPIO[1] = tx;

always @ (*) begin
	d6 = (accumulator[7]) ? 8'h2d : 8'h20;
	d7 = {4'h3,d4};
	d8 = {4'h3,d3};
	d9 = {4'h3,d2};
end
assign d10 = 8'h0a;
assign d11 = 8'h0d;

always @ (posedge CLOCK_50) begin
	case (txPulses)
		6'h00: begin
			currentWord <= d6;
			ldWord <= roll;
		end
		6'h0a: begin
			currentWord <= d7;
			ldWord <= roll;
		end
		6'h14: begin
			currentWord <= d8;
			ldWord <= roll;
		end
		6'h1e: begin
			currentWord <= d9;
			ldWord <= roll;
		end
		6'h28: begin
			currentWord <= d10;
			ldWord <= roll;
		end
		6'h32: begin
			currentWord <= d11;
			ldWord <= roll;
		end
		default: begin
			currentWord <= currentWord;
			ldWord <= 1'b0;
		end
	endcase
end

always @ (posedge CLOCK_50) begin
	case ({flag,roll})
		2'b10, 2'b11: begin
			txRst <= 1'b0;
			txPulses <= 6'h0;
		end
		2'b01: begin
			txRst <= (txPulses > 6'h3b);
			txPulses <= txPulses + 6'h01;
		end
		default: begin
			txRst <= (txPulses > 6'h3b);
			txPulses <= txPulses;
		end
	endcase
end

endmodule 