import RightShifterTypes::*;
import Gates::*;
import FIFO::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    // WTF! sel == 1? a : b; not the same as Lab1.
    // return orGate(andGate(a, sel), andGate(b, notGate(sel)));
    return orGate(andGate(a, notGate(sel)), andGate(b, sel));
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
    Bit#(32) res_vec = 0;
    for (Integer i = 0; i < 32; i = i+1) begin
        res_vec[i] = multiplexer1(sel, a[i], b[i]);
    end
    return res_vec; 
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) res_vec = 0;
    for (Integer i = 0; i < valueof(n); i = i+1) begin
        res_vec[i] = multiplexer1(sel, a[i], b[i]);
    end
    return res_vec; 
endfunction

typedef Bit#(32) Operand;
typedef Bit#(5) Shamt;
typedef Bit#(1) Sign;

module mkRightShifterPipelined (RightShifterPipelined);
    // struct {Bit#(32) operand, Bit#(5) shamt, Bit#(1) sign}
    FIFO#(Bit#(38)) shift_in <- mkFIFO();
    FIFO#(Bit#(38)) shift1_status <- mkFIFO();
    FIFO#(Bit#(38)) shift2_status <- mkFIFO();
    FIFO#(Bit#(38)) shift4_status <- mkFIFO();
    FIFO#(Bit#(38)) shift8_status <- mkFIFO();
    FIFO#(Bit#(38)) shift16_status <- mkFIFO();

// bsc macro seems not support ##.
#define STEP_RULE_DECL(fifo_in, fifo_out, shamt_offset, shift_offset) \
    Operand operand_shift = fifo_in.first()[37:6]; \
    Shamt shamt_shift = fifo_in.first()[5:1]; \
    Sign sign_shift = fifo_in.first()[0]; \
    operand_shift = multiplexer32( \
        shamt_shift[shamt_offset], operand_shift, \
        {signExtend(sign_shift), operand_shift[31:shift_offset]}); \
    fifo_out.enq({operand_shift, shamt_shift, sign_shift}); \
    fifo_in.deq();

    rule shift1 (True);
        STEP_RULE_DECL(shift_in, shift1_status, 0, 1) endrule
    rule shift2 (True);
        STEP_RULE_DECL(shift1_status, shift2_status, 1, 2) endrule
    rule shift4 (True);
        STEP_RULE_DECL(shift2_status, shift4_status, 2, 4) endrule
    rule shift8 (True);
        STEP_RULE_DECL(shift4_status, shift8_status, 3, 8) endrule
    rule shift16 (True);
        STEP_RULE_DECL(shift8_status, shift16_status, 4, 16) endrule

    method Action push(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
        Bit#(1) sign = case(mode) 
            LogicalRightShift: 1'b0;
            ArithmeticRightShift: operand[31];
        endcase;
        shift_in.enq({operand, shamt, sign});
        // $display("rsp push ", mode, " ", operand, " ", shamt);
    endmethod
    
    method ActionValue#(Bit#(32)) pull();
        Bit#(32) res = shift16_status.first()[37:6];
        shift16_status.deq();
        return res;
    endmethod

endmodule
