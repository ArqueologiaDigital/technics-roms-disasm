/* Phase 6, lane_p6 helper C, round 16, module 236 (modules_v10.tsv): SeqStep_VelNoteFwd again (run 100: +3).  The
   ROM keeps SEQ_OP_FROM in WA, the bar byte in C, and widens the byte in BC before moving it to WA for the call;
   V4.23 gave the value BC and the byte A.  Form a widens the byte into its own int local; form b (p6_C_16m236b.c)
   also routes the stored value through a second local (lane_sub's spelling (a)). */
/* cc900-module: SeqStep_MeasureRead SeqStep_WalkWithCallback */

extern int __near SEQ_OP_FROM;
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern unsigned int __near ram_28bf;
extern unsigned int __near ram_28c1;

extern void SeqVoice_SeekToBar(int, int);
extern void SeqData_AdvancePosition(void);
extern int SeqStep_WalkWithCallback(void);
extern void SeqStep_MeasureRead(void);

void SeqStep_VelNoteFwd(void)
{
    int v = SEQ_OP_FROM;
    unsigned char m;
    int a, t;
    if (v == 1) return;
    m = ram_2634;
    t = v;
    ram_287f = t;
    a = m;
    SeqVoice_SeekToBar(a, 0);
    if (SEQ_ERROR_CODE != 0) return;
    if (SeqStep_WalkWithCallback() == 0) {
        SEQ_DATA_BLOCK = ram_28bf;
        SEQ_DATA_OFFSET = ram_28c1;
        SeqData_AdvancePosition();
    }
    ram_273e = SEQ_DATA_OFFSET;
    ram_273c = SEQ_DATA_BLOCK;
    SeqStep_MeasureRead();
}
