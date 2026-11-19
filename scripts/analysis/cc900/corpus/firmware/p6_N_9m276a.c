/* lane_p6 helper N, round 9, form a: module 276 (ui/ui_mode_handlers.s), new function.
   MainCPU_self_test_routines: sets bit 1 of port 0x30 and, unless bit 0 is set, runs the factory self tests,
   each passing its error byte on to the next (DRAM, SRAM; program / table ROMs; rhythm, custom data ROMs, LCD
   controller, video RAM) and blinks the result after each group.  The tests are written inside the `if`, so the
   last call stays the ROM's `call; ret`.
   cc900-options: -O3 -Xr
*/
/* cc900-module: A_Short_Pause Report_test_result_by_blinking_LED Test_Custom_data_ROM_IC19 Test_DRAM_IC10_and_IC9 Test_LCD_Controller_IC206 Test_PROGRAM_and_TABLE_DATA_ROMs Test_Rhythm_data_ROM_IC14 Test_SRAM_IC21 Test_Video_RAM_IC207 */
/* cc900-name: Test_PROGRAM_and_TABLE_DATA_ROM=Test_PROGRAM_and_TABLE_DATA_ROMs */
/* cc900-name: Report_test_result_by_blinking=Report_test_result_by_blinking_LED */

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
