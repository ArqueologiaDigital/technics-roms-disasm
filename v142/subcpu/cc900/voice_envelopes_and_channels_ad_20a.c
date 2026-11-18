/* Functions of core/06_voice_envelopes_and_channels.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct b4 { unsigned char b0, b1, b2, b3; };
extern unsigned char ram_41368[];
extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];
extern unsigned int ram_45204;
extern unsigned int ram_45206;
extern unsigned int ram_45208;
extern unsigned int ram_4520c;
extern unsigned int ram_4520e;
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned int *Voice_BuildOutputList(int, int, int);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
extern void EFF_RoutingInit(int, int, int);
extern void ExtVoice_Build_SlotRegisters(unsigned char *v);
extern void Voice_SubVoice_ComputeAndTrig(unsigned char *v);
extern void Voice2_UpdatePitch(unsigned char *v);
extern void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
extern unsigned int EGEnv_Compute_A(int n);
extern unsigned int EGEnv_Compute_B(int n);
extern unsigned int EGEnv_Compute_A_Simple(int n);
extern unsigned int EGEnv_Compute_B_Simple(int n);
extern void Voice_Freq_WriteLeft(int n);
extern void Voice_Freq_WriteRight(int n);
extern void ToneGen_WriteVoice_Reg11(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg13(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg18(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg16(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg07(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_Reg15(int ch, unsigned int *p);
extern void ToneGen_WriteVoice_EnvLevel(int ch, unsigned int *p);
extern void ToneGen_WrVoice_Reg07_Or_Reg18(int ch, unsigned int *p);
extern void ToneGen_WrVoice_Reg15_Or_Reg16(int ch, unsigned int *p);
void AudioMod_Apply_Slot_Field2A(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k);
void AudioMod_Apply_Slot_Field29(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot, unsigned char k);
void AudioChannel_Handler_Cmd04_07(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);
void AudioChannel_Handler_Cmd08_0B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);
void AudioChannel_Handler_Cmd0C_0F(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);
void AudioChannel_Handler_Cmd10_13(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);
void AudioChannel_Handler_Cmd14_17(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);
void AudioChannel_Handler_Cmd18_1B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot);

/* cc900-name: Voice_SubVoice_ComputeAndTrig=Voice_SubVoice_ComputeAndTrigger */
/* cc900-name: ToneGen_WrVoice_Reg07_Or_Reg18=ToneGen_WriteVoice_Reg07_Or_Reg18 */
/* cc900-name: ToneGen_WrVoice_Reg15_Or_Reg16=ToneGen_WriteVoice_Reg15_Or_Reg16 */
/* cc900-module: AudioMod_Apply_Slot_Field29 AudioMod_Apply_Slot_Field2A ToneGen_WrVoice_Reg07_Or_Reg18 ToneGen_WrVoice_Reg15_Or_Reg16 ToneGen_WriteVoice_EnvLevel ToneGen_WriteVoice_Reg07 ToneGen_WriteVoice_Reg07_Or_Reg18 ToneGen_WriteVoice_Reg11 ToneGen_WriteVoice_Reg13 ToneGen_WriteVoice_Reg15 ToneGen_WriteVoice_Reg15_Or_Reg16 ToneGen_WriteVoice_Reg16 ToneGen_WriteVoice_Reg18 */
void AudioChannel_Handler_Cmd04_07(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 39])->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 0);
        AlgoFlag_Write(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
            } else {
                ram_4520c = EGEnv_Compute_A((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

void AudioChannel_Handler_Cmd08_0B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 55])->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 1);
        AlgoFlag_Write(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
            } else {
                ram_45204 = EGEnv_Compute_B((unsigned char)i);
            }
            ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
        }
    }
}

void AudioChannel_Handler_Cmd0C_0F(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 71])->b3 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field2A(part, val, m, slot, 2);
        AlgoFlag_Write(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
            } else {
                Voice_Freq_WriteLeft((unsigned char)i);
            }
            ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
        }
    }
}

void AudioChannel_Handler_Cmd10_13(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 39])->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            ExtVoice_Build_SlotRegisters(base[*q]);
            ToneGen_WriteVoice_Reg11(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 0);
        AlgoFlag_Write_Bit3(part, 0, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 0);
        olist = Voice_BuildOutputList(part, (unsigned char)(unsigned int)slot, 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 0, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_4520c = 0;
                ToneGen_WriteVoice_Reg18((unsigned char)i, ram_451cc);
            } else {
                ram_45208 = EGEnv_Compute_A_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}

void AudioChannel_Handler_Cmd14_17(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 55])->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice_SubVoice_ComputeAndTrig(base[*q]);
            ToneGen_WriteVoice_EnvLevel(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 1);
        AlgoFlag_Write_Bit3(part, 1, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 1);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 4), 32);
        for (j = 0; (olist[j] & 0xff) < 0x40; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 1, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ToneGen_WriteVoice_Reg07((unsigned char)i, ram_451cc);
            } else {
                ram_45206 = EGEnv_Compute_B_Simple((unsigned char)i);
                ToneGen_WriteVoice_Reg15((unsigned char)i, ram_451cc);
            }
        }
    }
}

void AudioChannel_Handler_Cmd18_1B(unsigned char part, unsigned char val, unsigned char *m, unsigned char slot)
{
    unsigned int i;
    if (((struct b4 *)&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(slot) * 4 + 71])->b2 == 0) {
        unsigned char *list;
        unsigned char (*base)[0x47];
        unsigned char *q;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        list = Voice_Query_PartVoices(part);
        *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
        base = ram_4308e;
        for (q = list + 5; *q < 0x40; q++) {
            Voice2_UpdatePitch(base[*q]);
            ToneGen_WriteVoice_Reg13(*q, ram_451cc);
        }
    } else {
        unsigned int *olist;
        unsigned int j;
        AudioMod_Apply_Slot_Field29(part, val, m, slot, 2);
        AlgoFlag_Write_Bit3(part, 2, slot);
        for (i = 0; i < 4; i++) EFF_RoutingInit(part, (unsigned char)i, 2);
        olist = Voice_BuildOutputList(part, (unsigned char)((unsigned int)slot | 8), 32);
        for (j = 0; (olist[j] & 0xff) < 0x80; j++) {
            i = olist[j];
            i &= 0xff;
            Voice_OpSlot_WriteParams(part, ram_41368 + part * 287, slot, 2, (unsigned char)i);
            if (val == 0) {
                *(unsigned int *)&ram_41368[part * 0x11f] |= 8;
                ram_45204 = 0;
                ram_4520e = 0;
                ToneGen_WrVoice_Reg07_Or_Reg18((unsigned char)i, ram_451cc);
            } else {
                Voice_Freq_WriteRight((unsigned char)i);
                ToneGen_WrVoice_Reg15_Or_Reg16((unsigned char)i, ram_451cc);
            }
        }
    }
}
