/* Functions of sequencer/seq_audio_mode.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near ram_31aa;
extern unsigned char __near ram_31ab;
extern unsigned char __near ram_31b1;
extern unsigned char __near ram_31b2;
extern unsigned char __near ram_31b8;
extern unsigned char __near ram_31b9;
extern unsigned char __near ram_31bf;
extern unsigned char __near ram_31c0;
extern unsigned char __near ram_31c6;
extern unsigned char __near ram_31c7;
extern unsigned char __near ram_3299;
extern unsigned char __near ram_32c6;
extern unsigned char __near CMP_SOLO;
extern unsigned char __near SEQ_METRO_FLAGS;

void AccTuning_ResetFiveParts_Rec0(void) { ram_31aa = 6; ram_31ab = 0; }
void AccTuning_ResetFiveParts_Rec1(void) { ram_31b1 = 0; ram_31b2 = 0; }
void AccTuning_ResetFiveParts_Rec2(void) { ram_31b8 = 0; ram_31b9 = 0; }
void AccTuning_ResetFiveParts_Rec3(void) { ram_31bf = 0; ram_31c0 = 0; }
void AccTuning_ResetFiveParts_Rec4(void) { ram_31c6 = 0; ram_31c7 = 0; }
void AudioMode_CopyAccentFlags(void) { ram_32c6 = CMP_SOLO & 0x3d; }
void AudioMode_CopyChannelMode(void) { ram_3299 = SEQ_METRO_FLAGS & 0x03; }
