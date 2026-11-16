/* lane_sub probe round 2, form b: refinements of round 1's misses (sub-CPU payload v1.42). */
extern unsigned char Detune_Scale_Curve[];
extern unsigned char ram_41342[];
extern unsigned char ram_4136a[];
extern unsigned char ram_41368[][0x11f];
extern int ram_41347;
struct st { int w[0x91]; };
extern struct st ram_45ca;

void DSP_StateTable_Reset(struct st *p) { struct st *d = (struct st *)0x45ca; *d = *p; }
int Detune_ScaleUnsigned(unsigned char a) { a = Detune_Scale_Curve[a]; return a; }
unsigned char ScaleTune_Get_User_Offset(unsigned char n) { unsigned int i = n; i += 12; return ram_41342[i]; }
void ScaleTune_Set_User_Offset(unsigned char n, unsigned char v) { unsigned int i = n; i += 12; ram_41342[i] = v - 0x80; }
void Voice_SetLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_41368[part][2] |= 0x2000; }
void Voice_ClearLFO_ActiveFlag(unsigned char part) { *(unsigned int *)&ram_41368[part][2] &= ~0x2000; }
void Voice_SetMasterTune(char a) { a = (a - 0x40) * 2; ram_41347 = a; }
