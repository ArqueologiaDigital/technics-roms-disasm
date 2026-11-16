typedef unsigned char *ucp;

struct frec { unsigned int w[6]; };
/* one byte seen as bit fields (bit fields fill a unit from bit 7); used through casts at any offset */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
struct b10 { unsigned char r : 6; unsigned char b1 : 1; unsigned char b0 : 1; };
struct r8 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char b2 : 1; unsigned char b1 : 1; unsigned char b0 : 1; };
struct eq2 { unsigned char h : 2; unsigned char f54 : 2; unsigned char b3 : 1; unsigned char b2 : 1; unsigned char l : 2; };
struct a4 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char lo : 3; };
struct a6 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1; unsigned char lo : 4; };
struct o56 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char r : 5; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern unsigned int ram_25db8[];
extern int ram_25ea8;
extern unsigned int ram_272cc;
extern unsigned int ram_272ce;
extern unsigned int SEQMAIN_WRITE_POS;
extern unsigned int SEQMAIN_READ_POS;
extern unsigned int ram_1e74f;
extern unsigned int ram_1e74b;
extern unsigned int ram_1e751;
extern unsigned int ram_204db;
extern unsigned int ram_204d7;
extern unsigned int ram_204dd;
extern unsigned int ram_1fc9f;
extern unsigned int ram_1fc9b;
extern unsigned int ram_1fca1;
extern unsigned int ram_1ef59;
extern unsigned int ram_1ef55;
extern unsigned int ram_1ef5b;
extern unsigned int ram_1f781;
extern unsigned int ram_1f77d;
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char PortConfig_Handler_0_Tbl[];
extern unsigned char __near SQSTEP_DISPLAY_MODE;
extern unsigned char __near STATUS_POPUP_ID;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern ucp __near ram_1114;
extern unsigned char __near ram_ec4;
extern unsigned int __near ram_b7ea;
