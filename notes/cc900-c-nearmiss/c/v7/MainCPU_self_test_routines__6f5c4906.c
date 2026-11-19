/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers_m276.c (2026-11-19-92-p6-r57)
   sha256 6f5c490674c848cd04c2727598dab8cd99fd0e63c1bf71a3c9fb6260174693d0 (tar-sha256); compiled at -O3 -Xr
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
