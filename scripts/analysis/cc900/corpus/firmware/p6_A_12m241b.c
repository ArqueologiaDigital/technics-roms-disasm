/* cc900-module: SndTable_LookupD_CalcAddr */
/* Phase 6, lane_p6 helper A, round 12, form b: module 241 of modules_v10.tsv (sequencer/smf_event_processor.s),
   SndTable_LookupD (the pointer stored as an address; the success path first). */
extern unsigned char ram_3e3ec;
extern unsigned int ram_23580;
extern unsigned char ram_2358a;
extern unsigned char *ram_3e3ee;
extern unsigned char ram_22d72[];
extern unsigned char SndTable_LookupD_CalcAddr(void);
extern void Kernel_StartTask(int task);

int SndTable_LookupD(void)
{
    ram_3e3ec = 1;
    ram_23580 = 0;
    ram_2358a = 1;
    ram_3e3ee = &ram_22d72[0];
    if (SndTable_LookupD_CalcAddr() == 0) {
        Kernel_StartTask(2);
        return 0;
    }
    ram_2358a = 2;
    ram_3e3ec = 0;
    return -1;
}
