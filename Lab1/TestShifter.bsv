import RightShifterTypes::*;
import RightShifter::*;

(* synthesize *)
module mkTests (Empty);
    RightShifter logicalShifter <- mkRightShifter;
    RightShifter arithmeticShifter <- mkRightShifter;
    
    // there are many ways to write tests.  Here is a very simple
    // version, just to get you started.
    
    rule test;

        let g = multiplexer1(1, 1, 0);
        if (g != 0) begin
            $display("result is ", g, " but expected 0");
        end
        else begin
            $display("correct!");
        end
    
        let c = logicalShifter.shift(LogicalRightShift, 12, 2);
        if (c != 3) begin
            $display("result is ", c, " but expected 3");
        end
        else begin
            $display("correct!");
        end

        let b = logicalShifter.shift(LogicalRightShift, 12, 1);
        if (b != 6) begin
            $display("result is ", b, " but expected 6");
        end
        else begin
            $display("correct!");
        end

        let a = logicalShifter.shift(LogicalRightShift, 1, 1);
        if (a != 0) begin
            $display("result is ", a); 
        end
        else begin
            $display("correct!");
        end
        
        let h = logicalShifter.shift(ArithmeticRightShift, 12, 2);
        if (h != 3) begin
            $display("result is ", h, " but expected 3");
        end
        else begin
            $display("correct!");
        end

        let j = logicalShifter.shift(ArithmeticRightShift, -12, 2);
        if (j != -3) begin
            $display("result is ", j, " but expected -3");
        end
        else begin
            $display("correct!");
        end

        $display("my test going ...");
        // Test multiplexer1
        Bit#(1) arr_mux_a[8] = {0, 1, 0, 1, 0, 1, 0, 1};
        Bit#(1) arr_mux_b[8] = {0, 0, 1, 1, 0, 0, 1, 1};
        Bit#(1) arr_mux_s[8] = {0, 0, 0, 0, 1, 1, 1, 1};
        Bit#(1) arr_mux_o[8] = {0, 1, 0, 1, 0, 0, 1, 1};
        for (Integer i = 0; i < 8; i = i + 1) begin
            let out = multiplexer1(arr_mux_s[i], arr_mux_a[i], arr_mux_b[i]);
            if (out != arr_mux_o[i]) begin
                $display("result is ", out, " but expected ", arr_mux_o[i]);
            end
            else begin
                $display("correct!");
            end
        end
        $display("multiplexer1 test finished!");

        // Test LogicalRightShift
        Bit#(32) arr_lrs_oprand[4] = {
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'd255, 32'd255};
        Bit#(5) arr_lrs_shamt[4] = {5'd15, 5'd31, 5'd3, 5'd0};
        Bit#(32) arr_lrs_out[4] = {32'h1FFFF, 32'h1, 32'd31, 32'd255};
        for (Integer i = 0; i < 4; i = i + 1) begin
            let out = logicalShifter.shift(
                LogicalRightShift, arr_lrs_oprand[i], arr_lrs_shamt[i]);
            if (out != arr_lrs_out[i]) begin
                $display("result is ", out, " but expected ", arr_lrs_out[i]);
            end
            else begin
                $display("correct!");
            end
        end
        $display("LogicalRightShift test finished!");

        // Test ArithmeticRightShift
        Bit#(32) arr_ars_oprand[5] = {
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFF1, 32'd255, 32'd255};
        Bit#(5) arr_ars_shamt[5] = {5'd15, 5'd31, 5'd3, 5'd3, 5'd0};
        Bit#(32) arr_ars_out[5] = {
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, 32'd31, 32'd255};
        for (Integer i = 0; i < 5; i = i + 1) begin
            let out = logicalShifter.shift(
                ArithmeticRightShift, arr_ars_oprand[i], arr_ars_shamt[i]);
            if (out != arr_ars_out[i]) begin
                $display("result is ", out, " but expected ", arr_ars_out[i]);
            end
            else begin
                $display("correct!");
            end
        end
        $display("ArithmeticRightShift test finished!");

      $finish(0);
    endrule
endmodule
