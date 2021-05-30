import RightShifterTypes::*;
import Gates::*;

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
	// Part 1: Re-implement this function using the gates found in the Gates.bsv file
	return (sel == 0)?a:b; 
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
	// Part 2: Re-implement this function using static elaboration (for-loop and multiplexer1)
	return (sel == 0)?a:b; 
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
	// Part 3: Re-implement this function as a polymorphic function using static elaboration
	return (sel == 0)?a:b;
endfunction


module mkRightShifter (RightShifter);
    method Bit#(32) shift(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
	// Parts 4 and 5: Implement this function with the multiplexers you implemented
        Bit#(32) result = 0;

        if (mode == LogicalRightShift) begin
           result = operand >> shamt;
        end

        if(mode == ArithmeticRightShift) 
        begin
	    Int#(32) signedOperand = unpack(operand);
            result = pack(signedOperand >> shamt);
        end
        return result;   
    endmethod
endmodule

