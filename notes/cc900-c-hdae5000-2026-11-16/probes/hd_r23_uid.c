/* hd_r23_uid.c (helper h_nm3b, lane_hd round 23): round 20's hd_r20_uid.c with these changes, from run 95 (V4.23's
   code aligned with the ROM instruction by instruction; the +22 first difference was only a branch distance):
   - locals: the aggregates in the reverse of the ROM's order (V4.23 lays arrays/structs out in reverse
     declaration order): box (the GetClientBox one, ROM xsp+32) first, then rect (+24), pt (+20), buf (+10).
   - both ApFuncCall results go through a conversion, `(unsigned int)CALLR(long, ..)()`: the ROM calls through XIX,
     V4.23 used XHL for a call whose result is stored straight away (it uses XIX where the result feeds an
     expression: a switch, a compare, a dereference); likewise malloc_X, `(unsigned char *)CALLR(void *, ..)()`.
   - tmp is `unsigned char *`, so both StrCpy calls convert it (the ROM pushes it as `ld xwa,xiz; push xwa` for
     the destination too; r20 pushed XIZ).
   - DrawString's stacked arguments in reverse, (.., tbl[i], 0L, 0xff, 0xf7): V4.23 pushes the stack arguments of
     a non-__cdecl call left to right (the ROM pushes 0L, 0xff, 0xf7 in that order).
   - the inner switch on `(unsigned long)arg` (the ROM's bound checks are unsigned, `jrl c` / `jrl ugt`).
   - byte compares with the operands swapped where the ROM loads the other one into A: `Text[i] !=
     *FillCharPtr` (the ROM: Text's address first, then `ld xwa,(FillCharPtr); ld a,(xwa); cp a,(xbc)`), and
     `buf[0] == Text[cursor]` (the ROM: `ld a,(xbc); cp a,(xsp+10)`).  V4.23 puts the RIGHT operand in A.
   hd_r20_uid.c: HDAE5000_AcHddNamingWindowProc (hd-ae5000_v2_06i.s,
   0x281411-0x282680), a calr singleton: the class proc of the HD naming window.  HDAE5000_AcHddNamingWindowProc_OnClear
   (asked for) is not a function: it is case 9 of the inner switch on the dial/index-switch argument (the ROM's
   HDAE5000_AcHddNamingWindowProc_CaseTable, 9 offsets from _OnPositionLeft; V4.23 puts that table in its own data),
   sharing the procedure's frame (obj/ev/arg at xsp+0x30/0x2c/0x28) and epilogue.  So this file is the whole
   procedure; the labels _OnPositionLeft ... _OnClear are the inner cases 1-9.
   Outer switch: the compares run I_AM_SELECTED ... PAINT, SHOW (inverted), so the source order is the reverse, SHOW
   first; the default (InheritedProc) body is last in the ROM, so `default:` is last here.
   RAM cells without a tree name: ram_22a02a (character page 0-2), ram_22a02c (page last drawn), ram_22a032 (naming
   mode from the AP function).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, const char *);
extern unsigned int __cdecl HDAE5000_StrLen(unsigned char *);

extern unsigned char HDAE5000_RAM_NamingText[];
extern long HDAE5000_RAM_NamingApFunction;
extern unsigned int HDAE5000_RAM_NamingLength;
extern unsigned int HDAE5000_RAM_NamingCursor;
extern unsigned int ram_22a02a;
extern unsigned int ram_22a02c;
extern unsigned int HDAE5000_RAM_NamingSelChar;
extern unsigned int HDAE5000_RAM_NamingSelCharDrawn;
extern unsigned int ram_22a032;
extern unsigned char *HDAE5000_RAM_NamingFillCharPtr;

extern unsigned char *HDAE5000_TextPtrs_Blank1_Chr5F[];
extern char **HDAE5000_TablePtrs_AcHddNamingWindowProc[];
extern unsigned int HDAE5000_Str_Chr25_AcHddNamingWindowProc[];
extern char *HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526[];
extern char *HDAE5000_TextPtrs_Chr21_to_Chr7D[];
extern unsigned char HDAE5000_CType_Table[];

struct NBox { int x; int y; int x2; int y2; };
struct NPt { int x; int y; };

long HDAE5000_AcHddNamingWindowProc(long obj, long ev, long arg)
{
    unsigned int i;
    unsigned int lead;
    unsigned int trail;
    unsigned int half;
    unsigned char *tmp;
    char **tbl;
    struct NBox box;
    struct NBox rect;
    struct NPt pt;
    unsigned char buf[10];

    switch (ev) {
    case EVT_SHOW:
        if (arg == 0 || arg == 3 || arg == 5) {
            if (HDAE5000_RAM_NamingApFunction == 0)
                HDAE5000_RAM_NamingApFunction = NAKA_APFUNC_NamingCheck;
            HDAE5000_RAM_NamingCursor = 0;
            ram_22a02a = 0;
            HDAE5000_RAM_NamingLength = (unsigned int)CALLR(long, ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_STRING_LENGTH, 0L);
            if (HDAE5000_RAM_NamingLength > 32)
                HDAE5000_RAM_NamingLength = 32;
            ram_22a032 = (unsigned int)CALLR(long, ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_NAMING_MODE, 0L);
            HDAE5000_RAM_NamingFillCharPtr = HDAE5000_TextPtrs_Blank1_Chr5F[ram_22a032];
            if (ram_22a032 != 0) {
                CALLV(ROOT->SetVisible)(OBJ_HddNamingABC, 0);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingabc, 0);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingSymbol, 0);
            } else {
                CALLV(ROOT->SetVisible)(OBJ_HddNamingABC, 1);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingabc, 1);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingSymbol, 1);
            }
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
            HDAE5000_RAM_NamingText[i] = 0;
            CALLV(ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_STRING, (long)HDAE5000_RAM_NamingText);
        }
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_UP, 5L);
        CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_DOWN, 3L);
        CALLV(ROOT->SetDialEnable)(1);
        return 0;
    case EVT_PAINT:
    case EVT_REPAINT:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        ram_22a02c = 0xffff;
        HDAE5000_RAM_NamingSelCharDrawn = 0xffff;
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        return 0;
    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        return 0;
    case EVT_SELE_DRAW:
        HDAE5000_RAM_NamingSelChar = arg;
        if (HDAE5000_RAM_NamingSelCharDrawn != HDAE5000_RAM_NamingSelChar) {
            CALLV(ROOT->GetClientBox)(obj, (long)&box);
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            if (HDAE5000_RAM_NamingSelCharDrawn != 0xffff) {
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelCharDrawn], (long)buf);
                rect.y = box.y + 10 + HDAE5000_RAM_NamingSelCharDrawn / 13 * 24;
                rect.x = box.x + 14 + HDAE5000_RAM_NamingSelCharDrawn % 13 * 16 - 1;
                rect.x2 = rect.x + HDAE5000_StrLen(buf) * 8 + 2;
                rect.y2 = rect.y + 17;
                CALLV(ROOT->DrawFrame)(&rect, 0xf5);
            }
            CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
            rect.y = box.y + 10 + HDAE5000_RAM_NamingSelChar / 13 * 24;
            rect.x = box.x + 14 + HDAE5000_RAM_NamingSelChar % 13 * 16 - 1;
            rect.x2 = rect.x + HDAE5000_StrLen(buf) * 8 + 2;
            rect.y2 = rect.y + 17;
            CALLV(ROOT->DrawFrame)(&rect, 0xf2);
            HDAE5000_RAM_NamingSelCharDrawn = HDAE5000_RAM_NamingSelChar;
        }
        return 0;
    case EVT_PARA_DRAW:
        if (ram_22a02c != ram_22a02a) {
            HDAE5000_RAM_NamingSelCharDrawn = 0xffff;
            CALLV(ROOT->GetClientBox)(obj, (long)&box);
            CALLV(ROOT->DrawBox)(&box, 0xf5);
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            for (i = 0; i <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]; i++) {
                pt.x = box.x + 14 + i % 13 * 16;
                pt.y = box.y + 10 + i / 13 * 24;
                CALLV(ROOT->DrawString)((long)&box, (long)&pt, tbl[i], 0L, 0xff, 0xf7);
            }
            ram_22a02c = ram_22a02a;
        }
        return 0;
    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        switch ((unsigned long)arg) {
        case 1:     /* _OnPositionLeft */
            if (HDAE5000_RAM_NamingCursor != 0) {
                HDAE5000_RAM_NamingCursor--;
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 2:     /* _OnPositionRight */
            if (HDAE5000_RAM_NamingCursor + 1 < HDAE5000_RAM_NamingLength) {
                HDAE5000_RAM_NamingCursor++;
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 3:     /* _OnPrevCharacter */
            if (HDAE5000_RAM_NamingSelChar != 0) {
                tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                HDAE5000_RAM_NamingSelChar--;
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 4:     /* _OnCharacterRowUpDown */
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                if (HDAE5000_RAM_NamingSelChar >= 13) {
                    HDAE5000_RAM_NamingSelChar -= 13;
                    tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                    CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                    CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                    CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                }
                break;
            case EVT_INDEXSW_DOWN_AIC:
            case EVT_INDEXSW_DOWN:
                tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                if (HDAE5000_RAM_NamingSelChar + 12 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]
                    && (buf[0] == 'Z' || buf[0] == 'z'))
                    HDAE5000_RAM_NamingSelChar--;
                if (HDAE5000_RAM_NamingSelChar + 13 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]) {
                    HDAE5000_RAM_NamingSelChar += 13;
                    tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                    CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                    if (buf[0] == 'S' && buf[1] == 'P')
                        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
                    else
                        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                    CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                    CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                }
                break;
            }
            break;
        case 5:     /* _OnNextCharacter */
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            if (HDAE5000_RAM_NamingSelChar + 1 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]) {
                HDAE5000_RAM_NamingSelChar++;
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                if (buf[0] == 'S' && buf[1] == 'P')
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
                else
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 6:     /* _OnInsert */
            for (i = HDAE5000_RAM_NamingLength - 1; i > HDAE5000_RAM_NamingCursor; i--)
                HDAE5000_RAM_NamingText[i] = HDAE5000_RAM_NamingText[i - 1];
            HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            break;
        case 7:     /* _OnDelete */
            for (i = HDAE5000_RAM_NamingCursor; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = HDAE5000_RAM_NamingText[i + 1];
            HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingLength - 1] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            break;
        case 8:     /* _OnCenterName */
            lead = 0;
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++) {
                if (HDAE5000_RAM_NamingText[i] != *HDAE5000_RAM_NamingFillCharPtr)
                    break;
                lead++;
            }
            if (lead != HDAE5000_RAM_NamingLength) {
                trail = 0;
                for (i = 0; i < HDAE5000_RAM_NamingLength; i++) {
                    if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingLength - i - 1] != *HDAE5000_RAM_NamingFillCharPtr)
                        break;
                    trail++;
                }
                half = lead;
                half += trail;
                half >>= 1;
                tmp = (unsigned char *)CALLR(void *, HAMA->malloc_X)((unsigned long)(HDAE5000_RAM_NamingLength + 1));
                HDAE5000_StrCpy((char *)tmp, (char *)&HDAE5000_RAM_NamingText[lead]);
                tmp[HDAE5000_RAM_NamingLength - lead - trail] = 0;
                HDAE5000_StrCpy((char *)&HDAE5000_RAM_NamingText[half], (char *)tmp);
                CALLV(HAMA->free_X)(tmp);
                for (i = 0; i < half; i++)
                    HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
                for (i = HDAE5000_RAM_NamingLength - (lead + trail - half); i < HDAE5000_RAM_NamingLength; i++)
                    HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            }
            break;
        case 9:     /* _OnClear */
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_SET_CURSOR, 0L);
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, 0L);
            break;
        }
        return 0;
    case EVT_SET_STRING:
        HDAE5000_StrCpy((char *)HDAE5000_RAM_NamingText, (char *)arg);
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, 0L);
        return 0;
    case EVT_GET_STRING:
        HDAE5000_StrCpy((char *)arg, (char *)HDAE5000_RAM_NamingText);
        return 0;
    case EVT_SET_AP_FUNCTION:
        HDAE5000_RAM_NamingApFunction = arg;
        return 0;
    case EVT_SET_PAGE:
        ram_22a02a = arg;
        if (ram_22a032 == 0)
            CALLV(ROOT->SendEvent)(-1L, EVT_YOU_ARE_SELECTED, (unsigned long)(unsigned int)arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (unsigned long)ram_22a02a);
        CALLV(ROOT->SendEvent)(OBJ_HddNamingLabel, EVT_PARA_DRAW, HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526[ram_22a02a]);
        return 0;
    case EVT_SET_CURSOR:
        HDAE5000_RAM_NamingCursor = arg;
        CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
        if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 1) {
            ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 'A');
        } else if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 2) {
            ram_22a02a = 1;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 'a');
        } else if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 4) {
            if (ram_22a02a == 2)
                ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 0x15);
        } else if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] == ' ') {
            if (ram_22a032 == 0) {
                if (ram_22a02a == 2)
                    ram_22a02a = 0;
                HDAE5000_RAM_NamingSelChar = 37;
            }
        } else if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] == '_') {
            if (ram_22a02a == 2)
                ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = 26;
        } else {
            tbl = HDAE5000_TextPtrs_Chr21_to_Chr7D;
            for (i = 0; i <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + 2]; i++) {
                CALLV(ROOT->ConvertStrings)(tbl[i], (long)buf);
                if (buf[0] == HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]) {
                    ram_22a02a = 2;
                    HDAE5000_RAM_NamingSelChar = i;
                }
            }
        }
        CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, (unsigned long)ram_22a02a);
        CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
        return 0;
    case EVT_SET_CHARA:
        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = arg;
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        return 0;
    case EVT_I_AM_SELECTED:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        if ((unsigned int)(((unsigned long)arg >> 16) & 0xffff) == 0) {
            CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, (unsigned long)(unsigned int)arg);
            if (HDAE5000_RAM_NamingSelChar > HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a])
                HDAE5000_RAM_NamingSelChar = HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a];
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
            if (buf[0] == 'S' && buf[1] == 'P')
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CHARA, (unsigned long)*HDAE5000_RAM_NamingFillCharPtr);
            else
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CHARA, (unsigned long)buf[0]);
            CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}
