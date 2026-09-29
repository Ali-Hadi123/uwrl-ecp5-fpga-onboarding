`timescale 1ns/1ps

module top_tb;

parameter int HALF_PERIOD_CYCLES = 7;

int passed_cycles = 0;
localparam cycles_to_pass = 10;

logic clk = 0;
logic led;

initial begin
    $dumpfile("blink.vcd");
    $dumpvars(0, top_tb);
end

initial begin
    #3000;
    $fatal(1, "Timeout error.")
end

always #20 clk = ~clk;

top #(.HALF_PERIOD_CYCLES(HALF_PERIOD_CYCLES)) dut (
    .clk_25mhz(clk),
    .led(led)
  );

initial begin
    //Check if the led if originally off
    #1ps;
    if (led !== 1'b0) 
        $fatal(1, "Led does not start low.");
end

localparam time first_toggle = 20 + (HALF_PERIOD_CYCLES - 1) * 40;
localparam time toggle_period = HALF_PERIOD_CYCLES * 40;

time change_allowed = first_toggle;

always @(led) begin
    //Check if led glitches between cycles.
    if ($time !== change_allowed)
        $fatal(1, "Led changed at unexpected time %t", $time);
    change_allowed += toggle_period;
end

int clk_cycles = 0;

always @(posedge clk) begin
    //Ensure that led is never X/Z
    #1ps;
    if (led === 1'bx || led === 1'bz)
        $fatal(1, "Led is X/Z."); 

    //Check that led follows cycles properly.
    if (clk_cycles < HALF_PERIOD_CYCLES - 1) begin
        if (led !== 1'b0) 
            $fatal(1, "Led is not low when expected");
        clk_cycles <= clk_cycles + 1;
        passed_cycles <= passed_cycles + 1;
    end
    else begin
        if (led !== 1'b1) 
            $fatal(1, "Led is not high when expected");
        clk_cycles <= 0;
        passed_cycles <= passed_cycles + 1;
    end
end

always begin
    if (passed_cycles === cycles_to_pass) begin
        $display("PASS");
        $finish;
    end
end

endmodule