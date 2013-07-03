/*      
# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# Copyright 2001-2004, ps2dev - http://www.ps2dev.org
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.
#
# $Id$
# Common used typedef
*/

#ifndef _TAMTYPES_H_
#define _TAMTYPES_H_ 1

typedef	unsigned char 		u8;
typedef unsigned short 		u16;

typedef	volatile unsigned char 		vu8;
typedef volatile unsigned short 	vu16;

#ifdef _EE
typedef unsigned int		u32;
typedef unsigned long long	u64;
#if _MIPS_SIM == _ABIN32
typedef unsigned int		u128 __attribute__(( mode(TI) ));
#endif

typedef volatile unsigned int		vu32;
typedef volatile unsigned long long	vu64;
#if _MIPS_SIM == _ABIN32
typedef volatile unsigned int		vu128 __attribute__(( mode(TI) ));
#endif
#else
typedef unsigned long int	u32;
typedef unsigned long long	u64;

typedef volatile unsigned long int	vu32;
typedef volatile unsigned long long	vu64;
#endif

typedef signed char 		s8;
typedef signed short 		s16;

typedef volatile signed char	vs8;
typedef volatile signed short	vs16;

#ifdef _EE
typedef signed int		s32;
typedef signed long long	s64;
#if _MIPS_SIM == _ABIN32
typedef signed int		s128 __attribute__(( mode(TI) ));
#endif

typedef volatile signed int		vs32;
typedef volatile signed long long	vs64;
#if _MIPS_SIM == _ABIN32
typedef volatile signed int		vs128 __attribute__(( mode(TI) ));
#endif
#else
typedef signed long int		s32;
typedef signed long long	s64;

typedef volatile signed long int	vs32;
typedef volatile signed long long	vs64;
#endif

#ifdef _EE
typedef union {
#if _MIPS_SIM == _ABIN32
	u128 qw;
#else
	u64  qwl;
	u64  qwh;
#endif
	u8   b[16];
	u16  hw[8];
	u32  sw[4];
	u64  dw[2];
} qword_t;

union _dword {
        u64 di;
        struct {
                u32 lo;
		u32 hi;
        } si;
};

#endif

#ifndef NULL
#define NULL	(void *)0
#endif

static inline u8  _lb(u32 addr) { return *(vu8 *)addr; }
static inline u16 _lh(u32 addr) { return *(vu16 *)addr; }
static inline u32 _lw(u32 addr) { return *(vu32 *)addr; }
#ifdef _EE
#if _MIPS_SIM == _ABIO32
static inline u64 _ld(u32 addr)
{
    union _dword val;
    long temp;

    __asm__ __volatile__(
	"	.set	push\n"
	"	.set	arch=r5900\n"
	"	ld	%0,(%3)\n"
		/* 63-32th bits must be same as 31th bit */
	"	dsra	%2,%0,32\n" 
	"	dsll	%1,%0,32\n" 
	"	dsra	%1,%1,32\n"
	"	.set	pop"
	: "=r"(temp), "=r" (val.si.lo), "=r" (val.si.hi) : "r" (addr));

    return val.di;
}
#else
static inline u64 _ld(u32 addr) { return *(vu64 *)addr; }
#endif
#endif

static inline void _sb(u8 val, u32 addr) { *(vu8 *)addr = val; }
static inline void _sh(u16 val, u32 addr) { *(vu16 *)addr = val; }
static inline void _sw(u32 val, u32 addr) { *(vu32 *)addr = val; }
#ifdef _EE
#if _MIPS_SIM == _ABIO32
static inline void _sd(u64 val, u32 addr)
{
    union _dword src;
    long temp;

    src.di=val;
    __asm__ __volatile__(
        "	.set push\n"
        "	.set arch=r5900\n"
        "	pextlw         %0,%2,%1\n"
        "	sd             %0,(%3)\n"
        "	.set   pop"
        : "=&r"(temp): "r"(src.si.lo), "r"(src.si.hi), "r" (addr));
}

#else
static inline void _sd(u64 val, u32 addr) { *(vu64 *)addr = val; }
#endif
#endif

#ifdef _EE
#if _MIPS_SIM == _ABIN32
static inline u128 _lq(u32 addr) { return *(vu128 *)addr; }
static inline void _sq(u128 val, u32 addr) { *(vu128 *)addr = val; }
#endif
#endif

#endif
