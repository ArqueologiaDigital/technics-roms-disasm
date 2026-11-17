/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_varint.c (2026-11-17-5-hd-r38-ports)
   sha256 9b099b08d929133648b8fae95404ed00d7b6d7a21f60cdc5e5618f5ef98808ac (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: VarEnc_d=HDAE5000_VarInt_Encode */
long VarEnc_d(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;
    unsigned long v;

    v = value;
    n = 0;
    do {
        tmp[n] = v % 128;
        v /= 128;
        n++;
    } while (v != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}
