/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-31-p6-r1b)
   sha256 55d0abda1f1ad176b6cda9b0417d1d509cf0856109b356f9c81748eff869e473 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ACC_SYNCHRO_STATE;
extern char __near PANEL_STYLE[];
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
void AccSynchro_UpdateArmed(void)
{
    char a;
    if (SEQ_REC_TRACKS == 0 && SEQ_TRACK_MASK == 0 && CMP_RECORD_PART == 0
        && ((a = PANEL_STYLE[3]) & 8) == 0 && (a & 7) != 0 && (PANEL_STYLE[5] & 2) != 0)
        ACC_SYNCHRO_STATE |= 0x80;
    else
        ACC_SYNCHRO_STATE = 0;
}
