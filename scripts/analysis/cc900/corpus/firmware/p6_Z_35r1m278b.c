/* Probe round 35r1, helper Z, form b: audio/audio_control_engine.s (module 278).  As form a, with the ROM's block
   order spelled by gotos (the large-change path first, then the medium one, the shared confirm / pending /
   clear tails last). */

struct dbst { unsigned char cnt : 2; unsigned char pend : 1; unsigned char conf : 1; };
extern int __cdecl Math_AbsInt16(int);
extern void AnalogIn_DebounceChange(unsigned char, unsigned char, struct dbst *);

void AnalogIn_DebounceChange(unsigned char now, unsigned char old, struct dbst *st)
{
    if (Math_AbsInt16(now - old) <= 2)
        goto small;
    if (Math_AbsInt16(now - old) <= 6)
        goto medium;
    if (st->cnt == 3)
        goto confirm;
    st->cnt++;
    goto clear;
medium:
    if (!st->pend)
        goto pending;
confirm:
    st->cnt = 0;
    st->pend = 0;
    st->conf = 1;
    return;
pending:
    st->pend = 1;
    return;
small:
    st->cnt = 0;
clear:
    st->pend = 0;
}
