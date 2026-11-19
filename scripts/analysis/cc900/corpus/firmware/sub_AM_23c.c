/* lane_sub helper AM, round 23, form c: form a (sub_AM_23a.c, which names each function's base file) changed
   only in these spellings --
   - Voice_Build_SoundingVoiceList: k unsigned and set through x as in form a, the chain byte read as
     `*((unsigned long)k + (ram_24e6 + (int)t * 12))` (the widened k as the left operand, so the sum lands in its
     copy as in the ROM's `add xiy,xwa`);
   - AudioMod_Scale_To_*: `int` return type, the byte temporary c declared FIRST (`c = m[2]; d = c;`);
   - VoiceState_FullReset: one 12-byte array member, the offsets as indices, `((struct v12x *)ram_24e6)[(int)i].a[j + 8]`
     (form a used three 4-byte members);
   - InterCPU_SendEditBufferToMain: mm `unsigned long` as in form a, n declared before mm;
   - NoteOn_RoutePacket: form a with i and ch declared first;
   - AudioMod_Apply_Slot_Field2A / _29: the doubling as `val = val + (unsigned char)(int)val;` (a double conversion).
   cc900-options: -Xr */

#define W(p, o) (*(unsigned int *)((p) + (o)))

struct v12 { unsigned char a[4]; unsigned char b[4]; unsigned char c[4]; };
struct r27 { unsigned char a[27]; };
struct v12x { unsigned char a[12]; };
struct f40 { unsigned char pad[40]; unsigned char f40, f41, f42; };

extern unsigned char __near ram_148d[];
extern unsigned char __near ram_134d[];
extern unsigned char __near ram_1351[];
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];
extern unsigned char __near ram_28ed[];
extern unsigned char Voice_CommandIndexTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];
extern unsigned char ram_41368[];
extern unsigned char ram_41383[];
extern unsigned char ram_41384[];
extern unsigned char ram_41387[];
extern unsigned char ram_41388[];
extern unsigned char *ram_4531c;

extern void InterCPU_E1_DMA_Transfer(unsigned char *src, unsigned int n, unsigned char *dst);
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);

/* cc900-module: OutputBuf_Flush_A OutputBuf_Flush_B Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource */
/* cc900-module: NoteOn_RoutePacket VoiceState_FullReset */

unsigned char *Voice_Build_SoundingVoiceList(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char b;
    unsigned char t;
    unsigned char d;
    unsigned char s;
    unsigned int k;
    unsigned char *q;
    unsigned char *out;
    int x;

    e = ~e;
    c &= e;
    q = &ram_1e4d[(int)a * 27];
    out = ram_28ed;
    for (b = 0; b < 27; b++) {
        if ((t = q[b]) < 0xc0) {
            d = Voice_CommandIndexTable[b];
            if ((d & e) == c) {
                if ((s = ram_212a[(int)t * 5]) < 0x40) {
                    t = s;
                    d = Voice_PolyphonyLimits_Table[d & 0x1f];
                    do {
                        *out++ = s;
                        x = d;
                        k = x;
                        t = *((unsigned long)k + (ram_24e6 + (int)t * 12));
                    } while (t != s);
                }
            }
        }
    }
    *out = 0xff;
    return ram_28ed;
}

/* ---- modulation scalers: m[1] bit 7 = bipolar, m[2] = depth ---- */

