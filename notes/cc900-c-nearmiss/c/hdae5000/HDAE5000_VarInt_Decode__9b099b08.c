/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_varint.c (2026-11-17-5-hd-r38-ports)
   sha256 9b099b08d929133648b8fae95404ed00d7b6d7a21f60cdc5e5618f5ef98808ac (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
long HDAE5000_VarInt_Decode(unsigned char *p, unsigned char *count)
{
    int i;
    unsigned long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7f;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}
