pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--base objects

--entities table, saves all the entities
actives = {}
entities = {}
controls = {}
destroy_queue = {}

--base object
active = {}
active.pausable = true

--creates an entity, used for subclasses to become an entity 
function active:new(o)
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
   
	return o
end

--adds the entity to the 'entities' list
function active:add()
	add(actives, self)
	self:ready()
end

--adds the entity to the '_queue'
function active:destroy()
	add(destroy_queue, self)
end

--override functions
function active:update() end
function active:ready() end 

--starts a timer that will call the function 'func' argument (the function arg must have a 'self' argument, EX: function my_object.my_function(this))
function active:start_timer(time, func)
	local t = timer:new{}
	t.maxtime = time
	t.time = time
	t.parent = self
	t.func = func
	t:add()
end
	
--timer object, can be created like any other active, but should be created with the active:start_timer() function
timer = active:new{}
timer.time = 0
timer.maxtime = 10
timer.parent = {}
timer.func = {}
	
function timer:update()
	if self.time > 0 then
		self.time -= 1
		if self.time <= 0 then
			self.func(self.parent)
			self:destroy()
		end
	end
end
	
function timer:start()
	self.time = self.maxtime
end

--entity, a visual and positional active
entity = active:new{}
entity.x = 0
entity.y = 0
entity.w = 8
entity.h = 8
entity.sprite = 1
entity.sprite_w = 1
entity.sprite_h = 1
entity.flip_h = false
entity.flip_v = false
entity.visible = true
entity.tag = ""
entity.groups = active:new{}
entity.color = -1

function entity:add()
	add(actives, self)
	add(entities, self)
	self:ready()
end

--returns true if the entity collides with an other entity
function entity:checkcoll(ent)
	if     
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
function entity:iscoll(tag)
	for i = 1, #entities do
		local ent = entities[i]
		
		if self:checkcoll(ent) then
			if ent ~= self and (ent:is_in_group(tag) or tag == nil or tag == '') then
				return ent
		 end
		end
	end
	
	return false
end

--goes through all entities and returns all the entities it is colliding with self
function entity:getcoll(tag)
	local ents = {}

	for i = 1, #entities do
		local ent = entities[i]
		
		if self:checkcoll(ent) then
   if ent ~= self and (ent:is_in_group(tag) or tag == nil or tag == '') then
 			add(ents, ent)
		 end
		end
	end

	return ents
end

--checks if the entity collides with a tile, o_x and o_y are the offset on the respective axis
function entity:tilecoll(o_x, o_y)
	local c_x = (self.x + o_x) / 8
	local c_y = (self.y + o_y) / 8

	if 
		fget(mget(c_x, c_y), 0) or
		fget(mget(c_x + 0.9, c_y), 0) or
		fget(mget(c_x, c_y + 0.9), 0) or
		fget(mget(c_x + 0.9, c_y + 0.9), 0)
	then
		return true
	else
		return false
	end
end


function entity:is_in_group(g)
	for i = 1, #self.groups do
		if g == self.groups[i] then
			return true
		end
	end

	return false
end

function entity:add_animation_player()
	self.anim_player = anim_player:new()
	self.anim_player.parent = self
	self.anim_player:add()
end

--control
control = active:new{}
control.visible = true

function control:add()
	add(active, self)
	add(controls, self)
	self:ready()
end

function control:draw(x, y) end

animation = 
{ 
	fps = 0, 
	start = 2,
	length = 2,
	name = "name"
}

function animation:new(o)
	local o = o or {}
	setmetatable(o, self)
	self.__index = self
   
	return o
end

anim_player = active:new{}
anim_player.time = 0
anim_player.animations = {}
anim_player.frame = 0
anim_player.parent = {}

function anim_player:update()
	self.time += 1

	if self.time >= self.current_animation.fps then
		self:frame_update()
		self.time = 0
	end
end

function anim_player:frame_update()
	self.parent.sprite = self.current_animation.start + self.frame
	self.frame += 1

	if self.frame >= self.current_animation.length then
		self.frame = 0
	end
end

function anim_player:new_animation(name, fps, start, length)
	local a = animation:new()
	a.fps = fps
	a.start = start
	a.length = length
	self.animations[name] = a
end

function anim_player:set_animation(name)
	if self.current_animation ~= self.animations[name] then 
		self.current_animation = self.animations[name]
		self.frame = 0
		self.time = 0
		self:frame_update()
	end
end

--table functions
table = {}

function table.move(tb, object, position)
	for i = 1, #tb do
		if tb[i] == object then
			tb[i] = tb[i + position] --sets the current position to the object that is occupying the wanted position
			tb[i + position] = object --sets the wanted position to the wanted object
		end
	end
end


-->8
--engine/drawing
camera_x = 0
camera_y = 0
background_color = 15
render = true
update = true

console = control:new{}
--console:add()
console.texts = {}
console.ptexts = {}
console.o_x = 4
console.o_y = 16
console.color = 0
--local texts = {}

--function console:draw(x, y)
--	--print out texts, a way for all functions to print
--	for i = 1, #self.texts do
--		print(self.texts[1], x + self.o_x, y + (i) * 8 + self.o_y, self.color)
--		del(self.texts, self.texts[1])
--	end
--
--	for i = 1, #self.ptexts do
--		print(self.ptexts[i], x + self.o_x, y + (i) * 8 + self.o_y, self.color)
--	end
--end

--function write(text)
--	add(console.texts, text)
--end

--function pwrite(text)
--	add(console.ptexts, text)
--end

function _update60()
	if (render) then
		cls(background_color)
		camera(camera_x, camera_y)
		map(0, 0, 0,0 , camera_x/8+17, camera_y/8+17)
	else
		camera_x = 0
		camera_y = 0 
		camera(0, 0)
	end

	--draw controls, draws before camera active movement happens
	for i = 1, #controls do
		local con = controls[i]
		if con.visible == true then
			con:draw(camera_x, camera_y)
		end
	end

	--updates actives
	for i = 1, #actives do
		local act = actives[i]
		
		if (update == false and act.pausable == true) then
			goto con
		end
		
		act:update()
		
		::con::
 end

	--draws entities
	if render then
		for i = 1, #entities do
			local ent = entities[i]
			if ent.visible then
				if ent.color > -1 then
					for j = 1, 16 do
						pal(j, ent.color)
					end
				end
				spr(ent.sprite, ent.x, ent.y, ent.sprite_w, ent.sprite_h, ent.flip_h, ent.flip_v)
				pal()
			end	
		end
	end
	 
	--remove object that are in the destroy_queue
	for i = 1, #destroy_queue do
		del(actives, destroy_queue[1])
		del(entities, destroy_queue[1])
		del(controls, destroy_queue[1])
		del(destroy_queue, destroy_queue[1])
	end
end

