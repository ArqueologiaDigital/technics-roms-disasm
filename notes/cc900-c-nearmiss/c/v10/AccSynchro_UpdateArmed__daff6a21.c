/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2a.c (2026-11-16-33-p6-r2)
   sha256 daff6a210ae1d585590cbca49a5d49ac10efb93aef3c1766c7663df3000edf26 (tar-sha256); compiled at -Xr */
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ACC_SYNCHRO_STATE;
struct pstyle { unsigned char prog : 8; unsigned char top : 1; unsigned char bank : 7; unsigned char b2, b3, b4, b5; };
extern struct pstyle __near PANEL_STYLE;
void AccSynchro_UpdateArmed(void)
{
    unsigned char a;
    if (SEQ_REC_TRACKS != 0 || SEQ_TRACK_MASK != 0 || CMP_RECORD_PART != 0)
        goto off;
    a = PANEL_STYLE.b3;
    if (a & 8)
        goto off;
    a &= 7;
    if (a == 0)
        goto off;
    if ((PANEL_STYLE.b5 & 2) == 0)
        goto off;
    ACC_SYNCHRO_STATE |= 0x80;
    return;
off:
    ACC_SYNCHRO_STATE = 0;
}
