/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_2a.c (2026-11-16-47-sub-r2)
   sha256 317481c6cc0b0362eb3d69ef64a520bc9035dd3312d59f39df1c5ca8e5f184c4 (name+funcs); compiled at -Xr
   cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern unsigned char ram_4134c;
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_4308e[];
extern unsigned char ram_43092[];
extern unsigned char *Voice_Query_PartVoices(int);
extern void Level_Build_Reg0C0(unsigned char *);
extern void Voice_Build_GateCommand(unsigned char *);
extern void Voice_ComputePitchBend2(unsigned char *);
extern void Voice_Build_GateCmd_NoPartial(unsigned char *);
extern void ToneGen_ReadPitch_AndScale(int);
void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    unsigned char *q;
    ram_4134c = v & 0x0f;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_41372[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                p = ram_43092[*q * 0x47];
                switch ((*(unsigned char **)&ram_4136e[p * 0x11f])[16] & 0xc0) {
                case 0:
                case 0x40:
                case 0xc0:
                    Level_Build_Reg0C0(ram_4308e + *q * 0x47);
                    Voice_Build_GateCommand(ram_4308e + *q * 0x47);
                    break;
                case 0x80:
                    Voice_ComputePitchBend2(ram_4308e + *q * 0x47);
                    Voice_Build_GateCmd_NoPartial(ram_4308e + *q * 0x47);
                    break;
                }
                ToneGen_ReadPitch_AndScale(*q);
            }
        }
    }
}
