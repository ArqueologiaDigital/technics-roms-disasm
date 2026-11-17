/* lane_hd round 41, helper h_n1, file c: HDAE5000_FormatDialog_CodeDigit with four variants.
   cc900-options: -Xr
   cc900-name: CodeDigit_f=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_x=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_q=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_k=HDAE5000_FormatDialog_CodeDigit
   Run 2026-11-17-10-hd-r39 (hd_r39_m4b.c: main, _l, _p, _s; hd_r39_m4c.c: main, _cl): everything after the digit's
   store is the ROM's in all of them (both declarations of StrPrefixCmp give the same code); the store differs:
   - ROM: the count widened in WA, COPIED TO BC, 2 added in BC, then the base address of the buffer (no +2 in it)
     into XDE, the digit into A and the store through the base plus the 16-bit register BC.
   - an UNSIGNED index (main, _l, _cl) is widened to 32 bits and added to the base loaded as a constant: not the ROM;
   - a SIGNED index (_p, _s) gives the ROM's addressing, base plus 16-bit register, but as an expression its +2 is
     folded into the base address and the count goes straight to BC.
   So the index is a signed int LOCAL: `i = count;` is the widening in WA and the copy to the local's register,
   `i += 2;` the add in that register, and it cannot share WA because it is still needed when the digit is loaded
   into A (the unsigned local of _l / _cl was dead by then and sat in WA).
     main:        int i (declared last); i = count; i += 2; buf[i] = digit;
     CodeDigit_f: i declared first of the locals;
     CodeDigit_x: the add inside the index, cells[i += 2] = ..;
     CodeDigit_q: the store through pointer arithmetic, *(cells + i) = ..;
     CodeDigit_k: i = count + 2 in one statement (a control: the add probably stays in WA).
   Unsure: that V4.23 gives the local BC and not DE or a stack word. */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);

extern unsigned char ram_22ad9c[];                      /* [0] = digits typed; the digits from +2 */
extern unsigned char HDAE5000_RAM_FormatCodeDigits[];   /* ram_22ad9c + 2 */
extern char HDAE5000_Str_HdFormatCode[];
extern char HDAE5000_Str_Track0RecoverCode[];

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int HDAE5000_FormatDialog_CodeDigit(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
    i += 2;
    ram_22ad9c[i] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

/* the index declared first */
int CodeDigit_f(int digit)
{
    int i;
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
    i += 2;
    ram_22ad9c[i] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

/* the add inside the index */
int CodeDigit_x(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
    ram_22ad9c[i += 2] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

/* pointer arithmetic */
int CodeDigit_q(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
    i += 2;
    *(ram_22ad9c + i) = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

/* control: one statement for the index */
int CodeDigit_k(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0] + 2;
    ram_22ad9c[i] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}
