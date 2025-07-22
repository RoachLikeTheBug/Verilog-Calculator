module timer_868us (
	input wire clk, reset,
	output wire rollover
);

reg [11:0] i;
reg roll;

assign rollover = roll;

initial begin
	roll = 1'b0;
	i = 12'h000;
end

always @ (*) begin
	if (i == 12'h1b1) begin //12'h1b2 is 434 in decimal
		roll = 1'b1;
	end 
	else begin
		roll = 1'b0;
	end
end

always @ (posedge clk) begin
	case (reset)
		1'b0: i <= (i < 12'h1b1) ? (i + 12'h001) : 12'h000;
		1'b1: i <= 12'h000;
	endcase
end

endmodule 