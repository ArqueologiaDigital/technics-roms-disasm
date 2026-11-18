/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20b.c (2026-11-18-18-sub-r21a)
   sha256 1a38294d9608c2cdcfb43a7ec910017dec23940711db7c62016a80b94617f566 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_1128;
extern unsigned int __near ram_2936[];
extern unsigned int __near ram_292e[];
extern unsigned char __near ram_148d[];
extern void ToneGen_SilenceChannel(unsigned char ch);
unsigned int ToneGen_Read_Register(unsigned int r);
void Voice_Retire_ToFreePool(unsigned char *v);
void Voice_ScanSlots_ReassignSources(unsigned char a);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_AdvanceSlotIterator(unsigned char a);
void Voice_Manager_PollBank(void)
{
    unsigned int x;
    unsigned int bit;
    unsigned char s;
    unsigned int m;
    unsigned char *v;

    ram_1128++;
    ram_1128 &= 3;
    m = ram_2936[ram_1128] | ToneGen_Read_Register(ram_1128);
    x = m;
    x ^= ram_292e[ram_1128];
    x &= ram_292e[ram_1128];
    ram_292e[ram_1128] = m;
    s = ram_1128 << 4;
    v = &ram_148d[(int)s * 39];
    for (bit = 1; bit != 0; bit = bit + bit) {
        if ((x & bit) && !(v[34] & 1)) {
            Voice_Retire_ToFreePool(v);
            ToneGen_SilenceChannel(s);
            Voice_ScanSlots_ReassignSources(s);
        } else if (!(v[34] & 0x81)) {
            v[37] = (ToneGen_Read_Register(s + 0x180) & 0x3fff) >> 5;
            if (v[37] < 0x80 && (v[34] & 4)) Voice_Demote_Decayed(v);
        }
        s++;
        v += 39;
    }
    Voice_AdvanceSlotIterator(ram_1128);
}
