/* Probe round 32r1, helper T, form b: audio/tonegen_fileio_handlers.s (module 277), as form a with the copy's
   addresses as long constants and each backup cell written as pointer arithmetic on (long) differences. */

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
    ram_8e6c = SndParam_LookupReadOnly(0L);
    ram_8e6e = SndParam_LookupReadOnly(0x102L);
    ram_8e70 = SndParam_LookupReadOnly(0x103L);
    ram_8e72 = SndParam_LookupReadOnly(0x300L);
    ram_8e74 = SndParam_LookupReadOnly(0x4006L);
    Mem_Copy((void *)0x3c8e4L, (void *)0xf9a0L, 0x620);
    *((long)PANEL_PART_RT1 - (long)PANEL_RECORDS + PANEL_RECALL_BACKUP) ^= 1;
    *((long)PANEL_PART_RT2 - (long)PANEL_RECORDS + PANEL_RECALL_BACKUP) ^= 1;
    *((long)PANEL_PART_LEFT - (long)PANEL_RECORDS + PANEL_RECALL_BACKUP) ^= 1;
    *((long)(PANEL_PMEM_SETTINGS + 1) - (long)PANEL_RECORDS + PANEL_RECALL_BACKUP) |= 0x7f;
}
