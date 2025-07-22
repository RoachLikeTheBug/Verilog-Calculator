module uart_tx (
	input wire clk, load, enable,
	input wire [7:0] reload,
	output wire out
);

localparam state0 = 2'b00;
localparam state1 = 2'b01;
localparam state2 = 2'b10;
localparam state3 = 2'b11;

reg [9:0] shiftR;
reg [3:0] enable_count;
reg [1:0] state, next_state;

assign out = shiftR[0];

initial begin
	state = state0;
	shiftR = {1'b1,reload,1'b0};
	enable_count = 4'h0;
end

// shift register and state register
always @ (posedge clk) begin
	case ({load,enable})
		2'b00: begin
			shiftR <= shiftR;
			state <= state;
		end
		2'b01: begin
			shiftR <= {1'b1,shiftR[9:1]};
			state <= next_state;
		end
		2'b10: begin
			shiftR <= {1'b1,reload,1'b0};
			state <= next_state;
		end
		2'b11: begin
			shiftR <= {1'b1,reload,1'b0};
			state <= next_state;
		end
	endcase
end

// state transition logic
always @ (*) begin
	if (load) begin
		next_state = state1;
	end
	if (~load) begin
		case (state)
			state1: next_state = state2;
			state2: next_state = state3;
			state3: next_state = (enable_count < 4'ha) ? state2 : state0;
		endcase
	end
end

// pulse counter
always @ (posedge clk) begin
	case (state) 
		state0: enable_count <= 4'h0;
		state1: enable_count <= 4'h0;
		state2: enable_count <= (enable) ? (enable_count + 4'h1) : enable_count;
		state3: enable_count <= enable_count;
	endcase
end

endmodule 