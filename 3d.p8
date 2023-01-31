pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
local x = 0
local y = 0
local z = 0
local zoom = 1

function definepos(this,x1,y1,z1)
	pos = {
		x=x1,
		y=y1,
		z=z1
	}
	add(this,pos)
end

function getline(face,vert)
			ax = face.anglex+obj.anglex
			ay = face.angley+obj.angley

			v=face.vertex[vert]
			o=face.origin
			at=atan2(v.x-o.x-x,v.y-o.y-y)
			d=((v.x-o.x)^2+(v.y-o.y)^2)^0.5
			dz=sin(ay)*v.z
			
			return{
				(face.position.x+d*cos(ax+at))*zoom,
				(face.position.y+d*sin(ax+at)*
				sin(ay+0.25)+dz)*zoom
			}
end

function drawline(face)
	for i=1, #face.vertex do
		v=i
		
		if(i>=#face.vertex) then
		vn=1
		--vn=i
		else
		 vn = i+1
		end
		
		l = getline(face,v)
		ln = getline(face,vn)
	
		line(l[1],l[2],ln[1],ln[2],12)
		--pset(l[1],l[2],6)
		spr(1,l[1]-1,l[2]-1)
	end
end

function setpos(face,pos)
 p = face.position
	p.x = pos[1]
	p.y = pos[2]
	p.z = poz[3]
end

function move(face,pos)
	p = face.position
	p.x = p.x + pos[1]
	p.y = p.y + pos[2]
	p.z = p.z + pos[3]
end

function objrotate(rotx,roty)
	for i = 1, #obj.face do
	 f = obj.face[i]
		f.anglex = f.anglex + rotx
		f.angley = f.angley + roty
	end
end

obj = {
	face = {},
	anglex = 0,
	angley = 0
}

function createface(ob,v,o,p,ax,ay)
	_o = {
		x=o[1],
		y=o[2],
		z=o[3]
	}
	_p = {
		x=p[1],
		y=p[2],
		z=p[3]
	}

	face = {
		vertex = v,
		origin = _o,
		position = _p,
		anglex = ax,
		angley = ax
	}
	
	add(ob,face)
end

vert1 = {}
vert2 = {}
vert3 = {}
vert4 = {}
function createcircle(n,r,vertex,ax)
	for i = 1, n do
		_ax = cos(ax+0.25)
		definepos(vertex,
		sin(i/(n+ax))*r*_ax,
		cos((i/n))*r,
		sin(i/(n+ax-0.25))*r)
	end
end

function createsphere(n,r,vertex,ax)
	for i = 1, n do
		local _vert = {}
		createcircle(n,cos(i/n)*r,_vert,ax)
		local a = (sin(i/n)*r)
		createface(obj.face,_vert,
		{a,0},{64,64},0,0)
	end
end
vert = {}
--create vertex pattern(square for only one face)
definepos(vert,0,0,0)
definepos(vert,25,0,0)
definepos(vert,25,25,0)
definepos(vert,0,25,0)
definepos(vert,0,0,0)
definepos(vert,0,0,25)
definepos(vert,0,25,25)
definepos(vert,0,25,0)
definepos(vert,0,25,25)
definepos(vert,25,25,25)
definepos(vert,25,25,0)
definepos(vert,25,25,25)
definepos(vert,25,0,25)
definepos(vert,25,0,0)
definepos(vert,25,0,25)
definepos(vert,0,0,25)

function _init()
	#include objtest.txt
	//impported square
	s_obj = {
	-0.500000,-0.500000,0.500000,
	0.500000,-0.500000,0.500000,
	-0.500000,0.500000,0.500000,
	0.500000,0.500000,0.500000,
	-0.500000,0.500000,-0.500000,
	0.500000,.500000,-0.500000,
	-0.500000,-0.500000,-0.500000,
	0.500000,-0.500000,-0.500000
	}
	
	cls()
	print(#s_obj)
	
	local ivert = {}
	
	for i = 1, #s_obj/3 do
		ivert[i] = {}
	end
	
	for _i = 1, #s_obj/3 do
		ivert[_i] = {
			x=0,
			y=1,
			z=2
		}
		local w = (_i-1)*3+1
		ivert[_i].x = s_obj[w]*40
		ivert[_i].y = s_obj[w+1]*40
		ivert[_i].z = s_obj[w+2]*40
	end
	
	for i = 1, #ivert do
		print(i 
		.." x:"..ivert[i].x
		.." y:"..ivert[i].y
		.." z:"..ivert[i].z) 
	end
	
	--createface(obj.face,ivert,{0,0},{64,64},0.25,0.25)
end

createsphere(13,64,vert1,0)
--createface(obj.face,vert,{16,16},{64,64},0.25,0.25)

function _update60()
	cls()
		
	for i = 1, #obj.face do
		drawline(obj.face[i])
	end
	
	local rotx = 0
	local roty = 0
	
	if(btn(➡️))then
		rotx = 0.01
		obj.anglex = obj.anglex+0.01
	end
	if(btn(⬅️))then
		obj.anglex = obj.anglex-0.01
	end
	if(btn(⬇️))then
		obj.angley = obj.angley+0.01
	end
	if(btn(⬆️))then
		obj.angley = obj.angley-0.01
	end
end
__gfx__
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
