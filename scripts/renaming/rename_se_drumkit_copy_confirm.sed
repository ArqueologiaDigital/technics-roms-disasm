# v10 (v9/v7 by harmonize_version_labels.py): the sound editor's "copy the preset drum kit to the USER KIT?" dialog.
# SeMenu_WaveformSelect_Apply draws, from the per-language pointer table, the list for language (0x340E4) up to the
# next one, then the YES / NO buttons; SeMenuTitle_DrawStaticScreen calls it when (1720) = 1.  The five lists' text
# fixes their languages: "ATTENTION! THE SELECTED DRUM KIT WILL BE COPIED TO THE USER KIT. ARE YOU SURE?",
# "ACHTUNG! SIE KOPIEREN EIN PRESET-DRUMKIT ...", "ATTENTION! COPIE DU DRUMKIT VERS LE USER KIT ...",
# "ATENCION! COPIA DEL EQUIPO DE TAMBOR ...", "ATTENZIONE! COPIATURA DEL DRUMKIT ...".  The table's sixth entry is
# the end of the Italian list.  It had nothing to do with a waveform.
s/\bSeMenu_WaveformSelect_Apply_Records2\b/SeMenu_DrumKitCopyConfirm_TextByLanguage/g
s/\bSeMenu_WaveformSelect_Apply_Records\b/SeMenu_DrumKitCopyConfirm_English_Records/g
s/\bSeMenu_WaveformSelect_Apply\b/SeMenu_DrawDrumKitCopyConfirm/g
s/\bSeScreenData_0x4447\b/SeMenu_DrumKitCopyConfirm_YesNo_Records/g
s/\bSeScreenData_0x44F5\b/SeMenu_DrumKitCopyConfirm_German_Records/g
s/\bSeScreenData_0x4560\b/SeMenu_DrumKitCopyConfirm_French_Records/g
s/\bSeScreenData_0x45DE\b/SeMenu_DrumKitCopyConfirm_Spanish_Records/g
s/\bSeScreenData_0x464E\b/SeMenu_DrumKitCopyConfirm_Italian_Records/g
