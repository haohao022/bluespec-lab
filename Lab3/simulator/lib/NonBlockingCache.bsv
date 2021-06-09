/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Types::*;
//import CompletionBuffer::*;
import MemTypes::*;
import Fifo::*;
import RegFile::*;

typedef 16 NumTags;
typedef Bit#(TLog#(NumTags)) Token;

interface NonBlockingCache;
  method Action req(Tuple2#(Token, MemReq) r);
  method ActionValue#(Tuple2#(Token, Maybe#(Data))) resp;

  method ActionValue#(MemReq) memReq;
  method Action memResp(Tuple2#(Addr, Line) r);
endinterface

typedef 1024 CacheEntries;
typedef Bit#(TLog#(CacheEntries)) CacheIndex;
typedef Bit#(TSub#(TSub#(AddrSz, TLog#(CacheEntries)), 2)) CacheTag;

typedef enum {Invalid, Valid, Locked} LineStatus deriving(Bits, Eq);

(* synthesize *)
module mkNonBlockingCache(NonBlockingCache);
  RegFile#(CacheIndex, Line) dataArray <- mkRegFileFull;
  RegFile#(CacheIndex, CacheTag) tagArray <- mkRegFileFull;
  RegFile#(CacheIndex, Bool) dirtyArray <- mkRegFileFull;
  RegFile#(CacheIndex, LineStatus) statusArray <- mkRegFileFull;

  Reg#(Bit#(TLog#(TAdd#(CacheEntries, 1)))) init <- mkReg(0);

  Fifo#(1, Tuple2#(Token, Maybe#(Data))) hitQ <- mkBypassFifo;

  StoreBuffer#(4) sb <- mkStoreBuffer;
  LoadBuffer#(16) lb <- mkLoadBuffer;
  WaitBuffer#(8)  wb <- mkWaitBuffer;

  Fifo#(2, MemReq) memReqQ <- mkCFFifo;
  Fifo#(2, Tuple2#(Addr, Line)) memRespQ <- mkCFFifo;

  function CacheIndex getIdx(Addr addr) = truncate(addr >> 2);
  function CacheTag getTag(Addr addr) = truncateLSB(addr);

  let inited = truncateLSB(init) == 1'b1;

  rule initialize(!inited);
    init <= init + 1;
    statusArray.upd(truncate(init), Invalid);
    dirtyArray.upd(truncate(init), False);
  endrule

  rule deqStore(inited);
    match {.token, .addr, .data} = sb.first;
    sb.deq;
    hitQ.enq(tuple2(token, Invalid));
    let idx = getIdx(addr);
    let tag = getTag(addr);
    let currStatus = statusArray.sub(idx);
    let currTag = tagArray.sub(idx);
    if(currStatus == Valid && currTag == tag)
    begin
      dataArray.upd(idx, data);
      dirtyArray.upd(idx, True);
    end
    else
      memReqQ.enq(MemReq{op: St, addr: addr, data: data});
  endrule

  rule handleLoad;
    let ldEntry = lb.getValidEntry;
    if(ldEntry matches tagged Valid .entry)
    begin
      if(entry.status == Writeback)
      begin
        memReqQ.enq(tuple2
      end
    end
  endrule

  method Action req(Tuple2#(Token, MemReq) r) if(inited);
    match {.token, .rreq} = r;
    if(rreq.op == St)
      sb.enq(tuple3(token, rreq.addr, rreq.data));
    else
    begin
      if(sb.search(rreq.addr) matches tagged Valid .data)
        hitQ.enq(tuple2(token, Valid (data)));
      else
      begin
        let idx = getIdx(rreq.addr);
        let tag = getTag(rreq.addr);
        let currStatus = statusArray.sub(idx);
        let currTag = tagArray.sub(idx);
        if(currTag == tag && currStatus == Valid)
          hitQ.enq(tuple2(token, Valid (dataArray.sub(idx))));
        else if(!lb.search(rreq.addr))
        begin
          let currDirty = dirtyArray.sub(idx);
          let currData = dataArray.sub(idx);
          statusArray.upd(idx, Locked);
          lb.add(token, rreq.addr, currData, currStatus, currDirty);
        end
        else
          wb.enq(tuple2(token, rreq.addr));
      end
    end
  endmethod

  method ActionValue#(Tuple2#(Token, Maybe#(Data))) resp;
    hitQ.deq;
    return hitQ.first;
  endmethod

  method ActionValue#(MemReq) memReq;
    memReqQ.deq;
    return memReqQ.first;
  endmethod

  method Action memResp(Tuple2#(Addr, Line) r);
    memRespQ.enq(r);
  endmethod
endmodule
