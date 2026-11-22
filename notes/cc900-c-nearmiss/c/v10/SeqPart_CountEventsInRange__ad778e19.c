/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_31r1m236a.c (2026-11-22-15-p6-r82)
   sha256 ad778e19503508cc9f320fdb099990cf6b9353d188d1d271fe7195282469e516 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_2652;
extern unsigned int __near ram_287f;
extern unsigned int __near ram_288b;
extern unsigned int __near ram_2889;
extern unsigned char __near ram_288e;
extern unsigned char SeqVoice_FindDrumPartIndex(void);
extern void SeqVoice_SeekToBar(int, int);
extern void SeqTrack_ProcessControlBytes(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void PartCtrl_AdvanceReadPos(void);
void SeqPart_CountEventsInRange(unsigned int *bars, unsigned int *steps)
{
    unsigned char n;
    unsigned char c;

    SEQ_ERROR_CODE = 0;
    n = SeqVoice_FindDrumPartIndex();
    ram_287f = 1;
    SeqVoice_SeekToBar(ram_2652, n);
    if (SEQ_ERROR_CODE != 0) return;
    ram_288b = SEQ_DATA_BLOCK;
    ram_2889 = SEQ_DATA_OFFSET;
    *bars = 0;
    for (;;) {
        *steps = 0;
        for (;;) {
            if (ram_288e == *steps) {
                SeqTrack_ProcessControlBytes();
                if (SEQ_ERROR_CODE != 0) return;
                break;
            }
            c = SeqPart_ReadByte_Secondary();
            if (c == 0x82) {
                (*bars)++;
                return;
            }
            if (c == 0x81) {
                (*steps)++;
                PartCtrl_AdvanceReadPos();
                if (SEQ_ERROR_CODE != 0) return;
            } else {
                PartCtrl_AdvanceReadPos();
                if (SEQ_ERROR_CODE != 0) return;
            }
        }
        (*bars)++;
    }
}
