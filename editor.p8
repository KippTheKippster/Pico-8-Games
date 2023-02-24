pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--printh("a = { 'hehe ha!', 'kdasop'}",'test_save.txt', true)
#include engine.p8

background_color = 1
render = true
update = true
camera_x = 0
camera_y = 0

menu = active:new{}
menu:add()

function menu:update()
	print("bruh",32,32, 13)
end

pcontrol = control:new{}
pcontrol.x = 0
pcontrol.y = 0
pcontrol.w = 32
pcontrol.h = 12
pcontrol.hovering = false
pcontrol.pressing = false
pcontrol.cursor = 1
pcontrol.tc = 7
pcontrol.bg = 1
pcontrol.flat = false
pcontrol.hover_bg = 13
pcontrol.normal_bg = 13
pcontrol.pressing_bg = 13
pcontrol.border_c = 0
pcontrol.border_w = 1
pcontrol.text = "control"
pcontrol.children = {}
pcontrol.parent = nil
pcontrol.coll = true

function pcontrol:draw(x,y)
	self:render(x,y)
end

function pcontrol:render(x, y)
	if self:is_visible() == false then
		return
	end

	if self.flat == false then
		rectfill
		(
		x + self.x, y + self.y,
		x + self.x + self.w, y + self.y + self.h,
		self.bg
		)
		
	--	rect
		--(
		--x + self.x, y + self.y,
		--x + self.x + self.w, y + self.y + self.h,
		--self.border_c
	--	)
	end
	
	text = print(self.text,
		x + self.x 
		+ self:center_x(),
		y + self.y
		+ self:center_y(),
		self.tc
	) 
	
	self.bg = self.normal_bg
end

function pcontrol:hover()
	self.bg = self.hover_bg
	self.hovering = true
end

function pcontrol:press()
	self.bg = self.pressing_bg
	self.pressing = true
end

function pcontrol:add_child(o)
	local t = {}
	for i = 1, #self.children do
		t[i] = self.children[i]
	end
	t[#self.children + 1] = o
	self.children = t
	o.parent = self
end

function pcontrol:is_visible()
	local c = self
	
	if c.visible == false then
		return false
	end
	
	while c.parent ~= nil do
		c = c.parent
		
		if c.visible == false then
			return false
		end
	end
	
	return true
end

function pcontrol:click() end

function pcontrol:center_x()
	return (self.w/2)-(#self.text*4)/2+1
end	

function pcontrol:center_y()
	return (self.h/2)-2
end	

button = pcontrol:new{}
button.hover_bg = 6
button.normal_bg = 13
button.pressing_bg = 7
button.cursor = 2
button.text = "button"


container = pcontrol:new{}
container.flat = true
container.cursor = 1
container.text = ""
container.coll = false

function container:draw(x, y)
	self:render(x,y)
	self:sort()
end

function container:sort() end

vcontainer = container:new{}

function vcontainer:sort()
	local h = 0
	local w = 0
	for i = 1, #self.children do
		local c = self.children[i]
		c.y = self.y + h 
		c.x = self.x
		w = max(w, c.w + 0)
		h += c.h + 1
	end
	self.h = h
	self.w = w
end

hcontainer = container:new{}

function hcontainer:sort()
	local h = 0
	local w = 0
	for i = 1, #self.children do
		local c = self.children[i]
		c.x = self.x + w 
		c.y = self.y
		h = max(h, c.h + 1)
		w += c.w + 1
	end
	self.h = h
	self.w = w
end

dropdown = button:new{}
dropdown.c = nil
dropdown.text = "dropdown"
dropdown.show = false

function dropdown:ready()
	self.c = vcontainer:new{}
	self.c:add()
	self:add_child(self.c)
	self.c.visible = false
end

function dropdown:click()
	self.show = self.show == false
end

function dropdown:draw(x, y)
	self:render(x, y)	
	
	self.c.y = self.y + self.h + 1
	self.c.x = self.x
	
	local h = mouse:checkcoll(self.c)
	if h == false then
		h = mouse:checkcoll(self)
	end
	
	if h == true and self.show == true then
		self.c.visible = true
	else
		self.c.visible = false
		self.show = false
	end
end
-->8
--mouse
mouse = entity:new{}
mouse.sprite = 1
mouse.focus = nil
mouse.w = 2
mouse.h = 2
mouse.i = 0

function mouse:ready()
	poke(0x5f2d, 1) --activates cursor
end

mouse:add()

function mouse:update()
	self.x = stat(32)-1
	self.y = stat(33)-1
	self:iscoll()
	self:input()
end

function mouse:checkcoll(ent)
	if     
	ent:is_visible() and
	self.x < ent.x + ent.w and
	self.x + self.w > ent.x and
	self.y < ent.y + ent.h and
	self.h + self.y > ent.y 
	then
		return true
	else
		return false
	end
end

--goes through all entities and checks if it is colliding with any of them
function mouse:iscoll(tag)
	for i = 1, #controls do
		local q = #controls - i+1
		local ent = controls[q]
		
		if ent.coll == true and self:checkcoll(ent) then
			ent:hover()
			self.sprite = ent.cursor
			if self.focus == ent then
				ent.hovering = true
			elseif self.focus ~= nil then
				self.focus.hovering = false
			end
			
			self.focus = ent
			return
		end
		
		if self.focus ~= nil then
				self.focus.hovering = false
		end
		
	end
	self.sprite = 1
	self.focus = nil
end

function mouse:input()
	local i = stat(34)
	local click = false
	if self.i == 1 and i ~= 1 then
		click = true
	end
	self.i = i
	
	if self.focus == nil then
		return
	end
	
	if i == 1 then
		self.focus:press()	
	end
	
	if click == true then
		self.focus:click()
	end
end
-->8
--spawn
button1 = button:new{}
button1:add()
button1.x = 64
button1.y = 64
button1.w = 64
button1.h = 24
button1.flat = false

function button1:click()
	print(self.children[1])
end

button2 = button:new{}
button2:add()
button2.x = 24
button2.y = 32
button2.w = 48
button2.h = 8

b4 = button:new{}
b4.text = "b4"
b4:add()

function button2:click()
	print("bruh")
end

d = dropdown:new{}
d.x = 90
d.y = 12

b1 = button:new{}
b1.text = "b1"
b1:add()
b2 = button:new{}
b2.text = "b2"
b2:add()
b3 = button:new{}
b3.text = "b3"
b3:add()

d:add()
d.c:add_child(b1)
d.c:add_child(b2)
d.c:add_child(b3)

c = vcontainer:new{}
c.w = 64
c.y = 16
c.normal_bg = 4
c:add()
c:add_child(button1)
c:add_child(b4)
c:add_child(d)
c:add_child(button2)

h = hcontainer:new{}

b5 = button:new{}
b5.text = "b5"
b5.w = 2
b5:add()

h:add()

h:add_child(c)
h:add_child(b5)

__gfx__
78000087010000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87800878171000000171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08788780177100000171101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00877800017710001171717100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00877800017771007177777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08788780001777111777777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
87800878001777710177777100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78000087000171100017771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
