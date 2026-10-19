# sdraw.cmd -- DISK MENU > STYLE CONVERT > OK on sdraw_probe, then dump its result area
# (0x502E0000..0x502E65FF) to res.bin beside cmd.txt and print the result words and the live
# volume record / cache-buffer headers
wait 30
press CPR_SEG1 04
wait 4
press CPL_SEG0 20
wait 6
press CPR_SEG6 01
wait 30
snap
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for i=0,15 do r[#r+1]=string.format("%08x", sp:read_u32(0x502E0000+4*i)) end; emu.print_error("PROBE "..table.concat(r," ").." end "..string.format("%08x", sp:read_u32(0x502E07FC)))
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local f=io.open(os.getenv("REMOTE_CMD"):gsub("cmd%.txt$","res.bin"),"wb"); for a=0x502E0000,0x502E65FF do f:write(string.char(sp:read_u8(a))) end; f:close(); emu.print_error("PROBE res.bin written")
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local r={} for a=0x50149730,0x5014976F do r[#r+1]=string.format("%02x", sp:read_u8(a)) end; emu.print_error("PROBE VOL "..table.concat(r," "))
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; for i=0,9 do local b=0x50149850+i*0x21C; emu.print_error(string.format("PROBE BUF%d dev=%08x sec=%08x x8=%08x xc=%08x cnt=%04x lru=%04x st=%08x fl=%02x tag=%02x %02x", i, sp:read_u32(b), sp:read_u32(b+4), sp:read_u32(b+8), sp:read_u32(b+12), sp:read_u16(b+16), sp:read_u16(b+18), sp:read_u32(b+20), sp:read_u8(b+24), sp:read_u8(b+25), sp:read_u8(b+26))) end
