/* lane_sub helper E, round 2, form c: functions that need a pointer variable reached with a 16-bit operand
   (declared `* __near`: kept out of forms a / b in case V4.23 reads it otherwise), the port bits as
   unsigned char bitfields (V4.23 allocates them from bit 7 down), and third spellings (sub-CPU payload v1.42). */

struct dspstate { int w[0x90]; int busy; };
struct pbits { unsigned char b7:1, b6:1, b5:1, b4:1, b3:1, b2:1, b1:1, b0:1; };

extern struct pbits __tiny ram_1c;                            /* P7 */
extern struct pbits __tiny ram_44;                            /* PH */
extern struct dspstate *__near ram_4a3a;
extern struct dspstate *__near ram_4a3e;
extern struct dspstate ram_45324;
extern long DSP_FreqParamCurve_Algo0[];
extern long DSP_FreqParamCurve_Algo1[];
extern long DSP_FreqParamCurve_Algo2[];

extern void DSP_State_ApplyAll(struct dspstate *s);
extern void MsgQueue_Send(int q, struct dspstate *m);
extern struct dspstate *MsgQueue_ReceiveBlocking(int q);
extern struct dspstate *MsgQueue_Receive_NoBlock(int q);

void DSP1_Assert_Reset(void) { ram_44.b1 = 0; }
void DSP1_Deassert_Reset(void) { ram_44.b1 = 1; }
void DSP2_Assert_Reset(void) { ram_44.b2 = 0; }
void DSP2_Deassert_Reset(void) { ram_44.b2 = 1; }
void DSP_Set_Command_Mode(void) { ram_1c.b6 = 0; }
void DSP_Set_Data_Mode(void) { ram_1c.b6 = 1; }
void DSP_Assert_Write(void) { ram_1c.b3 = 0; }
void DSP_Deassert_Write(void) { ram_1c.b3 = 1; }
void DSP_Assert_Read(void) { ram_1c.b4 = 0; }
void DSP_Deassert_Read(void) { ram_1c.b4 = 1; }

void DSP_State_ApplyBuf(struct dspstate *src)
{
    if ((ram_4a3a = MsgQueue_Receive_NoBlock(2)) == 0)
        ram_4a3a = MsgQueue_ReceiveBlocking(1);
    *ram_4a3a = *src;
    ram_4a3a->busy = 1;
    MsgQueue_Send(2, ram_4a3a);
}

void DSP_State_LoadAndApplyAll(struct dspstate *src)
{
    *(ram_4a3e = &ram_45324) = *src;
    ram_4a3e->busy = 1;
    DSP_State_ApplyAll(ram_4a3e);
    ram_4a3e->busy = 0;
}

long DSP_ParamFetch_AlgoTypeTable(unsigned char **pp, unsigned long i)
{
    unsigned char *p;
    long r;

    p = *pp;
    switch (*p) {
    case 0:
        r = DSP_FreqParamCurve_Algo0[i];
        break;
    case 1:
        r = DSP_FreqParamCurve_Algo1[i];
        break;
    case 2:
        r = DSP_FreqParamCurve_Algo2[i];
        break;
    }
    *pp = p + 1;
    return r;
}

unsigned char *DSP_TableWalk_Search(unsigned char *p, unsigned int key, unsigned int len, int *out)
{
    unsigned char *next;
    unsigned int w;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        next = p + w;
        p += 2;
        if (*p == key) {
            p += len + 1;
            if (p >= next) *out = 4;
            else *out = 0;
            return p;
        }
        p = next;
    }
    *out = 3;
    return p;
}

unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, int *st, unsigned char **out)
{
    unsigned int w;

    while (((w = ((unsigned int)p[0] << 8) + p[1]) >> 8) != 0xf0) {
        if (n == 0) {
            *st = 0;
            *out = p + w;
            p += 2;
            return p;
        }
        p += w;
        n--;
    }
    *st = 2;
    return p;
}

int __cdecl Audio_CmdHandler_40_5F(unsigned char n, unsigned char *d)
{
    while (n--)
        ;
    return 0;
}
