/* Probe round 32r1, helper T, form a: audio/tonegen_fileio_handlers.s (module 277).
   SndParam_SyncDisplayBitmap: five read-only sound parameters into the display cells, the panel records copied to
   the recall backup, then three part flags toggled and the memory-number byte set to 0x7f in the backup copy
   (each backup cell addressed as record address - PANEL_RECORDS + PANEL_RECALL_BACKUP). */

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
extern void SndParam_SyncDisplayBitmap(void);

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
