module cmdDisp (
	input wire deci,
	input wire [3:0] lastCmd,
	output wire [7:0] dispOut
);

reg [7:0] cmdToDisp;

assign dispOut = cmdToDisp;

always @ (*) begin
	case (lastCmd)
		4'h1: cmdToDisp = deci ? (8'haf - 8'h80) : 8'haf;
		4'h2: cmdToDisp = deci ? (8'hc7 - 8'h80) : 8'hc7;
		4'h4: cmdToDisp = deci ? (8'h92 - 8'h80) : 8'h92;
		4'h8: cmdToDisp = deci ? (8'h88 - 8'h80) : 8'h88;
		default: cmdToDisp = 8'hff;
	endcase
end

endmodule 