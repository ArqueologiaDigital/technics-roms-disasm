/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r13_ng2.c (2026-11-16-83-hd-r16)
   sha256 0ded6ef7285384191a739fce37af29d8f883d9d47f4f4faa2c3da680f6394fef (tar-sha256); compiled at -Xr */
extern unsigned char HDAE5000_RAM_DirNames[];
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
int HDAE5000_HD_StoreTables(int keep);
int HDAE5000_FlsName_SetAndStore(unsigned int fls, char *name, int keep)
{
    HDAE5000_StrNCpy(&HDAE5000_RAM_DirNames[(unsigned long)fls * 144 + 0x24180L], name, 16);
    return HDAE5000_HD_StoreTables(keep);
}
unsigned int fls;
int keep;
