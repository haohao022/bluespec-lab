/*

Copyright (C) 2012

Arvind <arvind@csail.mit.edu>
Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Proc::*;
import Types::*;

typedef enum {Start, Run} State deriving (Bits, Eq);

(* synthesize *)
module mkTestBench();
  Proc proc <- mkProc;

  Reg#(Bit#(32)) cycle <- mkReg(0);
  Reg#(State)    state <- mkReg(Start);

  rule start(state == Start);
    proc.hostToCpu(32'h1000);
    state <= Run;
  endrule

  rule run(state == Run);
    cycle <= cycle + 1;
    $display("\ncycle %d", cycle);
  endrule

  rule checkFinished(state == Run);
    let c = proc.cpuToHost;
    $fwrite(stderr, "\n--------------------------------------------\n");
    if(c == 0)
      $fwrite(stderr, "PASSED\n");
    else
      $fwrite(stderr, "FAILED %d\n", c);
    $finish;
  endrule
endmodule

