/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_10b.c (2026-11-16-72-p6-r13)
   sha256 c96afdd079443701549600468468164e587ead92655c2f88956f981bfebafa17 (tar-sha256); compiled at -Xr */
extern unsigned char SoundRam_Id_KN5000[];
extern unsigned char SoundRam_Id_KN1500[];
extern unsigned char SoundRam_Id_KN3000[];
extern unsigned char SoundRam_Id_KN2000[];
extern unsigned char SoundRam_Id_MKA[];
extern unsigned char SoundRam_Id_MKB[];
unsigned char SoundRam_IdentifyImage(unsigned char *p)
{
    unsigned int i;
    unsigned char *q;
    i = 0;
    q = SoundRam_Id_KN5000;
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 6;
    i = 0;
    q = SoundRam_Id_KN1500;
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 5;
    i = 0;
    q = SoundRam_Id_KN3000;
    for (; i < 16; i++)
        if (p[i] != q[i])
            break;
    if (i == 16)
        return 4;
    i = 0;
    q = SoundRam_Id_KN2000;
    for (; i < 6; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 6)
        return 1;
    i = 0;
    q = SoundRam_Id_MKA;
    for (; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 2;
    i = 0;
    q = SoundRam_Id_MKB;
    for (; i < 3; i++)
        if (p[i + 5] != q[i])
            break;
    if (i == 3)
        return 3;
    return 0;
}
