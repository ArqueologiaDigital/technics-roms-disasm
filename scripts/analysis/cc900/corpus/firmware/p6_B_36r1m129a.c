/* Probe round 36r1, helper B, form a: audio/semenu_routines.s (module 129), the xr_screen.py shape at -O3 -Xr.
   SeMenu_CopyWriteUpdate_Step3_Code_3_Helper(col, kind): clear a 9-byte display object, load the master byte,
   fill it {0x80, master, 1, col, 1, kind} and flush it; returns 0 (no object-flags call, unlike Type1).
   With it, one-spot retries of helper Z's SeMenu_RegisterElement_Type1 / _Type2 / _Extended (run r90: +13 at
   O3Xr, only the clear loop's registers differ: V4.23 gave the running pointer XBC, the ROM XWA, with either
   declaration order of the two pointers).  This form: no end-pointer variable; the loop tests q < o + 9, so the
   object's address is one common value copied into the running pointer and then turned into the bound. */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_SetObjectFlags */
/* cc900-name: SeM_CWU_S3C3H=SeMenu_CopyWriteUpdate_Step3_Code_3_Helper */

extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern int SeM_CWU_S3C3H(unsigned char, unsigned char);
extern int SeMenu_RegisterElement_Type1(unsigned char, unsigned char, unsigned char, unsigned char);
extern void SeMenu_RegisterElement_Type2(unsigned char, unsigned char, unsigned char, unsigned char);
extern int SeMenu_RegisterElement_Extended(unsigned char, unsigned char, unsigned char *, unsigned char);

int SeMenu_RegisterElement_Type1(unsigned char flags, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *p;

    q = o;
    do
        *q++ = 0;
    while (q < o + 9);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[1] = m;
    p[2] = row;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_SetObjectFlags(flags);
    SeMenu_FlushDisplayObj(o);
    return 0;
}

int SeM_CWU_S3C3H(unsigned char col, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *p;

    q = o;
    do
        *q++ = 0;
    while (q < o + 9);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[1] = m;
    p[2] = 1;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_FlushDisplayObj(p);
    return 0;
}

void SeMenu_RegisterElement_Type2(unsigned char mode, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *p;
    register unsigned char *d;

    q = o;
    do
        *q++ = 0;
    while (q < o + 9);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    d = p + 2;
    *d = row;
    if (mode == 0)
        *p = 0x86;
    else if (mode == 1)
        *p = 0x87;
    else if (mode == 2) {
        *p = 0x87;
        *d |= 0x40;
    } else
        *p = 0x85;
    p[1] = m;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_FlushDisplayObj(p);
}

int SeMenu_RegisterElement_Extended(unsigned char flags, unsigned char row, unsigned char *v, unsigned char kind)
{
    unsigned char m;
    unsigned char o[9];
    register unsigned char *q;
    register unsigned char *p;

    q = o;
    do
        *q++ = 0;
    while (q < o + 9);
    SeMenu_LoadMasterPtr(&m);
    p = o;
    p[0] = 0x80;
    p[0] |= 0x08;
    p[1] = m;
    p[2] = row;
    p[3] = 1;
    p[4] = *v;
    p[5] = kind;
    SeMenu_SetObjectFlags(flags);
    SeMenu_FlushDisplayObj(o);
    return 0;
}
