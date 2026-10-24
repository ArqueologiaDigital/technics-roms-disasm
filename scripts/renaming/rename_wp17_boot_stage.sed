# rename_wp17_boot_stage.sed -- WP17 review: RAM 0x0400 is a boot-progress byte, not only the NMI guard
# (LC_ALL=C sed -i -f, or scripts/renaming/apply_word_renames.py; the .s files hold raw high bytes).
# Boot_PostSelfTest stores 2 before TaskSched_Init and 3 after it, Boot_DisplayScreen 6 after the first
# screen group and 0x80 after the last; NMI_ClearGuardAndHalt stores 0.  Only NMI_StorePayloadChecksums
# reads it (`cp (..), 128`): 0x80 is the final stage, boot complete with the power-fail save armed.
s/\<NMI_GUARD\>/BOOT_STAGE/g
