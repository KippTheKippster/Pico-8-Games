pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
local dis = 21
local rot = 0
local x = 32
local y = 32

function _update60()
	cls(1)

	if(btn(2)) then --back
		--dis = dis - 0.1
		x = x + cos(rot)
		y = y + sin(rot)
	end
	if(btn(3)) then --forward
		--dis = dis + 0.1
		x = x - cos(rot)
		y = y - sin(rot)
	end
	if(btn(1)) then --right
		rot = rot + 0.005
	end
	if(btn(0)) then --left
		rot = rot - 0.005
	end
	
	local d =((x-32)^2+(y-48)^2)^0.5
	local dx = x - 32
	local dy = y - 32
	local r = 16*cos(rot)
	print(d .. " x : " .. x .. " y : " .. y)

	line(d * r,50-d, 
						d * r, 50 + d)
end	

function _init()
	cls(1)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
