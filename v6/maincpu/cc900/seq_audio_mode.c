/* Functions of sequencer/seq_audio_mode.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_318e, ram_318f, ram_3195, ram_3196, ram_319c, ram_319d, ram_31a3, ram_31a4, ram_31aa, ram_31ab;
extern unsigned char ram_327d, ram_32aa, CMP_SOLO, SEQ_METRO_FLAGS;

void AccTuning_ResetFiveParts_Rec0(void) { ram_318e = 6; ram_318f = 0; }
void AccTuning_ResetFiveParts_Rec1(void) { ram_3195 = 0; ram_3196 = 0; }
void AccTuning_ResetFiveParts_Rec2(void) { ram_319c = 0; ram_319d = 0; }
void AccTuning_ResetFiveParts_Rec3(void) { ram_31a3 = 0; ram_31a4 = 0; }
void AccTuning_ResetFiveParts_Rec4(void) { ram_31aa = 0; ram_31ab = 0; }
void AudioMode_CopyAccentFlags(void) { ram_32aa = CMP_SOLO & 0x3d; }
void AudioMode_CopyChannelMode(void) { ram_327d = SEQ_METRO_FLAGS & 0x03; }
