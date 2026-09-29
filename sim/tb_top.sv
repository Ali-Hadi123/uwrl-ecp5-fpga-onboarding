`timescale 1ns/1ps

module tb_top;

parameter int HALF_PERIOD_CYCLES = 7;

int passed_cycles = 0;
localparam cycles_to_pass = 30;

logic clk = 0;
logic led;

initial begin
    $dumpfile("build/blink.vcd");
    $dumpvars(0, tb_top);
end

initial begin
    #3000;
    $fatal(1, "Timeout error.");
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
    if ($time != 0) begin
        if ($time !== change_allowed)
            $fatal(1, "Led changed at unexpected time %t", $time);
        change_allowed += toggle_period;
    end
end

int edge_count = 0;
logic expected_led;

always @(posedge clk) begin
    #1ps;
    edge_count++;

    if (led === 1'bx || led === 1'bz)
        $fatal(1, "Led is X/Z."); 

    expected_led = (((edge_count / HALF_PERIOD_CYCLES) % 2) == 1);
    if (led !== expected_led)
        $fatal(1, "Led is %b at edge %0d, expected %b", led, edge_count, expected_led);

    passed_cycles <= passed_cycles + 1;
end

always @(passed_cycles) begin
    if (passed_cycles === cycles_to_pass) begin
        $display("PASS");
        $finish;
    end
end

endmodule