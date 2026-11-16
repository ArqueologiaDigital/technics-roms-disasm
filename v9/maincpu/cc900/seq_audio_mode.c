/* Functions of sequencer/seq_audio_mode.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char __near ram_3246;
extern unsigned char __near ram_3247;
extern unsigned char __near ram_324d;
extern unsigned char __near ram_324e;
extern unsigned char __near ram_3254;
extern unsigned char __near ram_3255;
extern unsigned char __near ram_325b;
extern unsigned char __near ram_325c;
extern unsigned char __near ram_3262;
extern unsigned char __near ram_3263;
extern unsigned char __near ram_3335;
extern unsigned char __near ram_3362;
extern unsigned char __near CMP_SOLO;
extern unsigned char __near SEQ_METRO_FLAGS;

void AccTuning_ResetFiveParts_Rec0(void) { ram_3246 = 6; ram_3247 = 0; }
void AccTuning_ResetFiveParts_Rec1(void) { ram_324d = 0; ram_324e = 0; }
void AccTuning_ResetFiveParts_Rec2(void) { ram_3254 = 0; ram_3255 = 0; }
void AccTuning_ResetFiveParts_Rec3(void) { ram_325b = 0; ram_325c = 0; }
void AccTuning_ResetFiveParts_Rec4(void) { ram_3262 = 0; ram_3263 = 0; }
void AudioMode_CopyAccentFlags(void) { ram_3362 = CMP_SOLO & 0x3d; }
void AudioMode_CopyChannelMode(void) { ram_3335 = SEQ_METRO_FLAGS & 0x03; }
