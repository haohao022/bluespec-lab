/*
** $Header: /projects/assam/cvsroot/scale/test/testbuild/sys/t0test_kmem.h,v 1.3 2004/09/04 18:11:10 jcasper Exp $
**
** Definitions of locations and costants used to communicate between T0
** and host programs.
**
** This is a subset of the old spert/os/kernel/kmem.h, and only includes
** stuff that could be useful in all types of T0 setups - including test
** harnesses.  Checkout spert/os/lowmem.h for other stuff.
**
** DJ - Wed Aug 31 15:31:29 1994
**
*/


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


/*
  This is now only used for t0test programs.  Some of the stuff below here
  (especially gdb related) might be redundant now.

  Krste Fri Oct  1 16:46:14 1999
 */

/******** This is included by assembler, C and C++ programs - be *********/
/******** careful not to add any language-specific stuff         *********/


/* Some standard values for the TOHOST register - used by test and
   diagnostic programs */

#define TOHOST_NULL 0x00
#define TOHOST_HALTED 0x01      /* Stopped intentionally */
#define TOHOST_ABORT 0x02	/* Something went wrong - register dump (as
				   described below) is valid */
#define TOHOST_CRASH 0x03       /* Crash with unknown cause */
#define TOHOST_DIAGFAIL 0x04    /* Diagnostics failed */

/* The values 0x2X and 0x3X are used to pass data back to the host in
   situations where memory cannot be used - e.g. bare die test rigs.
   Data is passed one nibble at a time, low nibble first.  
   Moving from high to low nibble indicates the next byte has been started */

#define TOHOST_LOWNIBBLE 0x20
#define TOHOST_HIGHNIBBLE 0x30
#define TOHOST_NIBBLECMD 0xf0	/* Mask for the above */
#define TOHOST_NIBBLEDATA 0x0f	/* Mask to get data from a nibble */

/* Higher-level functions - used to communicate between kernel and server -
   these have values 0x40 to 0x7f */

#define TOHOST_KERNEL 0x40

/* Values with top bit set are handled by hardware */

#define TOHOST_HW 0x80

/* Some standard values for the FROMHOST register */

#define FROMHOST_NULL 0		/* Quiescent state */
#define FROMHOST_LOWACK 0x20	/* Acknowledgement for TOHOST_LOWNIBBLE */
#define FROMHOST_HIGHACK 0x30	/* Acknowledgement for TOHOST_HIGHNIBBLE */
#define FROMHOST_KERNEL 0x40	/* Values above here used for kernel */

/*
** The fixed bit of memory used for communication with host.  Note, big objects
** which need to be passed to the host can be put elsewhere and just a pointer
** passed here.
** Note that memory is shadowed throughout the address space, so this
** stuff will appear allover the place, including location 0 onwards
*/

#define KMEM_KFIXED 0x0000
#define KMEM_KFIXED_END 0x1000

#define KMEM_NUM_CPUREGS 78     /* Number of registers saved */
#define KMEM_NUM_VECREGS 16     /* Number of vector registers */
#define KMEM_MAXVLEN 32         /* Number of elements in one vector */
#define KMEM_NUM_VECWORDS (KMEM_NUM_VECREGS*KMEM_MAXVLEN)

#define KMEM_SIZE_NULL 64          /* Space to leave empty for null.. */
                                   /* ..pointer references */
#define KMEM_SIZE_CPUREGS (KMEM_NUM_CPUREGS*4)
#define KMEM_SIZE_VECREGS (KMEM_NUM_VECWORDS*4)

/*
** Numbers for the various registers
** This must tie up with how gdb works.
*/

