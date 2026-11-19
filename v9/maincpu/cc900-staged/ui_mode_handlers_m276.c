/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: A_Short_Pause Report_test_result_by_blinking_LED Test_Custom_data_ROM_IC19 Test_DRAM_IC10_and_IC9 Test_LCD_Controller_IC206 Test_PROGRAM_and_TABLE_DATA_ROMs Test_Rhythm_data_ROM_IC14 Test_SRAM_IC21 Test_Video_RAM_IC207 */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void MainCPU_self_test_routines(void);

/* cc900-name: Test_PROGRAM_and_TABLE_DATA_ROM=Test_PROGRAM_and_TABLE_DATA_ROMs */
/* cc900-name: Report_test_result_by_blinking=Report_test_result_by_blinking_LED */
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
