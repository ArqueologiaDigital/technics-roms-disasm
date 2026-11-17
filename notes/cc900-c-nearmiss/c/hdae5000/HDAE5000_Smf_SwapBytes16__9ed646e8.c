/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_ui_display.c (2026-11-16-78-hd-r15-ports)
   sha256 9ed646e87039a316d16763fc1244357f9123880e28ac2be851fcb215c901ceb4 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x & 0xff;
    return r;
}
