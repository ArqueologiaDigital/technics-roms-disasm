/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20a.c (2026-11-18-18-sub-r21a)
   sha256 10b3c749d6f16af1459c1b1cb990f1b3d6b5060e4fbd7f40a3bce8193e36ef5d (tar-sha256); compiled at -Xr */
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
    unsigned char t;

    ram_1128++;
    ram_1128 &= 3;
    m = ram_2936[ram_1128] | ToneGen_Read_Register(ram_1128);
    x = (m ^ ram_292e[ram_1128]) & ram_292e[ram_1128];
    ram_292e[ram_1128] = m;
    t = ram_1128 << 4;
    s = t;
    v = &ram_148d[(int)t * 39];
    for (bit = 1; bit != 0; bit += bit) {
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