#define R_ZERO (0)
#define R_AT (1)
#define R_V0 (2)
#define R_V1 (3)
#define R_A0 (4)
#define R_A1 (5)
#define R_A2 (6)
#define R_A3 (7)
#define R_T0 (8)
#define R_T1 (9)
#define R_T2 (10)
#define R_T3 (11)
#define R_T4 (12)
#define R_T5 (13)
#define R_T6 (14)
#define R_T7 (15)
#define R_S0 (16)
#define R_S1 (17)
#define R_S2 (18)
#define R_S3 (19)
#define R_S4 (20)
#define R_S5 (21)
#define R_S6 (22)
#define R_S7 (23)
#define R_T8 (24)
#define R_T9 (25)
#define R_K0 (26)
#define R_K1 (27)
#define R_GP (28)
#define R_SP (29)
#define R_FP (30)
#define R_S8 (30)
#define R_RA (31)
#define R_SR (32)
#define R_LO (33)
#define R_HI (34)
#define R_BAD (35)
#define R_CAUSE (36)
#define R_PC (37)
#define R_F0 (38)
#define R_FCRCS (70)
#define R_FCRIR (71)
#define R_PSEUDOFP (72) /* Not quite sure why, but gdb has this */
#define R_VLR (73)
#define R_VCOND (74)
#define R_VOVF (75)
#define R_VSAT (76)
#define R_VREV (77)

/*
** Offsets (displacements) for the registers when stored in memory.
** This must tie up with how gdb works.
*/

#define RD_ZERO (R_ZERO*4)
#define RD_AT (R_AT*4)
#define RD_V0 (R_V0*4)
#define RD_V1 (R_V1*4)
#define RD_A0 (R_A0*4)
#define RD_A1 (R_A1*4)
#define RD_A2 (R_A2*4)
#define RD_A3 (R_A3*4)
#define RD_T0 (R_T0*4)
#define RD_T1 (R_T1*4)
#define RD_T2 (R_T2*4)
#define RD_T3 (R_T3*4)
#define RD_T4 (R_T4*4)
#define RD_T5 (R_T5*4)
#define RD_T6 (R_T6*4)
#define RD_T7 (R_T7*4)
#define RD_S0 (R_S0*4)
#define RD_S1 (R_S1*4)
#define RD_S2 (R_S2*4)
#define RD_S3 (R_S3*4)
#define RD_S4 (R_S4*4)
#define RD_S5 (R_S5*4)
#define RD_S6 (R_S6*4)
#define RD_S7 (R_S7*4)
#define RD_T8 (R_T8*4)
#define RD_T9 (R_T9*4)
#define RD_K0 (R_K0*4)
#define RD_K1 (R_K1*4)
#define RD_GP (R_GP*4)
#define RD_SP (R_SP*4)
#define RD_FP (R_FP*4)
#define RD_S8 (R_S8*4)
#define RD_RA (R_RA*4)
#define RD_SR (R_SR*4)
#define RD_LO (R_LO*4)
#define RD_HI (R_HI*4)
#define RD_BAD (R_BAD*4)
#define RD_CAUSE (R_CAUSE*4)
#define RD_PC (R_PC*4)
#define RD_F0 (R_F0*4)
#define RD_FCRCS (R_FCRCS*4)
#define RD_FCRIR (R_FCRIR*4)
#define RD_PSEUDOFP (R_PSEUDOFP*4)
#define RD_VLR (R_VLR*4)
#define RD_VCOND (R_VCOND*4)
#define RD_VOVF (R_VOVF*4)
#define RD_VSAT (R_VSAT*4)
#define RD_VREV (R_VREV*4)

/* Define the names of the registers as they appear in memory */

#define KMEM_REGNAMES \
"zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", \
"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7", \
"s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", \
"t8", "t9", "k0", "k1", "gp", "sp", "s8", "ra", \
"sr", "lo", "hi", "bad", "cause", "pc", \
"f0",   "f1",   "f2",   "f3",   "f4",   "f5",   "f6",   "f7", \
"f8",   "f9",   "f10",  "f11",  "f12",  "f13",  "f14",  "f15", \
"f16",  "f17",  "f18",  "f19",  "f20",  "f21",  "f22",  "f23",\
"f24",  "f25",  "f26",  "f27",  "f28",  "f29",  "f30",  "f31",\
"fcrcs", "fcrir", \
"fp", "vlr", "vcond", "vovf", "vsat", "vrev"

#define KMEM_NUM_CAUSES 32

/* Names for the different possible values in the cause register */

#define KMEM_CAUSENAMES \
    "Host int.", "Vector mem. int.", "Timer int.", "Unknown", \
    "Address load", "Address store", "Address fetch", "Unknown", \
    "Syscall", "Breakpoint", "Reserved inst.", "COP unusable", \
    "Overflow", "Unknown", "Unknown", "Unknown", \
    "Unknown", "Unknown", "Vector unit", "Unknown", \
    "Unknown", "Unknown", "Unknown", "Unknown", \
    "Unknown", "Unknown", "Unknown", "Unknown", \
    "Unknown", "Unknown", "Unknown", "Unknown"


