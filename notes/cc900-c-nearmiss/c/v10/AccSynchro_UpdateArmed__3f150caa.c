/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ACC_SYNCHRO_STATE;
extern char __near PANEL_STYLE[];
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
void AccSynchro_UpdateArmed(void)
{
    char a;
    if (SEQ_REC_TRACKS != 0) goto off;
    if (SEQ_TRACK_MASK != 0) goto off;
    if (CMP_RECORD_PART != 0) goto off;
    a = PANEL_STYLE[3];
    if (a & 8) goto off;
    if ((a & 7) == 0) goto off;
    if ((PANEL_STYLE[5] & 2) == 0) goto off;
    ACC_SYNCHRO_STATE |= 0x80;
    return;
off:
    ACC_SYNCHRO_STATE = 0;
}
