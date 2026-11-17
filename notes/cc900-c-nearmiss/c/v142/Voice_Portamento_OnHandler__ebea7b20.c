/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_B_7j.c (2026-11-16-79-sub-r7)
   sha256 ebea7b20874d86b6abbc94f697af05ece70c1ce78314197a491ad92cb8b4b437 (name+funcs); compiled at -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_413ce[];
extern void Voice_CC_SetSostenutoFlag(int, int);
extern void AlgoType_StateWrite(int, int);
extern void VoiceAlloc_WithRoutingFlag(int, int);
extern void Partial_Build_Present_Word(int);
extern void EnvTranspose_UpdateLoop(int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);
void Voice_Portamento_OnHandler(unsigned char part, unsigned char v)
{
    switch ((*(unsigned char **)&ram_4136e[part * 0x11f])[16] & 0xc0) {
    case 0:
    case 0xc0:
        Voice_CC_SetSostenutoFlag(part, v);
        AlgoType_StateWrite(part, 1);
        VoiceAlloc_WithRoutingFlag(part, v);
        Partial_Build_Present_Word(part);
        EnvTranspose_UpdateLoop(part);
        VoiceNoteParam_UpdateLoop(part);
        Voice_ActiveFlag_CheckAndLoad(part);
        ram_413ce[part * 0x11f] = Voice_SecondaryParam_Epilogue(part);
        break;
    case 0x40:
    case 0x80:
        break;
    }
}
