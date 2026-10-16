-- Measure the tick rate of the two firmware time counters and dump the kernel's
-- task-control-block pointer table, read-only. Output: $TMPDIR/rate_probe.log
local M=manager.machine; local sp=M.devices[":maincpu"].spaces["program"]
local out=io.open((os.getenv("TMPDIR") or "/tmp").."/rate_probe.log","w")
local function L(s) out:write(s.."\n"); out:flush() end
local samples={}
emu.register_periodic(function()
  local t=M.time:as_double()
  for _,ts in ipairs({4,14}) do
    if t>ts and not samples[ts] then
      samples[ts]={t=t, k=sp:read_u32(0x500D3C68), ms=sp:read_u32(0x50151C0C)}
      L(string.format("t=%.4f  kernel(0x500D3C68)=%d  timebase(0x50151C0C)=%d", t, samples[ts].k, samples[ts].ms))
      if ts==14 then
        local a,b=samples[4],samples[14]; local dt=b.t-a.t
        L(string.format("rates: 0x500D3C68 %.1f /s ; 0x50151C0C %.1f /s ; timebase/emulated-ms = %.4f", (b.k-a.k)/dt, (b.ms-a.ms)/dt, b.ms/(b.t*1000)))
        for id=0,15 do L(string.format("TCB[%2d] @0x%08X = 0x%08X", id, 0x50380000+id*4, sp:read_u32(0x50380000+id*4))) end
        L(string.format("cur task 0x5038002C = 0x%08X", sp:read_u32(0x5038002C)))
        M:exit()
      end
    end
  end
end)
