/*****************************************************************
** General definitions for SCALE kernel
**
** DJ - Mon Jun 28 21:34:37 1993
** $Id: kernel.h,v 1.3 2004/09/04 18:11:10 jcasper Exp $
******************************************************************/


/* Copyright (c) 2001 International Computer Science Institute,
   All rights reserved.

   Permission to use, copy, modify, and distribute this software and
   its documentation for any purpose, without fee, and without
   written agreement is hereby granted, provided that the above
   copyright notice and the following two paragraphs appear in all
   copies of this software.

   IN NO EVENT SHALL THE INTERNATIONAL COMPUTER SCIENCE INSTITUTE BE
   LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
   CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND
   ITS DOCUMENTATION, EVEN IF THE INTERNATIONAL COMPUTER SCIENCE
   INSTITUTE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   THE INTERNATIONAL COMPUTER SCIENCE INSTITUTE SPECIFICALLY DISCLAIMS
   ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE
   SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE
   INTERNATIONAL COMPUTER SCIENCE INSTITUTE HAS NO OBLIGATION TO
   PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. */


/* Copyright (c) 2001 Massachusetts Institute of Technology,
   All rights reserved.

   Permission to use, copy, modify, and distribute this software and
   its documentation for any purpose, without fee, and without
   written agreement is hereby granted, provided that the above
   copyright notice and the following two paragraphs appear in all
   copies of this software.

   IN NO EVENT SHALL THE MASSACHUSETTS INSTITUTE OF TECHNOLOGY BE
   LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
   CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND
   ITS DOCUMENTATION, EVEN IF THE MASSACHUSETTS INSTITUTE OF
   TECHNOLOGY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   THE MASSACHUSETTS INSTITUTE OF TECHNOLOGY SPECIFICALLY DISCLAIMS
   ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE
   SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE
   MASSACHUSETTS INSTITUTE OF TECHNOLOGY HAS NO OBLIGATION TO
   PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. */


#ifndef KERNEL_H_INCLUDED
#define KERNEL_H_INCLUDED

#include <regdef.h>

/* Where the exception jump table is located */

#define EXCEP_TABLE 0x1080

/* size of the kernel stack */

#define KSTACK_SIZE 1024

#define REG(a) (((T0_reg_t *) KMEM_REGS)[a])
#define FPREG(a) (((T0_fpreg_t *) KMEM_REG_F0)[a])
#define DPREG_L(a) (((T0_fpreg_t *) KMEM_REG_F0)[a])
#define DPREG_H(a) (((T0_fpreg_t *) KMEM_REG_F0)[a+1])

#define SHRL(a, b) ((UInt32) (a) >> (b))

#define SEXT16(a) ((Int32) ((Int16)(a)))

#define USER(addr) (addr+0x80000000)

/*
** Given an address and the opcode for the branch instruction at that
** address, find the address of the branch destination
*/

#define BRANCHADDR(addr, inst) \
    (T0_addrdiff_t)(SEXT16((inst) & OFFSET_MASK) << 2) + (addr) + 4;

/* This macro is used for calling C routines from assembler */
/* Note that we load the gp value from memory - this could be an immediate
	load, but because this would be resolved at link time this is a two
	insturction load.  KMEM_KERNEL_GP is in page zero, so this is a one
	instruction load, and as the gp value is unlikely to be needed immediately
	it ends up being quicker.
*/

#define CALLC(rtn, args)                        \
        lw      gp, KMEM_KERNEL_GP;             \
        jal     rtn

#define ABORT_KERNEL                            \
        li      a0, SCALE_SIGTRAP;                \
        li      a1, SCALE_BRK_KERNELBP;           \
        j       raise_signal

/* #defines that used to be in t0proc.h, but had to be moved here
   because that file no longer exists.  Note that some of these
   definitions are in T0_ISA.h, located in the t0isa module of
   the SCALE sims package, so they have to be manually kept in
   sync with that file.  (T0_ISA.h is not included because it
   is a C++ header file which includes other C++ header files
   like iostream, and scale-gcc cannot handle that.) */

