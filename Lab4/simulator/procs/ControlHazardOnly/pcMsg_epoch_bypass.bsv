/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Types::*;
import ProcTypes::*;
import MemTypes::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import Cop::*;
import Fifo::*;
import AddrPred::*;
import Scoreboard::*;

typedef struct {
  DecodedInst dInst;
  Data rVal1;
  Data rVal2;
  Data copVal;
  Addr pc;
  Addr ppc;
  Bool epoch;
} Fetch2Execute deriving (Bits, Eq);

typedef struct {
  Maybe#(FullIndx) dst;
  Data             data;
} Execute2Writeback deriving(Bits, Eq);

interface Proc;
   method ActionValue#(Tuple2#(RIndx, Data)) cpuToHost;
   method Action hostToCpu(Bit#(32) startpc);
endinterface

(* synthesize *)
module [Module] mkProc(Proc);
  Reg#(Addr) pc <- mkRegU;
  RFile      rf <- mkRFile;
  IMemory  iMem <- mkIMemory;
  DMemory  dMem <- mkDMemory;
  Cop       cop <- mkCop;
  AddrPred pcPred <- mkBtb;

  // Fifo#(1, Fetch2Execute) f2Ex <- mkPipelineFifo;
  Fifo#(2, Fetch2Execute) f2Ex <- mkCFFifo;
  Fifo#(2, Execute2Writeback) ex2Wb <- mkCFFifo;
  Fifo#(1, Redirect) execRedirect <- mkBypassFifo;
  // Fifo#(2, Redirect)   execRedirect <- mkCFFifo;

  Scoreboard#(3) scoreboard <- mkCFScoreboard;

  // This design uses two epoch registers, one for each stage of the pipeline.
  // Execute sets the eEpoch and discards any instruction that doesn't match it.
  // It passes the information about change of epoch to fetch stage indirectly by
  // passing a valid execRedirect using a Fifo. Fetch changes fEpoch everytime it
  // gets a execRedirect and tags every instruction with its epoch

  Reg#(Bool) fEpoch <- mkReg(False);
  Reg#(Bool) eEpoch <- mkReg(False);

  rule doFetch(cop.started);
    // Fetch.
    let inst = iMem.req(pc);
    $display("Fetch: pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));

    // Decode.
    let dInst = decode(inst);
    
    // Register Read.
    let rVal1 = rf.rd1(validRegValue(dInst.src1));
    let rVal2 = rf.rd2(validRegValue(dInst.src2));
    let copVal = cop.rd(validRegValue(dInst.src1));

    // dequeue the incoming redirect and update the predictor whether it's a mispredict or not
    if(execRedirect.notEmpty)
    begin
      execRedirect.deq;
      pcPred.update(execRedirect.first);
    end
    // change pc and the fetch's copy of the epoch only on a mispredict
    if(execRedirect.notEmpty && execRedirect.first.mispredict)
    begin
      fEpoch <= !fEpoch;
      pc <= execRedirect.first.nextPc;
    end
    // fetch the new instruction on a non mispredict
    else if(!scoreboard.search1(dInst.src1) && !scoreboard.search2(dInst.src2))
    begin
      let ppc = pcPred.predPc(pc);
      pc <= ppc;
      f2Ex.enq(Fetch2Execute{dInst: dInst, rVal1: rVal1, rVal2: rVal2,
                           copVal: copVal, pc: pc, ppc: ppc, epoch: fEpoch});
      let dst = dInst.dst;
      if (isValid(dst) && validValue(dst).regType == Normal)
        scoreboard.insert(dst);
    end
    else
    begin
      $display("Block the pipeline at pc: %h", pc);
    end
  endrule

  // Execute, Memory.
  rule doExecute;
    // let inst  = f2Ex.first.inst;
    let dInst = f2Ex.first.dInst;
    let rVal1 = f2Ex.first.rVal1;
    let rVal2 = f2Ex.first.rVal2;
    let copVal = f2Ex.first.copVal;
    let pc    = f2Ex.first.pc;
    let ppc   = f2Ex.first.ppc;
    let epoch = f2Ex.first.epoch;

    // Proceed only if the epochs match
    if(epoch == eEpoch)
    begin
      // $display("Execute: pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));
      $display("Execute: pc: %h", pc);
  
      // let dInst = decode(inst);
  
      // let rVal1 = rf.rd1(validRegValue(dInst.src1));
      // let rVal2 = rf.rd2(validRegValue(dInst.src2));     
  
      // let copVal = cop.rd(validRegValue(dInst.src1));
  
      let eInst = exec(dInst, rVal1, rVal2, pc, ppc, copVal);
  
      if(eInst.iType == Unsupported)
      begin
        $fwrite(stderr, "Executing unsupported instruction at pc: %x. Exiting\n", pc);
        $finish;
      end

      if(eInst.iType == Ld)
      begin
        let data <- dMem.req(MemReq{op: Ld, addr: eInst.addr, byteEn: ?, data: ?});
        eInst.data = gatherLoad(eInst.addr, eInst.byteEn, eInst.unsignedLd, data);
      end
      else if(eInst.iType == St)
      begin
        match {.byteEn, .data} = scatterStore(eInst.addr, eInst.byteEn, eInst.data);
        let d <- dMem.req(MemReq{op: St, addr: eInst.addr, byteEn: byteEn, data: data});
      end

      // if (isValid(eInst.dst) && validValue(eInst.dst).regType == Normal)
      //   rf.wr(validRegValue(eInst.dst), eInst.data);
  
      // Send the branch resolution to fetch stage, irrespective of whether it's mispredicted or not
      // Note that the primitive version don't consider J, JR either. And the
      // answer in BUAA_COURSE_SHARING is not reliable, it simply closes the
      // branch prediction. Anyway, thanks to those pioneers of our open
      // source course!
      if (eInst.iType == Br || eInst.iType == J || eInst.iType ==Jr)
        execRedirect.enq(Redirect{pc: pc, nextPc: eInst.addr,
          // brType: eInst.iType, taken: False, // Turn branch prediction off.
          brType: eInst.iType, taken: eInst.brTaken,
          mispredict: eInst.mispredict});
      // On a branch mispredict, change the epoch, to throw away wrong path instructions
      if (eInst.mispredict) eEpoch <= !eEpoch;
  
      cop.wr(eInst.dst, eInst.data);
      
      ex2Wb.enq(Execute2Writeback{dst: eInst.dst, data: eInst.data});
    end

    f2Ex.deq;
  endrule

  // Writeback.
  rule doWriteback;
    let dst = ex2Wb.first.dst;
    let data = ex2Wb.first.data;

    // [TODO] Conditional write.
    if (isValid(dst) && validValue(dst).regType == Normal)
    begin
      rf.wr(validRegValue(dst), data);
      scoreboard.remove;
    end
    // cop.wr(dst, data);

    ex2Wb.deq;
  endrule
  
  method ActionValue#(Tuple2#(RIndx, Data)) cpuToHost;
    let ret <- cop.cpuToHost;
    return ret;
  endmethod

  method Action hostToCpu(Bit#(32) startpc) if (!cop.started);
    cop.start;
    pc <= startpc;
  endmethod
endmodule

//comments
// This code also works with either (or both) Fifo replaced with CFFifo
// If both Fifos are CFFifo, then fetch and execute are also conflict free
// If either Fifo is not CFFifo, then fetch and execute can be scheduled concurrently, with execute<fetch
// If BypassFifo is used for pc-redirect, then the processor is slightly faster
// This is by far the most robust solution as we will see later
