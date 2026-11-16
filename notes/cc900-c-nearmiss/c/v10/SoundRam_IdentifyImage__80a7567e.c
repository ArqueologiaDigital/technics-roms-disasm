/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_10a.c (2026-11-16-72-p6-r13)
   sha256 80a7567efe1755b5949aea01df85573f86e10f9792155872ca4b949d6fa60592 (tar-sha256); compiled at -Xr */
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
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 6;
    i = 0;
    q = SoundRam_Id_KN1500;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 5;
    i = 0;
    q = SoundRam_Id_KN3000;
    do {
        if (p[i] != q[i])
            break;
        i++;
    } while (i < 16);
    if (i == 16)
        return 4;
    i = 0;
    q = SoundRam_Id_KN2000;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 6);
    if (i == 6)
        return 1;
    i = 0;
    q = SoundRam_Id_MKA;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 3);
    if (i == 3)
        return 2;
    i = 0;
    q = SoundRam_Id_MKB;
    do {
        if (p[i + 5] != q[i])
            break;
        i++;
    } while (i < 3);
    if (i == 3)
        return 3;
    return 0;
}
