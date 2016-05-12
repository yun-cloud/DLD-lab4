module testbench();
    parameter cyc = 10; // clock cycle
    parameter delay = cyc/2;
    parameter delta = cyc/5;

    wire done, ERROR;
    wire [31:0] result;
    reg clk, rst, start;
    reg [31:0] A, B;

    GCD gcd0(clk, rst, start, A, B, done, result, ERROR);

    // clock
    always #(cyc/2) clk = ~clk;

    initial begin
        rst = 1'b0;
        clk = 1'b1;
        start = 1'b0;
        #(cyc);
        #(delay) rst = 1;
        #(cyc*4) rst = 0;
        #(delay);

        #(delta);
        A=32'd0;
        B=32'd3;
        start = 1'b1;
        $display("A = %d, B = %d", A, B);
        #(cyc);
        start = 1'b0;
        $display("start = 1'b0");
        #(cyc)

        $display("waiting done");
        @(posedge done); // wait til done signal up
        #(delay);
        #(delay);
        $display("\tGCD = %d, ERROR = %d", result, ERROR);
        #(delay);
        #(cyc);

        #(2*cyc);
        $finish;
    end
endmodule
