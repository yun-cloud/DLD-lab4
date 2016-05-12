module GCD(clk, rst, start, A, B, done, result, ERROR);
    input clk, rst, start;
    input [31:0] A, B;
    output done, ERROR;
    output [31:0] result;

    wire startGCD, doneGCD, startDiv, doneDiv;
    wire [31:0] dividend, divisor, quotient, remainder;
    wire [3:0] stateGCD;

    assign done = doneGCD;

    Datapath dp(clk, startDiv, doneDiv, dividend, divisor, quotient, remainder);
    masterFSM mf(clk, rst, start, doneGCD, startGCD, done);
    GCDFSM gf(clk, rst, startGCD, doneGCD, startDiv, doneDiv, A, B, dividend, divisor, quotient, remainder, result, ERROR);
endmodule


module Datapath(clk, startDiv, doneDiv, dividend, divisor, quotient, remainder);
    input clk, startDiv;
    input [31:0] dividend, divisor;
    output doneDiv;
    output [31:0] quotient, remainder;

    divider32 d32(clk, startDiv, dividend, divisor, quotient, remainder, doneDiv);
endmodule

// define stateGCD
`define WAIT     4'b0000
`define LOAD     4'b0001
`define JUDGE    4'b0010
`define DIVIDE0  4'b0011
`define DIVIDE1  4'b0100
`define CHANGE   4'b0101
`define RESULT   4'b0110
`define ERROR    4'b0111
`define DONE     4'b1000
`define DELAY0   4'b1001
`define DELAY1   4'b1010

module GCDFSM(clk, rst, startGCD, doneGCD, startDiv, doneDiv, A, B, dividend, divisor, quotient, remainder, result, ERROR);
    input clk, rst, startGCD, doneDiv;
    input [31:0] A, B, quotient, remainder;
    output reg doneGCD, startDiv, ERROR;
    output reg [31:0] dividend, divisor, result;

    reg [3:0] stateGCD;
    reg [3:0] nsGCD;
    reg [31:0] nextDividend, nextDivisor;
    reg [2:0] delay;

    always @(posedge clk or posedge rst) begin
        if (rst) stateGCD <= `WAIT;
        else     stateGCD <= nsGCD;
    end

    always @(*) begin
        case (stateGCD)
            `WAIT: begin
                nsGCD = startGCD ? `LOAD : `WAIT;
                doneGCD = 1'b0;
                startDiv = 1'b0;
                ERROR = 1'b0;
                result = 0;
            end
            `LOAD: begin
                $display("state: LOAD");
                $display("load A = %d, B = %d", A, B);
                nsGCD = `CHANGE;
                nextDividend = (A > B) ? A : B;
                nextDivisor  = (A < B) ? A : B;
                if (nextDivisor == 0) begin
                    // ERROR, need some delay
                    delay = 7;
                    nsGCD = `DELAY0;
                end
            end
            `JUDGE: begin
                $display("state: JUDGE");
                // check if divisor == 1 or 0
                $display("JUDGE, divisor = %d", divisor);
                nsGCD = `DIVIDE0;
                if (divisor == 0 || divisor == 1) begin
                    nsGCD = `RESULT;
                end
            end
            `DIVIDE0: begin
                $display("state: DIVIDE0");
                startDiv = 1'b1;
                nsGCD = `DIVIDE1;
            end
            `DIVIDE1: begin
                $display("state: DIVIDE1");
                startDiv = 1'b0;
                nsGCD = (doneDiv) ? `CHANGE : `DIVIDE1;
                if (doneDiv) begin
                    nextDividend = divisor;
                    nextDivisor  = remainder;
                    $display("quotient = %d, remainder = %d", quotient, remainder);
                end
            end
            `CHANGE: begin
                $display("state: CHANGE");
                dividend = nextDividend;
                divisor  = nextDivisor;
                nsGCD = `JUDGE;
                $display("changed, dividend = %d, divisor = %d", dividend, divisor);
            end
            `RESULT: begin
                $display("state: RESULT");
                result = (divisor == 1) ? 1 : dividend;
                nsGCD = `DONE;
            end
            `ERROR: begin
                $display("state: ERROR");
                $display("ERROR");
                ERROR = 1'b1;
                nsGCD = `DONE;
            end
            `DONE: begin
                $display("state: DONE");
                doneGCD = 1'b1;
                nsGCD = `WAIT;
            end
            `DELAY0: begin
                $display("state: DELAY0, %d", delay);
                nsGCD = (delay > 0) ? `DELAY1 : `ERROR;
            end
            `DELAY1: begin
                $display("state: DELAY1");
                delay = delay - 1;
                nsGCD = `DELAY0;
            end
            default: begin
                nsGCD = `WAIT;
            end
        endcase
    end
endmodule

module masterFSM(clk, rst, start, doneGCD, startGCD, done);
    input clk, rst, start, doneGCD;
    output startGCD, done;

    reg state, ns;
    reg startGCD, done;
    parameter idle = 1'b0;
    parameter gcd  = 1'b1;

    always @(posedge clk or posedge rst) begin
        if (rst) state <= idle;
        else     state <= ns;
    end

    always @(*) begin
        case (state)
            idle: begin
                startGCD = 1'b0;
                done = 1'b0;
                ns = idle;
                if (start) begin
                    startGCD = 1'b1;
                    ns = gcd;
                end
            end
            default : begin
                startGCD = 1'b0;
                done = 1'b0;
                ns = gcd;
                if (doneGCD) begin
                    ns = idle;
                    done = 1'b1;
                end
            end
        endcase
    end
endmodule

`define SUB 4'b0101
module divider32(clk, start, dividend, divisor, quotient, remainder, done);
    input clk, start;
    input [31:0] dividend, divisor;
    output done;
    output [31:0] quotient, remainder;

    reg [31:0] quotient, remainder;
    reg done;
    //expand dividend and divisor,
    reg [63:0] long_dividend;
    reg [63:0] long_divisor;
    reg [4:0] state;
    reg inner_start;
    wire [63:0] differ;
    wire dontcare;

    // finite state machine
    always @(posedge clk or posedge start) begin
        if (start) begin
            state = 0;
            inner_start = 1;
        end
        else if (clk) begin
            state = state + 1;
        end
    end

    ALU64 sub(long_dividend, long_divisor, 1'b0, `SUB, differ, dontcare, dontcare, dontcare, dontcare);

    // Datapath
    always @(*) begin
        if (state == 0) begin
            long_dividend = {{32{1'b0}}, dividend};
            long_divisor  = {divisor,  {32{1'b0}}};
            quotient = 0;
            remainder = 0;
        end
        long_divisor = long_divisor >> 1;
        quotient = quotient << 1;
        done = 0;
        if (long_dividend >= long_divisor) begin
            long_dividend = long_dividend - long_divisor;
            quotient = quotient + 1;
        end
        if (state == 31) begin
            remainder = long_dividend[31:0];
            if (inner_start) begin
                inner_start = 0;
                done = 1;
            end
        end
    end
endmodule
