module uart_translator (
	input wire clk, ld, 
	input wire [7:0] word,
	output wire update,
	output wire [3:0] cmd, char
);

localparam state0 = 1'b0;
localparam state1 = 1'b1;

reg add, sub, lshift, rshift, dig, rst, up, sh, state, next_state, a, b, load, arith, lastWrd;
reg [3:0] concat;

assign update = up || sh;
assign char = word[3:0];
assign cmd = concat;

// rising edge detector on load
always @ (posedge clk) begin
	a <= ld;
	b <= a;
end

always @ (*) begin 
	load = a && ~b;
end

always @ (*) begin
	rst = ({add,sub,lshift,rshift,dig} == 5'b00000) && ld;
end

always @ (posedge clk) begin
	case (rst) 
		1'b1: state <= state0;
		default: begin
			case (load)
			1'b1: state <= next_state;
			default: state <= state;
			endcase
		end
	endcase
end

always @ (*) begin
	case (state)
		state0: next_state = (add || sub) ? state1 : state0;
		default: next_state = state0;
	endcase
end

// update and shift controllers
always @ (*) begin
	sh = (state == state0) && (lshift || rshift) && load;
	up = (state == state1) && dig && load;
end

// command register
always @ (posedge clk) begin
	concat <= (add || sub || lshift || rshift) ? ({add,sub,lshift,rshift}) : concat;
end

// command and digit checker
always @ (*) begin
	case (word) 
		8'h2b: begin
			add = 1'b1;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b0;
		end
		8'h2d: begin
			add = 1'b0;
			sub = 1'b1;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b0;
		end
		8'h30: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h31: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h32: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h33: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h34: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h35: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h36: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h37: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h38: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h39: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b1;
		end
		8'h3c: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b1;
			rshift = 1'b0;
			dig = 1'b0;
		end
		8'h3e: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b1;
			dig = 1'b0;
		end
		default: begin
			add = 1'b0;
			sub = 1'b0;
			lshift = 1'b0;
			rshift = 1'b0;
			dig = 1'b0;
		end
	endcase
end

endmodule 
