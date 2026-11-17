/* Phase 6, lane_p6 helper C, round 22, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form b
   of Flash_InitBytecodeBlock (form a, p6_C_22m159a.c, explains the one spot left): the column local declared before
   the result, both unsigned int. */
/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_AssignSlotsToBlocks Flash_CopyBlocksToSlots Flash_InitBytecodeBlock_Helper4 Flash_InitBytecodeBlock_Helper5 Flash_InitBytecodeBlock_Helper6 Flash_InitBytecodeBlock_Helper7 Flash_InitExtMemAddrs Flash_SlotUpdateOpsBlock Flash_StoreBaseAndInitAccPatch Flash_StoreBaseAndInitAccPatch_Sub Flash_WriteBackSlotTable Flash_WriteSlotOwnerMap NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store PartGrid_ColumnDispatch Flash_InitBytecodeBlock_Helper10 Flash_InitBytecodeBlock_Helper11 */
/* (module_calls.py prints the line without the two Helper1x; the ROM reaches both by calr, at 0xf16d6f and
   0xf16d72, and modules_v10.tsv puts both in module 159, so they are added here.) */
/* cc900-name: FIBB_Helper10=Flash_InitBytecodeBlock_Helper10 */
/* cc900-name: FIBB_Helper11=Flash_InitBytecodeBlock_Helper11 */
/* cc900-name: FlashStoreBaseSub=Flash_StoreBaseAndInitAccPatch_Sub */

struct styleimg { unsigned int w[0xb400]; };
typedef struct styleimg *imgp;

extern imgp __near RHYTHM_PATTERN_BUF_PTR;
extern imgp __near STYLE_WORK_IMAGE_PTR;
extern imgp __near STYLE_SRC_IMAGE_PTR;
extern imgp __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near ram_35b0;
extern unsigned int __near ram_6d4[];
extern unsigned int __near ram_73a[];
extern unsigned char __near ram_c68;
extern unsigned char __near ram_c6a;
extern unsigned char __near ram_c6c;
extern unsigned char MSP_Default_ChannelMap[][3];
extern unsigned char MSP_Default_GroupIndexPad[];

extern void Flash_InitExtMemAddrs(void);
extern void DualVoice_ScanAllColumns(int);
extern void DualVoice_ScanAllColumnsAlt(int);
extern unsigned char NoteEvent_Store(int);
extern void NoteEventBuffer_CopyToSlot(int);
extern void AccPatch_CountSlotsAlt(void);
extern void AccPatch_InitFromSlotIndex(void);
extern void DualVoice_ParamLoadDone(void);
extern void AccPatch_RecountFreeSlots(void);
extern void Flash_StoreBaseAndInitAccPatch(void);
extern void NoteEventBuffer_Store(int);
extern void Flash_WriteBackSlotTable(void);
extern int Flash_SlotUpdateOpsBlock(int);
extern void Flash_AssignSlotsToBlocks(int);
extern void FlashStoreBaseSub(int);
extern void Flash_WriteSlotOwnerMap(int);
extern void Flash_CopyBlocksToSlots(void);
extern void TmFlash_CopyToExtMem(void);
extern void Flash_InitBytecodeBlock_Helper4(void);
extern void Flash_InitBytecodeBlock_Helper5(void);
extern void Flash_InitBytecodeBlock_Helper6(void);
extern void Flash_InitBytecodeBlock_Helper7(void);
extern imgp PartGrid_ColumnDispatch(int);
extern void FIBB_Helper10(int);
extern void FIBB_Helper11(void);

unsigned char Flash_InitBytecodeBlock(unsigned char a, unsigned char c)
{
    unsigned char ret, v, idx, found;
    unsigned char i;
    unsigned int k, r;
    ret = 0;
    found = 0;
    Flash_InitExtMemAddrs();
    if (a < 10) {
        DualVoice_ScanAllColumns(a);
        DualVoice_ScanAllColumnsAlt(c);
        v = NoteEvent_Store(c);
        NoteEventBuffer_CopyToSlot(v);
        AccPatch_CountSlotsAlt();
        idx = MSP_Default_GroupIndexPad[c];
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        i = 0;
        do {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][idx];
            AccPatch_InitFromSlotIndex();
        } while (++i < 10);
        STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
        STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        ram_35b0 &= ~1;
        i = 0;
        do {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][a];
            STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i][idx];
            DualVoice_ParamLoadDone();
            if ((int)ram_35b0 & 1) {
                found = 1;
                break;
            }
        } while (++i < 10);
        AccPatch_RecountFreeSlots();
        if (found == 0) {
            if (ram_6d4[0] == 0xffff && ram_6d4[1] == 0xffff) {
                Flash_StoreBaseAndInitAccPatch();
                NoteEventBuffer_Store(v);
                if (ram_73a[0] != 0xffff || ram_73a[1] != 0xffff) Flash_WriteBackSlotTable();
            } else {
                r = Flash_SlotUpdateOpsBlock(c);
                k = c;
                if (r == 0) {
                    Flash_AssignSlotsToBlocks(k);
                    FlashStoreBaseSub(idx);
                    Flash_StoreBaseAndInitAccPatch();
                    NoteEventBuffer_Store(v);
                    Flash_WriteSlotOwnerMap(c);
                    Flash_CopyBlocksToSlots();
                    TmFlash_CopyToExtMem();
                } else {
                    Flash_InitBytecodeBlock_Helper4();
                    Flash_InitBytecodeBlock_Helper5();
                    Flash_InitBytecodeBlock_Helper6();
                    Flash_InitBytecodeBlock_Helper7();
                    ret = 2;
                    ram_c68 = a;
                    ram_c6a = c;
                    ram_c6c = idx;
                }
            }
        } else {
            ret = 1;
        }
    } else {
        DualVoice_ScanAllColumns(a);
        DualVoice_ScanAllColumnsAlt(c);
        *STYLE_WORK_IMAGE_PTR = *RHYTHM_PATTERN_BUF_PTR;
        idx = MSP_Default_GroupIndexPad[a];
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        i = 0;
        do {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][c];
            AccPatch_InitFromSlotIndex();
        } while (++i < 10);
        STYLE_SRC_IMAGE_PTR = PartGrid_ColumnDispatch(a);
        STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        ram_35b0 &= ~1;
        i = 0;
        do {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][idx];
            STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i][c];
            DualVoice_ParamLoadDone();
            if ((int)ram_35b0 & 1) {
                found = 1;
                STYLE_SRC_IMAGE_PTR = STYLE_DST_IMAGE_PTR;
                STYLE_COPY_SRC_SECTION = STYLE_COPY_DST_SECTION;
                AccPatch_InitFromSlotIndex();
                break;
            }
        } while (++i < 10);
        if (found == 0) {
            if (ram_6d4[0] == 0xffff && ram_6d4[1] == 0xffff) {
                *RHYTHM_PATTERN_BUF_PTR = *STYLE_WORK_IMAGE_PTR;
            } else {
                FIBB_Helper10(c);
                FIBB_Helper11();
                ret = 2;
                ram_c68 = a;
                ram_c6a = c;
                ram_c6c = idx;
            }
        } else {
            ret = 1;
        }
    }
    if (ret == 2) {
        ram_c68 = a;
        ram_c6a = c;
        ram_c6c = idx;
    }
    AccPatch_RecountFreeSlots();
    return ret;
}
