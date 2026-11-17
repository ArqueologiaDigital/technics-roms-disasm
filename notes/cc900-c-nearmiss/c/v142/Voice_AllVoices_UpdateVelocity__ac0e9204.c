/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_Q_17a.c (2026-11-16-126-sub-r17)
   sha256 ac0e9204f80496a2a00e80ac0c4a0b41db26241507df15b2c4016b2c7863b004 (name+funcs); compiled at -Xr
   cc900-name: Voice_Build_GateCmd_NoPartial=Voice_Build_GateCommand_NoPartial */
extern unsigned char ram_4134c;
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_4308e[][0x47];
extern unsigned char *Voice_Query_PartVoices(int part);
extern void Level_Build_Reg0C0(unsigned char *v);
extern void Voice_Build_GateCommand(unsigned char *v);
extern void Voice_ComputePitchBend2(unsigned char *v);
extern void Voice_Build_GateCmd_NoPartial(unsigned char *v);
extern void ToneGen_ReadPitch_AndScale(int ch);
void Voice_AllVoices_UpdateVelocity(unsigned char v)
{
    unsigned char p;
    unsigned char u;
    unsigned char *q;
    ram_4134c = v & 0x0f;
    for (p = 0; p < 26; p++) {
        if (*(unsigned int *)&ram_41372[p * 0x11f] & 2) {
            for (q = Voice_Query_PartVoices(p) + 5; *q < 0x40; q++) {
                u = ram_4308e[*q][4];
                p = u;
                switch ((*(unsigned char **)&ram_4136e[u * 0x11f])[16] & 0xc0) {
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
