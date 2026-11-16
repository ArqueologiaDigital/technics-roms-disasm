/* lane_sub helper B, round 11, form c (round 10 matched to +20, where V4.23 reloaded the cursor before the first
   test: now the list parameter is advanced in place, copied to the cursor, and tested itself; the loop is a guarded
   do-while with the increment at the end of the body, which round 10 showed compiles to the ROM's loop end):
   Voice_AllNotes_SustainRetrigger (core/06_voice_envelopes_and_channels.s,
   KN5000 sub-CPU payload v1.42), which reaches three tone-generator writers with calr.  For each voice of a channel
   list (list + 5, ended by a byte >= 0x40) it re-sends the levels by the voice type (word 1 bits 2-5); the voice
   record is in XIZ, the list cursor and the record base on the stack.  The ROM tests the first entry without
   reloading the cursor (Audio_Tick_ServiceVoices_A's open point), so this may stop there.
   cc900-module: ToneGen_WriteVoice_Direct ToneGen_WriteVoice_6Words ToneGen_WriteNote2ch */

extern unsigned char ram_4308e[][0x47];
extern unsigned int ram_451cc[];

extern void Voice_Calc_LevelPair_EGA(unsigned char *v);
extern void Voice_Calc_LevelPair_EGB(unsigned char *v);
extern void Voice_Calc_LevelPair_EGC(unsigned char *v);
extern void Voice_WriteVolume_SetFlag(unsigned char *v);
extern void Voice_WriteVolume_OrPan(unsigned char *v);
extern void ToneGen_WriteSegRegs_SameLevel(int ch, unsigned int *blk);
extern void Voice_Clear_HoldBit(int ch);
extern void ToneGen_WriteVoice_Direct(unsigned int a, unsigned int d);
extern void ToneGen_WriteVoice_6Words(unsigned int ch, unsigned int *p);
extern void ToneGen_WriteNote2ch(unsigned int ch, unsigned int *p);

void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag)
{
    unsigned char (*base)[0x47];
    unsigned char *q;
    unsigned char *v;
    base = ram_4308e;
    list += 5;
    q = list;
    if (*list < 0x40) do {
        v = base[*q];
        switch (*(unsigned int *)(v + 1) & 0x3c) {
        case 4:
        case 8:
        case 0x20:
            if ((*(unsigned int *)(v + 1) & 32768) || !(*(unsigned int *)(*(unsigned char **)(v + 35) + 10) & 1)) {
                if (*(unsigned int *)(v + 1) & 0x100) {
                    Voice_Calc_LevelPair_EGA(v);
                    ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                    ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                    Voice_Clear_HoldBit(*q);
                    *(unsigned int *)(v + 1) &= ~0x100;
                } else {
                    Voice_Calc_LevelPair_EGA(v);
                    Voice_Calc_LevelPair_EGB(v);
                    Voice_Calc_LevelPair_EGC(v);
                    ToneGen_WriteVoice_6Words(*q, ram_451cc);
                }
            } else if (*(unsigned int *)(v + 1) & 0x100) {
                Voice_Calc_LevelPair_EGA(v);
                ToneGen_WriteSegRegs_SameLevel(*q, ram_451cc);
                ToneGen_WriteVoice_Direct(*q, *(unsigned int *)(v + 45));
                Voice_Clear_HoldBit(*q);
                *(unsigned int *)(v + 1) &= ~0x100;
            } else if (!(*(unsigned int *)(v + 64) & 0xff)) {
                Voice_WriteVolume_SetFlag(v);
                ToneGen_WriteNote2ch(*q, ram_451cc);
            }
            break;
        case 0x10:
            if (flag != 0) {
                Voice_WriteVolume_OrPan(v);
                ToneGen_WriteNote2ch(*q, ram_451cc);
            }
            break;
        }
        q++;
    } while (*q < 0x40);
}
