/* cc900-module: SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr */
/* Phase 6, lane_p6 helper A, round 15, form b: module 129 (audio/semenu_routines.s), the display-record builders.
   The record is a 9-byte local (odd size: a char array), the master part a byte local passed by address. */
extern void SeMenu_LoadMasterPtr(unsigned char *m);
extern void SeMenu_FlushDisplayObj(unsigned char *r);

void SeMenu_SetDisplayValue(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p;
    for (p = r; p < r + 9; p++)
        *p = 0;
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0xc;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_RegisterParamDisplay(unsigned char v)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p;
    for (p = r; p < r + 9; p++)
        *p = 0;
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[3] = 0;
    r[4] = 1;
    r[5] = v;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_RegisterValueDisplay(unsigned char a, unsigned char c)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p;
    for (p = r; p < r + 9; p++)
        *p = 0;
    SeMenu_LoadMasterPtr(&m);
    r[0] = 0x80;
    r[1] = m;
    r[2] = 0x10;
    r[3] = a;
    r[4] = 1;
    r[5] = c;
    SeMenu_FlushDisplayObj(r);
}

void SeEasy_SendParamValue(unsigned char row, unsigned char *val)
{
    unsigned char m;
    unsigned char r[9];
    unsigned char *p;
    for (p = r; p < r + 9; p++)
        *p = 0;
    SeMenu_LoadMasterPtr(&m);
    r[0] = 136;
    r[1] = m;
    r[2] = 11;
    r[3] = row - 1;
    r[4] = *val;
    r[5] = 255;
    SeMenu_FlushDisplayObj(r);
}

void SeMenu_InitDisplayColumn(unsigned char a, unsigned char c)
{
    unsigned char r[9];
    unsigned char *p;
    for (p = r; p < r + 9; p++)
        *p = 0;
    r[0] = 0x80;
    r[1] = 0;
    r[2] = 0xb;
    r[3] = a;
    r[4] = 1;
    r[5] = c;
    SeMenu_FlushDisplayObj(r);
}

