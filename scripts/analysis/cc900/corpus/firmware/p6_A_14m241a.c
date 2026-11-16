/* cc900-module: SndTable_LookupD_CalcAddr */
/* Phase 6, lane_p6 helper A, round 14, form a: module 241 (sequencer/smf_event_processor.s), SndTable_LookupD.  Run 88
   form a had the ROM's layout but put the stored address in XWA; the ROM uses XBC, as for a local. */
extern unsigned char ram_3e3ec;
extern unsigned int ram_23580;
extern unsigned char ram_2358a;
extern unsigned char *ram_3e3ee;
extern unsigned char ram_22d72[];
extern unsigned char SndTable_LookupD_CalcAddr(void);
extern void Kernel_StartTask(int task);

int SndTable_LookupD(void)
{
    unsigned char *p;
    ram_3e3ec = 1;
    ram_23580 = 0;
    ram_2358a = 1;
    p = ram_22d72;
    ram_3e3ee = p;
    if (SndTable_LookupD_CalcAddr() != 0) {
        ram_2358a = 2;
        ram_3e3ec = 0;
        return -1;
    }
    Kernel_StartTask(2);
    return 0;
}
