module top #(parameter int HALF_PERIOD_CYCLES = 12500000) (
    input logic clk_25mhz,
    output logic led
);
    initial led = 0;
    int clk_count = 0;

    always_ff @(posedge clk_25mhz) begin
        if (clk_count == HALF_PERIOD_CYCLES - 1) begin
            clk_count <= 0;
            led <= ~led;
        end
        else clk_count <= clk_count + 1;
    end
endmodule