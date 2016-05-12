module ALU64(a,b,cin,fs,y,c,n,z,v);
	input [63:0] a,b;
	input cin;
	input [3:0] fs;
	output reg [63:0] y;
	output c; // carry out
	output n;
	output z;
	output v;

	wire [63:0] s;
	wire carryOut;
	wire ovf;

	wire sub = (fs==4'b0101) | (fs==4'b0110);
	wire withCarry = (fs==4'b0011);
	//wire sat = (fs==4'b0100) | (fs==4'b0110);
	wire ari_shift = (fs==4'b1100) | (fs==4'b1110);

	wire shift_ovf = a[63] ^ y[63];
	//wire sat_s = (sat & ovf) ? {1'b0,{31{1'b1}}} : s;
	//wire sat_s = 101;
	wire [63:0] sub_b = b ^ {64{sub}};
	wire sub_cry_cin = sub | (withCarry & cin);
	wire limit = {1'b0,{63{1'b1}}} + a[63];

	assign c = (fs==4'b1100) ? a[63] : carryOut;
	assign n = y[63];
	assign z = ~(|y);
	assign v = (ari_shift) ? shift_ovf : ovf;

	adder64 a0(a,sub_b,sub_cry_cin,carryOut,s,ovf);

	always @(*) begin
		case (fs)
			4'b0000: y = a;
			4'b0001: y = b;
			4'b0010: y = s;
			4'b0011: y = s;
			4'b0100: begin
				y = s;
				if (ovf) begin 
					y = {1'b0,{63{1'b1}}} + a[63]; 
				end
			end
			4'b0101: y = s;
			4'b0110: begin
				y = s;
				if (ovf) begin 
					y = {1'b0,{63{1'b1}}} + a[63]; 
				end
			end
			4'b0111: y = a & b;
			4'b1000: y = a | b;
			4'b1001: y = a ^ b;
			4'b1010: y = ~a;
			4'b1011: y = a << 1;
			4'b1100: y = $signed(a) <<< 1;
			4'b1101: y = a >> 1;
			4'b1110: y = $signed(a) >>> 1;
			default: y = 4'b0;
		endcase
	end
endmodule


