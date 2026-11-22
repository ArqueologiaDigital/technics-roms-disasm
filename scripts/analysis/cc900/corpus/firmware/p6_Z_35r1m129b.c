/* Probe round 35r1, helper Z, form b: audio/semenu_routines.s (module 129).  As form a, but the object keeps
   helper Y's declaration order (object, then master byte) and only the clear loop's pointers are swapped; Type2
   sets bit 6 through a `register` char copy (the ROM reads the byte into C, sets the bit, stores it);
   SeMenu_SelectPartAndRedraw as nested ifs. */
/* cc900-module: SeMenu_FlushDisplayObj SeMenu_IsPartEnabled SeMenu_LoadMasterPtr SeMenu_LoadPartParam SeMenu_SetCurrentPart SeMenu_SetObjectFlags SeMenu_SetupMenuDisplay SeMenu_StorePartParam */

extern void SeMenu_LoadMasterPtr(unsigned char *);
extern void SeMenu_SetObjectFlags(unsigned int);
extern void SeMenu_FlushDisplayObj(unsigned char *);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern int SeMenu_IsPartEnabled(int);
extern void SeMenu_SetCurrentPart(int);
extern void SeMenu_SetupMenuDisplay(int);
extern void __cdecl SeTitle_DrawField(int, int);
extern int SeMenu_RegisterElement_Type1(unsigned char, unsigned char, unsigned char, unsigned char);
extern void SeMenu_RegisterElement_Type2(unsigned char, unsigned char, unsigned char, unsigned char);
extern int SeMenu_RegisterElement_Extended(unsigned char, unsigned char, unsigned char *, unsigned char);
extern void SeMenu_SelectPartAndRedraw(unsigned char, unsigned char, unsigned char);

int SeMenu_RegisterElement_Extended(unsigned char flags, unsigned char row, unsigned char *v, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *e;
    register unsigned char *q;
    register unsigned char *p;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
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

int SeMenu_RegisterElement_Type1(unsigned char flags, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *e;
    register unsigned char *q;
    register unsigned char *p;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
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

void SeMenu_RegisterElement_Type2(unsigned char mode, unsigned char row, unsigned char col, unsigned char kind)
{
    unsigned char o[9];
    unsigned char m;
    register unsigned char *e;
    register unsigned char *q;
    register unsigned char *p;
    register unsigned char *d;
    register unsigned char c;

    e = (q = o) + 9;
    do
        *q++ = 0;
    while (q < e);
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
        c = *d;
        c |= 0x40;
        *d = c;
    } else
        *p = 0x85;
    p[1] = m;
    p[3] = col;
    p[4] = 1;
    p[5] = kind;
    SeMenu_FlushDisplayObj(p);
}

void SeMenu_SelectPartAndRedraw(unsigned char field, unsigned char part, unsigned char check)
{
    unsigned char cur;

    SeMenu_LoadPartParam(0, &cur);
    if (part != cur) {
        if (check != 1 || SeMenu_IsPartEnabled(part) != 0) {
            SeMenu_SetCurrentPart(part);
            SeMenu_StorePartParam(0, part);
            SeTitle_DrawField(field, 0);
            SeMenu_SetupMenuDisplay(1);
        }
    }
}
