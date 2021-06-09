/*

Copyright (C) 2012

Arvind <arvind@csail.mit.edu>
Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#include <iostream>
#include <unistd.h>

#include "SceMiHeaders.h"

void fromCop(void* userdata, const Tuple2_Bit_5_Bit_32& resp)
{
    bool* finish = (bool*)userdata;
    if(resp.m_tpl_1.getByte(0) == 18) {
      std::cerr << resp.m_tpl_2.getWord(0);
    }
    else if(resp.m_tpl_1.getByte(0) == 19) {
      int x = (int)resp.m_tpl_2.getWord(0);
      std::cerr << (char)x;
    }
    else if(resp.m_tpl_1.getByte(0) == 21) {
      (*finish) = true;
      if(resp.m_tpl_2.getWord(0) == 0)
        std::cerr << "PASSED\n";
      else
        std::cerr << "FAILED " << resp.m_tpl_2.getWord(0) << "\n";
    }
}

int main()
{
  SceMiParameters params("scemi.params");
  SceMi* scemi(SceMi::Init(SceMi::Version(SCEMI_VERSION_STRING), &params));

  InportQueueT<Addr> hostToCpu("", "scemi_dutin_inport", scemi);
  OutportProxyT<Tuple2_Bit_5_Bit_32> cpuToHost("", "scemi_dutout_outport", scemi);

  ShutdownXactor shutdown("", "scemi_shutdown", scemi);

  bool finish = false;
  cpuToHost.setCallBack(fromCop, &finish);
  SceMiServiceThread* sthread = new SceMiServiceThread(scemi);

  hostToCpu.sendMessage(0x1000);

  while (!finish) {
    sleep(0);
  }

  // Clean up
  shutdown.blocking_send_finish();
  sthread->stop();
  sthread->join();
  SceMi::Shutdown(scemi);
  delete sthread;

  return 0;
}
