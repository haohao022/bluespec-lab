int getTime()
{
  int ret;
  asm volatile ( "mtc0 $0, $10\n\t"
                 "mfc0 %0, $10" : "=r" (ret) :);
  return ret;
}

int getInsts()
{
  int ret;
  asm volatile( "mfc0 %0, $11" : "=r" (ret) :);
  return ret;
}
