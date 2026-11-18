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
extern unsigned char ram_4136e[];
extern unsigned int ram_451cc[];
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void ToneGen_WriteExtParams_56(int, unsigned int *);
extern void ToneGen_WriteExtParams_15(int, unsigned int *);
int CheckStatusBits_Zero(unsigned int part);
void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot);
void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot);

int CheckStatusBits_Zero(unsigned int part)
{
    return ((*(unsigned char **)((unsigned long)ram_4136e + (unsigned long)part * 0x11f))[16] & 0xc0) == 0;
}

void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 0, slot);
    AlgoFlag_Write_Bit3(part, 0, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 0);
    list = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 0);
    for (j = 0; (list[j] & 0xff) < 0x80; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
        ram_4520c = EGEnv_Compute_A((unsigned char)i);
        ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
        ToneGen_WriteExtParams_56(i, ram_451cc);
    }
}

void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot)
{
    unsigned int *list;
    unsigned int j;
    unsigned char k;
    unsigned int i;
    AlgoFlag_Write(part, 1, slot);
    AlgoFlag_Write_Bit3(part, 1, slot);
    for (k = 0; k < 4; k++) EFF_RoutingInit(part, k, 1);
    list = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 0);
    for (j = 0; (list[j] & 0xff) < 0x40; j++) {
        i = list[j];
        i &= 0xff;
        Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
        ram_45204 = EGEnv_Compute_B((unsigned char)i);
        ram_45206 = EGEnv_Compute_B_Simple((unsigned char)i);
        ToneGen_WriteExtParams_15(i, ram_451cc);
    }
}
