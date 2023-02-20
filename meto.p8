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
function entity:getcoll()
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
control.draw_sprite = false

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

console = control:new{}
console:add()
console.texts = {}
console.ptexts = {}
console.o_x = 4
console.o_y = 16
console.color = 0
--local texts = {}

function console:draw(x, y)
	--print out texts, a way for all functions to print
	for i = 1, #self.texts do
		print(self.texts[1], x + self.o_x, y + (i) * 8 + self.o_y, self.color)
		del(self.texts, self.texts[1])
	end

	for i = 1, #self.ptexts do
		print(self.ptexts[i], x + self.o_x, y + (i) * 8 + self.o_y, self.color)
	end
end

function write(text)
	add(console.texts, text)
end

function pwrite(text)
	add(console.ptexts, text)
end

function _update60()
	if (render) then
		cls(background_color)
		map(0, 0, 0, 0 , 64, 64)
		camera(camera_x, camera_y)
	else
		camera(0, 0)
	end

	--draw controls, draws before camera active movement happens
	for i = 1, #controls do
		local con = controls[i]
			con:draw(camera_x, camera_y)
	end

	--updates actives
	for i = 1, #actives do
		local act = actives[i]
		act:update()
   	end

	--draws entities
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
	 
	--remove object that are in the destroy_queue
	for i = 1, #destroy_queue do
		del(actives, destroy_queue[1])
		del(entities, destroy_queue[1])
		del(destroy_queue, destroy_queue[1])
	end
end

-->8
--camera
camera_borders = {}

current_camera = active:new{}
current_camera.border = nil
current_camera.local_x = 0
current_camera.local_y = 0
current_camera.shake_x = 0
current_camera.shake_y = 0
current_camera.shake_amp = 0

function current_camera:ready()
	self.shake_x = 0
	self.shake_y = 0
	self.shake_amp = 0
end

function current_camera:set_camera(x, y)
	camera_x = x - 64 + self.shake_x
	camera_y = y - 64 + self.shake_y
	self.local_x = camera_x
	self.local_y = camera_y
	if (current_camera.border ~= nil) then
		camera_x = mid(current_camera.border.x, camera_x, current_camera.border.x + current_camera.border.w)
		camera_y = mid(current_camera.border.y, camera_y, current_camera.border.y + current_camera.border.h)
	end

	--camera shake
	self.shake_x = sin(rnd(64)) * self.shake_amp;
	self.shake_y = sin(rnd(64)) * self.shake_amp;

	camera_x += self.shake_x
	camera_y += self.shake_y

	--print(self.shake_y, player.x, player.y - 32)
	--write(self.shake_y)
	--write(self.shake_x)
	--write('bruh ' .. self.shake_amp)
end

function current_camera:shake(amp)
	self.shake_amp += amp
end

function current_camera:update()
	if self.border == nil then
		for i = 1, #camera_borders do
			if camera_borders[i]:is_in_border(camera_x, camera_y) then
				self.border = camera_borders[i]
				break
			end
		end
	else
		if not self.border:is_in_border(self.local_x, self.local_y) then
			print(self.border.x .. ' : ' .. self.border.y .. ' : ' .. self.border.w .. ' : ' .. self.border.h , 88, 48)
			self.border = nil
		end
	end

	if self.shake_amp > 0 then
		self.shake_amp -= 0.6
		self.shake_amp = max(self.shake_amp)
	end
end

camera_border_start = entity:new{}
camera_border_start.sprite = 14
camera_border_start.visible = false

function camera_border_start:ready()
	mset(self.x / 8, self.y / 8, 33)
	self:get_size()
end

function camera_border_start:get_size()
	local x = self.x / 8
	local y = self.y / 8
	for i = 1, 256 do
		local t = mget(i + x, y)
		if t == 15 or t == 14 then
			for j = 1, 256 do 
				local a = mget(i + x, j + y) 
				if a == 15 or a == 14 then
					self.x += 8
					self.y += 8
					self.w = max(i * 8 - 128, 0)
					self.h = max(j * 8 - 128, 0)
					add(camera_borders, self)
					return
				end
			end
		end
	end
end

function camera_border_start:is_in_border(x, y)
	print(x .. ' : ' .. y, 90, 99)
	if     
	x - 64 <= self.w + self.x and
	x + 64 >= self.x and
	y - 64 <= self.h + self.y and
	y + 64 >= self.y 
	then
		return true
	else
		return false
	end
