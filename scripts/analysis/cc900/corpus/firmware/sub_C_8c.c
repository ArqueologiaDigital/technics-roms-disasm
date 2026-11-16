/* lane_sub probe round 8, helper C, form c: VoiceParam_FullSetup and VoiceStruct_BulkInit (core/08_voice_noteon_and_
   tonegen.s), KN5000 sub-CPU payload v1.42.  Both keep a byte loop counter in QIZH (the ROM's `ldib_erp 0xfb` /
   `inc1b_erp 0xfb`), which V4.23 allocates itself.  The tables at 0x44fce are addressed as 2D arrays of the row
   size each loop scales by (5, 81), so that V4.23 keeps the column offset in the index; 0x44fce + 6 is ram_44fd4.
   Callees reached with a zero-extended byte are declared without a prototype.

   cc900-module: BlockCopy_Words_BC_to_HL VoiceStruct_BulkInit VoiceSubSlot_Init */

extern unsigned char ram_41368[];               /* Part_Record_Base */
extern unsigned char ram_4136e[];               /* Part_PatchRecord_Ptr */
extern unsigned char ram_41372[];
extern unsigned char ram_4502b;
extern unsigned char ram_451a7;
extern unsigned char ram_44fce[];
extern unsigned char ram_44fd4[][81];
extern unsigned char ram_451af[][5];
extern unsigned char DSP_VOICEPARAM_DEFAULT_TABLE[];

struct partrec { unsigned char pad[110]; unsigned char partial[4][37]; };

extern void BlockCopy_Words_BC_to_HL(unsigned char *s, unsigned char *d, unsigned int n);
extern void VoiceSubSlot_Init();

void VoiceStruct_BulkInit(unsigned char part)
{
    unsigned char k;
    BlockCopy_Words_BC_to_HL(*(unsigned char **)(ram_4136e + part * 0x11f), ram_44fce, 0x66);
    for (k = 0; k < 4; k++)
        BlockCopy_Words_BC_to_HL(*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k],
                                 &((unsigned char (*)[81])ram_44fce)[k][102], 0x51);
}

void VoiceParam_FullSetup(unsigned char part)
{
    unsigned char k;
    unsigned char n;
    unsigned char j;
    VoiceStruct_BulkInit(part);
    for (k = 0; k < 4; k++) VoiceSubSlot_Init(part, k);
    if (*(unsigned int *)(ram_41372 + part * 0x11f) & 0x8000L) ram_4502b |= 0x80;
    else ram_4502b &= ~0x80;
    for (k = 0; k < 8; k++) ram_44fce[k + 472] = DSP_VOICEPARAM_DEFAULT_TABLE[k];
    n = 0;
    for (k = 0; k < 4; k++) {
        if ((ram_44fd4[k][102] & 0xc0) == 0) {
            if (!(ram_44fd4[k][102] & 0x20)) n++;
        }
    }
    if (n != 4) ram_451a7 = 0;
    for (k = 0; k < 4; k++) {
        ((unsigned char (*)[5])ram_44fce)[k][480] =
            (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[54] & 7;
        for (j = 0; j < 4; j++)
            ram_451af[k][j] = (*(unsigned char **)((struct partrec *)(ram_41368 + part * 0x11f))->partial[k])[(int)j + 77];
    }
}
