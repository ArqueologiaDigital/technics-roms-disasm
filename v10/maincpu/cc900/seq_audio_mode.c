/* Functions of sequencer/seq_audio_mode.s.  Firmware C (cc900 phase 6), built by scripts/build/cc900_firmware_c.py with the cc900 reference model;
   no Toshiba program.  Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet. */
extern unsigned char ram_3246, ram_3247, ram_324d, ram_324e, ram_3254, ram_3255, ram_325b, ram_325c, ram_3262, ram_3263;
extern unsigned char ram_3335, ram_3362, CMP_SOLO, SEQ_METRO_FLAGS;

void AccTuning_ResetFiveParts_Rec0(void) { ram_3246 = 6; ram_3247 = 0; }
void AccTuning_ResetFiveParts_Rec1(void) { ram_324d = 0; ram_324e = 0; }
void AccTuning_ResetFiveParts_Rec2(void) { ram_3254 = 0; ram_3255 = 0; }
void AccTuning_ResetFiveParts_Rec3(void) { ram_325b = 0; ram_325c = 0; }
void AccTuning_ResetFiveParts_Rec4(void) { ram_3262 = 0; ram_3263 = 0; }
void AudioMode_CopyAccentFlags(void) { ram_3362 = CMP_SOLO & 0x3d; }
void AudioMode_CopyChannelMode(void) { ram_3335 = SEQ_METRO_FLAGS & 0x03; }
