import RightShifterTypes::*;
import Gates::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    // Part 1: Re-implement this function using the gates found in the Gates.bsv file
    // return (sel == 0)? a : b;
    // ret = a & ~sel | b & sel
    return orGate(
        andGate(a, notGate(sel)),
        andGate(b, sel)
    );
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
    // Part 2: Re-implement this function using static elaboration (for-loop and multiplexer1)
    // return (sel == 0)? a : b;
    Bit#(32) mux_out;
    for (Integer i = 0; i < 32; i = i + 1) begin
        mux_out[i] = multiplexer1(sel, a[i], b[i]);
    end
    return mux_out;
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    // Part 3: Re-implement this function as a polymorphic function using static elaboration
    // return (sel == 0)? a : b;
    Bit#(n) mux_out;
    for (Integer i = 0; i < valueOf(n); i = i + 1) begin
        mux_out[i] = multiplexer1(sel, a[i], b[i]);
    end
    return mux_out;
endfunction

module mkRightShifter(RightShifter);
    method Bit#(32) shift(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
    // Parts 4 and 5: Implement this function with the multiplexers you implemented
        Bit#(32) result = operand;
        Bit#(1) sign_flag = case(mode)
            LogicalRightShift: 1'b0;
            ArithmeticRightShift: operand[31];
        endcase;

        for (Integer i = 0; i < 5; i = i + 1) begin
            Bit#(32) shifted = signExtend(sign_flag);
            for (Integer j = 0; j < 32 - 2 ** i; j = j + 1) begin
                shifted[j] = result[2 ** i + j];
            end
            result = multiplexer32(shamt[i], result, shifted);
        end

        // [DONE]
        // Bit#(32) shifted = {sign[((1 << i) - 1):0], step_shift_res[31:(1 << i)]};
        // Compiler always complain about the statement above, and I almost tried
        // everything (perhaps not) about that, so unrolling the for_loop instead.
        // let step_shift1 = multiplexer32(
        //     shamt[0], operand, {sign_flag[0:0], operand[31:1]});
        // let step_shift2 = multiplexer32(
        //     shamt[1], step_shift1, {sign_flag[1:0], step_shift1[31:2]});
        // let step_shift4 = multiplexer32(
        //     shamt[2], step_shift2, {sign_flag[3:0], step_shift2[31:4]});
        // let step_shift8 = multiplexer32(
        //     shamt[3], step_shift4, {sign_flag[7:0], step_shift4[31:8]});
        // result = multiplexer32(
        //     shamt[4], step_shift8, {sign_flag[15:0], step_shift8[31:16]});

        // if (mode == LogicalRightShift) begin
        //     result = operand >> shamt;
        // end

        // if(mode == ArithmeticRightShift) begin
        //     Int#(32) signedOperand = unpack(operand);
        //     result = pack(signedOperand >> shamt);
        // end
        return result;
    endmethod
endmodule
