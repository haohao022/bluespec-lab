import RightShifterTypes::*;
import RightShifter::*;
import FIFO::*;

#define SRL LogicalRightShift
#define SRA ArithmeticRightShift
#define CASE_NUM 9

(* synthesize *)
module mkTests (Empty);
    RightShifterPipelined rsp <- mkRightShifterPipelined;
    FIFO#(Bit#(32)) answerFifo <- mkSizedFIFO(6);
    Reg#(Bit#(1)) test_stage <- mkReg(0);
    Reg#(Bit#(32)) i <- mkReg(0);
    Reg#(Bit#(32)) cycle <- mkReg(0);

    rule run;
        Bit#(32) operand[CASE_NUM] = {
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'd255, 32'd255,
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFF1, 32'd255, 32'd255};
        ShiftMode mode[CASE_NUM] = {
            SRL, SRL, SRL, SRL,
            SRA, SRA, SRA, SRA, SRA};
        Bit#(5) shamt[CASE_NUM] = {
            5'd15, 5'd31, 5'd3, 5'd0,
            5'd15, 5'd31, 5'd3, 5'd3, 5'd0};
        Bit#(32) ans[CASE_NUM] = {
            32'h1FFFF, 32'h1, 32'd31, 32'd255,
            32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, 32'd31, 32'd255};

        // Functional test.
        if (test_stage == 1'b0) begin
            if (i == 0) $display(
                "+-----------------------------+\n",
                "| Functional test running ... |\n",
                "+-----------------------------+");
            rsp.push(mode[i], operand[i], shamt[i]);
            answerFifo.enq(ans[i]);
            i <= (i >= CASE_NUM - 1)? 32'b0 : (i + 1);
            test_stage <= (i >= CASE_NUM - 1)? 1'b1 : 1'b0;
        end
        // Throughput test.
        else begin
            if (i == 0) $display(
                "+-----------------------------+\n",
                "| Throughput test running ... |\n",
                "+-----------------------------+");
            // {i[0], i[31:1]} is to avoid the result is always 0(i >> 31).
            rsp.push(SRL, {i[0], i[31:1]}, 5'd31);
            answerFifo.enq({i[0], i[31:1]} >> 5'd31);
            i <= i + 1;
        end

        cycle <= cycle + 1;
    endrule

    rule test;
        let b <- rsp.pull();
        let answer = answerFifo.first();
        answerFifo.deq();
        
        // [TODO] Cycle information displayed on the terminal is not accurate.
        if (b != answer) begin
            $display("cycle:", cycle,
                     ", result is ", b, " but expected ", answer);
        end
        else begin
            $display("cycle:", cycle, ", correct! res = ", b);
        end

        if (cycle >= CASE_NUM + 32 + 5) $finish(0);
    endrule
endmodule
