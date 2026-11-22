/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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