end


-->8
--living entities
l_entities = {}

l_entity = entity:new{}
l_entity.max_hp = 3
l_entity.hp = 3
l_entity.damage = 1
l_entity.flash = false
l_entity.floor = false

--kills the entity
function l_entity:kill()
	self:destroy()
	sfx(1)

	local e = explosion:new{}
	e.x = self.x
	e.y = self.y
	e:add()
	
	local e = explosion:new{}
	e.x = self.x + (self.sprite_w/2) * 8 - 4
	e.y = self.y + (self.sprite_h/2) * 8 - 4
	e:add()
end

function l_entity.flashout(o)
	o.color = -1
end

--hurts the entity
function l_entity:hurt(damage)
	self.hp -= damage
	self:start_timer(4, l_entity.flashout)
	self.color = 7
	sfx(2)
	if self.hp <= 0 then
		self:kill()
	end
end

--moves and handles collisions
function l_entity:move(spd_x, spd_y)	
	self.floor = false

	if spd_x == 0 and spd_y == 0 then
		return
	end

	repeat
		local c_x = false
		local c_y = false

		if self:tilecoll(spd_x, 0) then
			self.x -= spd_x * 0.1
			c_x = true
		end

		if self:tilecoll(0, spd_y) then
			self.y -= spd_y	* 0.1
			c_y = true
			self.floor = true
		end

	until c_x == false and c_y == false

	self.x += spd_x
	self.y += spd_y
end

-->8
--player
--defining classes
--player
player = l_entity:new{}
player.hp = 5
player.max_hp = 5
player.spd_x = 0
player.spd_y = 0
player.grav = 0.05
player.jump = 2
player.can_shoot = true
player.up = false
player.invincible = false
player.groups = { 'player' }
player.just_pressed = false
player.charge = 0
player.max_ammo = 10
player.ammo = player.max_ammo
player:add_animation_player()
player.anim_player:new_animation('p_idle', 20, 64, 2)
player.anim_player:new_animation('run', 7, 66, 2)
player.anim_player:new_animation('air', 1, 67, 1)
player.anim_player:set_animation('p_idle')

--addsplayer
--player:add()

gun = entity:new{}
gun.sprite = 80

function player:ready()
	gun:add()
	invincible = false
	player.hurtout(self)
	player.flashout(self)
	player.shoot_timeout(self)
	current_camera:add()
end

