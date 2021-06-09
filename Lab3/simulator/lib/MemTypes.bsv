import Types::*;

typedef Data Line;

typedef Line MemResp;

typedef enum{Ld, St} MemOp deriving(Eq,Bits);
typedef struct{
    MemOp op;
    ByteEn byteEn;
    Addr  addr;
    Data  data;
} MemReq deriving(Eq,Bits);
