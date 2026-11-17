/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_7b.c (2026-11-16-45-p6-r9)
   sha256 097b93aed5fed7ce6eda526577e71a202b77bb96f3419f35ae2221cf3a33ea28 (tar-sha256); compiled at -O3 -Xr
   cc900-name: AccVoice_BCBD_Helper2=AccVoice_BarCounterBytecodeData_Helper2 */
extern unsigned char __near ram_33e0;
extern unsigned char __near ram_3421;
extern unsigned char __near ACC_LANE_MEASURE[];
extern unsigned int __near ACC_LANE_BLOCK[];
extern unsigned int __near ACC_LANE_READ_POS[];
extern unsigned int AccVoice_GetMeasureStartBlock(int, int, int);
extern unsigned int AccVoice_BCBD_Helper2(int, int, int);
void AccVoice_BarCounterBytecodeData(void)
{
    ram_33e0 = 0;
    ACC_LANE_BLOCK[0] = AccVoice_GetMeasureStartBlock(ram_3421, 0, ACC_LANE_MEASURE[0]);
    if (ACC_LANE_BLOCK[0] == 0xfffe) ram_33e0 |= 1;
    ACC_LANE_READ_POS[0] = AccVoice_BCBD_Helper2(ram_3421, 0, ACC_LANE_MEASURE[0]);
    ACC_LANE_BLOCK[2] = AccVoice_GetMeasureStartBlock(ram_3421, 1, ACC_LANE_MEASURE[2]);
    if (ACC_LANE_BLOCK[2] == 0xfffe) ram_33e0 |= 4;
    ACC_LANE_READ_POS[2] = AccVoice_BCBD_Helper2(ram_3421, 1, ACC_LANE_MEASURE[2]);
    ACC_LANE_BLOCK[3] = AccVoice_GetMeasureStartBlock(ram_3421, 2, ACC_LANE_MEASURE[3]);
    if (ACC_LANE_BLOCK[3] == 0xfffe) ram_33e0 |= 8;
    ACC_LANE_READ_POS[3] = AccVoice_BCBD_Helper2(ram_3421, 2, ACC_LANE_MEASURE[3]);
    ACC_LANE_BLOCK[4] = AccVoice_GetMeasureStartBlock(ram_3421, 3, ACC_LANE_MEASURE[4]);
    if (ACC_LANE_BLOCK[4] == 0xfffe) ram_33e0 |= 0x10;
    ACC_LANE_READ_POS[4] = AccVoice_BCBD_Helper2(ram_3421, 3, ACC_LANE_MEASURE[4]);
    ACC_LANE_BLOCK[5] = AccVoice_GetMeasureStartBlock(ram_3421, 4, ACC_LANE_MEASURE[5]);
    if (ACC_LANE_BLOCK[5] == 0xfffe) ram_33e0 |= 0x20;
    ACC_LANE_READ_POS[5] = AccVoice_BCBD_Helper2(ram_3421, 4, ACC_LANE_MEASURE[5]);
    ACC_LANE_BLOCK[1] = 0xfffe;
    ACC_LANE_READ_POS[1] = 6;
    ram_33e0 |= 2;
}
