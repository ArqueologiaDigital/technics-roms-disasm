/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_9m276a.c (2026-11-19-75-p6-r54)
   sha256 c5f2f6e2b68e051fdb8c596c5ea5e086e97ca92d2b988cc28c5480cb5ff63937 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: Report_test_result_by_blinking=Report_test_result_by_blinking_LED
   cc900-name: Test_PROGRAM_and_TABLE_DATA_ROM=Test_PROGRAM_and_TABLE_DATA_ROMs */
extern unsigned char __tiny ram_30;
extern unsigned char Test_DRAM_IC10_and_IC9(unsigned int);
extern unsigned char Test_SRAM_IC21(unsigned int);
extern unsigned char Test_PROGRAM_and_TABLE_DATA_ROM(unsigned int);
extern unsigned char Test_Rhythm_data_ROM_IC14(unsigned int);
extern unsigned char Test_Custom_data_ROM_IC19(unsigned int);
extern unsigned char Test_LCD_Controller_IC206(unsigned int);
extern unsigned char Test_Video_RAM_IC207(unsigned int);
extern void Report_test_result_by_blinking(unsigned int);
extern void A_Short_Pause(void);
void MainCPU_self_test_routines(void)
{
	ram_30 |= 0x02;
	if (!(ram_30 & 0x01)) {
		Report_test_result_by_blinking(Test_SRAM_IC21(Test_DRAM_IC10_and_IC9(0)));
		A_Short_Pause();
		Report_test_result_by_blinking(Test_PROGRAM_and_TABLE_DATA_ROM(0));
		Report_test_result_by_blinking(Test_Video_RAM_IC207(Test_LCD_Controller_IC206(
			Test_Custom_data_ROM_IC19(Test_Rhythm_data_ROM_IC14(0)))));
	}
}
