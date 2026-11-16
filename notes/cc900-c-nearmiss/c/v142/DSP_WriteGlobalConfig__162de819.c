/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_2b.c (2026-11-16-47-sub-r2)
   sha256 162de819f54cf9ec9603635f20562168dba6600f421b81838c9e376a9705aded (name+funcs); compiled at -Xr */
struct bcfg { int a; int b; int c; int d; long e; };
extern struct bcfg DSP_Bytecode_Global_Config[];
extern int DSP_BytecodeInterpreter_Init(int chip, unsigned int idx, struct bcfg *cfg, unsigned char *code);
int DSP_WriteGlobalConfig(int chip, unsigned char *code)
{
    return DSP_BytecodeInterpreter_Init(chip, 0, DSP_Bytecode_Global_Config, code);
}
