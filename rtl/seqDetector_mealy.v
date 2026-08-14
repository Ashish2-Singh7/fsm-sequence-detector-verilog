// FSM (output depends on input and present state) Mealy type finite state machine (fsm).

module seqDetector(out, clk, in, clear);

    // Overlapping seq detector (1100)
    // state encodings (min flipflops required is 2)
    // S0 = 0 0
    // S1 = 0 1
    // S2 = 1 0
    // S3 = 1 1

    parameter S0 = 2'b00,
              S1 = 2'b01,
              S2 = 2'b10,
              S3 = 2'b11;

    input clk, in, clear;
    output reg out;

    reg [1:0] state, next_state;

    always @(posedge clk) begin
        if (clear)
            state <= S0;
        else
            state <= next_state;
    end

    always @(negedge clk) begin
        case (state)
            S3: out = in ? 0  : 1;  // out becomes 1 only when in is 0
            default: out = 0;
        endcase
    end

    always @(*) begin
        case (state)
            S0: next_state = in ? S1 : S0;
            S1: next_state = in ? S2 : S0; 
            S2: next_state = in ? S2 : S3; 
            S3: next_state = in ? S1 : S0;
            default: next_state = S0;
        endcase
    end
    
endmodule