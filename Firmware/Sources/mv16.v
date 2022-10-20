
module mv16 (
	input	wire	[ 15:0 ]	sin16,
	output	wire	[ 15:0 ]	sout16,
	input	wire	[  2:0 ]	level
);

	wire	[  4:0 ]	M5;
	wire	[ 20:0 ]	sout21;

	function [ 4:0 ] getLinearLevel(input [2:0] in);
	begin
		case(in)
			3'b111:  getLinearLevel = 5'b10000;
			3'b110:  getLinearLevel = 5'b01110;
			3'b101:  getLinearLevel = 5'b01100;
			3'b100:  getLinearLevel = 5'b01010;
			3'b011:  getLinearLevel = 5'b01000;
			3'b010:  getLinearLevel = 5'b00111;
			3'b001:  getLinearLevel = 5'b00110;
			default: getLinearLevel = 5'b00101;
		endcase
	end
	endfunction

	assign	M5 = getLinearLevel(level);

	assign	sout21 = $signed( { 1'b0, M5 } ) * $signed( sin16 );

	assign	sout16 = sout21[ 19:4 ];
endmodule
