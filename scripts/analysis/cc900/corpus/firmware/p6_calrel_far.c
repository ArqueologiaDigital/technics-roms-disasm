/* Phase 6, probe calrel, far part (lane_vmb; see p6_calrel.c): a call and a tail call over about 49 KB, beyond the
   16-bit reach of calr and jrl, in both directions.  Which form does asm900 take: call #24 / jp #24? */
extern unsigned char __near flag;
extern unsigned char big[];                 /* large: each store below is ld (big+n:24), 1 -- 6 bytes */
void leaf_far(void);

#define S1(n)   big[n] = 1;
#define S16(n)  S1(n) S1(n+1) S1(n+2) S1(n+3) S1(n+4) S1(n+5) S1(n+6) S1(n+7) \
                S1(n+8) S1(n+9) S1(n+10) S1(n+11) S1(n+12) S1(n+13) S1(n+14) S1(n+15)
#define S256(n) S16(n) S16(n+16) S16(n+32) S16(n+48) S16(n+64) S16(n+80) S16(n+96) S16(n+112) \
                S16(n+128) S16(n+144) S16(n+160) S16(n+176) S16(n+192) S16(n+208) S16(n+224) S16(n+240)
#define S4096(n) S256(n) S256(n+256) S256(n+512) S256(n+768) S256(n+1024) S256(n+1280) S256(n+1536) \
                S256(n+1792) S256(n+2048) S256(n+2304) S256(n+2560) S256(n+2816) S256(n+3072) S256(n+3328) \
                S256(n+3584) S256(n+3840)

void leaf_near(void) { flag = 1; }
void call_far(void) { leaf_far(); flag = 10; }      /* cal over about 49 KB */
void tail_far(void) { leaf_far(); }                 /* j over about 49 KB */
void pad49k(void) { S4096(0) S4096(4096) }          /* 8192 stores, about 49 KB */
void leaf_far(void) { flag = 11; }
void call_far_back(void) { leaf_near(); flag = 12; }    /* cal back over pad49k */
void tail_far_back(void) { leaf_near(); }               /* j back over pad49k */
