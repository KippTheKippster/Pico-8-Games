pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
local rot = 0
local rspd =  0.01
local x = 52
local y = 64

local mp = false

local oldr = 0

local function fwall(px,py, r1, t)
	--spr(2, px, py)
	if(oldr == 0) then
		oldr = r1
	end
	
	dx = px - x
	dy = py - y
	
	dr = r1
	dr = mid(-0.4,dr,0.4)

	
	r = cos(r1)*100
	dis = ((dx^2 + dy^2)^0.5)
	*sin(dr)
	l = (64/dis)*12
 --r = (-r+0.5)*64
	
	
	rectfill(64+r-1, 64 + l,
	64+r+1, 64 - l, t)
	--line(64+r, 64 + l,
	--64+r, 64 - l, t)
	--rectfill(64+r, 64 + l,
	--64+oldr, 64 - l, t)
	oldr = r
end

local function _update60()
	--walk
	if(btn(2)) then --back
		x = x + cos(rot)
		y = y + sin(rot)
	end
	if(btn(3)) then --forward
		x = x - cos(rot)
		y = y - sin(rot)
	end
	if(btn(0)) then --right
		rot = rot + rspd
	end
	if(btn(1)) then --left
		rot = rot - rspd
	end
	
	if(btnp(4)) then --map
		if(mp == true) then
			mp = false
		else
			mp = true
		end
	end
	
	oldr = 0 

	--cast
	cls(1)
	if(mp == true) then
		map(0,0,0,0,128,128)
		spr(1, x, y)
		spr(4, x + 6 * cos(rot),y+6*sin(rot))
	else
	for i = 0, 110 do
		q = i / 220
			for z = 1, 32 do
				_x = flr(x/8 + cos(q + rot - 0.25) * z)
				_y = flr(y/8 + sin(q + rot - 0.25) * z)
				
				local t = mget(_x, _y)
				
				if(t ~= 0) then
					fwall(_x*8,_y*8, q, t)
					break
				end
			end
	end
	
	vx = 56
	vy = 96
	spr(81,0+vx,0+vy)
	spr(82,8+vx,0+vy)
	spr(97,0+vx,8+vy)
	spr(98,8+vx,8+vy)
	spr(113,0+vx,16+vy)
	spr(114,8+vx,16+vy)
	spr(129,0+vx,24+vy)
	spr(130,8+vx,24+vy)
	end
	if(mp == true) then
		camera(x-64,y-64)
	else
		camera(0,0)
	end
end
__gfx__
00000000ccccccccddddddddeeeeeeee00000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc0cc0ccddddddddeeeeeeee00088000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ccccccccd88888ddeeeeeeee00088000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000ccccc0cd88888ddeeeeeeee08888880ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000cccc0ccd88888ddeeeeeeee08888880ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700c00c00ccd88888ddeeeeeeee00088000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc000cccddddddddeeeeeeee00088000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccddddddddeeeeeeee00000000ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005d5d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ddd5d5ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddd5d5d5dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddd5d5d5dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd5dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005ddddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055ddddddddd55f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005555555555555ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f55555555555ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fff555ffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000fffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000fffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000fffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000fffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000ffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0505050505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000003030000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000003030000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000303000000000505050505050505050505050505050505050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000303000000000500000000000000000505000000000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000500000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000500000004040400000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000000000000500000000000000000500000004040404000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505000000000000000505050500000000000000000000000004040404000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005000000000000000000000000000000000000000000000000000404000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005000000000000000000000000000000000000000500000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005000000000000000000000000000000000000000500000000000000030000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005000000000000000000000000000000000000000500000000000000000000000005050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005000000000000000000000000000000000000000500000000000000000000000005000005050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000005050505050505050505050505050505050505050505000000000000000000000000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505050505050000000000000000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505050505050000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050500000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050500000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505000000000000000000000000000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505050000000000000000000000000005050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505050505050000000000000000000505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000050505050505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000