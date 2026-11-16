/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m14a.c (2026-11-16-27-p6-m14)
   sha256 e95e51a66b0871648f791559c6c0341da30001311638b392e5f82ec7a0ca5142 (name+funcs); compiled at -O3 -XS -Xr */
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }
