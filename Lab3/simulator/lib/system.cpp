/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/uio.h>
#include <stdio.h>

enum Handle {Open = 0, Close = 1, Lseek = 2, Writev = 3, Readv = 4, Nothing, OpenName, OpenFlags, OpenMode, LseekOffset, LseekWhence, WritevCnt, WritevIovLen, WritevIovBuf, ReadvCnt, ReadvIovLen, ReadvIovBuf};

enum Handle handle = Nothing;

extern "C" int systemCall(bool proceed, int x) {
  char *buf = NULL;
  int arg1 = 0, arg2 = 0, cnt = 0, res = 0;
  unsigned int idx = 0;
  struct iovec* vec = NULL;
  fprintf(stderr, "System call: %d %x %c during handler: %d\n", x, x, x, handle);
  switch (handle) {
    case Nothing:
      handle = (enum Handle)x;
      return 0;
    case Open:
      arg1 = x;
      buf = (char *)malloc(x);
      cnt = 0;
      handle = OpenName;
      return 0;
    case OpenName:
      if(cnt == arg1) {
        handle = OpenFlags;
      }
      else {
        buf[cnt] = (char)x;
        cnt++;
      }
      return 0;
    case OpenFlags:
      arg1 = x;
      handle = OpenMode;
      return 0;
    case OpenMode:
      res = open(buf, arg1, x);
      free(buf);
      handle = Nothing;
      return res;
    case Close:
      handle = Nothing;
      return close(x);
    case Lseek:
      arg1 = x;
      handle = LseekOffset;
      return 0;
    case LseekOffset:
      arg2 = x;
      handle = LseekWhence;
      return 0;
    case LseekWhence:
      handle = Nothing;
      return lseek(arg1, arg2, x);
    case Writev:
      arg1 = x;
      handle = WritevCnt;
      return 0;
    case WritevCnt:
      arg2 = x;
      vec = (struct iovec*)malloc(x);
      cnt = 0;
      handle = WritevIovLen;
      return 0;
    case WritevIovLen:
      if(cnt == arg2) {
        res = writev(arg1, vec, arg2);
        for(cnt = 0; cnt < arg2; cnt++)
          free(vec[cnt].iov_base);
        free(vec);
        handle = Nothing;
        return res;
      }
      else {
        vec[cnt].iov_len = x;
        vec[cnt].iov_base = (char *)malloc(x);
        idx = 0;
        handle = WritevIovBuf;
        return 0;
      }
    case WritevIovBuf:
      if(idx == vec[cnt].iov_len) {
        cnt++;
        handle = WritevIovLen;
      }
      else {
        char* ptr = (char*)vec[cnt].iov_base;
        ptr[idx] = (char)x;
        idx++;
      }
      return 0;
    case Readv:
      arg1 = x;
      handle = ReadvCnt;
      return 0;
    case ReadvCnt:
      arg2 = x;
      vec = (struct iovec*)malloc(x);
      cnt = 0;
      handle = ReadvIovLen;
      return 0;
    case ReadvIovLen:
      if(cnt == arg2) {
        res = readv(arg1, vec, arg2);
        handle = ReadvIovBuf;
        cnt = 0;
        idx = 0;
      }
      else {
        vec[cnt].iov_len = x;
        vec[cnt].iov_base = (char *)malloc(x);
        cnt++;
      }
      return 0;
    case ReadvIovBuf:
      if(cnt == arg2) {
        for(cnt = 0; cnt < arg2; cnt++)
          free(vec[cnt].iov_base);
        free(vec);
        handle == Nothing;
        return res;
      }
      else if(idx == vec[cnt].iov_len) {
        cnt++;
        idx = 0;
        return 0;
      }
      else {
        unsigned int temp = idx;
        char* ptr = (char*)vec[cnt].iov_base;
        idx++;
        return ptr[temp];
      }
  }
  return 0;
}
