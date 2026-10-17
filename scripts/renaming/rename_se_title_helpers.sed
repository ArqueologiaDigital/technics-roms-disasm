# The three helpers of the sound editor's title-method dispatch (all trees), named for what they do:
#  - SeMenu_WaveformSelect_Handler: C = 0, A = 0x10, Display_DeferOrDrawWall -- SeTitle_DrawStaticScreen calls it
#    before the title's static-screen routine (draws the wall);
#  - SeMenu_WaveformSelect_Process: C = 7, A = 0x0C, Display_DeferOrUpdateScreen -- called after it;
#  - SeMenu_WaveformSelect_End: a bare `ret`, the entry of every title id no title uses in both tables.
s/\bSeMenu_WaveformSelect_Handler \/ _Process\b/SeTitle_DrawWall \/ SeTitle_UpdateScreen/g
s/\bSeMenu_WaveformSelect_Handler\b/SeTitle_DrawWall/g
s/\bSeMenu_WaveformSelect_Process\b/SeTitle_UpdateScreen/g
s/\bSeMenu_WaveformSelect_End\b/SeTitle_UnusedSlot/g
