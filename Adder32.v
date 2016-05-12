module adder64(a,b,cin,cout,s,ovf);
    input [63:0] a,b;
    input cin;
    output cout;
    output [63:0] s;
    output ovf;

    wire [64:0] c;

    assign c[0] = cin;
    assign cout = c[8];
    assign c[64:1] = (a & b) | (a & c[63:0]) | (b & c[63:0]);
    assign s = a ^ b ^ c[63:0];
    assign ovf = ^c[64:63];
endmodule
