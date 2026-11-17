/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_E_7b.c (2026-11-16-79-sub-r7)
   sha256 55b39cc070036b9caa2848a386c36cf52910262a58cbf514c079d7e1af9f81a1 (name+funcs); compiled at -Xr */
/* lane_sub helper E, round 7, form b: other spellings of sub_E_7a.c's functions (sub-CPU payload v1.42): the chip
   switch with case 1 first, a local copy of the value-table pointer in DSP_ParameterWriteEngine, the keybed
   locals in another order, the note message as a near array, the serial test the other way round. */

/* cc900-module: DSP_NopReturn DSP_WriteParamCmd30 DSP_TableWalk_SearchWithState DSP_PerParameterTranslator Keybed_Decode_Event Keybed_Read_Event InterCPU_DMA_SendDataPacket SAVE_BYTE_TO_RING_BUFFER Serial1_Enable_TX_Interrupt Serial1_HandleEnableCommand */

struct bcfg { int a; int b; int c; int d; long e; };

extern unsigned char __tiny ram_18;                           /* P6 */
extern unsigned int ram_110000;
extern unsigned int ram_110002;
extern unsigned char __near ram_4a42[];
extern unsigned char __near ram_4a4a;
extern unsigned char __near ram_4a4c[];
extern unsigned char __near ram_1034;                         /* SERIAL_1_VAR_1034 */
extern unsigned char EFF_SlotToChip_Table[];

extern int DSP_DispatchData(int d, int chip);
extern int DSP_DispatchCommand(int d, int chip);
extern void DSP_NopReturn();
extern void DSP_WriteParamCmd30(int chip, unsigned int b, long v);
extern void Keybed_Decode_Event(unsigned char *ev, unsigned char d);
extern void InterCPU_DMA_SendDataPacket(int ch, int n, unsigned char *buf);
extern void SAVE_BYTE_TO_RING_BUFFER(void *rb, int c);
extern void Serial1_Enable_TX_Interrupt(void);
extern void Serial1_HandleEnableCommand(int c);
extern unsigned char *DSP_StreamDecode_3ByteWord(unsigned char *p, void *out);
extern unsigned char *DSP_TableWalk_SearchWithState(unsigned char *p, int n, void *st, unsigned char **out);
extern unsigned char *DSP_PerParameterTranslator(int chip, unsigned int slot, int v, unsigned char *p, void *desc,
                                                 unsigned char *rec, struct bcfg *work, int *status);

void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);

void DSP_WriteOscParam(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    default:
            DSP_DispatchData(8, chip);
            DSP_DispatchData(1, chip);
            DSP_DispatchData((unsigned char)(((base + a) >> 4) & 0xf), chip);
            DSP_DispatchData((unsigned char)((((base + a) << 4) & 0xf0) + 8), chip);
            DSP_DispatchData(0x21, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x26), chip);
        break;
    }
}

void DSP_WriteFreqParam(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    default:
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
            DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
        break;
    }
}

void DSP_WriteFreqParam_AlgoType(unsigned int a, long v, int chip, unsigned int base)
{
    switch (chip) {
    case 1:
            DSP_WriteParamCmd30(chip, a, v);
        break;
    default:
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData((unsigned char)((((base + a) >> 4) & 0xf) + 0x10), chip);
            DSP_DispatchData((unsigned char)(((base + a) << 4) & 0xf0), chip);
            DSP_DispatchData(0, chip);
            DSP_DispatchData(0xa, chip);
            DSP_DispatchData((unsigned char)((v >> 17) & 0x7f), chip);
            DSP_DispatchData((unsigned char)((v >> 9) & 0xff), chip);
            DSP_DispatchData((unsigned char)((v >> 1) & 0xff), chip);
            DSP_DispatchData((unsigned char)(((v << 7) & 0x80) + 0x15), chip);
        break;
    }
}

void DSP_ParameterWriteEngine(unsigned int slot, struct bcfg *work, void *desc, unsigned char *vals, int v,
                              unsigned char *rec)
{
    int status;
    unsigned char *end;
    int chip;
    unsigned char *p;

    chip = EFF_SlotToChip_Table[slot];
    status = 0;
    p = DSP_TableWalk_SearchWithState(vals, v, &status, &end);
    if (status != 0) {
        DSP_NopReturn(status);
        return;
    }
    while (p < end) {
        if (chip == 0) {
            status = DSP_DispatchCommand(1, chip);
            status = DSP_DispatchData(1, chip);
            status = DSP_DispatchData(0x60, chip);
        }
        p = DSP_PerParameterTranslator(chip, slot, v, p, desc, rec, work, &status);
        if (status != 0) {
            DSP_NopReturn(status);
            return;
        }
        if (chip == 0)
            status = DSP_DispatchCommand(3, chip);
    }
}

unsigned int Keybed_Read_Event(unsigned char *ev)
{
    unsigned int st;
    unsigned char lo;
    unsigned char hi;
    unsigned int d;

    ram_18 |= 0x80;
    __ASM(" nop");
    st = ram_110002;
    if (st & 1) {
        ram_18 &= ~0x80;
        __ASM(" nop");
        d = ram_110000;
        lo = d & 0xff;
        hi = (d >> 8) & 0xff;
        if (hi == 0xff || (st & 2)) {
            if (lo & 0x80)
                return 0xffff;
            Keybed_Decode_Event(ev, lo);
            ev[1] = 0;
            return 0;
        } else {
            Keybed_Decode_Event(ev, lo);
            return 0;
        }
    }
    return 0xffff;
}

void ToneGen_Process_Notes(void)
{
    unsigned int i = 0;
    unsigned char ev[2];

    while (Keybed_Read_Event(ev) != 0xffff) {
        if (ev[1] != 0) {
            ram_4a4c[ev[0]] = 0xff;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        } else if (ram_4a4c[ev[0]] == 0xff) {
            ram_4a4c[ev[0]] = 0;
            ram_4a42[0] = 0x90;
            ram_4a42[1] = ev[0];
            ram_4a42[2] = ev[1];
            if (ram_4a4a == 1)
                InterCPU_DMA_Send(2, 3, (unsigned char *)0x4a42);
        }
    }
}

int __cdecl Serial1_DataTransmit_Loop(unsigned char n, unsigned char *p)
{
    while (n--) {
        if (ram_1034 & 4) {
            SAVE_BYTE_TO_RING_BUFFER((void *)0x1016, *p++);
            Serial1_Enable_TX_Interrupt();
        } else {
            Serial1_HandleEnableCommand(*p++);
        }
    }
    return 0;
}
