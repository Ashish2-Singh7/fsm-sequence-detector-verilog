module top;

    wire out;
    reg clk, clear, in;
    integer i;
    parameter N = 19;

    reg [N-1:0] arr = 'b0110011001011001001;

    seqDetector DUT(out, clk, in, clear);

    initial begin
        $dumpfile("./sim/waveform.vcd");
        $dumpvars(0, top);
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // clk signal of time period 10units is generated here.
    end

    initial begin
        $display($time, "in: %b | out: %b", in, out);

        // input: 0110011001011001001
        clear = 1'b1;
        in = arr[N-1];
        #8;
        
        clear = 1'b0; // Release reset
        
        #0 $display($time, "in: %b | out: %b", in, out);
        for (i = 1; i<=N-1; i = i + 1) begin
            #10;
            $display($time, "in: %b | out: %b", in, out);
            in = arr[N-1-i];
        end
        #10 $finish;
    end

endmodule
