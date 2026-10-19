wait 30
lua local sp=manager.machine.devices[":maincpu"].spaces["program"]; local s,cur,start={}, {}, nil; for a=0x50001100,0x50001400 do local b=sp:read_u8(a); if b>=32 and b<127 then if not start then start=a end; cur[#cur+1]=string.char(b) else if #cur>=3 then s[#s+1]=string.format("%08X %s",start,table.concat(cur)) end; cur={}; start=nil end end; for _,l in ipairs(s) do emu.print_error("STR "..l) end
exit
