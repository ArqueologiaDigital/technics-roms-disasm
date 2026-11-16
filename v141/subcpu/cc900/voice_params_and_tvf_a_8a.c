/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_451c2;
extern int ram_4132f;
extern unsigned char __near ram_148d[];
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Reprioritise(unsigned char *p);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
void DList_Unlink_SelfLink(unsigned char *n);
void DList_InsertAfter_Offsets0(unsigned char *n, unsigned char *q);
void DList_Unlink_SelfLink_Offsets8(unsigned char *n);
void DList_InsertAfter_Offsets8(unsigned char *n, unsigned char *q);
void VoiceSlot_NoteOff(unsigned char n);
void VList_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k);
void VList_MoveToPool(unsigned char *n, unsigned char *list, unsigned char k);
void Voice_Pitch_CopyBase(unsigned char *v);
void Voice_Pitch_WriteOutReg_Sec(unsigned char *v);

/* cc900-name: Voice_Pitch_WriteOutReg_Sec=Voice_Pitch_WriteOutputReg_Secondary */
/* cc900-name: VList_MoveToPool=Voice_List_MoveToPool */
/* cc900-name: VList_MoveToPartList=Voice_List_MoveToPartList */
/* cc900-module: DList_InsertAfter_Offsets0 DList_InsertAfter_Offsets8 DList_Unlink_SelfLink DList_Unlink_SelfLink_Offsets16 DList_Unlink_SelfLink_Offsets8 Pitch_Fold_Octaves_Into_Range Pitch_Saturate_15bit Voice_List_MoveToPartList Voice_List_MoveToPool Voice_Reprioritise */
void VoiceSlot_NoteOff(unsigned char n)
{
    unsigned char *v;
    if (n < 0x40) {
        v = &ram_148d[(int)n * 39];
        Voice_List_MoveToPartList(v, (*(unsigned char **)((v) + (24))), 1);
        Voice_Reprioritise(v);
        if (v != (*(unsigned char **)((v) + (16)))) DList_Unlink_SelfLink_Offsets16(v);
    }
}

void VList_MoveToPartList(unsigned char *n, unsigned char *list, unsigned char k)
{
    unsigned char *o;
    unsigned char c;
    o = (*(unsigned char **)((n) + (24)));
    c = n[28];
    if (*(unsigned char **)(o + ((int)c * 4 + 4)) == n) {
        if ((*(unsigned char **)((n) + (8))) != n) *(unsigned char **)(o + ((int)c * 4 + 4)) = (*(unsigned char **)((n) + (8)));
        else *(unsigned char **)(o + ((int)c * 4 + 4)) = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 4)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 4)) = n;
        DList_Unlink_SelfLink_Offsets8(n);
    } else DList_InsertAfter_Offsets8(n, *(unsigned char **)(list + ((int)k * 4 + 4)));
    (*(unsigned char **)((n) + (24))) = list;
    n[28] = k;
}

void VList_MoveToPool(unsigned char *n, unsigned char *list, unsigned char k)
{
    unsigned char *o;
    unsigned char c;
    o = (*(unsigned char **)((n) + (29)));
    c = n[33];
    if (*(unsigned char **)(o + ((int)c * 4 + 2)) == n) {
        if ((*(unsigned char **)((n) + (0))) != n) *(unsigned char **)(o + ((int)c * 4 + 2)) = (*(unsigned char **)((n) + (0)));
        else *(unsigned char **)(o + ((int)c * 4 + 2)) = 0;
    }
    if (*(unsigned char **)(list + ((int)k * 4 + 2)) == 0) {
        *(unsigned char **)(list + ((int)k * 4 + 2)) = n;
        DList_Unlink_SelfLink(n);
    } else DList_InsertAfter_Offsets0(n, *(unsigned char **)(list + ((int)k * 4 + 2)));
    (*(unsigned char **)((n) + (29))) = list;
    n[33] = k;
}

void Voice_Pitch_CopyBase(unsigned char *v)
{
    unsigned char *t;
    int p;
    t = (*(unsigned char **)((v) + (23)));
    p = (*(int *)(((*(unsigned char **)((v) + (31)))) + (12)));
    (*(int *)((v) + (8))) = p;
    p += (int)(char)t[3] << 8;
    p += (int)(char)t[4] * 2;
    (*(int *)((v) + (6))) = Pitch_Fold_Octaves_Into_Range(p, (*(unsigned char **)((v) + (31)))[9], (*(unsigned char **)((v) + (31)))[10]);
}

void Voice_Pitch_WriteOutReg_Sec(unsigned char *v)
{
    int d;
    d = (*(int *)((v) + (10))) + ram_4132f;
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x10) {
        if ((*(unsigned int *)(((*(unsigned char **)((v) + (39)))) + (24))) & 0x20) d -= (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
        else d += (*(int *)(((*(unsigned char **)((v) + (35)))) + (29)));
    }
    ram_451c2 = Pitch_Saturate_15bit(d);
}
