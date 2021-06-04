import RightShifterTypes::*;
import Gates::*;
import FIFO::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    // WTF! sel == 1? a : b; not the same as Lab1.
    // return orGate(andGate(a, sel),andGate(b, notGate(sel))); 
    return orGate(andGate(a, notGate(sel)),andGate(b, sel)); 
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

// typedef struct {
//     Bit#(32) operand;
//     Bit#(5) shamt;
//     Bit#(1) sign;
// } FIFOStatus deriving(Bits, Eq);

module mkRightShifterPipelined (RightShifterPipelined);
    // FIFO#(Bit#(32)) operand_in <- mkFIFO();
    // FIFO#(Bit#(5)) shamt_in <- mkFIFO();
    // FIFO#(Bit#(1)) sign_in <- mkFIFO();
    FIFO#(Bit#(38)) shift_in <- mkFIFO();
    FIFO#(Bit#(38)) shift1_status <- mkFIFO();
    FIFO#(Bit#(38)) shift2_status <- mkFIFO();
    FIFO#(Bit#(38)) shift4_status <- mkFIFO();
    FIFO#(Bit#(38)) shift8_status <- mkFIFO();
    FIFO#(Bit#(38)) shift16_status <- mkFIFO();

    // Perhaps bsc support only the most stupid macro.
    // #define STEP_RULE_DECLARE_HASH(step, fifo_in, fifo_out)\
    //     rule shift ## step (True);\
    //         Operand operand_shift ## step = fifo_in.first()[37:6];\
    //         Shamt shamt_shift ## step = fifo_in.first()[5:1];\
    //         Sign sign_shift ## step = fifo_in.first()[0];\
    //         operand_shift1 = multiplexer32(\
    //             shamt_shift ## step[0],\
    //             operand_shift ## step,\
    //             {sign_shift ## step, operand_shift ## step[31:1]}\
    //         );\
    //         fifo_in.deq();\
    //         fifo_out.enq({\
    //             operand_shift ## step, shamt_shift ## step, sign_shift ## step});\
    //     endrule

    rule shift1 (True);
        Bit#(32) operand_shift1 = shift_in.first()[37:6];
        Bit#(5) shamt_shift1 = shift_in.first()[5:1];
        Bit#(1) sign_shift1 = shift_in.first()[0];

        operand_shift1 = multiplexer32(
            shamt_shift1[0], operand_shift1, 
            {sign_shift1, operand_shift1[31:1]}
        );
        shift1_status.enq({operand_shift1, shamt_shift1, sign_shift1});
        shift_in.deq();
    endrule

    rule shift2 (True);
        Bit#(32) operand_shift2 = shift1_status.first()[37:6];
        Bit#(5) shamt_shift2 = shift1_status.first()[5:1];
        Bit#(1) sign_shift2 = shift1_status.first()[0];

        operand_shift2 = multiplexer32(
            shamt_shift2[1], operand_shift2, 
            {sign_shift2, operand_shift2[31:1]}
        );
        shift2_status.enq({operand_shift2, shamt_shift2, sign_shift2});
        shift1_status.deq();
    endrule

    rule shift4 (True);
        Bit#(32) operand_shift4 = shift2_status.first()[37:6];
        Bit#(5) shamt_shift4 = shift2_status.first()[5:1];
        Bit#(1) sign_shift4 = shift2_status.first()[0];

        operand_shift4 = multiplexer32(
            shamt_shift4[2], operand_shift4, 
            {sign_shift4, operand_shift4[31:1]}
        );
        shift4_status.enq({operand_shift4, shamt_shift4, sign_shift4});
        shift2_status.deq();
    endrule

    rule shift8 (True);
        Bit#(32) operand_shift8 = shift4_status.first()[37:6];
        Bit#(5) shamt_shift8 = shift4_status.first()[5:1];
        Bit#(1) sign_shift8 = shift4_status.first()[0];

        operand_shift8 = multiplexer32(
            shamt_shift8[3], operand_shift8, 
            {sign_shift8, operand_shift8[31:1]}
        );
        shift8_status.enq({operand_shift8, shamt_shift8, sign_shift8});
        shift4_status.deq();
    endrule

    rule shift16 (True);
        Bit#(32) operand_shift16 = shift8_status.first()[37:6];
        Bit#(5) shamt_shift16 = shift8_status.first()[5:1];
        Bit#(1) sign_shift16 = shift8_status.first()[0];

        operand_shift16 = multiplexer32(
            shamt_shift16[4], operand_shift16, 
            {sign_shift16, operand_shift16[31:1]}
        );
        shift16_status.enq({operand_shift16, shamt_shift16, sign_shift16});
        shift8_status.deq();
    endrule

    method Action push(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
        Bit#(1) sign = case(mode) 
            LogicalRightShift: 1'b0;
            ArithmeticRightShift: operand[31];
        endcase;
        shift_in.enq({operand, shamt, sign});
    endmethod
    
    method ActionValue#(Bit#(32)) pull();
        Bit#(32) res = shift16_status.first()[37:6];
        shift16_status.deq();
        return res;
    endmethod

endmodule