function player:update()
	--write('count: ' .. #self.anim_player.animations)
	--for v in all(self.anim_player.animations) do
		--write('asdas: '.. v.name)
	--end
	current_camera:set_camera(self.x + self.w / 2, self.y + self.h / 2)

	gun.x = self.x
	gun.y = self.y

	self.spd_x = 0
	self.up = false

	--move
	if btn(1) then
		self.spd_x += 1
		self.flip_h = false
		self.anim_player:set_animation('run')
	elseif btn(0) then
		self.spd_x -= 1
		self.flip_h = true
		self.anim_player:set_animation('run')
	else
		self.anim_player:set_animation('p_idle')
	end

	if btn(2) then
		self.up = true
	end

	gun.flip_h = self.flip_h
	if self.up then
		gun.sprite = 81
	else
		gun.sprite = 80
	end
	
	--gravity
	if self:tilecoll(0, 0.5) then
		self.spd_y = 0
		--jump
		if btn(4) then
			self.spd_y = -self.jump
		end
	else
		self.spd_y += self.grav
		self.anim_player:set_animation('air')
	end

	--ceiling
	if self:tilecoll(0, -1) then
		self.spd_y = 0.1
	end

	self:move(self.spd_x, self.spd_y)
	
	if btn(5) then
		if (self.ammo > 0) then
			self.charge += 1

			if self.charge == 10 then
				sfx(6)
			end
		end 

		if self.can_shoot and self.just_pressed then
			self:shoot(p_bullet, 0)
		end
	elseif (self.ammo > 0) then
		self.just_pressed = true
		if self.charge >= 40 then
			self:shoot(p_missile, 10)
			self.ammo = self.ammo - 1
		end
		player.charge = 0
	else
		self.just_pressed = true
	end

	local e = self:iscoll('hurt')
	if e and not self.invincible then
		self:hurt(1)
		self.invincible = true
		self:start_timer(60, player.hurtout)
		sfx(3)
		current_camera:shake(7)

		if e:is_in_group('bullet') then
			e:destroy()
		end
	end
end

function player:shoot(new_bullet, sound)
	local b = new_bullet:new{}
	b:add()
	b.x = self.x
	b.y = self.y
	b.up = self.up

	self:start_timer(6, player.shoot_timeout)
	self.can_shoot = false
	self.just_pressed = false

	sfx(sound)

	if self.flip_h and not self.up then
		b.speed *= -1
		b.flip_h = self.flip_h
	end
	
	if self.up then
		b.anim_player:set_animation("up")
	else
		b.anim_player:set_animation("pb_idle")
	end
end

function player.hurtout(o)
	o.invincible = false
end

function player.shoot_timeout(o)
	o.can_shoot = true
end

function player:kill()
	gameoverscreen()
end

--bullet
p_bullet = entity:new{}
p_bullet.sprite = 2
p_bullet.speed = 2
p_bullet.maxtime = 40
p_bullet.timer = 0
p_bullet.damage = 1
p_bullet.tag = 'bullet'
p_bullet.up = false
p_bullet.groups = { 'bullet' }

function p_bullet:ready()
	self:add_animation_player()
	self.anim_player:new_animation("pb_idle", 10, 2, 1)
	self.anim_player:new_animation("up", 10, 3, 1)
	self.anim_player:set_animation("pb_idle")
end

function p_bullet:update()
	if (self.up) then
		self.y -= self.speed
	else
		self.x += self.speed
	end
	self.timer += 1
	
	local ent = self:iscoll('enemy')
	if ent then
		self:kill()
		ent:hurt(self.damage)
	end
	
	if self.timer >= self.maxtime or self:tilecoll(0, 0) then
		self:kill()
	end
end

function p_bullet:kill()
	self:destroy()
end

p_missile = p_bullet:new{}
p_missile.sprite = 11
p_missile.speed = 3
p_missile.maxtime = 60
p_missile.damage = 10

function p_missile:ready()
	self:add_animation_player()
	self.anim_player:new_animation("pb_idle", 6, 96, 2)
	self.anim_player:new_animation("up", 6, 98, 2)
	self.anim_player:set_animation("pb_idle")

end

function p_missile:kill()
	e = explosion:new{}
	e.x = self.x
	e.y = self.y 
	e:add()
	sfx(9)
	self:destroy()

	--pretty epic
	--local t = turret:new{}
	--t.x = self.x
	--t.y = self.y
	--t:add()
end

-->8
--pickups
pickup = entity:new{}
pickup.float = 0
pickup.sy = 0
pickup.permanent = false

function pickup:ready()
	self.sy = self.y
	if (self.permanent == false) then
		self:start_timer(600, pickup.timeout)
	end
end

function pickup.timeout(o)
	o:destroy()
end

function pickup:update()
	self.y = 2*sin(self.float) + self.sy
	self.float = self.float + 0.005

	if (self:iscoll("player")) then
		self:pickupped()
		self:destroy()
	end
end

function pickup:pickupped() end

hp_pickup = pickup:new{}
hp_pickup.sprite = 112
hp_pickup:add_animation_player()
hp_pickup.anim_player:new_animation('hp_pickup', 36, 114, 2)
hp_pickup.anim_player:set_animation('hp_pickup')

function hp_pickup:pickupped()
	player.hp = min(player.hp + 2, player.max_hp)
end

ammo_pickup = pickup:new{}
ammo_pickup:add_animation_player()
ammo_pickup.anim_player:new_animation('ammo_pickup', 36, 112, 2)
ammo_pickup.anim_player:set_animation('ammo_pickup')

function ammo_pickup:pickupped()
	player.ammo = min(player.ammo + 2, player.max_ammo)
end

maxhp_pickup = pickup:new{}
maxhp_pickup.sprite = 116
maxhp_pickup.permanent = true

function maxhp_pickup:pickupped()
	player.max_hp = player.max_hp + 1
	player.hp = player.max_hp
end

-->8
--enemies

--loot table
local loot_table =
{
	hp_pickup,
	ammo_pickup,
	1,1,1,1,1
}

enemy = l_entity:new{}
enemy.groups = { 'enemy', 'hurt' }

function enemy:player_angle(o_x, o_y)
	--if o_x == nil then o_x = 0 end
	--if o_y == nil then o_y = 0 end
	return atan2((player.x + o_x) - self.x, (player.y + o_y) - self.y)
end

function enemy:player_distance()
	local dx = abs(self.x - player.x)
	local dy = abs(self.y - player.y) 
	if (dx > dy) then
		return dx
	else
		return dy
	end
end

function enemy:kill()
	self:destroy()
	sfx(1)

	local e = explosion:new{}
	e.x = self.x
	e.y = self.y
	e:add()
	
	local e = explosion:new{}
	e.x = self.x + (self.sprite_w/2) * 8 - 4
	e.y = self.y + (self.sprite_h/2) * 8 - 4
	e:add()

	self:rand_item()
end

function enemy:rand_item()
	local b = flr(rnd(#loot_table)) + 1
	local a = loot_table[b]
	if a == 1 then
		return
	end
	
	local pick = a:new{}
	pick.x = self.x
	pick.y = self.y
	pick:add()
end

alien = enemy:new{}

alien.sprite = 4
alien.tag = 'enemy'
alien.hp = 10 
alien.groups = { 'enemy', 'hurt', 'alien' }

function alien:update()
	self:move(-0.2, 0)
end

turret = enemy:new{}

turret.sprite = 5
turret.tag = 'enemy'
turret.hp = 6
turret.groups = { 'enemy', 'hurt', 'turret' }
turret.can_shoot = true

--turret is ready
function turret:ready()
	self:add_animation_player()
	self.anim_player:new_animation('idle', 15, 5, 2)
	self.anim_player:set_animation('idle')
end

function turret:update()
	--shoot
	if (self.can_shoot and self:player_distance() <= 48) then
		t = turret_bullet:new{}
		t.x = self.x
		t.y = self.y
		t.angle = self:player_angle(0, 0)--atan2(player.x - self.x, player.y - self.y)
		t:add()
		self.can_shoot = false
		self:start_timer(170 + rnd(60), turret.shootout)
		sfx(4)
	end
end

function turret.shootout(o)
	o.can_shoot = true
end

boss = enemy:new{}

security_boss = boss:new{}
security_boss.sprite_w = 4
security_boss.sprite_h = 2
security_boss.sprite = 129

bomber = enemy:new{}
bomber.sprite = 160
bomber.sprite_w = 2
bomber.sprite_h = 2
bomber.can_shoot = true
bomber.w = 16
bomber.h = 16
bomber.hp = 25
bomber.max_hp = 25



function bomber:update()
	local distance = self:player_distance()

	if self.can_shoot and distance <= 48 then
		self.can_shoot = false
		local m = missile:new{}
		m.angle = self:player_angle(0, 120)
		m.x = self.x
		m.y = self.y
		m:add()
		self:start_timer(60, bomber.shootout)
	end

	if distance <= 48 then
		local a = self:player_angle(0, -24)
		self:move(cos(a) * 0.3, sin(a) * 0.2)
	end
end

function bomber.shootout(o)
	o.can_shoot = true
end

stretcher = enemy:new{}
stretcher.center_x = 0
stretcher.center_x = 0
stretcher.target_x = 0
stretcher.target_y = 0
stretcher.sprite = 163
stretcher.hp = 20
stretcher.neck_count = 4
stretcher.necks = {}
stretcher.time = 0
stretcher.maxtime = 35
stretcher.timedir = 1
stretcher.dx = 0
stretcher.dy = 0
stretcher.can_attack = true

neck = entity:new{}
neck.id = 0
neck.parent = {}
neck.sprite = 162

function stretcher:ready()
	self.center_x = self.x
	self.center_y = self.y
	self:new_target(self.center_x, self.center_y)

	local b = {}

	for i = 1, self.neck_count do
		local n = neck:new()
		n.id = i
		n.x = self.x
		n.y = self.y
		n.parent = self
		n:add()
		b[i] = n
		table.move(entities, n, -1)
	end

	self.necks = b
end

function stretcher:attack()
	self.timedir = 1
	self:new_target(player.x, player.y)
	self:start_timer(64, stretcher.back)
	self.can_attack = false
end

function stretcher.back(o)
	o.timedir = -1
	o:start_timer(64, stretcher.ready_attack)
end

function stretcher.ready_attack(o)
	o.can_attack = true
end

function stretcher:new_target(x, y)
	self.time = 0
	self.target_x = x
	self.target_y = y
	self.dx = self.target_x - self.center_x 
	self.dy = self.target_y - self.center_y 
end

function stretcher:update()
	self.time += 1 * self.timedir
	self.time = mid(0, self.time, self.maxtime)

	local p = (self.time / self.maxtime) 

	self.x = self.center_x + self.dx * p
	self.y = self.center_y + self.dy * p

	if self:player_distance() <= 38	 and self.can_attack then
		self:attack()
	end
	--self:move_to(self.target_x, self.target_y)
end

function stretcher:kill()
	local e = explosion:new{}
	e.x = self.x
	e.y = self.y
	e:add()
	for i = 1, self.neck_count do
		self.necks[i]:kill()
	end
	self:rand_item()
	self:destroy()
end

function neck:kill()
	local e = explosion:new{}
	e.x = self.x
	e.y = self.y
	e:add()
	self:destroy()
end

function neck:update()
	self.x = self.parent.x + ((self.parent.center_x - self.parent.x) / self.parent.neck_count) * self.id
	self.y = self.parent.y + ((self.parent.center_y - self.parent.y) / self.parent.neck_count) * self.id
end


bullet = entity:new{}
bullet.speed = 0.5
bullet.angle = 0
bullet.time = 120

function bullet:ready()
	self:start_timer(120, bullet.timeout)
end

function bullet:update()
	self.x += cos(self.angle) * self.speed
	self.y += sin(self.angle) * self.speed
end

function bullet.timeout(o)
	o:destroy()
end

turret_bullet = bullet:new{}
turret_bullet.sprite = 6
turret_bullet.groups = { 'bullet', 'hurt' }

missile = bullet:new{}
missile.sprite = 128
missile:add()
missile.time = 180
missile.x = 32
missile.y = 16
missile.speed = 1.5
missile.angle = -0.2
missile.groups = { 'hurt' }

function missile:update()
	self.x += cos(self.angle) * self.speed
	self.y += sin(self.angle) * self.speed

	if self:tilecoll(0, 0) then
		self:kill()
	end
end

function missile:kill()
	sfx(5)
	local e = explosion:new{}
	e.x = self.x
	e.y = self.y 
	e:add()
	self:destroy()
end

-->8
--effects
explosion = entity:new{}
explosion.timer = 0
explosion.sprite = 7

function explosion:update()
	self.timer += 1
	if self.timer % 4 == 0 then
		self.sprite += 1
		
		if self.sprite > 10 then
			self:destroy()
		end 
	end
end

-->8
--spawnmanager
	
function spawnents()
	for i = 0, 64 do
		for j = 0, 64 do
			local c = mget(i, j)
			local a = nil
		
			if c == 1 then
				player:add()
				player.x = i * 8
				player.y = j * 8
				mset(i, j, 0)
			elseif c == 4 then
				a = alien:new{}
			elseif c == 5 then
				a = turret:new{}
			elseif c == 129 then
				a = security_boss:new{}
			elseif c == 14 then
				a = camera_border_start:new{}
			elseif c == 15 then
				--a = camera_border_end:new{}
			elseif c == 128 then
				a = missile:new{}
			elseif c == 160 then
				a = bomber:new{}
			elseif c == 163 then
				a = stretcher:new{}
			elseif c == 114 then
				a = hp_pickup:new{}
			elseif c == 112 then
				a = ammo_pickup:new{}
			elseif c == 116 then
				a = maxhp_pickup:new{}
			end
			
			if a ~= nil then 
				for x = 0, a.sprite_w - 1 do
					for y = 0, a.sprite_h - 1 do
						mset(i + x, j + y, 0)
					end
				end
				a.x = i * 8
				a.y = j * 8
				a:add()
			end
		end
	end
end

spawnents()
-->8
--ui
health_ui = control:new{}
health_ui:add()
health_ui.x = 2
health_ui.y = 2

function health_ui:draw(x, y)
	local s = player.hp / player.max_hp

	health_ui.x = 2 + x
	health_ui.y = 2 + y

	for i = 0, player.max_hp - 1 do
		spr(79, x + 2 + 3 * i, y + 4)
	end

	if (s > 0) then
		--rectfill(
		--health_ui.x,
		--health_ui.y,
		--24 * s + health_ui.x,
		--8 + health_ui.y, 8)
		for i = 0, player.hp - 1 do
			spr(78, x + 2 + 3 * i, y + 4)
		end
	end

	--rect(health_ui.x, health_ui.y, health_ui.x + 24, health_ui.y + 8, 0)
end

ammo_ui = control:new{}
ammo_ui:add()

function ammo_ui:draw(x, y)
	print("ammo:" .. player.ammo .. "/" .. player.max_ammo , x + 2, y + 14, 0)
end

-->8
--screens
screen = active:new{}

function screen:ready()
	self.i = 0
	self.c = 0
	self.s1 = 50
	self.s2 = 114
	self.s3 = 140
	self.s4 = 200
end

function screen:update()
	self.i += 1
	
	if (self.i < self.s1) then return end
	
	cls(self.c)	
	self.c += 0.08
	
	if (self.i < self.s2) then return end
	
	cls(0)
	
	if (self.i < self.s3) then return end
	
	print("game over!", 44, 60, 7)
	
	if (self.i < self.s4) then return end
	
	print("press z to try again!", 22, 68, 7)
	print("press x for menu", 22 + 12, 76, 7)

	
	if (btn(4)) then
		run()
	elseif(btn(5)) then
		load("menu_test")
	end
end

--game over screen
function gameoverscreen()
	render = false
	for i = 1, #actives do
		actives[i]:destroy()
	end
	cls(0)
	screen:add()
	sfx(11)
end

__gfx__
78000087abbbbbbc000000000009800000cccc0000611600000000000000000000000000700000077000000700000000000000000000000099999999cccccccc
87800878ab0bb0bc00000000008ff9000c0000c0018ff810008888000077770007700770070990700000000000000000000000000000000090099000c00c0000
08788780bb0bb0bb00999900009aa8000cccccc0068ff86008ffff8007777770077997700000000000000000000000000000000000000000099909990ccc0ccc
00877800bbb55bbb097f7f90008aa9000c0cc0c00018810008f77f8007777770009099000900009000000000000000000000000000000000099990090ccc000c
00877800005555b009f7f790009ff80000cccc000006600008f77f8007777770009909000900009000000000000000000000000000000000099999900ccc0ccc
08788780b000b0000099990000098000000cc0000000000008ffff8007777770077997700000000000000000000000000000000000000000099999900ccc0ccc
87800878bbb00bbb0000000000089000000cc00000111100008888000077770007700770070990700000000000000000000000000000000090090009c00c0000
78000087bbbbbbbb000000000009800000cccc0001666610000000000000000000000000700000077000000700000000000000000000000099999999cccccccc
b3b3bb3bb3b3b3b33bbb3b3b3bb3111111113bb300000000000000003b33bbb3b3b3bbb3bb3b3b3bb3b3b33b3b3b3bb3b33b3b3b7776666d77777777d6666777
3bbb33bbbb3bbb3bb3b3bbb3bbb3111111113bbb00000b000000000003003b303bbbb33b33b3bbb3bb3b3111b333b33b1113b3bb766dddd1666666661dddd667
b3bbbbb3bbb33bbbbbbbbbb3bb311111111113bb0000b300000000000b000330b3bb311111113b3b3bb31ddd11133311ddd13bbb76ddd7d16d6d6d6d1d7ddd67
3bb333313331133b333bbb3b3311111111111133b00b3000000000000b0003b03bb311dddd111bbbb331ddddddd111dddddd13b36dddd1d1dddddddd1d1dddd6
bb331111111111131113bbbb11111111111111110b03300000b0000b00000300bb311d1111d113b33111111111111111111111116d7dddd1111111111dddd7d6
3b3111111111111111113b3b11111111111111110b333b0000b000b0000003003b311d1111d111b31d1ddddddddddddddddd1d116d1dddd1dddddddd1dddd1d6
bb31111111111111111113b31111111111111111033b33b00b033b0000000b00bb3111dddd1113bb11d1d1d1d1d1d1d1d1d1d1116ddddd11d1d1d1d111ddddd6
3b31111111111111111113b31111111111111111b3b33b33b33b33b300000b003bb311d11d113bbb111111111111111111111111d1111111111111111111111d
b3b311111111111111113bb31111111111111111000003000000000380000000b3b31dd11dd13bb3111111111111111111111111766d1dd1111111111dd1d667
3bb3111111111111111113bb11111111111111110000030000000b3bb20000003bb31d1111d113bb1d1d1d111d1d1d1d1d1d1d1d76dd1d111111111111d1dd67
bb31111111111111111113b3111111111111111100000b000000bbb3b3000000bb311dd11dd113b3ddddddd1dddddddd11dddddd766d1dd1111111111dd1d667
3b3111111111111111113b3b111111111111111100000b000000b0b333b000003b311d1111d13b3bb3113111111131111111111376dd1d111111111111d1dd67
b3b311111111111111113bb33311111111111133003003000000300bb0300000b3b31dd11dd13bb3bbb3b33dd333b33dd333bb3b766d1dd1111111111dd1d667
b3b311111111111111113b3bbb311111111113bb0b0b03000000300b30200000b3b31d1111d13b3b3bbbbbb33bbbbbb33bbbbbb376dd1d111111111111d1dd67
3bb3111111111111111113b3bbb3111111113bbb0300030000002003308000003bb31dd11dd113b3b33b3bbbb33b3bbbb33b3bbb766d1dd1111111111dd1d667
bb31111111111111111113bb3bb3111111113bb3003b300000008000b0000000bb311d1111d113bb3bb3b3b33bb3b3b33bb3b3b376dd1d111111111111d1dd67
bb31111111111111111113bb00000000000000000000000022b333bb3b3bbb3b3b311dd11dd113bb000000000000000000000000d1111111111111111111111d
3b31111111111111111113bb0000000000000000000000008300b320bbb313b3b33111dddd1113bb0000000000000000000000006ddddd111d1d1d1d11ddddd6
b3b3111111111111111113b300000000000000000000000003000b803b31d13b3b311d1111d113b30000000000000000000000006d7dddd1dddddddd1dddd7d6
b3b311111111311111113b3b0000000000000000000000000b000200b31d7d1bb3311d1111d13b3b0000000000000000000000006d1dddd1111111111dddd1d6
3b3133331333b33111333b3b0000000000000000000000000b00080031dd1d133b3311dddd333b3b0000000000000000000000006dddd7d1dddddddd1d7dddd6
bbb3bbbb3bbbbbb333bbbbb3000000000000000008000000020000003b1ddd1bbbb3333133bbbbb300000000000000000000000076ddd1d1d6d6d6d61d1ddd67
3bbbb3b3b33b3bbbbb33bbb300000000000000000320008008000000b3b111b33bbb3bb3bb33bbb3000000000000000000000000766dddd1666666661dddd667
b3bb3b3b3bb3b3b3b3bb3b3b00000000000000003b3b023b000000003b3bb33bb33bbb3bb3bb3b3b0000000000000000000000007776666d77777777d6666777
00000a00000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000
0099aaa000000a0000000a000099aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000099000001dd10000
00991cc00099aaa00099aaa000991cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000ff000001dd10000
0999111000991cc000991cc009991110000000000000000000000000000000000000000000000000000000000000000000000000000000000ff000001dd10000
02999aa0099911100999111002999aa000000000000000000000000000000000000000000000000000000000000000000000000000000000099000001dd10000
002999a002999aa002999aa0002999a000000000000000000000000000000000000000000000000000000000000000000000000000000000099000001dd10000
0029999000299990002999900029999900000000000000000000000000000000000000000000000000000000000000000000000000000000099000001dd10000
00090090000900900000990009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000
00000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000001d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000010000001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d11dd100001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd0100000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000820000000002200000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000688200000028820000988900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62222820688882900081180000288200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86111282968888890021120000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
86111282968888890021120002888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62222820688882900021120008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000000688200000026620028866882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000820000000668866086699668000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000770000000000000777700777666dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0028820000788700000880000788887066688dd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00811800008228000082280078822887768228d10000280000000000000000000000000000000000000000000000000000000000000000000000000000000000
00211200008228000821128078222287682112810000120000000000000000000000000000000000000000000000000000000000000000000000000000000000
00211200008228000821128078222287682112810021228000000000000000000000000000000000000000000000000000000000000000000000000000000000
002112000082280000822800788228876d8228d10082812000000000000000000000000000000000000000000000000000000000000000000000000000000000
002112000082280000088000078888706dd88d110002112000000000000000000000000000000000000000000000000000000000000000000000000000000000
011881100888888000000000007777006dd111110008228000000000000000000000000000000000000000000000000000000000000000000000000000000000
06500560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60222206566666666666666666666666666666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52888825000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
028ee820056666666666666666666666666666500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
028ee820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
52888825005666666666666666666666666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60222206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06500560000000000005166666615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005166666615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005eeeeeeeeeeeeee5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006666606022220660222206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000000500002eeee2002ffff20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005ccccccc050002eeffee22ff77ff2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000cccccccccc0002effffe22f7887f2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc002effffe22f7887f2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc002eeffee22ff77ff2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ccccccccccccc002eeee2002ffff20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccccc6022220660222206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000001010101010000000101010101010101010101010100000001010101010101010101010000000000010100000001010100000000000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e3131313131313131313131313131313131313131313131313131310e31313131313131313131310f313131310f00000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1500000000000000000010120000000000000000000000000000000000000000000000000000000000000026200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
123500000000000000262022270000000000000000000000000000000f000000000000000000000000000015200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1412270000350415000030320000000000000016053500000000000000000000000000000000000000000010132121212121212122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2432000000101112000000000000000000000010111200000000000000000000000000000000000000000020212121212121212122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2217000000302322270400000000000000002630313200000000000000000000000000000000000000002620212121212121212122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22250000000030320000000000053500000000003600000000000000000000000000000000000000000000200e21210f2121212122000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200040015001736000000001011122700000000000000000000000000000000000000000000000000000030232121212121212122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2227001012002500000400101324320000000000000000001635051635150016001500351615000000a30026202121212121212122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2200003032000000000000303132040000000000000000351011111111111111111111111112000000000035202121243131313132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
223500360435000516000036173500001535000000000010132121212424313131313131313200000000261013212122000000000000000000000000000000001b1b1a1d1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14111111111111111111111111111111111227000026101321212121222227170036170000170000000000202121212200000000000000181b1c11111a19000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21212121212121212121212121212121212235001510132121212121222200250000151615001615001615202121212200000000000000282e2e2e2e2e29000000000f000000371a1c37000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
212121212121212121212121212121212122111111111111122121212222000000a310111111111111111113212121220000181b190000282e2e2e2e2e29000000000000000028000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121222121212121211421212122222700002630313123243131312324313131320000282e290000382b2a312c2b39000000000000000028000029000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21212121213131313131212121222021212221212121212121212121222200150000170000303200a3003032000000000000382b390000000000000000000000000000000000372a2c37000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121211411111321212122202121142121212121212121212100141112270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212114132121212121212121212121212100212122000000000000000070007000000000000000181b1b1b1900001d1e1e1e1f00001d1e371c111a1d1e1f00111a1e1e1c11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121212121212121212121212100212122270074161516000100350000151635000000282e2e2e2900002d2121212f0000282e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21212121212121212121212121212121212121000000000000000000001111111111111111111111111111111111111111111a1b1b1b1c11003d3e3e3e3f0000282e2e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
212121212121212121212121212121212121212100000000000000000021212121212121212121212121212121212121212121212121212121212121212121212121212e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000212121212121212121212121212121212121212121212121212121212121212121212121212e2e2e2e2e2e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000021212121212121212121210f212121210f21212121212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000212121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00002121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003b0502645035050300502b0503115020050273501f350233500305000050321003210031100301002c4001a7001a7001b700266002a700297001d7002670024700296001f7002270022700302002a200
000300002b7502e6502d6502c6502b6502f6502a45029450224502145020450204501d0501805015050116500e6500c6500000000000000000000000000000000000000000000000000000000000000000000000
0002000033150311502e1502a15029150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000f651066601366001650020501660000000026000f6010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001005024350223501f0501d050000001715019150120500655003550005500040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003f6503e6503c6503b6503a6503f6503f650232503e65021250202501f2501e2501d25034650336503265032650316503665035650112500e2500e2501865018650176501665019650126500c65005650
0003000003450034500945003450044500745005450034500c450084500345009450124500b4500c45009450104500b450164500c4501345014450194501545018450214501e4501d45024450283502b35034350
000100001c35014450115501735014450144501035014450144501445015350144501c5501445014450163501445012350144501b550144501445013350144501445014450144501b5500c350144501445014450
00010000164501c450214501c450154501d45016450154501d4501d450154501e450194501e45024450144501f4501f450144502045014450204501a4502045016450174501b4501b4501b4501d4502045020450
0001000000000306503465038650380503b6502c050386503465031650206502665024650270501f650160501c65019650166501565010050116500f6500e6500d650120500e650106501c050166501965016050
000100003645033450324502e4502c4502a450284502545023450204501e4501b4501845014450114500e4500c4500a4500745005450034500145000450000000000000000000000000000000000000000000000
000a000024050280502a0502e05030050310503305034050340503405033050310502f0502b05027050210501c05017050110500f0500a05007050050500205001050000500100008050020500e0500405001050
