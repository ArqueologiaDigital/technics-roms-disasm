# (and the mode twin just above them: EVT_CHANGE_MODE, param NAKA_MODE_MD_PS + A)
# The two routines that open a title by its index (ui/ui_control_panel.s): they post
# EVT_CHANGE_TITLE / EVT_INTERRUPT_TITLE with param TITLE_PS + A.  Neither changes a mode or
# sends a sound command.
s/\bUI_PostModeChangeEvent\b/UI_ChangeTitleByIndex/g
s/\bSoundCtrl_SendCommand\b/UI_InterruptTitleByIndex/g
s/\bUI_PostPartChangeEvent\b/UI_ChangeModeByIndex/g
