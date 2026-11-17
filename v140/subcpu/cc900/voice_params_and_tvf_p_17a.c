/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_45188;
extern unsigned int ram_4518a;
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
int TVF_Set_Bypass(unsigned char *v);
int TVF_Build_Full(unsigned char *v);
int Voice_PitchPack_Mode2(unsigned char *v);
int Voice_PitchPack_Mode3(unsigned char *v);
int Voice_PitchPack_Mode4_Single(unsigned char *v);
void Voice_PitchPack_Mode5_Dual(unsigned char *v);
int TVF_Clamp_Cutoff(int a);
void Voice_Reprioritise(unsigned char *p);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, char all);
int TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Offset_Reg100(unsigned char *v);
void Voice_AdvanceSlotIterator(unsigned char a);

/* cc900-module: DList_Unlink_SelfLink_Offsets16 Quad_Decode_A_To_L TVF_Build_Full TVF_Clamp_Cutoff TVF_Set_Bypass VoiceSlot_UpdateNoteSource Voice_List_MoveToPartList Voice_PitchPack_Mode2 Voice_PitchPack_Mode3 Voice_PitchPack_Mode4_Single Voice_PitchPack_Mode5_Dual Voice_Reprioritise */
/* cc900-data: TVF_Build_Dispatch 1 = TVF_Build_CaseOffsets */
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    unsigned char *next;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
                for (;;) {
                    Voice_List_MoveToPartList(n, (*(unsigned char **)((n) + (24))), 1);
                    Voice_Reprioritise(n);
                    **pp = n[36];
                    *pp += 1;
                    if (n == (*(unsigned char **)((n) + (16)))) goto done;
                    next = (*(unsigned char **)((n) + (16)));
                    DList_Unlink_SelfLink_Offsets16(n);
                    n = next;
                }
            }
            n = (*(unsigned char **)((n) + (8)));
        } while (n != head);
    }
done:
    **pp = 0xff;
}

int TVF_Build_Dispatch(unsigned char *v)
{
    switch ((*(unsigned char **)((v) + (23)))[54] & 7) {
    default:
    case 0:
        return TVF_Set_Bypass(v);
    case 1:
        return TVF_Build_Full(v);
    case 2:
        return Voice_PitchPack_Mode2(v);
    case 3:
        return Voice_PitchPack_Mode3(v);
    case 4:
        return Voice_PitchPack_Mode4_Single(v);
    case 5:
        Voice_PitchPack_Mode5_Dual(v);
        break;
    }
}

void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x40)
        ram_45188 = ((*(int *)((v) + (66))) & 0xff80) | TVF_Clamp_Cutoff(((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x80) ?
                                                             (int)(((*(unsigned int *)((v) + (66))) & 0x7f) - (char)(*(unsigned char **)((v) + (35)))[31]) :
                                                             (int)(((*(unsigned int *)((v) + (66))) & 0x7f) + (char)(*(unsigned char **)((v) + (35)))[31]));
    else ram_45188 = (*(int *)((v) + (66)));
    ram_4518a = (*(int *)((v) + (68)));
}

void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    unsigned char k = 0x30;
    i = k * a;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}
