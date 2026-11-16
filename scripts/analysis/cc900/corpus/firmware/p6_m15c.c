/* Phase 6, probe m15 (form c): which C, if any, makes V4.23 shift left by a variable count with the logical sll
   (the ROM's FileIO_* bit functions, demo/file_demo_proc.s) instead of sla?  Variants by operand type. */
extern unsigned int ram_272cc;
extern unsigned long ul;
void sh_u_var(unsigned char a) { unsigned int m = 1; m <<= a; ram_272cc |= m; }
void sh_u_int(unsigned int a) { if (a < 10) ram_272cc |= 1U << a; }
void sh_u_cast(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)1 << (unsigned int)a; }
void sh_ul(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)(1UL << a); }
void sh_uc(unsigned char a) { unsigned char m = 1; if (a < 10) ram_272cc |= (unsigned int)(m << a); }
void sh_u_glob(unsigned char a) { if (a < 10) ram_272cc = ram_272cc | (1U << a); }
void sh_s(unsigned char a) { if (a < 10) ram_272cc |= (unsigned int)(1 << a); }
void sh_u_char_arg(char a) { if (a < 10) ram_272cc |= 1U << a; }
