/* Phase 6, probe m16: how does V4.23's listing declare an extern qualified __near or __tiny (16 / 8-bit absolute
   operands; the default in this "maximum" mode is large, 24-bit)?  The firmware reaches most RAM cells below 0x10000
   with 16-bit operands but the chord variables (CHORD_FLAGS, 0xcede..) with 24-bit ones: plain externs there,
   __near ones elsewhere? */
extern unsigned char __near near_c;
extern unsigned int __near near_i;
extern unsigned char __tiny tiny_c;
extern unsigned char large_c;
unsigned char rd_near(void) { return near_c; }
unsigned int rd_near_i(void) { return near_i; }
unsigned char rd_tiny(void) { return tiny_c; }
unsigned char rd_large(void) { return large_c; }
void wr_all(unsigned char a) { near_c = a; tiny_c = a; large_c = a; }
extern unsigned char __near near_arr[];
extern unsigned char __tiny tiny_arr[];
extern unsigned char large_arr[];
unsigned char rd_near_arr(unsigned char i) { return near_arr[i]; }
unsigned char rd_tiny_arr(unsigned char i) { return tiny_arr[i]; }
unsigned char rd_large_arr(unsigned char i) { return large_arr[i]; }
unsigned char *adr_near(void) { return &near_c; }
unsigned char *adr_tiny(void) { return &tiny_c; }
unsigned char *adr_large(void) { return &large_c; }
void bit_near(void) { near_c |= 4; }
void bit_large(void) { large_c |= 4; }
unsigned char __near def_near;
unsigned char __tiny def_tiny;
unsigned char def_large;
void wr_defs(unsigned char a) { def_near = a; def_tiny = a; def_large = a; }
