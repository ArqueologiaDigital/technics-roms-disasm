/* Phase 6 milestone 2, probe a: three v10 functions the reference model does not reproduce from the C below.
   Each variant is a guess at the firmware's C; compiled at -O3 -XS -Xr (the firmware's options).
   - GetNamingWindowID (ROM: ld XHL,0xa / ret): a 32-bit constant return; the model writes lda XHL,0xa.
   - Medley_GetPlaybackStatus (ROM: xor HL,HL / ld L,(0x1155) / ret): a byte zero-extended into HL; the model
     writes ld L,(..) / extz HL.
   - VariScreen_IsHalfRangeAbove (ROM: srl 1,A / cp A,C / scc nc,L / ret): the model cannot compile the compare. */
extern unsigned char ram_1155;
extern unsigned int ram_1155_w;
struct medley_bits { unsigned int status : 8; unsigned int rest : 8; };
extern struct medley_bits ram_1155_s;

long naming_long(void) { return 10; }
void *naming_ptr(void) { return (void *)10; }
unsigned long naming_ulong(void) { return 10; }
int naming_int(void) { return 10; }

int medley_uc(void) { return ram_1155; }
unsigned int medley_uc_u(void) { return ram_1155; }
int medley_mask(void) { return ram_1155_w & 0xff; }
int medley_cast(void) { return (unsigned char)ram_1155_w; }
int medley_bitfield(void) { return ram_1155_s.status; }
int medley_local(void) { int r = 0; r = ram_1155; return r; }

char vari_char(unsigned char a, unsigned char c) { return (a >> 1) >= c; }
int vari_int(unsigned char a, unsigned char c) { return (a >> 1) >= c; }
unsigned char vari_uchar(unsigned char a, unsigned char c) { return (unsigned char)(a >> 1) >= c; }
char vari_local(unsigned char a, unsigned char c) { unsigned char h = a >> 1; return h >= c; }
char vari_div(unsigned char a, unsigned char c) { return a / 2 >= c; }
