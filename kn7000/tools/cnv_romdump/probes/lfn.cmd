# lfn.cmd -- DISK MENU > STYLE CONVERT > OK on lfn_probe.s, then print its six result words (0x502E0000)
wait 30
press CPR_SEG1 04
wait 4
press CPL_SEG0 20
wait 6
press CPR_SEG6 01
wait 15
snap
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for i=0,5 do r[#r+1]=string.format("%d", sp:read_u32(0x502E0000+4*i) | 0) end; emu.print_error("PROBE "..table.concat(r," "))