/* An area for C null pointers to corrupt */

#define KMEM_NULL (KMEM_KFIXED)


/* Somewhere to put all our registers - gdb references this */

#define KMEM_REGS (KMEM_NULL + KMEM_SIZE_NULL)
#define KMEM_REG_ZERO (KMEM_REGS + RD_ZERO)
#define KMEM_REG_AT (KMEM_REGS + RD_AT)
#define KMEM_REG_V0 (KMEM_REGS + RD_V0)
#define KMEM_REG_V1 (KMEM_REGS + RD_V1)
#define KMEM_REG_A0 (KMEM_REGS + RD_A0)
#define KMEM_REG_A1 (KMEM_REGS + RD_A1)
#define KMEM_REG_A2 (KMEM_REGS + RD_A2)
#define KMEM_REG_A3 (KMEM_REGS + RD_A3)
#define KMEM_REG_T0 (KMEM_REGS + RD_T0)
#define KMEM_REG_T1 (KMEM_REGS + RD_T1)
#define KMEM_REG_T2 (KMEM_REGS + RD_T2)
#define KMEM_REG_T3 (KMEM_REGS + RD_T3)
#define KMEM_REG_T4 (KMEM_REGS + RD_T4)
#define KMEM_REG_T5 (KMEM_REGS + RD_T5)
#define KMEM_REG_T6 (KMEM_REGS + RD_T6)
#define KMEM_REG_T7 (KMEM_REGS + RD_T7)
#define KMEM_REG_T8 (KMEM_REGS + RD_T8)
#define KMEM_REG_T9 (KMEM_REGS + RD_T9)
#define KMEM_REG_S0 (KMEM_REGS + RD_S0)
#define KMEM_REG_S1 (KMEM_REGS + RD_S1)
#define KMEM_REG_S2 (KMEM_REGS + RD_S2)
#define KMEM_REG_S3 (KMEM_REGS + RD_S3)
#define KMEM_REG_S4 (KMEM_REGS + RD_S4)
#define KMEM_REG_S5 (KMEM_REGS + RD_S5)
#define KMEM_REG_S6 (KMEM_REGS + RD_S6)
#define KMEM_REG_S7 (KMEM_REGS + RD_S7)
#define KMEM_REG_K0 (KMEM_REGS + RD_K0)
#define KMEM_REG_K1 (KMEM_REGS + RD_K1)
#define KMEM_REG_GP (KMEM_REGS + RD_GP)
#define KMEM_REG_SP (KMEM_REGS + RD_SP)
#define KMEM_REG_FP (KMEM_REGS + RD_FP)
#define KMEM_REG_RA (KMEM_REGS + RD_RA)
#define KMEM_REG_SR (KMEM_REGS + RD_SR)
#define KMEM_REG_LO (KMEM_REGS + RD_LO)
#define KMEM_REG_HI (KMEM_REGS + RD_HI)
#define KMEM_REG_BAD (KMEM_REGS + RD_BAD)
#define KMEM_REG_CAUSE (KMEM_REGS + RD_CAUSE)
#define KMEM_REG_PC (KMEM_REGS + RD_PC)
#define KMEM_REG_F0 (KMEM_REGS + RD_F0)
#define KMEM_REG_FCRCS (KMEM_REGS + RD_FCRCS)
#define KMEM_REG_FCRIR (KMEM_REGS + RD_FCRIR)
#define KMEM_REG_VLR (KMEM_REGS + RD_VLR)
#define KMEM_REG_VCOND (KMEM_REGS + RD_VCOND)
#define KMEM_REG_VOVF (KMEM_REGS + RD_VOVF)
#define KMEM_REG_VSAT (KMEM_REGS + RD_VSAT)
#define KMEM_REG_VREV (KMEM_REGS + RD_VREV)

#define KMEM_VECREGS (KMEM_REGS + KMEM_NUM_CPUREGS*4)

#define KMEM_KERNEL (KMEM_VECREGS + KMEM_NUM_VECWORDS*4)


