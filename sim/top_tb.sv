`timescale 1ns/1ps

module top_tb;

parameter int HALF_PERIOD_CYCLES = 7;

logic clk = 0;
logic led;

initial begin
    $dumpfile("blink.vcd");
    $dumpvars(0, top_tb);
end

always #20 clk = ~clk;

top #(.HALF_PERIOD_CYCLES(HALF_PERIOD_CYCLES)) dut (
    .clk_25mhz(clk),
    .led(led)
  );

initial begin
    //Check if the led if originally off
    #1;
    if (led !== 1'b0) 
        $fatal(1, "Led does not start low.");
end

int clk_cycles = 0;

always @(posedge clk) begin
    //Ensure that led is never X/Z
    #1;
    if (led === 1'bx || led === 1'bz)
        $fatal(1, "Led is X/Z."); 

    if (clk_cycles < HALF_PERIOD_CYCLES - 1) begin
        if (led !== 1'b0) 
            $fatal(1, "Led is not low when expected");
        clk_cycles <= clk_cycles + 1;
    end
    else begin
        if (led !== 1'b1) 
            $fatal(1, "Led is not high when expected");
        clk_cycles <= 0;
    end
    
end

endmodule