 # Header file for test abstract machine on a SCALE0 simulation
 # 
 # $Id: scaletest.h,v 1.1 2004/09/04 18:11:10 jcasper Exp $
 # DJ - Mon Aug 23 15:25:57 1993

#include <sys/kernel.h>
#include <sys/t0test_kmem.h>


        .globl  __start
        .globl  __testcode

#include <regdef.h>

/* These are not normally available for user mode programs-however,
   we want to use them in test programs */

#define TEST_SMIPS .err
#define TEST_SMIPSRAW .err
#define TEST_SMIPSUSER .err

#if defined(TESTAM_SMIPS)
#undef TEST_SMIPS
#define TEST_SMIPS
 # Status reg. mask for IM_HOST | IM_EXTINT0 | IM_EXTINT1 | IEP
#define __TESTSTATUS 0x00005804
#endif
#if defined(TESTAM_SMIPSRAW)
#undef TEST_SMIPSRAW
#define TEST_SMIPSRAW
 # Status reg. mask for IM_HOST | IM_EXTINT0 | IM_EXTINT1 | IEP
#define __TESTSTATUS 0x00005804
#endif
#if defined(TESTAM_SMIPSUSER)
#undef TEST_SMIPSUSER
#define TEST_SMIPSUSER
 # Status reg. mask for IM_HOST | IM_EXTINT0 | IM_EXTINT1 | IEP
#define __TESTSTATUS 0x00005804
#endif

#if defined(TESTAM_SMIPS)
        .globl  __teststatus
        .data   99
__teststatus:
        .word   __TESTSTATUS
#endif
#if defined(TESTAM_SMIPSRAW)
        .globl  __teststatus
        .data   99
__teststatus:
        .word   __TESTSTATUS
#endif
#if defined(TESTAM_SMIPSUSER)
        .globl  __teststatus
        .data   99
__teststatus:
        .word   __TESTSTATUS
#endif

        .globl  __TESTDATABEGIN

#define TEST_DATABEGIN                  \
        .data 1;                        \
        .align  4;                      \
__TESTDATABEGIN:


        .globl  __TESTDATAEND

#define TEST_DATAEND                    \
__TESTDATAEND:

        .data 2
__testsentinel:
        .word   0xdeadbeef

#if defined(TESTAM_SMIPS)
#define SYNC nop; nop
#elif defined(TESTAM_SMIPSRAW)
#define SYNC nop; nop
#elif defined(TESTAM_SMIPSUSER)
#define SYNC nop; nop
#else
#define SYNC sync
#endif

#if defined(TESTAM_SMIPS)
#define TEST_CRASH                      \
        break
#elif defined(TESTAM_SMIPSRAW)
#define TEST_CRASH                      \
        break
#elif defined(TESTAM_SMIPSUSER)
#define TEST_CRASH                      \
        break
#else
#define TEST_CRASH                      \
        la      k1, __testcrash;        \
        jalr    k0, k1;                 \
        nop
#endif

#define TEST_DONE                       \
        SYNC;                           \
        li      t0, TOHOST_HALTED;      \
        .set    noat;                   \
        mtc0    t0, $21;                \
        .set    at;                     \
1:      b       1b

/* Output a word in a0 to the SIP port - potentially destroys t0-t9, v0-v1 */

#define TEST_OUTPUT_A0			\
	la	t0, __testoutput;	\
	jalr	t0

#define TEST_CODEBEGIN                  \
        .text;                          \
        .ent    __testcode;             \
__testcode:;                            \
__start:

        

#define TEST_CODEEND                    \
        .end    __testcode;             \
        TEST_DONE

	.data
	.align 2
ptab:	.word 0x00000000
	.word 0x00000001
	.word 0x00000002
	.word 0x00000003
	.word 0x00000004
	.word 0x00000005
	.word 0x00000006
	.word 0x00000007
	.word 0x00000008

