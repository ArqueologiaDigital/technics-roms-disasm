/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern int __near ram_293e;

struct tvf { char pad[66]; int a; int b; };
struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };

void DList_Unlink_SelfLink(struct dl *p)
{
    struct dl *n = p->next;
    struct dl *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

unsigned char BitTest_Bit0_L(unsigned char a)
{
    if (a & 1) return 1;
    return 0;
}

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k) { return t[(k & 0x7f00) >> 8]; }

int Int_ClampSignedToRange(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

int TVF_Clamp_Cutoff(int a)
{
    if (a > 0x78) a = 0x78;
    else if (a < 0) a = 0;
    return a;
}

int TVF_Bias_Clamp_Amount(int a)
{
    a += 0x18;
    if (a > 0x78) a = 0x78;
    return a;
}

void TVF_Set_Bypass(struct tvf *p) { p->a = 0x17f; p->b = 0x7f7f; }

int ClampS16_WA_Short(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

void Pitch_Apply_Zone_Trim(struct zone *p) { p->out = p->base + ram_293e; }