#define RESET_ADDR 0x1000
#define EXCEPT_ADDR 0x1100
#define EXTINT0_ADDR 0x1200
#define EXTINT1_ADDR 0x1300
#define CP0_FROMHOST $20
#define CP0_TOHOST $21
#define CP0_BADVADDR $8
#define CP0_COUNT $9
#define CP0_COMPARE $11
#define CP0_STATUS $12
#define CP0_CAUSE $13
#define CP0_EPC $14
#define CP0_VUEPC $22
#define CP0_VUBADVADDR $23
#define IEC_SHIFT 0
#define IEC_MASK 1
#define STATUS_IEC (IEC_MASK << IEC_SHIFT)
#define KUC_SHIFT 1
#define KUC_MASK 1
#define STATUS_KUC (KUC_MASK << KUC_SHIFT)
#define IEP_SHIFT 2
#define IEP_MASK 1
#define STATUS_IEP (IEP_MASK << IEP_SHIFT)
#define KUP_SHIFT 3
#define KUP_MASK 1
#define STATUS_KUP (KUP_MASK << KUP_SHIFT)
#define IEO_SHIFT 4
#define IEO_MASK 1
#define STATUS_IEO (IEO_MASK << IEO_SHIFT)
#define KUO_SHIFT 5
#define KUO_MASK 1
#define STATUS_KUO (KUO_MASK << KUO_SHIFT)
#define IM_SHIFT 8
#define IM_MASK 0xff
#define STATUS_IM (IM_MASK << IM_SHIFT)
#define STATUS_IM_3 (1 << (IM_SHIFT+3))
#define STATUS_IM_4 (1 << (IM_SHIFT+4))
#define STATUS_IM_5 (1 << (IM_SHIFT+5))
#define STATUS_IM_6 (1 << (IM_SHIFT+6))
#define STATUS_IM_7 (1 << (IM_SHIFT+7))
#define STATUS_IM_EXTINT1 (STATUS_IM_3)
#define STATUS_IM_EXTINT0 (STATUS_IM_4)
#define STATUS_IM_VUI (STATUS_IM_5)
#define STATUS_IM_HOST (STATUS_IM_6)
#define STATUS_IM_TIMER (STATUS_IM_7)
#define CU0_SHIFT 28
#define CU0_MASK 1
#define STATUS_CU0 (CU0_MASK << CU0_SHIFT)
#define CU2_SHIFT 30
#define CU2_MASK 1
#define STATUS_CU2 (CU2_MASK << CU2_SHIFT)
#define BD_SHIFT 31
#define BD_MASK 1
#define CAUSE_BD (BD_MASK << BD_SHIFT)
#define IP_SHIFT 8
#define IP_MASK 0xff
#define CAUSE_IP (IP_MASK << IP_SHIFT)
#define CAUSE_IP_3 (1 << (IP_SHIFT+3))
#define CAUSE_IP_4 (1 << (IP_SHIFT+4))
#define CAUSE_IP_5 (1 << (IP_SHIFT+5))
#define CAUSE_IP_6 (1 << (IP_SHIFT+6))
#define CAUSE_IP_7 (1 << (IP_SHIFT+7))
#define CAUSE_IP_EXTINT1 (CAUSE_IP_3)
#define CAUSE_IP_EXTINT0 (CAUSE_IP_4)
#define CAUSE_IP_VUI (CAUSE_IP_5)
#define CAUSE_IP_HOST (CAUSE_IP_6)
#define CAUSE_IP_TIMER (CAUSE_IP_7)
#define CE_SHIFT 28
#define CE_MASK 0x03
#define CAUSE_CE (CE_MASK << CE_SHIFT)
#define CAUSE_CE_FPU (1 << CE_SHIFT)
#define CAUSE_CE_VU (2 << CE_SHIFT)
#define EXCEP_SHIFT 2
#define EXCEP_MASK 0x1f
#define CAUSE_EXCEP (EXCEP_MASK << EXCEP_SHIFT)
#define CAUSE_EXCEP_HINT 0
#define CAUSE_EXCEP_VINT 1
#define CAUSE_EXCEP_TINT 2
#define CAUSE_EXCEP_ADEL 4
#define CAUSE_EXCEP_ADES 5
#define CAUSE_EXCEP_ADEF 6
#define CAUSE_EXCEP_SYS 8
#define CAUSE_EXCEP_BP 9
#define CAUSE_EXCEP_RI 10
#define CAUSE_EXCEP_CP 11
#define CAUSE_EXCEP_OV 12
#define CAUSE_EXCEP_VU 18

#endif /* KERNEL_H_INCLUDED */
