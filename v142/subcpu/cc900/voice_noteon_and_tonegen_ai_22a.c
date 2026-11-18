/* Functions of core/08_voice_noteon_and_tonegen.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned int ram_451cc[];
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteExtParams_15_Bank(int, unsigned int *);

/* cc900-name: ToneGen_WriteExtParams_15_Bank=ToneGen_WriteExtParams_15_Banked */
void VoiceAlloc_Apply_Algo_Group2(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 2, slot);
    AlgoFlag_Write_Bit3(part, 2, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 2);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
        Voice_Freq_WriteLeft((unsigned char)i);
        Voice_Freq_WriteRight((unsigned char)i);
        ToneGen_WriteExtParams_15_Bank(i, ram_451cc);
    }
}
