/* Functions of sequencer/seq_audio_mode.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_31aa, ram_31ab, ram_31b1, ram_31b2, ram_31b8, ram_31b9, ram_31bf, ram_31c0, ram_31c6, ram_31c7;
extern unsigned char ram_3299, ram_32c6, CMP_SOLO, SEQ_METRO_FLAGS;

void AccTuning_ResetFiveParts_Rec0(void) { ram_31aa = 6; ram_31ab = 0; }
void AccTuning_ResetFiveParts_Rec1(void) { ram_31b1 = 0; ram_31b2 = 0; }
void AccTuning_ResetFiveParts_Rec2(void) { ram_31b8 = 0; ram_31b9 = 0; }
void AccTuning_ResetFiveParts_Rec3(void) { ram_31bf = 0; ram_31c0 = 0; }
void AccTuning_ResetFiveParts_Rec4(void) { ram_31c6 = 0; ram_31c7 = 0; }
void AudioMode_CopyAccentFlags(void) { ram_32c6 = CMP_SOLO & 0x3d; }
void AudioMode_CopyChannelMode(void) { ram_3299 = SEQ_METRO_FLAGS & 0x03; }
