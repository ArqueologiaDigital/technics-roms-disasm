/* lane_sub probe round 2, form a: refinements of round 1's misses (sub-CPU payload v1.42). */
extern unsigned char Detune_Scale_Curve[];
extern unsigned char ram_41342[];
extern unsigned char ram_4136a[];
extern unsigned char ram_41368[][0x11f];
extern int ram_41347;
struct st { int w[0x91]; };
extern struct st ram_45ca;

void DSP_StateTable_Reset(struct st *p) { *(struct st *)0x45ca = *p; }
unsigned int Detune_ScaleUnsigned(unsigned char a) { a = Detune_Scale_Curve[a]; return a; }
unsigned char ScaleTune_Get_User_Offset(unsigned char n) { return ram_41342[(unsigned int)n + 12]; }
void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { ram_41342[(unsigned int)n + 12] = v - 0x80; }
void Voice_SetLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4136a[part * 0x11f] |= 0x2000; }
void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_4136a[part * 0x11f] &= ~0x2000; }
void Voice_SetMasterTune(char a) { a -= 0x40; a += a; ram_41347 = a; }
