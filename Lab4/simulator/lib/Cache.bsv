/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Types::*;
import MemTypes::*;
import Fifo::*;
import RegFile::*;
import Vector::*;

interface Cache;
  method Action req(MemReq r);
  method ActionValue#(Data) resp;

  method ActionValue#(MemReq) memReq;
  method Action memResp(Line r);
endinterface

typedef 1024 CacheEntries;
typedef Bit#(TLog#(CacheEntries)) CacheIndex;
typedef Bit#(TSub#(TSub#(AddrSz, TLog#(CacheEntries)), 2)) CacheTag;

typedef enum {Ready, StartMiss, SendFillReq, WaitFillResp} CacheStatus deriving (Bits, Eq);

(* synthesize *)
module mkCache(Cache);
  RegFile#(CacheIndex, Line) dataArray <- mkRegFileFull;
  RegFile#(CacheIndex, Maybe#(CacheTag)) tagArray <- mkRegFileFull;
  RegFile#(CacheIndex, Bool) dirtyArray <- mkRegFileFull;

  Reg#(Bit#(TLog#(TAdd#(CacheEntries, 1)))) init <- mkReg(0);

  Fifo#(1, Data) hitQ <- mkBypassFifo;

  Reg#(MemReq) miss <- mkRegU;

  Reg#(CacheStatus) status <- mkReg(Ready);

  Fifo#(2, MemReq) memReqQ <- mkCFFifo;
  Fifo#(2, Line) memRespQ <- mkCFFifo;

  function CacheIndex getIdx(Addr addr) = truncate(addr >> 2);
  function CacheTag getTag(Addr addr) = truncateLSB(addr);

  let inited = truncateLSB(init) == 1'b1;

  rule initialize(!inited);
    init <= init + 1;
    tagArray.upd(truncate(init), Invalid);
    dirtyArray.upd(truncate(init), False);
  endrule

  rule startMiss(status == StartMiss);
    let idx = getIdx(miss.addr);
    let tag = tagArray.sub(idx);
    let dirty = dirtyArray.sub(idx);
    if(isValid(tag) && dirty)
    begin
      let addr = {validValue(tag), idx, 2'b0};
      let data = dataArray.sub(idx);
      memReqQ.enq(MemReq{op: St, addr: addr, byteEn: miss.byteEn, data: data});
      status <= SendFillReq;
    end
    else
    begin
      memReqQ.enq(miss);
      status <= WaitFillResp;
    end
  endrule

  rule sendFillReq(status == SendFillReq);
    memReqQ.enq(miss);
    status <= WaitFillResp;
  endrule

  rule waitFillResp(status == WaitFillResp && inited);
    let idx = getIdx(miss.addr);
    let tag = getTag(miss.addr);
    let data = memRespQ.first;
    dataArray.upd(idx, data);
    tagArray.upd(idx, Valid (tag));
    dirtyArray.upd(idx, False);
    hitQ.enq(data);
    memRespQ.deq;
    status <= Ready;
  endrule

  method Action req(MemReq r) if(status == Ready && inited);
    let idx = getIdx(r.addr);
    let tag = getTag(r.addr);
    let currTag = tagArray.sub(idx);
    let hit = Valid (tag) == currTag;
    let data = dataArray.sub(idx);
    if(r.op == Ld)
    begin
      if(hit)
      begin
        hitQ.enq(data);
      end
      else
      begin
        miss <= r;
        status <= StartMiss;
      end
    end
    else
    begin
      if(hit)
      begin
        Vector#(NumBytes, Bit#(8)) bytes = unpack(data);
        Vector#(NumBytes, Bit#(8)) bytesIn = unpack(r.data);
        for(Integer i = 0; i < valueOf(NumBytes); i = i + 1)
        begin
          if(r.byteEn[i])
            bytes[i] = bytesIn[i];
        end
        dataArray.upd(idx, pack(bytes));
        dirtyArray.upd(idx, True);
      end
      else
      begin
        memReqQ.enq(r);
      end
    end
  endmethod

  method ActionValue#(Data) resp;
    hitQ.deq;
    return hitQ.first;
  endmethod

  method ActionValue#(MemReq) memReq;
    memReqQ.deq;
    return memReqQ.first;
  endmethod

  method Action memResp(Line r);
    memRespQ.enq(r);
  endmethod
endmodule
