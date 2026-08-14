// FSM (output depends on present state only) Moore type finite state machine (fsm).

module seqDetector(out, clk, in, clear);

    parameter S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100;

    input clk, in, clear;
    output reg out;

    reg [2:0] state, next_state;

    always @(posedge clk) begin
        if (clear)
            state <= S0;
        else
            state <= next_state;
    end

    always @(state) begin
        case (state)
            S4: out = 1;
            default: out = 0;
        endcase
        
    end

    always @(*) begin
        case (state)
            S0: next_state = in ? S1 : S0;
            S1: next_state = in ? S2 : S0;
            S2: next_state = in ? S2 : S3;
            S3: next_state = in ? S1 : S4;
            S4: next_state = in ? S1 : S0;
            default: next_state = S0;
        endcase
    end
    
endmodule