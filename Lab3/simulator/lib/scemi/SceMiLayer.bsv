import DefaultValue::*;
import SceMi::*;
import GetPut::*;

import Types::*;
import Proc::*;
import ProcTypes::*;

module [SceMiModule] mkSceMiLayer();

  SceMiClockConfiguration conf = defaultValue;   
  SceMiClockPortIfc clk_port <- mkSceMiClockPort(conf);

  Proc proc <- buildDut(mkProc, clk_port);

  Put#(Addr) procStartPc = (interface Put;
    method put = proc.hostToCpu;
  endinterface);

  Get#(Tuple2#(RIndx, Data)) procCop = (interface Get;
    method get = proc.cpuToHost;
  endinterface);

  Empty dutin <- mkPutXactor(procStartPc, clk_port);
  Empty dutout <- mkGetXactor(procCop, clk_port);

  Empty shutdown <- mkShutdownXactor();
endmodule
