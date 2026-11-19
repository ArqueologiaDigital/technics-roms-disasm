/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w3b.c (2026-11-19-10-sub-r23w-asm)
   sha256 d20e29023118a40f2a271ad82f83ef4675b92a35036e76a09e526311c9db51e7 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern unsigned char ram_4134c;
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_4308e[][0x47];
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
                switch ((*(unsigned char **)&ram_4136e[(p = ram_4308e[*q][4]) * 0x11f])[16] & 0xc0) {
                case 0:
                case 0x40:
                case 0xc0:
                    Level_Build_Reg0C0(ram_4308e[*q]);
                    Voice_Build_GateCommand(ram_4308e[*q]);
                    break;
                case 0x80:
                    Voice_ComputePitchBend2(ram_4308e[*q]);
                    Voice_Build_GateCmd_NoPartial(ram_4308e[*q]);
                    break;
                }
                ToneGen_ReadPitch_AndScale(*q);
            }
        }
    }
}
