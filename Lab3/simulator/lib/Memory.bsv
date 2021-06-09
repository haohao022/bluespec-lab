/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Types::*;
import MemTypes::*;
import RegFile::*;
import Fifo::*;
import Vector::*;

interface Memory;
  method Action iReq(MemReq r);
  method ActionValue#(MemResp) iResp;
  method Action dReq(MemReq r);
  method ActionValue#(MemResp) dResp;
endinterface

(* synthesize *)
module mkMemory(Memory);
  RegFile#(Bit#(26), Data) mem <- mkRegFileWCFLoad("memory.vmh", 0, maxBound);

  Fifo#(2, MemReq) iMemReqQ <- mkCFFifo;
  Fifo#(2, MemResp) iMemRespQ <- mkCFFifo;

  Fifo#(2, MemReq) dMemReqQ <- mkCFFifo;
  Fifo#(2, MemResp) dMemRespQ <- mkCFFifo;

  rule getDResp;
    let req = dMemReqQ.first;
    let idx = truncate(req.addr >> 2);
    let data = mem.sub(idx);
    if(req.op==St)
    begin
      Vector#(NumBytes, Bit#(8)) bytes = unpack(data);
      Vector#(NumBytes, Bit#(8)) bytesIn = unpack(req.data);
      for(Integer i = 0; i < valueOf(NumBytes); i = i + 1)
      begin
        if(req.byteEn[i])
          bytes[i] = bytesIn[i];
      end
      mem.upd(idx, pack(bytes));
    end
    else
      dMemRespQ.enq(data);
    dMemReqQ.deq;
  endrule

  rule getIResp;
    let addr = iMemReqQ.first.addr;
    iMemRespQ.enq(mem.sub(truncate(addr >> 2)));
    iMemReqQ.deq;
  endrule

  method dReq = dMemReqQ.enq;

  method ActionValue#(MemResp) dResp;
    dMemRespQ.deq;
    return dMemRespQ.first;
  endmethod

  method iReq = iMemReqQ.enq;

  method ActionValue#(MemResp) iResp;
    iMemRespQ.deq;
    return iMemRespQ.first;
  endmethod
endmodule

