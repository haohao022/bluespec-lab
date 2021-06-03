import RightShifterTypes::*;
import Gates::*;
import FIFO::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    return orGate(andGate(a, sel),andGate(b, notGate(sel))); 
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

typedef struct {
    Bit#(32) operand;
    Bit#(5) shamt;
    Bit#(1) sign;
} FIFOStatus deriving(Bits, Eq);

module mkRightShifterPipelined (RightShifterPipelined);
    FIFO#(Bit#(32)) operand <- mkFIFO();
    FIFO#(Bit#(5)) shamt <- mkFIFO();
    FIFO#(Bit#(1)) sign <- mkFIFO();
    FIFO#(Bit#(38)) shift1_status <- mkFIFO();
    FIFO#(Bit#(38)) shift2_status <- mkFIFO();
    FIFO#(Bit#(38)) shift4_status <- mkFIFO();
    FIFO#(Bit#(38)) shift8_status <- mkFIFO();
    FIFO#(Bit#(38)) shift16_status <- mkFIFO();

    rule shift1 (True);
        FIFOStatus status = {operand.first(), shamt.first(), sign.first()};
        
    endrule

    method Action push(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
    /* Write your code here */
    endmethod
    
    method ActionValue#(Bit#(32)) pull();
        return {shift16_status.first()};
    endmethod

endmodule
