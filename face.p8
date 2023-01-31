pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
local x = 0
local y = 0
local z = 0

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
			at=atan2(v.x-o.x,v.y-o.y)
			--a=ax
			d=((v.x-o.x)^2+(v.y-o.y)^2)^0.5
			dz=sin(ay)*v.z
			
			--print(dz)
			
			return{
				face.position.x+d*cos(ax+at),
				face.position.y+d*sin(ax+at)*
				sin(ay+0.25)+dz
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
		
		line(l[1],l[2],ln[1],ln[2],i)
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

function createface(ob,v,o,p,a)
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
		anglex = a,
		angley = 0
	}
	
	add(ob,face)
end

vert1 = {}
vert2 = {}
vert3 = {}
vert4 = {}
function createcircle(n,r,vertex)
	for i = 1, n do
		definepos(vertex,sin(i/n)*r,cos(i/n)*r,0)
	end
end

vert = {}
--create vertex pattern
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

--createcircle(vertexamount,radius,vertexpattern)
createcircle(4,16,vert1)
createcircle(4,16,vert2)
createcircle(4,16,vert3)
createcircle(4,16,vert4)

function _init()
	--createface(table,vertextable,
	--origin,position,anglex)
	createface(obj.face,vert,
	{0,0},{64,64},0)
		createface(obj.face,vert,
	{0,0},{64,64},0)
	--createface(obj.face,vert2,
	--{0,0},{64,64},0)
	obj.face[1].angley = 0.25
end

function _update60()
	cls()
		
	for i = 1, #obj.face do
		drawline(obj.face[i])
	end
	
	--setpos(obj.face[1],{44,44})
	--move(obj.face[1],{-0.5,-0.5})
	--obj.face[1].anglex = obj.face[1].anglex-0.01
	--obj.face[1].angley = obj.face[1].angley-0.01
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
	
	--objrotate(rotx,roty)
end
__gfx__
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
