/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ACC_SYNCHRO_STATE;
extern char __near PANEL_STYLE[];
void AccSynchro_UpdateArmed(void)
{
    char a;
    if (SEQ_REC_TRACKS == 0 && SEQ_TRACK_MASK == 0 && CMP_RECORD_PART == 0) {
        a = PANEL_STYLE[3];
        if ((a & 8) == 0 && (a & 7) != 0 && (PANEL_STYLE[5] & 2) != 0) {
            ACC_SYNCHRO_STATE |= 0x80;
            return;
        }
    }
    ACC_SYNCHRO_STATE = 0;
}
