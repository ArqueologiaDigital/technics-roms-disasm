/* Phase 6, lane_p6 helper C, round 15, form b: routines from the memory-to-memory pool (poolmm_C.txt) without calls to
   their own module.  The cells the ROM copies with ldmm8 / ld (mem),(mem) are __near (V4.23 then moves them directly);
   the ones it copies through a register stay as the ROM addresses them.  Form a (p6_C_15a.c) has the same names. */

/* __near: 16-bit absolute operand; plain: 24-bit. */
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd36;
extern unsigned char __near ram_bd38;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd06;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0a;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd12;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd16;
extern unsigned char __near ram_35b0;
extern long __near STYLE_DST_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near DEMO_CURRENT_SONG;
extern unsigned int __near DEMO_ACTIVE_ENTRY;
extern unsigned int DemoSong_EntryCol[];

extern void DualVoice_ParamLoadDone(void);
extern void AccPatch_InitFromSlotIndex(void);

void MidiChan_SetStateMode(void)
{
    if (ram_bd18 & 0x40) ram_bd36 = 1;
    else ram_bd36 = 2;
    if (ram_bd36 == ram_bd38) return;
    ram_bd1c |= 0x40;
    ram_bd38 = ram_bd36;
}

void MidiSeq_SyncToneStates_Upper(void)
{
    if (ram_bd18 & 0x40) {
        ram_bd00 &= ~0x80;
        ram_bd02 = ram_bd00;
        ram_bd04 &= ~0x80;
        ram_bd06 = ram_bd04;
        ram_bd08 &= ~0x80;
        ram_bd0a = ram_bd08;
    } else {
        ram_bd0c &= ~0x80;
        ram_bd0e = ram_bd0c;
        ram_bd10 &= ~0x80;
        ram_bd12 = ram_bd10;
        ram_bd14 &= ~0x80;
        ram_bd16 = ram_bd14;
    }
}

int AccPatch_CopySection(void)
{
    int r = 0;
    ram_35b0 &= ~1;
    DualVoice_ParamLoadDone();
    if ((unsigned int)ram_35b0 & 1) {
        STYLE_SRC_IMAGE_PTR = STYLE_DST_IMAGE_PTR;
        STYLE_COPY_SRC_SECTION = STYLE_COPY_DST_SECTION;
        AccPatch_InitFromSlotIndex();
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        r = -107;
    }
    return r;
}

void Demo_SelectEntry_LoadPattern(void)
{
    DEMO_ACTIVE_ENTRY = DemoSong_EntryCol[DEMO_CURRENT_SONG];
}