int AudioMod_Scale_To_Part_1C(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char c;
    unsigned int r, d;
    if (m[1] & 0x80) {
        c = m[2];
        d = c;
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        c = m[2];
        d = c;
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41384[part * 0x11f] = r;
}

int AudioMod_Scale_To_Part_1B(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char c;
    unsigned int r, d;
    if (m[1] & 0x80) {
        c = m[2];
        d = c;
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        c = m[2];
        d = c;
        r = (unsigned int)v;
        r = r * d;
    }
    r = r >> 6;
    ram_41383[part * 0x11f] = r;
}

int AudioMod_Scale_To_Part_1F(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char c;
    int r, d;
    if (m[1] & 0x80) {
        c = m[2];
        d = c;
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        c = m[2];
        d = c;
        r = (int)v;
        r = r * d;
    }
    r = r >> 1;
    r = r / 127;
    ram_41387[part * 0x11f] = r;
}

/* cc900-name: AudioMod_Scale_To_LevelPairShf=AudioMod_Scale_To_LevelPairShift */
int AudioMod_Scale_To_LevelPairShf(unsigned char part, unsigned char v, unsigned char *m)
{
    unsigned char c;
    int r, d;
    if (m[1] & 0x80) {
        c = m[2];
        d = c;
        r = (int)v - 64;
        r = r + r;
        r = r * d;
    } else {
        c = m[2];
        d = c;
        r = (int)v;
        r = r * d;
    }
    r = r / 127;
    ram_41388[part * 0x11f] = r;
}

void VoiceState_FullReset(void)
{
    unsigned char j;
    unsigned char i;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            ((struct v12x *)ram_24e6)[(int)i].a[j + 8] = 0xff;
            ((struct v12x *)ram_24e6)[(int)i].a[j] = i;
            ((struct v12x *)ram_24e6)[(int)i].a[j + 4] = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++)
            ((struct r27 *)ram_1e4d)[(int)i].a[j] = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}

void InterCPU_SendEditBufferToMain(unsigned char part, unsigned int u1, unsigned int u2)
{
    unsigned int n;
    unsigned long mm;

    mm = 0x1e0000;
    n = 470;
    InterCPU_E1_DMA_Transfer(&ram_4531c[(int)part * 80 + 19111], n,
                             (unsigned char *)((long)((int)part * 80 + 19111) + mm));
}

void NoteOn_RoutePacket(unsigned char *q)
{
    unsigned char i;
    unsigned char ch;
    unsigned char **l1;
    unsigned char **l2;
    unsigned char key;
    unsigned char all;
    unsigned char *out;
    unsigned char *v;
    unsigned int x;

    x = W(q, 3) & 0x7f;
    all = x;
    x = W(q, 1) & 0x7f;
    key = x;
    out = q + 5;
    if (W(q, 3) & 0x1f00) {
        v = ram_148d;
        for (i = 0; i < 0x40; i++) {
            if (!(v[34] & 1)) *out++ = v[36];
            v += 39;
        }
        *out = 0xff;
    } else {
        ch = (W(q, 1) & 0x1f00) >> 8;
        l1 = (unsigned char **)(ram_134d + (int)ch * 12);
        l2 = (unsigned char **)(ram_1351 + (int)ch * 12);
        if (ch < 0x1a) {
            if (q[0] & 0x80) {
                if (W(q, 3) & 0x7f) {
                    if (*l1 != 0) {
                        v = *l1;
                        for (;;) {
                            OutputBuf_Flush_B(&out, *l1, key, all);
                            if (*l1 == 0) break;
                            if (*l1 == v) break;
                        }
                    }
                    *out = 0xff;
                } else OutputBuf_Flush_B(&out, *l1, key, all);
            } else if (q[0] & 0x40) {
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 3) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 1) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
            } else {
                OutputBuf_Flush_A(&out, *l2, key, all);
            }
        } else *out = 0xff;
    }
}

/* ---- the slot byte writers: byte 40 of operator (k, slot) of the part record takes the routing bits of m[0];
   byte 42 (Field2A) / 41 (Field29) takes the scaled controller ---- */

void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val = val + (unsigned char)(int)val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = x | y;
    } else ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f42 = t;
}

void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k)
{
    unsigned char x, y;
    unsigned int t, d;
    if (m[1] & 0x80) {
        if (val > 64) {
            val = val - 64;
            val = val + (unsigned char)(int)val;
        } else val = 0;
    }
    if (val != 0) {
        x = ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 & 0x55;
        y = m[0] & 0x55;
        x = x | y;
        y = m[0] & 0xaa;
        ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = x | y;
    } else ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f40 = 0;
    t = val;
    d = m[2];
    t = t * d;
    t >>= 6;
    if (t == 0 && val != 0) t = 1;
    ((struct f40 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 16 + (int)(slot) * 4])->f41 = t;
}
