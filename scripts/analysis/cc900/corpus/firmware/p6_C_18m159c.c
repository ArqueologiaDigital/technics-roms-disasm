/* Phase 6, lane_p6 helper C, round 18, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form c:
   Flash_InitBytecodeBlock (new, memory-to-memory pool, 703 B), DualVoice_LoadAndScan's larger sibling.  For a
   section a and a column c, two mirrored halves:
   - a < 10: scan, store the column's note event, copy the group's ten sections from the work image and compare
     section a against them; no hit: if the slot table at 0x6d4 is empty (two 0xffff words) store the base and the
     event buffer and write back the slot table unless 0x73a is empty too, else either assign the slots (when
     Flash_SlotUpdateOpsBlock gives 0) or run helpers 4..7 and return 2;
   - a >= 10: scan, copy the whole rhythm image to the work image (0xb400 words, ldirw), copy the group of section a,
     compare against the image PartGrid_ColumnDispatch gives; a hit copies that section back; no hit: copy the work
     image back if 0x6d4 is empty, else helpers 10 and 11 and return 2.
   A hit returns 1; on 2 the section, column and group are remembered in 0xc68 / 0xc6a / 0xc6c.  The ROM keeps a and
   c on the stack and the loop counter in QIZH (it saves only QIZ).  The image copies are struct assignments.
   Kept in its own file: the 92,160-byte struct may not compile. */
/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_AssignSlotsToBlocks Flash_CopyBlocksToSlots Flash_InitBytecodeBlock_Helper4 Flash_InitBytecodeBlock_Helper5 Flash_InitBytecodeBlock_Helper6 Flash_InitBytecodeBlock_Helper7 Flash_InitExtMemAddrs Flash_SlotUpdateOpsBlock Flash_StoreBaseAndInitAccPatch Flash_StoreBaseAndInitAccPatch_Sub Flash_WriteBackSlotTable Flash_WriteSlotOwnerMap NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store PartGrid_ColumnDispatch Flash_InitBytecodeBlock_Helper10 Flash_InitBytecodeBlock_Helper11 */
/* (module_calls.py prints the line without the two Helper1x, for a reason not found; the ROM reaches both by calr,
   at 0xf16d6f and 0xf16d72, and modules_v10.tsv puts both in module 159, so they are added here.) */
/* cc900-name: FIBB_Helper10=Flash_InitBytecodeBlock_Helper10 */
/* cc900-name: FIBB_Helper11=Flash_InitBytecodeBlock_Helper11 */

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
extern unsigned char MSP_Default_ChannelMap[];
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
extern void Flash_StoreBaseAndInitAccPatch_Sub(int);
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
    unsigned char found, idx, v, ret;
    unsigned char i;
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
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + idx];
            AccPatch_InitFromSlotIndex();
        }
        STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
        STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        ram_35b0 &= ~1;
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + a];
            STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i * 3 + idx];
            DualVoice_ParamLoadDone();
            if (ram_35b0 & 1) {
                found = 1;
                break;
            }
        }
        AccPatch_RecountFreeSlots();
        if (found == 0) {
            if (ram_6d4[0] == 0xffff && ram_6d4[1] == 0xffff) {
                Flash_StoreBaseAndInitAccPatch();
                NoteEventBuffer_Store(v);
                if (ram_73a[0] != 0xffff || ram_73a[1] != 0xffff) Flash_WriteBackSlotTable();
            } else if (Flash_SlotUpdateOpsBlock(c) == 0) {
                Flash_AssignSlotsToBlocks(c);
                Flash_StoreBaseAndInitAccPatch_Sub(idx);
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
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + c];
            AccPatch_InitFromSlotIndex();
        }
        STYLE_SRC_IMAGE_PTR = PartGrid_ColumnDispatch(a);
        STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        ram_35b0 &= ~1;
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + idx];
            STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i * 3 + c];
            DualVoice_ParamLoadDone();
            if (ram_35b0 & 1) {
                found = 1;
                STYLE_SRC_IMAGE_PTR = STYLE_DST_IMAGE_PTR;
                STYLE_COPY_SRC_SECTION = STYLE_COPY_DST_SECTION;
                AccPatch_InitFromSlotIndex();
                break;
            }
        }
        if (found == 0) {
            if (ram_6d4[0] == 0xffff && ram_6d4[1] == 0xffff) {
                *RHYTHM_PATTERN_BUF_PTR = *STYLE_WORK_IMAGE_PTR;
            } else {
                FIBB_Helper10(c);
                FIBB_Helper11();
                ret = 2;
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
