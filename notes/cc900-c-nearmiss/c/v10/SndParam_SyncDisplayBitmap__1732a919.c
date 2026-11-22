/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_T_32r1m277a.c (2026-11-22-17-p6-r84)
   sha256 1732a919acb0ee5763a90e8664e7f2741faa44d7e046adc9c0ba39d7947f3e56 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_8e6c;
extern unsigned char __near ram_8e6e;
extern unsigned char __near ram_8e70;
extern unsigned char __near ram_8e72;
extern unsigned char __near ram_8e74;
extern unsigned char __near PANEL_RECORDS[];
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern unsigned char __near PANEL_PMEM_SETTINGS[];
extern unsigned char PANEL_RECALL_BACKUP[];
extern int SndParam_LookupReadOnly(long);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
void SndParam_SyncDisplayBitmap(void)
{
    ram_8e6c = SndParam_LookupReadOnly(0);
    ram_8e6e = SndParam_LookupReadOnly(0x102);
    ram_8e70 = SndParam_LookupReadOnly(0x103);
    ram_8e72 = SndParam_LookupReadOnly(0x300);
    ram_8e74 = SndParam_LookupReadOnly(0x4006);
    Mem_Copy(PANEL_RECALL_BACKUP, PANEL_RECORDS, 0x620);
    PANEL_RECALL_BACKUP[PANEL_PART_RT1 - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[PANEL_PART_RT2 - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[PANEL_PART_LEFT - PANEL_RECORDS] ^= 1;
    PANEL_RECALL_BACKUP[&PANEL_PMEM_SETTINGS[1] - PANEL_RECORDS] |= 0x7f;
}
