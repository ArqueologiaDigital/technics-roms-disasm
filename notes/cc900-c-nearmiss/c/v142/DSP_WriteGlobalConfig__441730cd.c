/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2a.c (2026-11-16-47-sub-r2)
   sha256 441730cd34a51ded89e917ad1d8715eb068dfde21b11eb7ad3c950b0e876929a (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern struct bcfg DSP_Bytecode_Global_Config[];
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
void DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    DSP_BytecodeInterpreter_Init(chip, 0, DSP_Bytecode_Global_Config, code);
}
