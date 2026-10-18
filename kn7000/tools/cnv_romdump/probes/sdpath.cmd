# sdpath.cmd -- DISK MENU > STYLE CONVERT > OK on sdpath_probe, then dump its result area
# (0x502E0000..0x502E13FF) to res.bin beside cmd.txt and print the result words, the SD device
# entry 0x50007A20 and the live volume record
wait 30
press CPR_SEG1 04
wait 4
press CPL_SEG0 20
wait 6
press CPR_SEG6 01
wait 30
snap
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for i=0,10 do r[#r+1]=string.format("%08x", sp:read_u32(0x502E0000+4*i)) end; emu.print_error("PROBE "..table.concat(r," ").." end "..string.format("%08x", sp:read_u32(0x502E07FC)))
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local f=io.open(os.getenv("REMOTE_CMD"):gsub("cmd%.txt$","res.bin"),"wb"); for a=0x502E0000,0x502E13FF do f:write(string.char(sp:read_u8(a))) end; f:close(); emu.print_error("PROBE res.bin written")
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for a=0x50007A20,0x50007A47 do r[#r+1]=string.format("%02x", sp:read_u8(a)) end; emu.print_error("PROBE DEVC "..table.concat(r," "))
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for a=0x50149730,0x5014976F do r[#r+1]=string.format("%02x", sp:read_u8(a)) end; emu.print_error("PROBE VOL "..table.concat(r," "))
