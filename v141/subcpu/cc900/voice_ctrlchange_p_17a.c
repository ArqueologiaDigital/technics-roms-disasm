/* Functions of core/07_voice_ctrlchange.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int Voice_Part_Trim_Table_A[];
extern unsigned int Voice_Part_Trim_Table_B[];
extern unsigned int Voice_Part_Trim_Base[];
extern unsigned int Voice_Part_Trim_Addend_1[];
extern unsigned int Voice_Part_Trim_Addend_2[];
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char ram_41350[];
extern unsigned char ram_41356[];
extern unsigned char ram_41452[];
extern unsigned char ram_4145e[];
extern unsigned char ram_41460[];
extern unsigned char ram_41462[];
void Voice_Selector_FindBestSlot(unsigned char *w, char *cnt, char *idx, char *val);
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
void Voice_PitchBend(unsigned char *m);
void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot);
void Voice_Selector_ComputeMixWeights(unsigned char part);

/* cc900-module: AudioChannel_Dispatch Voice_Selector_FindBestSlot */
void Voice_PitchBend(unsigned char *m)
{
    unsigned char part;
    unsigned int w;
    unsigned char *q;
    if (m[1] >= 0x1a) return;
    part = m[1];
    w = (unsigned int)m[3] << 7;
    w |= m[2] | 32768;
    switch ((*(unsigned char **)(ram_41356 + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        AudioChannel_Dispatch(part, w, *(unsigned char **)(ram_41356 + (int)part * 287) + 20);
        return;
    case 0x80:
        q = *(unsigned char **)(ram_41356 + (int)part * 287);
        AudioChannel_Dispatch(part, w, q + 18);
        return;
    }
}

void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    unsigned char *s;
    s = &((unsigned char *)(unsigned long)(ram_41350 + (int)part * 287))[(int)slot * 37 + 0x6e];
    *(unsigned char **)(s + 4) = Voice_DefaultToneRecord;
}

void Voice_Selector_ComputeMixWeights(unsigned char part)
{
    unsigned char g2, g1, g0;
    unsigned int x;
    Voice_Selector_FindBestSlot(&ram_41452[(int)part * 287], (char *)&g2, (char *)&g1, (char *)&g0);
    *(unsigned int *)&ram_4145e[(int)part * 287] = Voice_Part_Trim_Table_A[g2];
    *(unsigned int *)&ram_41462[(int)part * 287] = Voice_Part_Trim_Table_B[g1];
    x = Voice_Part_Trim_Base[g2];
    x += Voice_Part_Trim_Addend_1[g1];
    x += Voice_Part_Trim_Addend_2[g0];
    *(unsigned int *)&ram_41460[(int)part * 287] = x;
}
