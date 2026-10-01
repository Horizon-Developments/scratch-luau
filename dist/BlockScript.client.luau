-- Prepended to the bundle by build.sh AFTER wax + darklua, so darklua never renames it.
-- ROBLOX EXECUTOR SUPPORT: defines `loadasset(url)` for executor environments. It downloads the file once into
-- Scratch/img/ and returns its getcustomasset id. It needs executor-only functions (isfolder, makefolder, isfile,
-- writefile, getcustomasset, game:HttpGet).
-- Roblox Studio / normal game scripts: the script still runs. Those functions are missing there, so loadasset errors,
-- UI/Assets.lua pcalls it, and the flag/loop icons are simply left out. Nothing else depends on it.
local cache = {}

local function loadasset(url)
	local name = url:match("[^/]+$") -- e.g. "flag.png"
	local path = "Scratch/img/" .. name

	if cache[path] then
		return cache[path]
	end

	if not isfolder("Scratch") then makefolder("Scratch") end
	if not isfolder("Scratch/img") then makefolder("Scratch/img") end

	if not isfile(path) then
		writefile(path, game:HttpGet(url))
	end

	cache[path] = getcustomasset(path)
	return cache[path]
end
local a,b,c={},{},{}
local d={__index=function(d,e)return rawget(d,"__kids")[e]end}
local function __node(e,g)
local h=setmetatable({Name=e,Parent=g,__kids={}},d)
if g then rawget(g,"__kids")[e]=h end
return h
end
local e=__node("BlockScript",nil)
local function __require(g)
if type(g)~="table"or not b[g]then return require(g)end
local h=c[g]
if h==nil then
h={v=b[g](g,__require)}
c[g]=h
end
return h.v
end
do local g=e for h,i in ipairs({"Lang"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Control"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Custom"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Events"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Lists"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Operators"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Output"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Sensing"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Blocks","Variables"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core","Interpreter"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core","Plugins"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core","Registry"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core","Validate"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang","Core","Values"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Plugin"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Assets"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","BlockView"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Console"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Drag"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Editor"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Palette"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Program"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Shapes"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Theme"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Toolbar"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Transfer"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"UI","Workspace"})do g=rawget(g,"__kids")[i]or __node(i,g)end end
do local g=e for h,i in ipairs({"Lang"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)





local j=i(h.Core.Registry)
local k=i(h.Core.Interpreter)
local l=i(h.Core.Values)
local m=i(h.Core.Validate)
local n=i(h.Core.Plugins)

local o={Registry=j,Interpreter=k,Values=l,Validate=m,Plugins=n}

function o.newRegistry()
local p=j.new()
i(h.Blocks)(p)
return p
end

function o.newInterpreter(p,q)return k.new(p,q)end



function o.importProgram(p,q)
local r=m.checkSize(q)
if r then return nil,r end
if p.custom then p.custom.sync(type(q)=="table"and q.scripts or nil,true)end
return m.program(q,p)
end



function o.loadPlugin(p,q)return n.load(p,q)end

return o

end end
do local g=e for h,i in ipairs({"Lang","Blocks"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)



return function(j)
local k=i(h.Parent.Core.Values)
local l={
i(h.Events),
i(h.Control),
i(h.Operators),
i(h.Variables),
i(h.Lists),
i(h.Sensing),
i(h.Output),
i(h.Custom),
}
for m,n in ipairs(l)do
n(j,k)
end
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Control"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Control",{name="Control",color={255,171,25}})

j:defineBlock({id="control_wait",category="Control",shape="stack",
label="wait {SECS} seconds",
inputs={SECS={type="number",default=1}},
run=function(l,m)l:wait(math.max(0,m.SECS))end})

j:defineBlock({id="control_repeat",footerIcon="loop",category="Control",shape="c",
label="repeat {TIMES}",stacks={"SUBSTACK"},
inputs={TIMES={type="number",default=10}},
run=function(l,m)
for n=1,math.floor(m.TIMES)do
if not l:alive()then return"STOP"end
local o=l:stack("SUBSTACK")
if o then return o end
l:loopStep()
end
end})


j:defineBlock({id="control_forever",footerIcon="loop",category="Control",shape="cap",
label="forever",stacks={"SUBSTACK"},
run=function(l)
while l:alive()do
local m=l:stack("SUBSTACK")
if m then return m end
l:loopStep()
end
return"STOP"
end})

j:defineBlock({id="control_if",category="Control",shape="c",
label="if {COND} then",stacks={"THEN"},
inputs={COND={type="boolean"}},
run=function(l,m)
if m.COND then return l:stack("THEN")end
end})

j:defineBlock({id="control_if_else",category="Control",shape="c",
label="if {COND} then",stacks={"THEN","ELSE"},
inputs={COND={type="boolean"}},
run=function(l,m)
return l:stack(m.COND and"THEN"or"ELSE")
end})

j:defineBlock({id="control_wait_until",category="Control",shape="stack",
label="wait until {COND}",
inputs={COND={type="boolean",lazy=true}},
run=function(l)
while l:alive()and not l:input("COND")do l:yield()end
end})

j:defineBlock({id="control_repeat_until",footerIcon="loop",category="Control",shape="c",
label="repeat until {COND}",stacks={"SUBSTACK"},
inputs={COND={type="boolean",lazy=true}},
run=function(l)
while l:alive()and not l:input("COND")do
local m=l:stack("SUBSTACK")
if m then return m end
l:loopStep()
end
end})

j:defineBlock({id="control_while",footerIcon="loop",category="Control",shape="c",
label="while {COND}",stacks={"SUBSTACK"},
inputs={COND={type="boolean",lazy=true}},
run=function(l)
while l:alive()and l:input("COND")do
local m=l:stack("SUBSTACK")
if m then return m end
l:loopStep()
end
end})


j:defineBlock({id="control_for_each",footerIcon="loop",category="Control",shape="c",
label="for {VAR} = 1 to {VALUE}",stacks={"SUBSTACK"},
inputs={VAR={type="variable",default="i"},VALUE={type="number",default=10}},
run=function(l,m)
local n=1
while l:alive()and n<=m.VALUE do
l.interp:setVar(m.VAR,n)
local o=l:stack("SUBSTACK")
if o then return o end
l:loopStep()
n=n+1
end
end})


j:defineBlock({id="control_for_in",footerIcon="loop",category="Control",shape="c",
label="for each {VAR} in {LIST}",stacks={"SUBSTACK"},
inputs={VAR={type="variable",default="item"},LIST={type="list",default="my list"}},
run=function(l,m)
local n=l.interp:list(m.LIST)
local o=1
while l:alive()and n[o]~=nil do
l.interp:setVar(m.VAR,n[o])
local p=l:stack("SUBSTACK")
if p then return p end
l:loopStep()
o=o+1
end
end})


j:defineBlock({id="control_all_at_once",category="Control",shape="c",
label="all at once",stacks={"SUBSTACK"},
run=function(l)return l:stack("SUBSTACK")end})

j:defineBlock({id="control_get_counter",category="Control",shape="reporter",label="counter",
run=function(l)return l.interp.counter end})
j:defineBlock({id="control_incr_counter",category="Control",shape="stack",label="increment counter",
run=function(l)l.interp.counter=l.interp.counter+1 end})
j:defineBlock({id="control_clear_counter",category="Control",shape="stack",label="clear counter",
run=function(l)l.interp.counter=0 end})


j:defineBlock({id="control_stop",category="Control",shape="cap",
label="stop {OPTION}",
inputs={OPTION={type="string",default="this script",options={"this script","all","other scripts"}}},
shapeOf=function(l)return l.inputs.OPTION=="other scripts"and"stack"or"cap"end,
run=function(l,m)
if m.OPTION=="all"then l:stopAll()return"STOP"end
if m.OPTION=="other scripts"then l:stopOthers()return nil end
return"STOP"
end})


j:defineBlock({id="control_error",category="Control",shape="cap",label="error {MESSAGE}",
inputs={MESSAGE={type="any",default="something went wrong",raw=true}},
run=function(l,m)error(k.toString(m.MESSAGE),0)end})



j:defineBlock({id="control_pcall",category="Control",shape="c",
label="pcall, error message in {VAR}",stacks={"TRY","CATCH"},
inputs={VAR={type="variable",default="err"}},
run=function(l,m)
local n=l.thread
local o,p,q,r,s=n.cur,n.execDepth,n.depth,n.frame,n.warp
local t,u=pcall(l.stack,l,"TRY")
if t then return u end
n.cur,n.execDepth,n.depth,n.frame,n.warp=o,p,q,r,s
l.interp:setVar(m.VAR,k.toString(u))
return l:stack("CATCH")
end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Custom"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)












return function(j,k)
local l=k.LIMITS
j:defineCategory("Custom",{name="My Blocks",color={255,102,128}})

local m=l.MAX_CALL_DEPTH
local n="custom:"
local o={"normal","without pausing"}

local function trim(p)return(string.match(p,"^%s*(.-)%s*$"))end

local function nameOf(p)
if type(p)=="string"or type(p)=="number"then
local q=trim(k.toString(p))
if q~=""then return q end
end
end



local function parse(p)
local q,r,s={},{},1
local function literal(t)table.insert(q,(string.gsub(t,"%%","")))end
while s<=#p do
local t,u,v=string.find(p,"%(([^()<>]+)%)",s)
local w,x,y=string.find(p,"<([^()<>]+)>",s)
local z,A,C,D
if t and(not w or t<w)then z,A,C,D=t,u,v,"s"
elseif w then z,A,C,D=w,x,y,"b"end
if not z then literal(string.sub(p,s))break end
literal(string.sub(p,s,z-1))
C=trim(C)
if C==""then literal(string.sub(p,z,A))
else
if#r>=l.MAX_PARAMS then literal(string.sub(p,z,A))
else
table.insert(r,{name=C,kind=D})
table.insert(q,"%"..D)
end
end
s=A+1
end
return{code=trim((string.gsub(table.concat(q),"%s+"," "))),params=r}
end


local function kindsOf(p)
local q={}
for r in string.gmatch(p,"%%([sb])")do table.insert(q,r)end
return q
end

local function defineNameOf(p)
return nameOf(type(p.inputs)=="table"and p.inputs.NAME)
end

local function findDefine(p,q)
for r,s in ipairs(p and p.scripts or{})do
local t=s.blocks and s.blocks[1]
if t and t.op=="custom_define"then
local u=defineNameOf(t)
if u and parse(u).code==q then return s,t end
end
end
end

j:defineBlock({id="custom_define",category="Custom",shape="hat",bowler=true,label="define {NAME} {MODE}",
inputs={NAME={type="string",default="my block",reporters=false},
MODE={type="string",default="normal",options=o}},
hat={event="define"}})


j:defineBlock({id="custom_arg",category="Custom",shape="reporter",label="{NAME}",listed=false,
inputs={NAME={type="param",default=""}},
run=function(p,q)
local r=p.thread.frame
local s=r and r.vals[q.NAME]
if s==nil then return 0 end
return s
end})
j:defineBlock({id="custom_arg_bool",category="Custom",shape="boolean",label="{NAME}",listed=false,
inputs={NAME={type="param",default=""}},
run=function(p,q)
local r=p.thread.frame
return r~=nil and k.toBool(r.vals[q.NAME])
end})

local p={}

local function defineCall(q)
local r=kindsOf(q)
local s,t,u={},{},1
for v,w in ipairs(r)do
local x,y=string.find(q,"%%"..w,u)
table.insert(t,(string.gsub(string.sub(q,u,x-1),"[{}%%]","")))
table.insert(t,"{P"..v.."}")
s["P"..v]=w=="b"and{type="boolean"}or{type="any",default=""}
u=y+1
end
table.insert(t,(string.gsub(string.sub(q,u),"[{}%%]","")))
local v=table.concat(t)
if string.find(v,"^%s*$")then v="block"end
local w=j:defineBlock({id=n..q,category="Custom",shape="stack",label=v,listed=false,
inputs=s,
run=function(w,x)
local y=w.interp
local z,A=findDefine(y.program,q)
if not z then error("\""..q.."\" has no define block",0)end
local C=w.thread
C.depth=(C.depth or 0)+1
if C.depth>m then error("blocks nested too deep (recursion without an end?)",0)end
local D={parent=C.frame,vals={}}
for E,F in ipairs(parse(defineNameOf(A)).params)do D.vals[F.name]=x["P"..E]end
C.frame=D
local E=A.inputs.MODE=="without pausing"
if E then y:enterWarp(C)end
local F=y:runStack(C,z.blocks,2)
if E then y:exitWarp(C)end
C.frame=D.parent
C.depth=C.depth-1

if F and not w:alive()then return"STOP"end
end})
p[q]=w
return w
end

local function walk(q,r,s)
if type(q)~="table"or s>100 then return end
for t,u in ipairs(q)do
if type(u)=="table"then
r(u)
if type(u.inputs)=="table"then
for v,w in pairs(u.inputs)do
if type(w)=="table"and w.op then walk({w},r,s+1)end
end
end
if type(u.stacks)=="table"then
for v,w in pairs(u.stacks)do walk(w,r,s+1)end
end
end
end
end

local q={}
j.custom=q
q.parse=parse



function q.sync(r,s)
local t,u,v,w={},{},false,false
if type(r)=="table"then
for x,y in ipairs(r)do
if type(y)=="table"and type(y.blocks)=="table"then
local z=y.blocks[1]
if type(z)=="table"and z.op=="custom_define"then
local A=defineNameOf(z)
if A then
local C=parse(A)
t[C.code]=true
if#C.params>0 then v=true end
end
end
walk(y.blocks,function(A)
if type(A.op)=="string"and string.sub(A.op,1,#n)==n then
u[string.sub(A.op,#n+1)]=true
end
end,1)
end
end
end
for x in pairs(t)do u[x]=true end
local x=0
for y in pairs(u)do
if not p[y]and not j:get(n..y)then
x=x+1
if x>l.MAX_CUSTOM then break end
defineCall(y)
w=true
end
end
if not s then
local y,z={},false
for A in pairs(p)do
if not u[A]then y[n..A]=true;z=true end
end
if z then
for A in pairs(y)do p[string.sub(A,#n+1)]=nil end
j:removeBlocks(y)
w=true
end
end
for y,z in pairs(p)do
local A=t[y]==true
if(z.listed~=false)~=A then w=true end
z.listed=A
end

for y,z in ipairs({"custom_arg","custom_arg_bool"})do
local A=j:get(z)
if(A.listed~=false)~=v then w=true end
A.listed=v
end
return w
end





function q.rename(r,s,t,u)
local v,w=parse(nameOf(t)or""),parse(nameOf(u)or"")
local x=0
if type(r)~="table"then return x end


local y={}
for z,A in ipairs(v.params)do
local C=w.params[z]
if C and C.name~=A.name then y[A.name]=C.name end
end
if next(y)then
for z,A in ipairs(r)do
if type(A)=="table"and type(A.blocks)=="table"and A.blocks[1]==s then
walk(A.blocks,function(C)
if(C.op=="custom_arg"or C.op=="custom_arg_bool")and type(C.inputs)=="table"and y[C.inputs.NAME]then
C.inputs.NAME=y[C.inputs.NAME]
x=x+1
end
end,1)
end
end
end

if v.code==w.code or v.code==""or w.code==""then return x end
for z,A in ipairs(r)do
local C=type(A)=="table"and type(A.blocks)=="table"and A.blocks[1]
if C and C~=s and type(C)=="table"and C.op=="custom_define"then
local D=defineNameOf(C)
if D and parse(D).code==v.code then return x end
end
end
if not j:get(n..w.code)then defineCall(w.code)end
local z=j:get(n..w.code)
local A,C=n..v.code,n..w.code
for D,E in ipairs(r)do
if type(E)=="table"then
walk(E.blocks,function(F)
if F.op==A then
local G=type(F.inputs)=="table"and F.inputs or{}
F.op=C
F.inputs={}
for H,I in pairs(z.inputs)do
local J=G[H]
if J==nil then J=I.default end
F.inputs[H]=J
end
x=x+1
end
end,1)
end
end
return x
end
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Events"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Events",{name="Events",color={255,191,0}})

j:defineBlock({id="events_when_run",category="Events",shape="hat",
label="when {@flag} clicked",hat={event="run"}})

j:defineBlock({id="events_when_broadcast",category="Events",shape="hat",
label="when I receive {MESSAGE}",
inputs={MESSAGE={type="string",default="message1",reporters=false}},
hat={event="broadcast",filter=function(l,m)return k.equals(l.MESSAGE,m)end}})


j:defineBlock({id="events_when_key",category="Events",shape="hat",
label="when {KEY} key pressed",
inputs={KEY={type="string",default="space",options=k.KEYS,reporters=false}},
hat={event="key",persistent=true,once=true,filter=function(l,m)return l.KEY=="any"or l.KEY==m end}})


j:defineBlock({id="events_when_timer",category="Events",shape="hat",
label="when timer > {VALUE}",
inputs={VALUE={type="number",default=10}},
hat={event="edge",poll=function(l,m)return m:timer()>l.VALUE end}})

j:defineBlock({id="events_broadcast",category="Events",shape="stack",
label="broadcast {MESSAGE}",
inputs={MESSAGE={type="string",default="message1"}},
run=function(l,m)l.interp:fire("broadcast",m.MESSAGE,l.thread)end})

j:defineBlock({id="events_broadcast_wait",category="Events",shape="stack",
label="broadcast {MESSAGE} and wait",
inputs={MESSAGE={type="string",default="message1"}},
run=function(l,m)
local n=l.interp:fire("broadcast",m.MESSAGE,l.thread)
local function pending()
for o,p in ipairs(n)do if not p.done then return true end end
return false
end
while l:alive()and pending()do l:yield()end
end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Lists"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Lists",{name="Lists",color={255,102,26}})

local function list(l,m)return l.interp:list(m)end
local l={type="list",default="my list"}

local function INDEX(m)return{type="any",default=m or 1}end

j:defineBlock({id="list_add",category="Lists",shape="stack",label="add {ITEM} to {LIST}",
inputs={ITEM={type="any",default="thing"},LIST=l},
run=function(m,n)
local o=list(m,n.LIST)
m.interp:checkListGrow(o,n.ITEM)
o[#o+1]=n.ITEM
end})

j:defineBlock({id="list_delete",category="Lists",shape="stack",label="delete {INDEX} of {LIST}",
inputs={INDEX=INDEX(),LIST=l},
run=function(m,n)
local o=list(m,n.LIST)
local p=k.listIndex(n.INDEX,#o,true)
if p=="all"then m.interp.lists[n.LIST]={}
elseif p then table.remove(o,p)end
end})

j:defineBlock({id="list_clear",category="Lists",shape="stack",label="delete all of {LIST}",
inputs={LIST=l},run=function(m,n)list(m,n.LIST)m.interp.lists[n.LIST]={}end})

j:defineBlock({id="list_insert",category="Lists",shape="stack",label="insert {ITEM} at {INDEX} of {LIST}",
inputs={ITEM={type="any",default="thing"},INDEX=INDEX(),LIST=l},
run=function(m,n)
local o=list(m,n.LIST)
local p=k.listIndex(n.INDEX,#o+1,false)
if p then
m.interp:checkListGrow(o,n.ITEM)
table.insert(o,p,n.ITEM)
end
end})

j:defineBlock({id="list_replace",category="Lists",shape="stack",label="replace item {INDEX} of {LIST} with {ITEM}",
inputs={INDEX=INDEX(),LIST=l,ITEM={type="any",default="thing"}},
run=function(m,n)
local o=list(m,n.LIST)
local p=k.listIndex(n.INDEX,#o,false)
if p then o[p]=k.limitString(n.ITEM)end
end})

j:defineBlock({id="list_item",category="Lists",shape="reporter",output="any",label="item {INDEX} of {LIST}",
inputs={INDEX=INDEX(),LIST=l},
run=function(m,n)
local o=list(m,n.LIST)
local p=k.listIndex(n.INDEX,#o,false)
if not p then return nil end
return o[p]
end})


j:defineBlock({id="list_indexof",category="Lists",shape="reporter",output="any",label="item # of {ITEM} in {LIST}",
inputs={ITEM={type="any",default="thing"},LIST=l},
run=function(m,n)
for o,p in ipairs(list(m,n.LIST))do if k.equals(p,n.ITEM)then return o end end
return nil
end})

j:defineBlock({id="list_length",category="Lists",shape="reporter",label="length of {LIST}",
inputs={LIST=l},run=function(m,n)return#list(m,n.LIST)end})

j:defineBlock({id="list_contains",category="Lists",shape="boolean",label="{LIST} contains {ITEM}",
inputs={LIST=l,ITEM={type="any",default="thing"}},
run=function(m,n)
for o,p in ipairs(list(m,n.LIST))do if k.equals(p,n.ITEM)then return true end end
return false
end})


j:defineBlock({id="list_contents",category="Lists",shape="reporter",label="{LIST}",
inputs={LIST=l},run=function(m,n)return k.listContents(list(m,n.LIST))end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Operators"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Operators",{name="Operators",color={89,192,89}})

local function binary(l,m,n,o,p,q)
j:defineBlock({id=l,category="Operators",shape=n,
label="{A} "..m.." {B}",
inputs={A={type=o,default=q and q[1]},B={type=o,default=q and q[2]}},
run=function(r,s)return p(s.A,s.B)end})
end

binary("op_add","+","reporter","number",function(l,m)return l+m end)
binary("op_sub","-","reporter","number",function(l,m)return l-m end)
binary("op_mul","*","reporter","number",function(l,m)return l*m end)
binary("op_div","/","reporter","number",function(l,m)return l/m end)
binary("op_mod","mod","reporter","number",function(l,m)
if m==0 then return 0/0 end
local n=math.fmod(l,m)
if n/m<0 then n=n+m end
return n
end)

binary("op_gt",">","boolean","any",function(l,m)return k.less(m,l)end,{0,50})
binary("op_lt","<","boolean","any",function(l,m)return k.less(l,m)end,{0,50})
binary("op_eq","=","boolean","any",function(l,m)return k.equals(l,m)end,{0,50})



local function logic(l,m,n)
j:defineBlock({id=l,category="Operators",shape="boolean",label="{A} "..m.." {B}",
inputs={A={type="boolean",raw=true,lazy=true},B={type="boolean",raw=true,lazy=true}},
run=function(o)
local p=o:input("A")
if k.toBool(p)==n then return p end
return o:input("B")
end})
end
logic("op_and","and",false)
logic("op_or","or",true)

j:defineBlock({id="op_not",category="Operators",shape="boolean",label="not {A}",
inputs={A={type="boolean"}},run=function(l,m)return not m.A end})



j:defineBlock({id="op_if_else",category="Operators",shape="reporter",label="if {COND} then {A} else {B}",
inputs={COND={type="boolean",lazy=true},A={type="any",default=1,lazy=true},B={type="any",default=0,lazy=true}},
run=function(l)
if l:input("COND")then return l:input("A")end
return l:input("B")
end})


j:defineBlock({id="op_random",category="Operators",shape="reporter",
label="pick random {FROM} to {TO}",
inputs={FROM={type="number",default=1},TO={type="number",default=10}},
run=function(l,m)

local n=2147483647
local function whole(o)o=math.max(-n,math.min(n,o))return o>=0 and math.floor(o)or-math.floor(-o)end
local o,p=whole(m.FROM),whole(m.TO)
if o>p then error("interval is empty",0)end
return math.random(o,p)
end})


local function str(l)
if type(l)=="string"then return l end
if type(l)=="number"then return k.toString(l)end
error("expected text, got "..k.typeName(l),0)
end


j:defineBlock({id="op_join",category="Operators",shape="reporter",label="join {A} {B}",
inputs={A={type="any",default="apple ",raw=true},B={type="any",default="banana",raw=true}},
run=function(l,m)
if type(m.A)~="string"and type(m.A)~="number"then error("attempt to concatenate "..k.typeName(m.A),0)end
if type(m.B)~="string"and type(m.B)~="number"then error("attempt to concatenate "..k.typeName(m.B),0)end
local n,o=str(m.A),str(m.B)
if#n+#o>k.LIMITS.MAX_STRING then error("string too long",0)end
return n..o
end})


j:defineBlock({id="op_letter",category="Operators",shape="reporter",label="letter {N} of {S}",
inputs={N={type="number",default=1},S={type="any",default="apple",raw=true}},
run=function(l,m)
local n=m.N>=0 and math.floor(m.N)or-math.floor(-m.N)
if n~=n or n==math.huge or n==-math.huge then return""end
return string.sub(str(m.S),n,n)
end})


j:defineBlock({id="op_length",category="Operators",shape="reporter",label="length of {S}",
inputs={S={type="any",default="apple",raw=true}},run=function(l,m)return#str(m.S)end})


j:defineBlock({id="op_contains",category="Operators",shape="boolean",label="{S} contains {T}",
inputs={S={type="any",default="apple",raw=true},T={type="any",default="a",raw=true}},
run=function(l,m)return string.find(str(m.S),str(m.T),1,true)~=nil end})


j:defineBlock({id="op_tonumber",category="Operators",shape="reporter",output="any",label="tonumber {A}",
inputs={A={type="any",default="10",raw=true}},
run=function(l,m)
if type(m.A)=="number"then return m.A end
if type(m.A)=="string"then return k.parseNumber(m.A)end
return nil
end})
j:defineBlock({id="op_tostring",category="Operators",shape="reporter",label="tostring {A}",
inputs={A={type="any",default=10,raw=true}},
run=function(l,m)return k.toString(m.A)end})


j:defineBlock({id="op_nil",category="Operators",shape="reporter",output="any",label="nil",
run=function()return nil end})


j:defineBlock({id="op_round",category="Operators",shape="reporter",label="round {A}",
inputs={A={type="number"}},run=function(l,m)return k.round(m.A)end})


j:defineBlock({id="op_pi",category="Operators",shape="reporter",label="pi",run=function()return math.pi end})

local l={
abs=math.abs,floor=math.floor,ceiling=math.ceil,sqrt=math.sqrt,
sin=math.sin,cos=math.cos,tan=math.tan,
asin=math.asin,acos=math.acos,atan=math.atan,
ln=math.log,log=function(l)return math.log(l)/math.log(10)end,
["e ^"]=math.exp,["10 ^"]=function(l)return 10^l end,
}
j:defineBlock({id="op_math",category="Operators",shape="reporter",label="{FN} of {A}",
inputs={FN={type="string",default="abs",options={"abs","floor","ceiling","sqrt","sin","cos","tan","asin","acos","atan","ln","log","e ^","10 ^"}},
A={type="number"}},
run=function(m,n)local o=l[n.FN]return o and o(n.A)or 0 end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Output"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Output",{name="Output",color={15,189,140}})

j:defineBlock({id="out_print",category="Output",shape="stack",label="print {TEXT}",
inputs={TEXT={type="string",default="Hello!"}},
run=function(l,m)l:say(m.TEXT,"say")end})

j:defineBlock({id="out_clear",category="Output",shape="stack",label="clear output",
run=function(l)if l.interp.opts.clear then l.interp.opts.clear()end end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Sensing"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Sensing",{name="Sensing",color={92,177,214}})

j:defineBlock({id="sensing_ask",category="Sensing",shape="stack",label="ask {PROMPT} and wait",
inputs={PROMPT={type="string",default="What's your name?"}},
run=function(l,m)
local n=l.interp.opts.ask
local o=l.thread
o.asking=true
local p,q=pcall(function()return n and k.toString(n(m.PROMPT))or""end)
o.asking=false
if not p then error(q,0)end
l.interp.answer=string.sub(q,1,k.LIMITS.MAX_STRING)
end})

j:defineBlock({id="sensing_answer",category="Sensing",shape="reporter",label="answer",
run=function(l)return l.interp.answer end})



j:defineBlock({id="sensing_keypressed",category="Sensing",shape="boolean",label="key {KEY} pressed?",
inputs={KEY={type="string",default="space",options=k.KEYS,reporters=true}},
run=function(l,m)return l.interp:keyDown(m.KEY)end})

j:defineBlock({id="sensing_mousedown",category="Sensing",shape="boolean",label="mouse down?",
run=function(l)return l.interp:mouseDown()end})

local l={"year","month","date","day of week","hour","minute","second"}
j:defineBlock({id="sensing_current",category="Sensing",shape="reporter",label="current {UNIT}",
inputs={UNIT={type="string",default="year",options=l}},
run=function(m,n)
local o=m.interp:localDate()
local p={year=o.year,month=o.month,date=o.day,["day of week"]=o.wday,
hour=o.hour,minute=o.min,second=o.sec}
return p[n.UNIT]or 0
end})

j:defineBlock({id="sensing_dayssince2000",category="Sensing",shape="reporter",label="days since 2000",
run=function(m)return m.interp:daysSince2000()end})

j:defineBlock({id="sensing_timer",category="Sensing",shape="reporter",label="timer",
run=function(m)return m.interp:timer()end})

j:defineBlock({id="sensing_reset_timer",category="Sensing",shape="stack",label="reset timer",
run=function(m)m.interp:resetTimer()end})
end

end end
do local g=e for h,i in ipairs({"Lang","Blocks","Variables"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
return function(j,k)
j:defineCategory("Variables",{name="Variables",color={255,140,26}})

j:defineBlock({id="data_set",category="Variables",shape="stack",label="set {NAME} to {VALUE}",
inputs={NAME={type="variable",default="my variable"},VALUE={type="any",default=0}},
run=function(l,m)l.interp:setVar(m.NAME,m.VALUE)end})

j:defineBlock({id="data_change",category="Variables",shape="stack",label="change {NAME} by {BY}",
inputs={NAME={type="variable",default="my variable"},BY={type="number",default=1}},
run=function(l,m)l.interp:setVar(m.NAME,k.toNumber(l.interp.vars[m.NAME])+m.BY)end})

j:defineBlock({id="data_get",category="Variables",shape="reporter",output="any",label="{NAME}",
inputs={NAME={type="variable",default="my variable"}},

run=function(l,m)return l.interp.vars[m.NAME]end})
end

end end
do local g=e for h,i in ipairs({"Lang","Core","Interpreter"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


















local j=i(h.Parent.Values)

local k={}
k.__index=k

local l=j.LIMITS
local m=0.1


local function daysFromCivil(n,o,p)
if o<=2 then n=n-1 end
local q=math.floor(n/400)
local r=n-q*400
local s=math.floor((153*(o+(o>2 and-3 or 9))+2)/5)+p-1
local t=r*365+math.floor(r/4)-math.floor(r/100)+s
return q*146097+t-719468
end


local n={}
n.__index=n
function n:stack(o)return self.interp:runStack(self.thread,self.block.stacks[o]or{})end
function n:input(o)return self.interp:evalInput(self.thread,self.block,o)end
function n:alive()return not(self.thread.stopped or self.interp.halted)end
function n:tick()self.interp:tick(self.thread)end
function n:loopStep()self.interp:loopStep(self.thread)end
function n:yield()self.interp:pause(self.thread)end
function n:warp(o)if o then self.interp:enterWarp(self.thread)else self.interp:exitWarp(self.thread)end end
function n:stopOthers()self.interp:stopOthers(self.thread)end
function n:wait(o)self.interp:sleep(self.thread,o)end
function n:say(o,p)self.interp:say(o,p)end
function n:stopAll()self.interp:stop()end

function k.new(o,p)
p=p or{}
local q=setmetatable({},k)
q.registry=o
q.opts=p
q.spawn=p.spawn or(task and task.spawn)or function(r)r()end
q.defer=p.defer or(task and task.defer)or nil
q.cancel=p.cancel or(task and task.cancel)or nil
q.turn=p.turn or(task and task.defer and function()
local r=coroutine.running()
task.defer(r)
coroutine.yield()
end)or nil
q.wait=p.wait or(task and task.wait)or function()end
q.clock=p.clock or os.clock
q.budget=p.budget or 500
q.vars,q.lists,q.threads,q.watchers={},{},{},{}
q.program,q.halted,q.running=nil,false,false
q.active,q.steps,q.answer,q.timerStart,q.runId=0,0,"",0,0
q.counter=0
q.nthreads,q.starts,q.lines,q.frameStart=0,0,0,nil
q.uncounted,q.throttled=false,false
return q
end



function k:_frameCheck()
local o=self.clock()
local p=self.frameStart
if p==nil or o<p or o-p>=l.FRAME_WINDOW then
self.frameStart,self.starts,self.lines=o,0,0
end
return o
end


function k:_overBudget()
local o=self:_frameCheck()
return o-self.frameStart>=l.FRAME_SECONDS
end


function k:say(o,p)
local q=j.toString(o)
if#q>l.MAX_PRINT then
local r=l.MAX_PRINT
while r>0 do
local s=string.byte(q,r+1)
if s and s>=0x80 and s<0xC0 then r=r-1 else break end
end
q=string.sub(q,1,r).."..."
end
self:_frameCheck()
self.lines=self.lines+1
if self.lines>l.MAX_LINES_PER_FRAME then
if self.throttled then return end
self.throttled,q,p=true,"output throttled (too many lines per frame)","say"
end
if self.opts.output then self.opts.output(q,p or"say")else print(q)end
end


function k:setVar(o,p)
local q=self.vars
if q[o]==nil then
if#o>l.MAX_NAME then error("name too long",0)end
local r=0
for s in pairs(q)do r=r+1 end
if r>=l.MAX_VARS then error("too many variables",0)end
end
q[o]=j.limitString(p)
end

function k:list(o)
local p=self.lists[o]
if p then return p end
if#o>l.MAX_NAME then error("name too long",0)end
local q=0
for r in pairs(self.lists)do q=q+1 end
if q>=l.MAX_LISTS then error("too many lists",0)end
p={}
self.lists[o]=p
return p
end


function k:checkListGrow(o,p)
j.limitString(p)
if#o>=l.MAX_LIST then error("list too long",0)end
local q=0
for r,s in pairs(self.lists)do q=q+#s end
if q>=l.MAX_LISTS_TOTAL_ITEMS then error("too many list items",0)end
end

function k:timer()return self.clock()-self.timerStart end
function k:resetTimer()self.timerStart=self.clock()end



function k:enterWarp(o)
if(o.warp or 0)==0 then o.warpStart=self.clock()end
o.warp=(o.warp or 0)+1
end

function k:exitWarp(o)
o.warp=math.max(0,(o.warp or 0)-1)
end


function k:pause(o)
if o and(o.warp or 0)>0 then
if self.clock()-o.warpStart<l.WARP_SECONDS then return end
o.warpStart=self.clock()
end
self.wait()
self:_frameCheck()
end



function k:tick(o)
self.steps=self.steps+1
if self.steps>=self.budget then
self.steps=0
self:pause(o)
elseif self.steps%16==0 and self:_overBudget()then
self:pause(o)
end
end



function k:loopStep(o)
self:tick(o)
if(o.warp or 0)>0 then return end
if self:_overBudget()then
self.steps=0
self.wait()
self:_frameCheck()
elseif self.turn then
self.turn()
end
end


function k:resetData()
self.vars,self.lists,self.counter,self.answer={},{},0,""
end



function k:sleep(o,p)
local q,r=p,true
while r or q>0 do
r=false
local s=q<m and q or m
self.wait(s)
q=q-s
if o.stopped or self.halted then return end
end
end

function k:stopOthers(o)
local p={}
for q in pairs(self.threads)do
if q~=o then p[#p+1]=q end
end
for q,r in ipairs(p)do self:_kill(r)end
end


function k:_kill(o)
o.stopped=true
if not o.asking then self:_cancel(o.handle)end
self:_retire(o)
end


function k:_retire(o)
if o.retired then return end
o.retired,o.done=true,true
if o.runId~=self.runId then return end
if self.threads[o]then
self.threads[o]=nil
self.nthreads=self.nthreads-1
end
self.active=self.active-1
if self.active==0 then self:_finish()end
end


function k:_threadFor(o)
for p in pairs(self.threads)do
if p.script==o and not p.retired then return p end
end
end


function k:localDate()
local o=self.opts.date and self.opts.date()
if not o and DateTime then
local p=DateTime.now():ToLocalTime()
o={year=p.Year,month=p.Month,day=p.Day,hour=p.Hour,min=p.Minute,sec=p.Second}
end
o=o or os.date("*t")
local p=daysFromCivil(o.year,o.month,o.day)
return{year=o.year,month=o.month,day=o.day,wday=(p+4)%7+1,
hour=o.hour or 0,min=o.min or 0,sec=o.sec or 0,days=p}
end

function k:daysSince2000()
local o=self:localDate()
return o.days-daysFromCivil(2000,1,1)+(o.hour*3600+o.min*60+o.sec)/86400
end

function k:keyDown(o)return self.opts.keyDown~=nil and self.opts.keyDown(o)==true end
function k:mouseDown()return self.opts.mouseDown~=nil and self.opts.mouseDown()==true end

function k:fail(o,p)
self:stop()
if self.opts.onError then self.opts.onError(tostring(o),p)else warn("[BlockScript] "..tostring(o))end
end

function k:_finish()
if not self.running then return end
self.running=false
if self.opts.onFinish then self.opts.onFinish()end
end


function k:_cancel(o)
if o~=nil and self.cancel and o~=coroutine.running()then pcall(self.cancel,o)end
end

function k:stop()
self.halted=true
for o in pairs(self.threads)do
o.stopped,o.retired=true,true
if not o.asking then self:_cancel(o.handle)end
end
for o,p in ipairs(self.watchers)do self:_cancel(p)end
self.threads,self.watchers,self.nthreads={},{},0
self:_finish()
end



function k:execBlock(o,p)
local q=self.registry:get(p.op)
if not q then
o.cur=p
error("Unknown block: "..tostring(p.op),0)
end
local r=(o.execDepth or 0)+1
if r>l.MAX_EXEC_DEPTH then
o.cur=p
error("blocks nested too deep",0)
end
o.execDepth=r
local s=o.cur
o.cur=p
local t=setmetatable({interp=self,thread=o,block=p,def=q},n)
local u={}
for v,w in pairs(q.inputs)do
if not w.lazy then u[v]=self:evalInput(o,p,v)end
end
local v
if not(self.halted or o.stopped)then
self:tick(o)
v=q.run(t,u)
end
o.execDepth=r-1
o.cur=s
return v
end

function k:evalInput(o,p,q)
local r=self.registry:get(p.op)
local s=r.inputs[q]
local t=p.inputs[q]
if type(t)=="table"and t.op then t=self:execBlock(o,t)end
if s.raw then return t end
return j.coerce(s.type,t)
end


function k:runStack(o,p,q)
for r=q or 1,#p do
if o.stopped or self.halted then return"STOP"end
local s=self:execBlock(o,p[r])
if s then return s end
end
return nil
end




function k:_launch(o,p)
if self.defer then return self.defer(o)end
if p then return self.spawn(function()self.wait()o()end)end
return self.spawn(o)
end


function k:_startThread(o,p,q)
if self.nthreads>=l.MAX_THREADS then
self:fail("too many scripts running")
return nil
end
if not self.uncounted then
self:_frameCheck()
self.starts=self.starts+1
if self.starts>l.MAX_STARTS_PER_FRAME then
self:fail("too many scripts running")
return nil
end
end
local r={stopped=false,done=false,script=o,runId=self.runId}
self.threads[r]=true
self.nthreads=self.nthreads+1
self.active=self.active+1
local s=self.runId
r.handle=self:_launch(function()
if r.stopped or self.halted or s~=self.runId then return end
self:_frameCheck()
local t,u=pcall(self.runStack,self,r,o.blocks,p)
if not t and not self.halted and s==self.runId then self:fail(u,r.cur)end
self:_retire(r)
end,q)
return r
end

local function hatArgs(o,p,q)
local r,s={stopped=false},{}
for t in pairs(q.inputs)do s[t]=o:evalInput(r,p,t)end
return s
end



function k:_startWatchers()
local o=false
local p=self.runId
for q,r in ipairs(self.program.scripts)do
local s=r.blocks[1]
local t=s and self.registry:get(s.op)
if t and t.shape=="hat"and(t.hat.persistent or t.hat.poll)then
o=true
if t.hat.poll then
local u=self:_launch(function()
local u=false
while not self.halted and p==self.runId do
if not self:_threadFor(r)then
local v,w=pcall(function()return t.hat.poll(hatArgs(self,s,t),self)end)
if not v then self:fail(w,s)return end
if w and not u then self:_startThread(r,2,true)end
u=w and true or false
end
self.wait()
end
end,false)
if u~=nil then table.insert(self.watchers,u)end
end
end
end
if o then self.active=self.active+1 end
end



function k:fire(o,p,q)
local r={}
if not self.program then return r end
for s,t in ipairs(self.program.scripts)do
local u=t.blocks[1]
local v=u and self.registry:get(u.op)
if v and v.shape=="hat"and v.hat.event==o then
local w=true
if v.hat.filter then
local x,y=pcall(function()return v.hat.filter(hatArgs(self,u,v),p)end)
if not x then self:fail(y,u)break end
w=y
end
if w then
local x=self:_threadFor(t)
if x and v.hat.once then
w=false
elseif x then
self:_kill(x)
end
end
if w then
local x=self:_startThread(t,2,q~=nil)
if not x then break end
table.insert(r,x)
end
end
end
return r
end

function k:run(o)
self:stop()
self.program=o
self.runId=self.runId+1
self.threads,self.watchers={},{}
self.halted,self.running,self.active,self.steps=false,true,1,0
self.nthreads,self.starts,self.lines,self.frameStart,self.throttled=0,0,0,nil,false
self:resetTimer()
self.uncounted=true
self:fire("run")
self.uncounted=false
if not self.halted then self:_startWatchers()end
self.active=self.active-1
if self.active==0 then self:_finish()end
end

return k

end end
do local g=e for h,i in ipairs({"Lang","Core","Plugins"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


local j={}

local function deepCopy(k,l)
if type(k)~="table"then return k end
l=l or{}
if l[k]then return l[k]end
local m={}
l[k]=m
for n,o in pairs(k)do m[deepCopy(n,l)]=deepCopy(o,l)end
return m
end


function j.load(k,l)
local m="plugin"
local n,o={},{}
local p,q=pcall(function()
assert(type(l)=="table"and type(l.GetData)=="function","not a plugin (no GetData)")
local p=l:GetData()
assert(type(p)=="table","GetData must return a table")
assert(type(p.Name)=="string"and p.Name~="","plugin needs a Name")
m=p.Name
k.plugins=k.plugins or{}
assert(not k.plugins[m],"plugin already loaded")


for q,r in ipairs(p.Categories or{})do
assert(type(r)=="table"and type(r.id)=="string","category needs a string id")
if not k.categories[r.id]then
k:defineCategory(r.id,r)
table.insert(n,r.id)
end
end
for q,r in ipairs(p.Blocks or{})do
assert(type(r)=="table"and type(r.id)=="string","block needs a string id")
assert(not k.blocks[r.id],"block id already exists: "..r.id)

local s={}
for t,u in pairs(r)do s[t]=deepCopy(u)end
k:defineBlock(s)
o[r.id]=true
end
end)
if not p then
k:removeBlocks(o)
for r,s in ipairs(n)do k:removeCategory(s)end

return m..": "..(string.gsub(tostring(q),"^[^\n:]*:%d+: ",""))
end
k.plugins[m]={categories=n,blocks=o}
return nil
end

return j

end end
do local g=e for h,i in ipairs({"Lang","Core","Registry"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


























local j={}
j.__index=j

local k={hat=true,stack=true,cap=true,c=true,reporter=true,boolean=true}

local function parseLabel(l)
local m,n={},1
while true do
local o,p,q=string.find(l,"{(@?[%w_]+)}",n)
if not o then break end
if o>n then table.insert(m,{text=string.sub(l,n,o-1)})end
if string.sub(q,1,1)=="@"then table.insert(m,{icon=string.sub(q,2)})
else table.insert(m,{input=q})end
n=p+1
end
if n<=#l then table.insert(m,{text=string.sub(l,n)})end
return m
end

function j.new()
return setmetatable({blocks={},blockOrder={},categories={},categoryOrder={}},j)
end

function j:defineCategory(l,m)
assert(type(l)=="string","category id must be a string")
m=m or{}
if not self.categories[l]then table.insert(self.categoryOrder,l)end
self.categories[l]={id=l,name=m.name or l,color=m.color or{150,150,150}}
end

function j:defineBlock(l)
assert(type(l)=="table"and type(l.id)=="string","block needs a string id")
assert(not self.blocks[l.id],"duplicate block id: "..l.id)
assert(k[l.shape],"bad shape for "..l.id)
assert(self.categories[l.category],"unknown category for "..l.id)
l.inputs=l.inputs or{}
l.stacks=l.stacks or{}
l.label=l.label or l.id
l.segments=parseLabel(l.label)
if l.shape=="hat"then
assert(l.hat and l.hat.event,"hat block needs hat.event: "..l.id)
l.run=l.run or function()end
end
assert(type(l.run)=="function","block needs run(): "..l.id)
for m,n in ipairs(l.segments)do
if n.input then assert(l.inputs[n.input],l.id..": label uses undeclared input "..n.input)end
end
self.blocks[l.id]=l
table.insert(self.blockOrder,l.id)
return l
end


function j:removeBlocks(l)
local m,n={},0
for o,p in ipairs(self.blockOrder)do
if l[p]then self.blocks[p]=nil;n=n+1 else table.insert(m,p)end
end
self.blockOrder=m
return n
end


function j:removeCategory(l)
if not self.categories[l]then return false end
self.categories[l]=nil
local m={}
for n,o in ipairs(self.categoryOrder)do
if o~=l then table.insert(m,o)end
end
self.categoryOrder=m
return true
end

function j:get(l)return self.blocks[l]end


function j:shapeOf(l)
local m=self.blocks[l.op]
if m.shapeOf then return m.shapeOf(l)end
return m.shape
end



function j:accepts(l,m,n,o)
local p=l and l.inputs[m]
if not p then return false end
if n~="reporter"and n~="boolean"then return false end
local q=p.reporters
if q==nil then
q=not(p.options~=nil or p.type=="variable"or p.type=="list"or p.type=="param")
end
if not q then return false end
if p.type=="boolean"then return n=="boolean"or(o~=nil and o.output=="any")end
return true
end



function j:wrapSlot(l)
local m=l and self.blocks[l.op]
local n=m and m.stacks[1]
if not n then return nil end
local o=l.stacks and l.stacks[n]
if o and#o>0 then return nil end
return n
end

function j:listByCategory(l)
local m={}
for n,o in ipairs(self.blockOrder)do
if self.blocks[o].category==l and self.blocks[o].listed~=false then table.insert(m,self.blocks[o])end
end
return m
end


function j:createBlock(l)
local m=assert(self.blocks[l],"unknown block: "..tostring(l))
local n={op=l,inputs={},stacks={}}
for o,p in pairs(m.inputs)do n.inputs[o]=p.default end
for o,p in ipairs(m.stacks)do n.stacks[p]={}end
return n
end

return j

end end
do local g=e for h,i in ipairs({"Lang","Core","Validate"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)









local j=i(h.Parent.Values)
local k=j.LIMITS
local l={VERSION=1}

local m=k.MAX_DEPTH

local function isValueShape(n)return n=="reporter"or n=="boolean"end



function l.checkSize(n)
if type(n)~="table"or type(n.scripts)~="table"then return nil end
if#n.scripts>k.MAX_SCRIPTS then return"too many scripts (max "..k.MAX_SCRIPTS..")"end
local o=0
local function walk(p,q)
if type(p)~="table"then return nil end
o=o+1
if o>k.MAX_BLOCKS then return"too many blocks (max "..k.MAX_BLOCKS..")"end
if q>m then return"blocks nested too deep"end
if type(p.inputs)=="table"then
for r,s in pairs(p.inputs)do
if type(s)=="table"then local t=walk(s,q+1)if t then return t end end
end
end
if type(p.stacks)=="table"then
for r,s in pairs(p.stacks)do
if type(s)=="table"then
for t=1,#s do local u=walk(s[t],q+1)if u then return u end end
end
end
end
return nil
end
for p=1,#n.scripts do
local q=n.scripts[p]
if type(q)=="table"and type(q.blocks)=="table"then
for r=1,#q.blocks do local s=walk(q.blocks[r],1)if s then return s end end
end
end
return nil
end

local n

local function block(o,p,q,r,s)
if type(p)~="table"then return nil,q..": block must be an object"end
if r>m then return nil,q..": blocks nested too deep"end
local t=type(p.op)=="string"and o:get(p.op)
if not t then return nil,q..": unknown block "..tostring(p.op)end
local u=isValueShape(t.shape)
if s and not u then return nil,q..": "..t.id.." cannot go in an input"end
if not s and u then return nil,q..": "..t.id.." cannot be a stack block"end

local v=o:createBlock(p.op)
if p.inputs~=nil and type(p.inputs)~="table"then return nil,q..": inputs must be an object"end
for w,x in pairs(p.inputs or{})do
if t.inputs[w]then
local y=q.."."..tostring(w)
local z=type(x)
if z=="table"then
local A,C=block(o,x,y,r+1,true)
if not A then return nil,C end
if not o:accepts(t,w,o:get(A.op).shape,o:get(A.op))then
return nil,y..": "..A.op.." cannot go in the "..w.." slot of "..t.id
end
v.inputs[w]=A
elseif z=="string"or z=="number"or z=="boolean"then
if z=="string"and#x>k.MAX_LITERAL then return nil,y..": text longer than "..k.MAX_LITERAL.." characters"end
if z=="string"and p.op=="custom_define"and w=="NAME"and#x>k.MAX_NAME then
return nil,y..": name longer than "..k.MAX_NAME.." characters"
end
v.inputs[w]=x
else
return nil,y..": input must be a value or a block"
end
end
end

if p.stacks~=nil and type(p.stacks)~="table"then return nil,q..": stacks must be an object"end
for w,x in ipairs(t.stacks)do
local y=p.stacks and p.stacks[x]
if y~=nil then
if type(y)~="table"then return nil,q.."."..x..": stack must be a list"end
local z,A=n(o,y,q.."."..x,r+1,false)
if not z then return nil,A end
v.stacks[x]=z
end
end
return v
end


function n(o,p,q,r,s)
local t={}
for u=1,#p do
local v=q.."["..u.."]"
local w,x=block(o,p[u],v,r,false)
if not w then return nil,x end
local y=o:get(w.op)
if y.shape=="hat"and not(s and u==1)then
return nil,v..": "..y.id.." can only start a script"
end
if u<#p and o:shapeOf(w)=="cap"then
return nil,v..": nothing can follow "..y.id
end
t[u]=w
end
return t
end

function l.program(o,p)
if type(o)~="table"then return nil,"program must be an object"end
if type(o.blockscript)=="number"and o.blockscript>l.VERSION then
return nil,"saved by a newer BlockScript (format "..o.blockscript..")"
end
if type(o.scripts)~="table"then return nil,"program has no scripts list"end
local q=l.checkSize(o)
if q then return nil,q end
local r={}
for s=1,#o.scripts do
local t=o.scripts[s]
local u="scripts["..s.."]"
if type(t)~="table"or type(t.blocks)~="table"or#t.blocks==0 then
return nil,u..": needs a non-empty blocks list"
end
local v,w
local x=#t.blocks==1 and type(t.blocks[1])=="table"and type(t.blocks[1].op)=="string"and p:get(t.blocks[1].op)
if x and isValueShape(x.shape)then
local y,z=block(p,t.blocks[1],u..".blocks[1]",1,true)
if not y then return nil,z end
v={y}
else
v,w=n(p,t.blocks,u..".blocks",1,true)
if not v then return nil,w end
end
local y=type(t.x)=="number"and t.x or 0
local z=type(t.y)=="number"and t.y or 0
r[s]={x=math.max(0,y),y=math.max(0,z),blocks=v}
end
return{scripts=r}
end

return l

end end
do local g=e for h,i in ipairs({"Lang","Core","Values"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)

local j={}



j.LIMITS={
MAX_THREADS=200,
MAX_STARTS_PER_FRAME=50,
FRAME_SECONDS=0.008,
FRAME_WINDOW=0.015,
WARP_SECONDS=0.5,
MAX_STRING=1000000,
MAX_LIST=200000,
MAX_LISTS_TOTAL_ITEMS=1000000,MAX_VARS=1000,MAX_LISTS=200,
MAX_PRINT=10000,
MAX_LINES_PER_FRAME=100,
MAX_EXEC_DEPTH=3000,
MAX_CALL_DEPTH=500,
MAX_SCRIPTS=1000,MAX_BLOCKS=20000,
MAX_JSON_BYTES=1000000,
MAX_NAME=200,MAX_PARAMS=16,MAX_CUSTOM=500,
MAX_LITERAL=10000,MAX_DEPTH=100,
}
local k=j.LIMITS


function j.typeName(l)
if l==nil then return"nil"end
return type(l)
end



function j.parseNumber(l)
local m=string.match(l,"^%s*(.-)%s*$")
if m==""or string.find(m,"[nNpP]")then return nil end
local n=tonumber(m)
if n==nil or n~=n then return nil end
return n+0.0
end



function j.toNumber(l)
if type(l)=="number"then return l+0.0 end
if type(l)=="string"then
local m=j.parseNumber(l)
if m~=nil then return m end
end
error("expected a number, got "..(type(l)=="string"and"text \""..string.sub(l,1,20).."\""or j.typeName(l)),0)
end


function j.limitString(l)
if type(l)=="string"and#l>k.MAX_STRING then error("string too long",0)end
return l
end


function j.toString(l)
if type(l)=="number"then
if l~=l then return"nan"end
if l==math.huge then return"inf"end
if l==-math.huge then return"-inf"end
return string.format("%.14g",l)
end
return tostring(l)
end


function j.round(l)
if l>=0 then return math.floor(l+0.5)end
return-math.floor(-l+0.5)
end



function j.chars(l)
local m={}
if utf8 and utf8.len(l)then
for n in string.gmatch(l,utf8.charpattern)do m[#m+1]=n end
else
for n=1,#l do m[n]=string.sub(l,n,n)end
end
return m
end


function j.length(l)
return(utf8 and utf8.len(l))or#l
end


function j.letter(l,m)
local n=j.length(l)
if m~=m or m<1 or m>n then return""end
if utf8 and utf8.len(l)then
local o=utf8.offset(l,m)
local p=utf8.offset(l,m+1)
return string.sub(l,o,(p or#l+1)-1)
end
return string.sub(l,m,m)
end




function j.listIndex(l,m,n)
if type(l)=="string"then
if l=="all"then return n and"all"or nil end
if l=="last"then return m>0 and m or nil end
if l=="random"or l=="any"then return m>0 and math.random(1,m)or nil end
return nil
end
if type(l)~="number"or l~=math.floor(l)or l<1 or l>m then return nil end
return math.floor(l)
end


function j.toBool(l)
return l~=nil and l~=false
end


function j.equals(l,m)return l==m end


function j.less(l,m)
local n,o=type(l),type(m)
if n==o and(n=="number"or n=="string")then return l<m end
error("attempt to compare "..j.typeName(l).." with "..j.typeName(m),0)
end


function j.listContents(l)
local m=true
for n,o in ipairs(l)do
if not(type(o)=="string"and j.length(o)==1)then m=false break end
end
local n,o={},0
for p,q in ipairs(l)do
local r=j.toString(q)
o=o+#r+1
if o>k.MAX_STRING then error("string too long",0)end
n[p]=r
end
return table.concat(n,m and""or" ")
end


j.KEYS={"space","up arrow","down arrow","right arrow","left arrow","any"}
for l=string.byte("a"),string.byte("z")do table.insert(j.KEYS,string.char(l))end
for l=0,9 do table.insert(j.KEYS,tostring(l))end


function j.coerce(l,m)
if l=="number"then return j.toNumber(m)end
if l=="string"or l=="variable"or l=="list"or l=="param"then return j.toString(m)end
if l=="boolean"then return j.toBool(m)end
return m
end

return j

end end
do local g=e for h,i in ipairs({"Plugin"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)











local j={}
j.__index=j

local k={hat=true,stack=true,cap=true,c=true,reporter=true,boolean=true}



local l={}
l.__index=l

function l:SetLabel(m)self.label=m;return self end
function l:SetShape(m)
assert(k[m],"bad shape: "..tostring(m))
self.shape=m
return self
end
function l:SetCategory(m)self.category=m;return self end
function l:SetRun(m)
assert(type(m)=="function","run must be a function")
self.run=m
return self
end
function l:SetInput(m,n)self.inputs[m]=n;return self end
function l:RemoveInput(m)self.inputs[m]=nil;return self end

function l:SetStacks(m)self.stacks=m;return self end
function l:SetHat(m)self.hat=m;return self end
function l:Set(m,n)self[m]=n;return self end


function l:ToDef()
local m={}
for n,o in pairs(self)do m[n]=o end
return m
end


function j.new(m)
m=m or{}
assert(type(m)=="table","Plugin.new expects a table")
local n=setmetatable({},j)
n._data={}
for o,p in pairs(m)do n._data[o]=p end
if n._data.Name==nil then n._data.Name="Unnamed plugin"end
if n._data.Description==nil then n._data.Description=""end
n._categories,n._categoryById={},{}
n._blocks,n._blockById={},{}
return n
end



function j:CreateCategory(m,n)
assert(type(m)=="string"and m~="","category id must be a non-empty string")
local o=self._categoryById[m]
if o then return o end
n=n or{}
o={id=m,name=n.name or m,color=n.color or{150,150,150}}
self._categoryById[m]=o
table.insert(self._categories,o)
return o
end





function j:CreateBlock(m,n)
assert(type(m)=="string"and m~="","block id must be a non-empty string")
assert(not self._blockById[m],"duplicate block id in plugin: "..m)
n=n or{}
assert(type(n)=="table","CreateBlock fields must be a table")
local o=setmetatable({},l)
for p,q in pairs(n)do o[p]=q end
o.id=m
o.shape=o.shape or"stack"
assert(k[o.shape],"bad shape for "..m..": "..tostring(o.shape))
o.category=o.category or(self._categories[#self._categories]and self._categories[#self._categories].id)
assert(o.category,"block "..m.." has no category: pass fields.category or call CreateCategory first")
o.label=o.label or m
o.inputs=o.inputs or{}
o.stacks=o.stacks or{}
self._blockById[m]=o
table.insert(self._blocks,o)
return o
end




function j:GetData()
local m={}
for n,o in pairs(self._data)do m[n]=o end
m.Categories=table.move(self._categories,1,#self._categories,1,{})
m.Blocks=table.move(self._blocks,1,#self._blocks,1,{})
return m
end

j.Block=l

return j

end end
do local g=e for h,i in ipairs({"UI","Assets"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)






local j={}

j.BASE="https://raw.githubusercontent.com/Horizon-Developments/scratch-luau/refs/heads/main/"


j.PATHS={
flag="assets/icons/flag.png",
loop="assets/icons/loop.png",
}

local k={}
local l={}

local function loader()
local m,n=pcall(function()return loadasset end)
if m and type(n)=="function"then return n end
return nil
end

local function fetch(m,n)
local o,p=j.PATHS[m],loader()
if not o or not p then k[m]=false;return n(nil)end
l[m]={n}
local function work()
local q,r=pcall(function()return p(j.BASE..o)end)
local s=q and type(r)=="string"and r~=""and r or nil
k[m]=s or false
local t=l[m]
l[m]=nil
for u,v in ipairs(t)do v(s)end
end
if task and task.spawn then task.spawn(work)else work()end
end


function j.get(m,n)
local o=k[m]
if o~=nil then return n(o or nil)end
if l[m]then table.insert(l[m],n)return end
fetch(m,n)
end

function j.apply(m,n)
j.get(n,function(o)
if o and m.Parent then m.Image=o end
end)
end


function j.icon(m,n,o,p)
local q=Instance.new("ImageLabel")
q.Name="Icon_"..n
q.BackgroundTransparency=1
q.BorderSizePixel=0
q.Size=UDim2.new(0,o,0,o)
q.ScaleType=Enum.ScaleType.Fit
q.LayoutOrder=p or 0
q.Image=""
q.Parent=m
j.apply(q,n)
return q
end

return j

end end
do local g=e for h,i in ipairs({"UI","BlockView"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)







local j=i(h.Parent.Theme)
local k=i(h.Parent.Shapes)
local l=i(h.Parent.Assets)

local m={}
m.__index=m





function m.new(n,o,p)
return setmetatable({registry=n,map=o,targets=p},m)
end

function m:_target(n,o,p)
if self.targets then self.targets.inputs[n]={block=o,name=p}end
end


function m:_field(n,o,p)
if self.targets and self.targets.fields then self.targets.fields[n]={block=o,name=p}end
end

local function corner(n,o)
local p=Instance.new("UICorner")
p.CornerRadius=o
p.Parent=n
return p
end

local function padding(n,o,p,q,r)
local s=Instance.new("UIPadding")
s.PaddingLeft,s.PaddingRight=UDim.new(0,o),UDim.new(0,p)
s.PaddingTop,s.PaddingBottom=UDim.new(0,q),UDim.new(0,r)
s.Parent=n
end

local function listLayout(n,o,p,q)
local r=Instance.new("UIListLayout")
r.FillDirection=o
r.Padding=UDim.new(0,p)
r.SortOrder=Enum.SortOrder.LayoutOrder
r.VerticalAlignment=q or Enum.VerticalAlignment.Top
r.Parent=n
return r
end

local function frame(n,o,p)
local q=Instance.new("Frame")
q.Name=o
q.BackgroundColor3=p
q.BorderSizePixel=0
q.AutomaticSize=Enum.AutomaticSize.XY
q.Size=UDim2.new(0,0,0,0)
q.Parent=n
return q
end

local function label(n,o,p,q)
local r=Instance.new("TextLabel")
r.Name="Text"
r.BackgroundTransparency=1
r.AutomaticSize=Enum.AutomaticSize.XY
r.Size=UDim2.new(0,0,0,24)
r.Font=j.blockFont
r.TextSize=j.textSize
r.TextColor3=p
r.Text=o
r.LayoutOrder=q
r.Parent=n
return r
end




local function field(n,o,p,q)
local r=q and j.dropdown(q)or j.field
local s=frame(n,"Field",r)
s.LayoutOrder=p
s.Size=UDim2.new(0,0,0,24)
s.AutomaticSize=Enum.AutomaticSize.X
corner(s,UDim.new(0.5,0))
local t=Instance.new("TextLabel")
t.BackgroundTransparency=1
t.AutomaticSize=Enum.AutomaticSize.X
t.Size=UDim2.new(0,0,1,0)
t.Font=j.blockFont
t.TextSize=j.textSize
t.TextColor3=q and j.textOn(r)or j.fieldText
t.Text=tostring(o==nil and""or o)
t.Parent=s
padding(t,10,10,0,0)
local u=Instance.new("UISizeConstraint")
u.MinSize=Vector2.new(28,24)
u.Parent=s
return s
end


local function emptySlot(n,o,p)
local q=Instance.new("Frame")
q.Name="EmptySlot"
q.BackgroundTransparency=1
q.BorderSizePixel=0
q.LayoutOrder=o
q.Size=UDim2.new(0,40,0,24)
q.Parent=n
k.hexagon(q,j.recess(p),nil,1)
return q
end

function m:_row(n,o,p,q,r)
local s=Instance.new("Frame")
s.Name="Row"
s.BackgroundTransparency=1
s.AutomaticSize=Enum.AutomaticSize.XY
s.Size=UDim2.new(0,0,0,j.rowHeight)
s.Parent=q
listLayout(s,Enum.FillDirection.Horizontal,j.gap,Enum.VerticalAlignment.Center)


local t=r=="boolean"and j.pad+14 or j.pad
padding(s,t,t,4,4)
local u=j.textOn(p)

for v,w in ipairs(o.segments)do
if w.icon then
l.icon(s,w.icon,j.iconSize,v)
elseif w.text then

local x=w.text:gsub("^%s+",""):gsub("%s+$","")
if x~=""then label(s,x,u,v)end
else
local x=o.inputs[w.input]
local y=n.inputs[w.input]
if type(y)=="table"and y.op then
local z=self:build(y,s)
z.LayoutOrder=v
self:_target(z,n,w.input)
elseif x.type=="boolean"and y==nil then
self:_target(emptySlot(s,v,p),n,w.input)
else
local z=x.options~=nil or x.type=="variable"or x.type=="list"or x.type=="param"
local A=field(s,y,v,z and p or nil)
self:_target(A,n,w.input)
self:_field(A,n,w.input)
end
end
end
return s
end

function m:build(n,o)
local p=assert(self.registry:get(n.op),"unknown block: "..tostring(n.op))
local q=j.categoryColor(self.registry.categories[p.category])
local r=self.registry:shapeOf(n)

local s=frame(o,"Block_"..n.op,q)

local t=k.surface(s,r,q,j.edge(q),{bowler=p.bowler})
listLayout(t,Enum.FillDirection.Vertical,0)
if self.map then self.map[s]=n end

local u=self:_row(n,p,q,t,r)
u.LayoutOrder=1

if#p.stacks>0 then
for v,w in ipairs(p.stacks)do
if v>1 then

local x=Instance.new("Frame")
x.Name="Divider_"..w
x.BackgroundTransparency=1
x.AutomaticSize=Enum.AutomaticSize.XY
x.Size=UDim2.new(0,0,0,j.rowHeight)
x.LayoutOrder=v*2
x.Parent=t
padding(x,j.pad,j.pad,0,0)
local y=label(x,string.lower(w),j.textOn(q),1)
y.Position=UDim2.new(0,0,0.5,-12)
end
local x=Instance.new("Frame")
x.Name="Slot_"..w
x.BackgroundTransparency=1
x.AutomaticSize=Enum.AutomaticSize.XY
x.Size=UDim2.new(0,0,0,j.cSlotMinHeight)
x.LayoutOrder=v*2+1
x.Parent=t
if self.targets then self.targets.slots[x]={block=n,name=w}end
padding(x,j.cSlotIndent,0,0,0)
local y=self:buildStack(n.stacks[w]or{},x)
y.LayoutOrder=1
local z=Instance.new("UISizeConstraint")
z.MinSize=Vector2.new(60,j.cSlotMinHeight)
z.Parent=y
end
local v=Instance.new("Frame")
v.Name="Footer"
v.BackgroundTransparency=1
v.Size=UDim2.new(0,0,0,p.footerIcon and j.cFooterIcon or j.cFooter)
v.LayoutOrder=1000
v.Parent=t
if p.footerIcon then

local w=l.icon(v,p.footerIcon,j.iconSize)
w.Position=UDim2.new(0,j.pad,0.5,-j.iconSize/2)
end
end

return s
end


function m:buildStack(n,o)
local p=Instance.new("Frame")
p.Name="Stack"
p.BackgroundTransparency=1
p.AutomaticSize=Enum.AutomaticSize.XY
p.Size=UDim2.new(0,0,0,0)
p.Parent=o
listLayout(p,Enum.FillDirection.Vertical,0)
for q,r in ipairs(n)do
local s=self:build(r,p)
s.LayoutOrder=q

s.ZIndex=#n-q+1
end
return p
end

return m

end end
do local g=e for h,i in ipairs({"UI","Console"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)






local j=i(h.Parent.Theme)

local k={}
k.__index=k

local l=500
local m=48
local n=44

local function corner(o)
local p=Instance.new("UICorner")
p.CornerRadius=j.radius
p.Parent=o
end

local o={
say=j.text,
error=j.error,
ask=j.textDim,
input=j.textDim,
}

function k.new(p)
local q=setmetatable({nodes={},count=0,pending=nil},k)

local r=Instance.new("Frame")
r.Name="Console"
r.BackgroundColor3=j.panel
r.BorderSizePixel=0
r.Position=UDim2.new(0,j.paletteWidth,1,-j.consoleHeight)
r.Size=UDim2.new(1,-j.paletteWidth,0,j.consoleHeight)
r.Parent=p
q.root=r

local s=Instance.new("TextLabel")
s.Name="Title"
s.BackgroundTransparency=1
s.Position=UDim2.fromOffset(12,0)
s.Size=UDim2.new(0.5,0,0,m)
s.Font=j.font
s.TextSize=j.textSize
s.TextColor3=j.textDim
s.TextXAlignment=Enum.TextXAlignment.Left
s.Text="Output"
s.Parent=r

local t=Instance.new("TextButton")
t.Name="ClearOutput"
t.AutoButtonColor=false
t.BackgroundColor3=j.ground
t.BorderSizePixel=0
t.AnchorPoint=Vector2.new(1,0.5)
t.Position=UDim2.new(1,-8,0,m/2)
t.Size=UDim2.fromOffset(120,44)
t.Font=j.font
t.TextSize=j.textSize
t.TextColor3=j.text
t.Text="Clear output"
t.Parent=r
corner(t)
t.Activated:Connect(function()q:clear()end)

local u=Instance.new("ScrollingFrame")
u.Name="Lines"
u.BackgroundColor3=j.ground
u.BorderSizePixel=0
u.Position=UDim2.fromOffset(8,m)
u.Size=UDim2.new(1,-16,1,-m-8)
u.CanvasSize=UDim2.new(0,0,0,0)
u.AutomaticCanvasSize=Enum.AutomaticSize.Y
u.ScrollingDirection=Enum.ScrollingDirection.Y
u.ScrollBarThickness=6
u.ScrollBarImageColor3=j.textDim
u.Parent=r
corner(u)
local v=Instance.new("UIListLayout")
v.SortOrder=Enum.SortOrder.LayoutOrder
v.Parent=u
local w=Instance.new("UIPadding")
w.PaddingLeft,w.PaddingRight=UDim.new(0,8),UDim.new(0,8)
w.PaddingTop,w.PaddingBottom=UDim.new(0,6),UDim.new(0,6)
w.Parent=u
q.scroll=u


local x=Instance.new("TextBox")
x.Name="Answer"
x.Visible=false
x.BackgroundColor3=j.field
x.BorderSizePixel=0
x.ClearTextOnFocus=false
x.Font=j.monoFont
x.TextSize=j.textSize
x.TextColor3=j.fieldText
x.PlaceholderText="Type an answer, then Enter"
x.PlaceholderColor3=j.textDim
x.Text=""
x.TextXAlignment=Enum.TextXAlignment.Left
x.AnchorPoint=Vector2.new(0,1)
x.Position=UDim2.new(0,8,1,-8)
x.Size=UDim2.new(1,-16,0,n)
x.Parent=r
corner(x)
local y=Instance.new("UIPadding")
y.PaddingLeft,y.PaddingRight=UDim.new(0,8),UDim.new(0,8)
y.Parent=x

local z=Instance.new("UIStroke")
z.Color=j.accent
z.Thickness=2
z.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
z.Parent=x
q.box=x
x.FocusLost:Connect(function(A)
if A then q:_submit(x.Text)end
end)

return q
end

function k:_scrollToEnd()
task.defer(function()
self.scroll.CanvasPosition=Vector2.new(0,1e6)
end)
end

function k:add(p,q)
q=q or"say"
self.count+=1
local r=Instance.new("TextLabel")
r.Name="Line"
r.BackgroundTransparency=1
r.AutomaticSize=Enum.AutomaticSize.Y
r.Size=UDim2.new(1,0,0,0)
r.LayoutOrder=self.count
r.Font=j.monoFont
r.TextSize=j.textSize
r.TextColor3=o[q]or j.text
r.TextWrapped=true
r.TextXAlignment=Enum.TextXAlignment.Left
r.TextYAlignment=Enum.TextYAlignment.Top
r.Text=tostring(p)
r.Parent=self.scroll
table.insert(self.nodes,r)
if#self.nodes>l then
table.remove(self.nodes,1):Destroy()
end
self:_scrollToEnd()
end

function k:clear()
for p,q in ipairs(self.nodes)do q:Destroy()end
self.nodes={}
end

function k:_showInput(p)
self.box.Visible=p
self.scroll.Size=p and UDim2.new(1,-16,1,-m-n-16)or UDim2.new(1,-16,1,-m-8)
if p then
self.box.Text=""
self.box:CaptureFocus()
else
self.box:ReleaseFocus()
end
end

function k:_submit(p)
local q=self.pending
if not q then return end
self.pending=nil
self:_showInput(false)
self:add("> "..p,"input")
task.spawn(q,p)
end


function k:ask(p)
self:cancel()
self:add(p,"ask")
self.pending=coroutine.running()
self:_showInput(true)
return coroutine.yield()
end

function k:cancel()
local p=self.pending
if not p then return end
self.pending=nil
self:_showInput(false)
task.spawn(p,"")
end

return k

end end
do local g=e for h,i in ipairs({"UI","Drag"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)
local j=game:GetService("UserInputService")

local k={}


function k.track(l,m,n)
local o=l.UserInputType==Enum.UserInputType.Touch
local p,q
p=j.InputChanged:Connect(function(r)
if r==l or(not o and r.UserInputType==Enum.UserInputType.MouseMovement)then
m(Vector2.new(r.Position.X,r.Position.Y))
end
end)
q=j.InputEnded:Connect(function(r)
if r==l or(not o and r.UserInputType==l.UserInputType)then
p:Disconnect()
q:Disconnect()
if n then n(Vector2.new(r.Position.X,r.Position.Y))end
end
end)
end

return k

end end
do local g=e for h,i in ipairs({"UI","Editor"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)






local j=i(h.Parent.Theme)

local k={}
k.__index=k

local l=40
local m=168
local n=280

function k.new(o,p,q)
return setmetatable({parent=o,registry=p,program=q},k)
end

local function corner(o)
local p=Instance.new("UICorner")
p.CornerRadius=j.radius
p.Parent=o
end


function k:_rel(o)
return(o-self.parent.AbsolutePosition)/j.scale
end

function k:close()
if self.layer then
self.layer:Destroy()
self.layer=nil
end
end


function k:_backdrop()
self:close()
local o=Instance.new("TextButton")
o.Name="EditorBackdrop"
o.BackgroundTransparency=1
o.Text=""
o.AutoButtonColor=false
o.Size=UDim2.fromScale(1,1)
o.ZIndex=250
o.Parent=self.parent
o.Activated:Connect(function()self:close()end)
self.layer=o
return o
end

function k:_commit(o,p,q,r)
local s=r
if q.type=="number"or q.type=="any"then
local t=tonumber(r)
if t~=nil then
s=t
end
end
self:close()
self.program:setInput(o,p,s)
end

function k:_text(o,p,q,r,s)
local t=self:_backdrop()
local u,v=self:_rel(o.AbsolutePosition),o.AbsoluteSize/j.scale
local w=Instance.new("TextBox")
w.Name="FieldBox"
w.BackgroundColor3=j.field
w.BorderSizePixel=0
w.ClearTextOnFocus=false
w.Font=j.font
w.TextSize=j.textSize
w.TextColor3=j.fieldText
w.TextXAlignment=Enum.TextXAlignment.Left
w.Text=tostring(s==nil and""or s)
w.Position=UDim2.fromOffset(u.X,u.Y)
w.Size=UDim2.fromOffset(math.max(v.X,72),math.max(v.Y,24))
w.ZIndex=300
w.Parent=t
corner(w)
local x=Instance.new("UIPadding")
x.PaddingLeft,x.PaddingRight=UDim.new(0,6),UDim.new(0,6)
x.Parent=w

local y=Instance.new("UIStroke")
y.Color=j.accent
y.Thickness=2
y.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
y.Parent=w
local z=false
w.FocusLost:Connect(function()
if z then return end
z=true
self:_commit(p,q,r,w.Text)
end)
w:CaptureFocus()
end


function k:_names(o,p)
local q,r={},{}
local function add(s)
if type(s)=="string"and s~=""and not q[s]then
q[s]=true
table.insert(r,s)
end
end
local function walk(s)
for t,u in ipairs(s)do
local v=self.registry:get(u.op)
if v then
for w,x in pairs(v.inputs)do
local y=u.inputs[w]
if x.type==o then add(y)end
if type(y)=="table"and y.op then walk({y})end
end
end
for w,x in pairs(u.stacks)do walk(x)end
end
end
for s,t in ipairs(self.program:get().scripts)do walk(t.blocks)end
add(p)
table.sort(r,function(s,t)return string.lower(s)<string.lower(t)end)
return r
end


function k:_paramNames(o)
local p={}
local q,r=self.program:scriptOf(o)
local s=r and r.blocks[1]
if s and s.op=="custom_define"and type(s.inputs.NAME)=="string"then
for t,u in ipairs(self.registry.custom.parse(s.inputs.NAME).params)do table.insert(p,u.name)end
end
return p
end

function k:_menu(o,p,q,r,s,t,u)
local v=self:_backdrop()
local w=#s+(u and 1 or 0)
local x=math.min(w*l,n)
local y,z=self:_rel(o.AbsolutePosition),o.AbsoluteSize/j.scale
local A=self.parent.AbsoluteSize/j.scale
local C=math.clamp(y.X,4,math.max(4,A.X-m-4))
local D=y.Y+z.Y+2
if D+x>A.Y-4 then D=math.max(4,y.Y-x-2)end

local E=Instance.new("ScrollingFrame")
E.Name="FieldMenu"
E.BackgroundColor3=j.panel
E.BorderSizePixel=0
E.Position=UDim2.fromOffset(C,D)
E.Size=UDim2.fromOffset(m,x)
E.CanvasSize=UDim2.new(0,0,0,0)
E.AutomaticCanvasSize=Enum.AutomaticSize.Y
E.ScrollBarThickness=4
E.ScrollBarImageColor3=j.textDim
E.ZIndex=300
E.Parent=v
corner(E)

local F=Instance.new("UIStroke")
F.Color=j.textDim
F.Thickness=1
F.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
F.Parent=E
local G=Instance.new("UIListLayout")
G.SortOrder=Enum.SortOrder.LayoutOrder
G.Parent=E

local function item(H,I,J,K)
local L=Instance.new("TextButton")
L.Name="Item"
L.AutoButtonColor=false
L.BackgroundColor3=J and j.accent or j.panel
L.BackgroundTransparency=J and 0 or 1
L.BorderSizePixel=0
L.Size=UDim2.new(1,0,0,l)
L.LayoutOrder=I
L.Font=j.font
L.TextSize=j.textSize
L.TextColor3=j.text
L.TextXAlignment=Enum.TextXAlignment.Left
L.Text=H
L.ZIndex=301
L.Parent=E
local M=Instance.new("UIPadding")
M.PaddingLeft=UDim.new(0,12)
M.Parent=L
L.Activated:Connect(K)
end

for H,I in ipairs(s)do
item(tostring(I),H,tostring(I)==tostring(t),function()
self:close()
self.program:setInput(p,q,I)
end)
end
if u then
item("New name",#s+1,false,function()
self:_text(o,p,q,r,"")
end)
end
end


function k:open(o,p)
local q=self.registry:get(p.block.op)
local r=q and q.inputs[p.name]
if not r then return end
local s=p.block.inputs[p.name]
if r.options then
self:_menu(o,p.block,p.name,r,r.options,s,false)
elseif r.type=="param"and#self:_paramNames(p.block)>0 then
self:_menu(o,p.block,p.name,r,self:_paramNames(p.block),s,false)
elseif r.type=="variable"or r.type=="list"then
self:_menu(o,p.block,p.name,r,self:_names(r.type,s),s,true)
else
self:_text(o,p.block,p.name,r,s)
end
end

return k

end end
do local g=e for h,i in ipairs({"UI","Palette"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


local j=i(h.Parent.Theme)
local k=i(h.Parent.BlockView)
local l=i(h.Parent.Drag)

local m={}
m.__index=m

local function corner(n)
local o=Instance.new("UICorner")
o.CornerRadius=j.radius
o.Parent=n
end

function m.new(n,o,p,q,r)
local s=setmetatable({registry=o,onSpawn=p,onHover=q,onHoverEnd=r,tabs={},selected=nil},m)

local t=Instance.new("Frame")
t.Name="Palette"
t.BackgroundColor3=j.panel
t.BorderSizePixel=0
t.Size=UDim2.new(0,j.paletteWidth,1,0)
t.Parent=n
s.root,s.parent=t,n

local u=Instance.new("ScrollingFrame")
u.Name="Tabs"
u.BackgroundTransparency=1
u.BorderSizePixel=0
u.Size=UDim2.new(0,j.tabWidth,1,0)
u.CanvasSize=UDim2.new(0,0,0,0)
u.AutomaticCanvasSize=Enum.AutomaticSize.Y
u.ScrollBarThickness=0
u.Parent=t
s.tabCol=u
local v=Instance.new("UIListLayout")
v.Padding=UDim.new(0,4)
v.SortOrder=Enum.SortOrder.LayoutOrder
v.Parent=u
local w=Instance.new("UIPadding")
w.PaddingTop,w.PaddingLeft,w.PaddingRight=UDim.new(0,8),UDim.new(0,8),UDim.new(0,4)
w.Parent=u

local x=Instance.new("ScrollingFrame")
x.Name="Blocks"
x.BackgroundTransparency=1
x.BorderSizePixel=0
x.Position=UDim2.new(0,j.tabWidth,0,0)
x.Size=UDim2.new(1,-j.tabWidth,1,0)
x.CanvasSize=UDim2.new(0,0,0,0)
x.AutomaticCanvasSize=Enum.AutomaticSize.XY
x.ScrollingDirection=Enum.ScrollingDirection.XY
x.ScrollBarThickness=6
x.ScrollBarImageColor3=j.textDim
x.Parent=t
local y=Instance.new("UIListLayout")
y.Padding=UDim.new(0,4)
y.SortOrder=Enum.SortOrder.LayoutOrder
y.Parent=x
local z=Instance.new("UIPadding")
z.PaddingTop,z.PaddingLeft,z.PaddingRight,z.PaddingBottom=UDim.new(0,8),UDim.new(0,8),UDim.new(0,8),UDim.new(0,8)
z.Parent=x
s.list=x

for A,C in ipairs(o.categoryOrder)do
s:_addTab(u,C,A)
end
if o.categoryOrder[1]then s:select(o.categoryOrder[1])end
return s
end

function m:_addTab(n,o,p)
local q=self.registry.categories[o]
local r=Instance.new("TextButton")
r.Name="Tab_"..o
r.AutoButtonColor=false
r.BackgroundColor3=j.panel
r.BorderSizePixel=0
r.Size=UDim2.new(1,0,0,j.tabHeight)
r.LayoutOrder=p
r.Font=j.font
r.TextSize=j.textSize
r.TextColor3=j.text
r.TextXAlignment=Enum.TextXAlignment.Left
r.Text=q.name
r.Parent=n
corner(r)
local s=Instance.new("UIPadding")
s.PaddingLeft=UDim.new(0,14)
s.Parent=r

local t=Instance.new("Frame")
t.Name="CategoryKey"
t.BackgroundColor3=j.categoryColor(q)
t.BorderSizePixel=0
t.Size=UDim2.new(0,4,1,-12)
t.Position=UDim2.new(0,-8,0,6)
t.Parent=r
r.Activated:Connect(function()self:select(o)end)
self.tabs[o]=r
end

function m:select(n)
self.selected=n
for o,p in pairs(self.tabs)do
p.BackgroundColor3=(o==n)and j.accent or j.panel
end
for o,p in ipairs(self.list:GetChildren())do
if p:IsA("GuiObject")then p:Destroy()end
end
self.list.CanvasPosition=Vector2.new(0,0)

local o=k.new(self.registry)
for p,q in ipairs(self.registry:listByCategory(n))do

local r=Instance.new("Frame")
r.Name="Item_"..q.id
r.BackgroundTransparency=1
r.AutomaticSize=Enum.AutomaticSize.XY
r.Size=UDim2.new(0,0,0,0)
r.LayoutOrder=p
r.Parent=self.list
local s=Instance.new("UIPadding")
s.PaddingTop,s.PaddingBottom=UDim.new(0,4),UDim.new(0,4)
s.Parent=r
local t=o:build(self.registry:createBlock(q.id),r)


local u=Instance.new("TextButton")
u.Name="Hit"
u.BackgroundTransparency=1
u.Text=""
u.ZIndex=10
u.Parent=r
local function fit()u.Size=UDim2.fromOffset(t.AbsoluteSize.X/j.scale,t.AbsoluteSize.Y/j.scale)end
t:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
u.InputBegan:Connect(function(v)
local w=v.UserInputType
if w==Enum.UserInputType.MouseButton1 or w==Enum.UserInputType.Touch then
self:_drag(v,q.id,t)
end
end)
end
end


function m:refresh()

for n,o in ipairs(self.registry.categoryOrder)do
if not self.tabs[o]then self:_addTab(self.tabCol,o,n)end
end
if self.selected then self:select(self.selected)
elseif self.registry.categoryOrder[1]then self:select(self.registry.categoryOrder[1])end
end

function m:_ghost(n)
local o=Instance.new("Frame")
o.Name="DragGhost"
o.BackgroundTransparency=1
o.AutomaticSize=Enum.AutomaticSize.XY
o.Size=UDim2.new(0,0,0,0)
o.ZIndex=100
o.Parent=self.parent
local p=k.new(self.registry):build(self.registry:createBlock(n),o)

local q=Instance.new("Frame")
q.BackgroundColor3=Color3.new(0,0,0)
q.BackgroundTransparency=0.6
q.BorderSizePixel=0
q.Position=UDim2.fromOffset(3,4)
q.ZIndex=0
q.Parent=o
corner(q)
local function fit()q.Size=UDim2.fromOffset(p.AbsoluteSize.X/j.scale,p.AbsoluteSize.Y/j.scale)end
p:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
return o,p
end


function m:_drag(n,o,p)
local q=Vector2.new(n.Position.X,n.Position.Y)
local r=q-p.AbsolutePosition
local s=n.UserInputType==Enum.UserInputType.Touch
local t,u,v
l.track(n,function(w)
if not t then
local x=w-q
if v or x.Magnitude<8 then return end
if s and math.abs(x.Y)>math.abs(x.X)then
v=true
return
end
self.list.ScrollingEnabled=false
t,u=self:_ghost(o)
end
t.Position=UDim2.fromOffset((w.X-r.X-self.parent.AbsolutePosition.X)/j.scale,(w.Y-r.Y-self.parent.AbsolutePosition.Y)/j.scale)
if self.onHover then
if w.X>self.root.AbsolutePosition.X+self.root.AbsoluteSize.X then self.onHover(o,u)
elseif self.onHoverEnd then self.onHoverEnd()end
end
end,function(w)
self.list.ScrollingEnabled=true
local x=u and u.AbsoluteSize
if t then t:Destroy()end
if self.onHoverEnd then self.onHoverEnd()end
if v then return end
if not t or w.X>self.root.AbsolutePosition.X+self.root.AbsoluteSize.X then
self.onSpawn(o,t and w-r,x)
end
end)
end

return m

end end
do local g=e for h,i in ipairs({"UI","Program"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)



local j={}
j.__index=j

function j.new(k)
return setmetatable({data=k or{scripts={}},listeners={}},j)
end

function j:get()return self.data end

function j:onChanged(k)
table.insert(self.listeners,k)
end

function j:changed()
for k,l in ipairs(self.listeners)do l(self.data)end
end

function j:addScript(k,l,m,n)
table.insert(self.data.scripts,{x=l,y=m,blocks={k}})
if not n then self:changed()end
return#self.data.scripts
end

function j:count()return#self.data.scripts end


function j:replace(k)
self.data=k
self:changed()
end

function j:clear()
self.data={scripts={}}
self:changed()
end

local function locate(k,l)
for m,n in ipairs(k)do
if n==l then return k,m end
for o,p in pairs(n.stacks)do
local q,r=locate(p,l)
if q then return q,r end
end
end
end

function j:find(k)
for l,m in ipairs(self.data.scripts)do
local n,o=locate(m.blocks,k)
if n then return n,o,l end
end
end


function j:detach(k,l,m)
local n,o,p=self:find(k)
if o==1 and n==self.data.scripts[p].blocks then return p end
local q=table.move(n,o,#n,1,{})
for r=#n,o,-1 do n[r]=nil end
table.insert(self.data.scripts,{x=l,y=m,blocks=q})
self:changed()
return#self.data.scripts
end


local function locateInput(k,l)
for m,n in ipairs(k)do
for o,p in pairs(n.inputs)do
if p==l then return n,o end
if type(p)=="table"and p.op then
local q,r=locateInput({p},l)
if q then return q,r end
end
end
for o,p in pairs(n.stacks)do
local q,r=locateInput(p,l)
if q then return q,r end
end
end
end

function j:findInput(k)
for l,m in ipairs(self.data.scripts)do
local n,o=locateInput(m.blocks,k)
if n then return n,o end
end
end


function j:detachInput(k,l,m,n)
local o,p=self:findInput(k)
if not o then return nil end
o.inputs[p]=n
table.insert(self.data.scripts,{x=l,y=m,blocks={k}})
self:changed()
return#self.data.scripts
end









function j:attach(k,l)
local m=self.data.scripts[k]
if not m or not l or not l.block or locate(m.blocks,l.block)then return false end
local n=l.wrap
if n~=nil then
local o=m.blocks[1]
local p=type(o)=="table"and type(o.stacks)=="table"and o.stacks[n]
if type(p)~="table"or#p>0 then
if l.kind=="wrap"then return false end
n=nil
end
elseif l.kind=="wrap"then
return false
end


local o,p,q
if l.kind=="after"then
o,p=self:find(l.block)
if not o then return false end
elseif l.kind=="before"or l.kind=="wrap"then
local r,s,t=self:find(l.block)
if not r or s~=1 or r~=self.data.scripts[t].blocks then return false end
q=self.data.scripts[t]
elseif l.kind=="slot"then
if not self:scriptOf(l.block)then return false end
elseif l.kind=="input"then
if not self:scriptOf(l.block)or#m.blocks~=1 then return false end
else
return false
end
if q==m then return false end
table.remove(self.data.scripts,k)
local r=m.blocks
if l.kind=="after"then
if n then
local s=table.move(o,p+1,#o,1,{})
for t=#o,p+1,-1 do o[t]=nil end
if#s>0 then r[1].stacks[n]=s end
end
for s,t in ipairs(r)do table.insert(o,p+s,t)end
elseif l.kind=="before"then
for s=#r,1,-1 do table.insert(q.blocks,1,r[s])end
q.x,q.y=m.x,m.y
elseif l.kind=="wrap"then
r[1].stacks[n]=q.blocks
q.blocks=r
q.x,q.y=m.x,m.y
elseif l.kind=="slot"then
local s=l.block.stacks[l.name]
if not s then s={};l.block.stacks[l.name]=s end
if n and#s>0 then
r[1].stacks[n]=s
l.block.stacks[l.name]=r
else
for t=#r,1,-1 do table.insert(s,1,r[t])end
end
elseif l.kind=="input"then
local s=l.block.inputs[l.name]
l.block.inputs[l.name]=r[1]
if type(s)=="table"and s.op then

table.insert(self.data.scripts,{x=m.x+40,y=m.y+40,blocks={s}})
end
end
self:changed()
return true
end



local function contains(k,l)
for m,n in ipairs(k)do
if n==l then return true end
for o,p in pairs(n.inputs)do
if type(p)=="table"and p.op and contains({p},l)then return true end
end
for o,p in pairs(n.stacks)do
if contains(p,l)then return true end
end
end
return false
end

function j:scriptOf(k)
for l,m in ipairs(self.data.scripts)do
if contains(m.blocks,k)then return l,m end
end
end




function j:setInput(k,l,m)
local n=k.inputs[l]
k.inputs[l]=m
if self.onSet then self.onSet(k,l,n,m)end
self:changed()
end

function j:moveScript(k,l,m)
local n=self.data.scripts[k]
n.x,n.y=l,m
self:changed()
end

function j:removeScript(k)
table.remove(self.data.scripts,k)
self:changed()
end

return j

end end
do local g=e for h,i in ipairs({"UI","Shapes"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)








local j=i(h.Parent.Theme)

local k={}

local function frame(l,m,n,o,p)
local q=Instance.new("Frame")
q.Name=m
q.BackgroundColor3=n
q.BorderSizePixel=0
q.Size=o
if p then q.Position=p end
q.Parent=l
return q
end

local function corner(l,m)
local n=Instance.new("UICorner")
n.CornerRadius=m
n.Parent=l
return n
end



local function holder(l,m,n)
local o=Instance.new("Frame")
o.Name=m
o.BackgroundTransparency=1
o.BorderSizePixel=0
o.Size=UDim2.new(0,0,0,0)
o.LayoutOrder=n
o.Parent=l
return o
end




function k.hexagon(l,m,n,o)
local p=Instance.new("Frame")
p.Name="Hex"
p.BackgroundTransparency=1
p.BorderSizePixel=0
p.Size=UDim2.new(1,0,1,0)
p.ZIndex=o or 1
p.Parent=l

local function layer(q,r)
local s=Instance.new("Frame")
s.Name=q
s.BackgroundTransparency=1
s.BorderSizePixel=0
s.Parent=p
local t=frame(s,"Mid",r,UDim2.new(0,0,0,0))
local u=frame(s,"Left",r,UDim2.new(0,0,0,0))
local v=frame(s,"Right",r,UDim2.new(0,0,0,0))
for w,x in ipairs({u,v})do
x.AnchorPoint=Vector2.new(0.5,0.5)
x.Rotation=45
end
return{root=s,mid=t,left=u,right=v}
end
local q=n and layer("Edge",n)
local r=layer("Fill",m)

local function place(s,t,u,v,w)
s.root.Position=UDim2.fromOffset(t,u)
s.root.Size=UDim2.fromOffset(v,w)
local x=w/2
local y=w/math.sqrt(2)
s.mid.Position=UDim2.fromOffset(x,0)
s.mid.Size=UDim2.fromOffset(math.max(0,v-w),w)
s.left.Size=UDim2.fromOffset(y,y)
s.left.Position=UDim2.fromOffset(x,x)
s.right.Size=UDim2.fromOffset(y,y)
s.right.Position=UDim2.fromOffset(v-x,x)
end

local function update()
local s=j.scale>0 and j.scale or 1
local t,u=p.AbsoluteSize.X/s,p.AbsoluteSize.Y/s
if u<=0 then return end
local v=n and(p:GetAttribute("Inset")or 1)or 0
if q then place(q,0,0,t,u)end
place(r,v,v,math.max(0,t-2*v),math.max(0,u-2*v))
end
p:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
p:GetAttributeChangedSignal("Inset"):Connect(update)
update()
return p
end




function k.surface(l,m,n,o,p)
p=p or{}
if m=="boolean"then
l.BackgroundTransparency=1
k.hexagon(l,n,o,1)
local q=Instance.new("Frame")
q.Name="Content"
q.BackgroundTransparency=1
q.BorderSizePixel=0
q.AutomaticSize=Enum.AutomaticSize.XY
q.Size=UDim2.new(0,0,0,0)
q.ZIndex=2
q.Parent=l
return q
end

l.BackgroundColor3=n
if m=="reporter"then
corner(l,UDim.new(0.5,0))
elseif p.bowler then
corner(l,j.bowlerRadius)
else
corner(l,j.blockRadius)
end
local q=Instance.new("UIStroke")
q.Name="Edge"
q.Color=o
q.Thickness=1
q.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
q.Parent=l
if m=="reporter"then return l end

local r=m~="hat"
local s=m~="cap"
local t,u,v=j.notchX,j.notchW,j.notchH

if m=="hat"and not p.bowler then


local w=j.hatHeight
local x=holder(l,"Top",0)
local y=Instance.new("Frame")
y.Name="Dome"
y.BackgroundTransparency=1
y.BorderSizePixel=0
y.ClipsDescendants=true
y.Position=UDim2.new(0,-1,0,-(w+1))
y.Size=UDim2.new(0,j.hatWidth+2,0,w+1+4)
y.Parent=x
corner(frame(y,"Edge",o,UDim2.new(1,0,0,2*(w+1)),UDim2.new(0,0,0,0)),UDim.new(0.5,0))
corner(frame(y,"Fill",n,UDim2.new(1,-2,0,2*w),UDim2.new(0,1,0,1)),UDim.new(0.5,0))
elseif r then

local w=holder(l,"Top",0)
corner(frame(w,"Notch",o,UDim2.new(0,u,0,v),UDim2.new(0,t,0,0)),UDim.new(0,3))
end

if s then


local w=holder(l,"Bottom",10000)
local x=frame(w,"TabEdge",o,UDim2.new(0,u+2,0,v+2),UDim2.new(0,t-1,0,-1))
corner(x,UDim.new(0,4))
x.ZIndex=1
local y=frame(w,"Tab",n,UDim2.new(0,u,0,v+2),UDim2.new(0,t,0,-2))
corner(y,UDim.new(0,3))
y.ZIndex=2
end
return l
end


function k.markError(l,m,n)
local o=l:FindFirstChildOfClass("UIStroke")
if o then
o.Color=m
o.Thickness=n
return
end
local p=l:FindFirstChild("Hex")
if p then
local q=p:FindFirstChild("Edge")
if q then
for r,s in ipairs(q:GetChildren())do s.BackgroundColor3=m end
end
p:SetAttribute("Inset",n)
end
end

return k

end end
do local g=e for h,i in ipairs({"UI","Theme"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


local j={
ground=Color3.fromRGB(28,30,34),
panel=Color3.fromRGB(42,45,51),
text=Color3.fromRGB(235,237,240),
textDim=Color3.fromRGB(160,165,174),
accent=Color3.fromRGB(76,139,245),
error=Color3.fromRGB(244,120,120),
field=Color3.fromRGB(246,246,246),
fieldText=Color3.fromRGB(30,32,36),

font=Enum.Font.GothamMedium,
blockFont=Enum.Font.GothamBold,
whiteBlockText=false,
monoFont=Enum.Font.Code,
textSize=14,
radius=UDim.new(0,4),
blockRadius=UDim.new(0,5),
bowlerRadius=UDim.new(0,14),
reporterRadius=UDim.new(0,10),
booleanRadius=UDim.new(0,2),


notchX=14,
notchW=28,
notchH=6,
hatHeight=18,
hatWidth=88,
rowHeight=40,
pad=8,
gap=6,
cSlotIndent=16,
cSlotMinHeight=24,
cFooter=10,
cFooterIcon=24,
iconSize=20,
paletteWidth=320,
tabWidth=96,
tabHeight=44,
toolbarHeight=56,
consoleHeight=184,
scale=1,
}

function j.categoryColor(k)
local l=k and k.color or{150,150,150}
return Color3.fromRGB(l[1],l[2],l[3])
end



function j.edge(k)
return Color3.new(k.R*0.78,k.G*0.78,k.B*0.78)
end


function j.dropdown(k)
return Color3.new(k.R*0.5,k.G*0.5,k.B*0.5)
end


local function luminance(k)
local function f(l)return l<=0.03928 and l/12.92 or((l+0.055)/1.055)^2.4 end
return 0.2126*f(k.R)+0.7152*f(k.G)+0.0722*f(k.B)
end
j.luminance=luminance



function j.textOn(k)
if j.whiteBlockText then return Color3.new(1,1,1)end
local l=luminance(k)
local m=1.05/(l+0.05)
local n=(l+0.05)/(luminance(j.fieldText)+0.05)
return m>n and Color3.new(1,1,1)or j.fieldText
end


function j.recess(k)
return Color3.new(k.R*0.6,k.G*0.6,k.B*0.6)
end

return j

end end
do local g=e for h,i in ipairs({"UI","Toolbar"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)



local j=i(h.Parent.Theme)

local k={}
k.__index=k

local l=3

local function button(m,n,o,p,q,r,s)
local t=Instance.new("TextButton")
t.Name=n
t.AutoButtonColor=false
t.BackgroundColor3=q
t.BorderSizePixel=0
t.Size=UDim2.fromOffset(p,44)
t.LayoutOrder=s
t.Font=j.font
t.TextSize=j.textSize
t.TextColor3=r
t.Text=o
t.Parent=m
local u=Instance.new("UICorner")
u.CornerRadius=j.radius
u.Parent=t
return t
end

function k.new(m,n)
local o=setmetatable({handlers=n,confirmToken=0},k)

local p=Instance.new("Frame")
p.Name="Toolbar"
p.BackgroundColor3=j.panel
p.BorderSizePixel=0
p.Position=UDim2.new(0,j.paletteWidth,0,0)
p.Size=UDim2.new(1,-j.paletteWidth,0,j.toolbarHeight)
p.Parent=m
o.bar=p

local q=Instance.new("UIListLayout")
q.FillDirection=Enum.FillDirection.Horizontal
q.VerticalAlignment=Enum.VerticalAlignment.Center
q.SortOrder=Enum.SortOrder.LayoutOrder
q.Padding=UDim.new(0,8)
q.Parent=p
local r=Instance.new("UIPadding")
r.PaddingLeft=UDim.new(0,8)
r.Parent=p


o.run=button(p,"Run","Run",96,j.accent,j.fieldText,1)
o.stop=button(p,"Stop","Stop",96,j.ground,j.textDim,2)
o.clear=button(p,"ClearWorkspace","Clear workspace",152,j.ground,j.text,3)

o.save=button(p,"Save","Save",88,j.ground,j.text,4)
o.load=button(p,"Load","Load",88,j.ground,j.text,5)

o.run.Activated:Connect(function()
o:_resetClear()
n.onRun()
end)
o.stop.Activated:Connect(function()
o:_resetClear()
n.onStop()
end)
o.save.Activated:Connect(function()
o:_resetClear()
n.onSave()
end)
o.load.Activated:Connect(function()
o:_resetClear()
n.onLoad()
end)

o.clear.Activated:Connect(function()
if o.confirming then
o:_resetClear()
n.onClear()
return
end
o.confirming=true
o.clear.Text="Tap again to delete all"
o.clear.TextColor3=j.error
o.confirmToken+=1
local s=o.confirmToken
task.delay(l,function()
if o.confirmToken==s then o:_resetClear()end
end)
end)
return o
end

function k:_resetClear()
self.confirmToken+=1
self.confirming=false
self.clear.Text="Clear workspace"
self.clear.TextColor3=j.text
end

function k:setRunning(m)
self.stop.TextColor3=m and j.text or j.textDim
end

return k

end end
do local g=e for h,i in ipairs({"UI","Transfer"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)







local j=i(h.Parent.Theme)

local k={}
k.__index=k

local l,m=560,380

local function corner(n)
local o=Instance.new("UICorner")
o.CornerRadius=j.radius
o.Parent=n
end

local function label(n,o,p,q,r,s)
local t=Instance.new("TextLabel")
t.BackgroundTransparency=1
t.Position=UDim2.fromOffset(16,p)
t.Size=UDim2.new(1,-32,0,q)
t.Font=j.font
t.TextSize=j.textSize
t.TextColor3=r
t.TextXAlignment=Enum.TextXAlignment.Left
t.TextYAlignment=Enum.TextYAlignment.Top
t.TextWrapped=s or false
t.Text=o
t.Parent=n
return t
end

function k.new(n)
return setmetatable({parent=n},k)
end

function k:close()
if self.layer then
self.layer:Destroy()
self.layer=nil
end
end

function k:open(n)
self:close()

local o=Instance.new("TextButton")
o.Name="TransferLayer"
o.BackgroundTransparency=1
o.Text=""
o.AutoButtonColor=false
o.Size=UDim2.fromScale(1,1)
o.ZIndex=400
o.Parent=self.parent
self.layer=o

local p=Instance.new("Frame")
p.Name="Panel"
p.BackgroundColor3=j.panel
p.BorderSizePixel=0
p.AnchorPoint=Vector2.new(0.5,0.5)

p.Position=UDim2.new(0.5,j.paletteWidth/2,0.5,0)
p.Size=UDim2.fromOffset(l,m)
p.Parent=o
corner(p)

local q=Instance.new("UIStroke")
q.Color=j.textDim
q.Thickness=1
q.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
q.Parent=p

label(p,n.title or"",10,24,j.text)
label(p,n.hint or"",36,20,j.textDim)

local r=Instance.new("TextBox")
r.Name="Text"
r.BackgroundColor3=j.field
r.BorderSizePixel=0
r.Position=UDim2.fromOffset(16,64)
r.Size=UDim2.new(1,-32,0,212)
r.MultiLine=true
r.TextWrapped=true
r.ClearTextOnFocus=false
r.Font=j.font
r.TextSize=j.textSize
r.TextColor3=j.fieldText
r.TextXAlignment=Enum.TextXAlignment.Left
r.TextYAlignment=Enum.TextYAlignment.Top
r.Text=n.text or""
r.Parent=p
corner(r)
local s=Instance.new("UIPadding")
s.PaddingLeft,s.PaddingRight,s.PaddingTop,s.PaddingBottom=UDim.new(0,8),UDim.new(0,8),UDim.new(0,6),UDim.new(0,6)
s.Parent=r


local t=label(p,n.error or"",282,34,j.error,true)

local u=Instance.new("Frame")
u.BackgroundTransparency=1
u.Position=UDim2.new(0,16,1,-56)
u.Size=UDim2.new(1,-32,0,44)
u.Parent=p
local v=Instance.new("UIListLayout")
v.FillDirection=Enum.FillDirection.Horizontal
v.SortOrder=Enum.SortOrder.LayoutOrder
v.Padding=UDim.new(0,8)
v.Parent=u

local function button(w,x,y,z)
local A=Instance.new("TextButton")
A.AutoButtonColor=false
A.BackgroundColor3=j.ground
A.BorderSizePixel=0
A.Size=UDim2.fromOffset(x,40)
A.LayoutOrder=y
A.Font=j.font
A.TextSize=j.textSize
A.TextColor3=j.text
A.Text=w
A.Parent=u
corner(A)
A.Activated:Connect(z)
end

for w,x in ipairs(n.actions or{})do
button(x.label,176,w,function()
local y=x.run(r.Text,r)
if y==nil then
self:close()
elseif type(y)=="string"then
t.Text=y
else
t.Text=""
end
end)
end
button("Close",96,100,function()self:close()end)
end

return k

end end
do local g=e for h,i in ipairs({"UI","Workspace"})do g=rawget(g,"__kids")[i]end
b[g]=function(h,i)


local j=game:GetService("Players")
local k=i(h.Parent.Theme)
local l=i(h.Parent.BlockView)
local m=i(h.Parent.Shapes)
local n=i(h.Parent.Drag)

local o={}
o.__index=o

function o.new(p,q,r)
local s=setmetatable({registry=q,program=r,blockOf={}},o)

local t=Instance.new("ScrollingFrame")
t.Name="Workspace"
t.BackgroundColor3=k.ground
t.BorderSizePixel=0

t.Size=UDim2.new(1,-k.paletteWidth,1,-(k.toolbarHeight+k.consoleHeight))
t.Position=UDim2.new(0,k.paletteWidth,0,k.toolbarHeight)
t.ScrollingDirection=Enum.ScrollingDirection.XY
t.CanvasSize=UDim2.new(0,0,0,0)
t.AutomaticCanvasSize=Enum.AutomaticSize.XY
t.ScrollBarThickness=8
t.ScrollBarImageColor3=k.textDim
t.Parent=p
s.canvas=t

local u=Instance.new("Frame")
u.Name="Scripts"
u.BackgroundTransparency=1
u.Size=UDim2.new(1,0,1,0)
u.Parent=t
s.layer=u


local v=Instance.new("Frame")
v.Name="SnapPreview"
v.BackgroundColor3=k.accent
v.BorderSizePixel=0
v.Visible=false
v.ZIndex=200
v.Parent=p
s.preview,s.targets=v,{inputs={},slots={},fields={}}

s:_wirePan()
r:onChanged(function()s:render()end)
s:render()
return s
end

function o:_toCanvas(p)
return(p-self.canvas.AbsolutePosition)/k.scale+self.canvas.CanvasPosition
end



function o:_grab(p,q,r)


if not q or not self.blockOf[q]then return false end
local s=Vector2.new(p.Position.X,p.Position.Y)
local t=self.blockOf[q]
local u,v,w,x
self.busy=true
self.canvas.ScrollingEnabled=false
n.track(p,function(y)
if not v then
if(y-s).Magnitude<6 then return end
local z=self:_toCanvas(q.AbsolutePosition)
if self.program:find(t)then
u=self.program:detach(t,z.X,z.Y-12)
else
local A,C=self.program:findInput(t)
local D=A and self.registry:get(A.op).inputs[C]
u=self.program:detachInput(t,z.X,z.Y-12,D and D.default)
end
if not u then return end
local A=self.program:get().scripts[u]
w,x=A.x,A.y
v=self.layer["Script"..u]
v.ZIndex=10
end
local z=(y-s)/k.scale
v.Position=UDim2.fromOffset(math.max(0,w+z.X),math.max(0,x+z.Y)+12)
self:_showPreview(self:_findTarget(self:_specOfHolder(u,v),v))
end,function(y)
self.busy=false
self.canvas.ScrollingEnabled=true
self:_showPreview(nil)
if not v then

if r and self.editor then self.editor:open(r,self.targets.fields[r])end
return
end
local z=self:_findTarget(self:_specOfHolder(u,v),v)
local A=(y-s)/k.scale
if y.X<self.canvas.AbsolutePosition.X then
self.program:removeScript(u)
elseif not(z and self.program:attach(u,z))then
self.program:moveScript(u,math.max(0,w+A.X),math.max(0,x+A.Y))
end
end)
return true
end


local p=40

local function isValue(q)return q=="reporter"or q=="boolean"end


function o:_specOfHolder(q,r)
local s=self.program:get().scripts[q].blocks
local t,u=self.registry:shapeOf(s[1]),self.registry:shapeOf(s[#s])
local v=r.AbsolutePosition

local w=self.registry:wrapSlot(s[1])
local x
if w then
for y,z in pairs(self.targets.slots)do
if z.block==s[1]and z.name==w then
x=y.AbsolutePosition+Vector2.new(k.cSlotIndent*k.scale,0)
break
end
end
end
return{first=t,last=u,count=#s,top=v,bottom=v+Vector2.new(0,r.AbsoluteSize.Y),
def=self.registry:get(s[1].op),wrap=w,slotPos=x}
end


function o:_specOfOp(q,r,s)
local t=self.registry:createBlock(q)
local u=self.registry:shapeOf(t)
local v=self.registry:wrapSlot(t)

local w=v and(r+Vector2.new(k.cSlotIndent*k.scale,k.rowHeight*k.scale))or nil
return{first=u,last=u,count=1,top=r,bottom=r+Vector2.new(0,s.Y),
def=self.registry:get(q),wrap=v,slotPos=w}
end


function o:_findTarget(q,r)
local s,t,u=self.registry,self.program,k.scale
local v,w=nil,p*u
local function skip(x)return r and(x==r or r:IsAncestorOf(x))end

if isValue(q.first)then
if q.count~=1 then return nil end
for x,y in pairs(self.targets.inputs)do
local z=(x.AbsolutePosition-q.top).Magnitude
if z<w and not skip(x)then

if s:accepts(s:get(y.block.op),y.name,q.first,q.def)then
v,w={kind="input",block=y.block,name=y.name,pos=x.AbsolutePosition,size=x.AbsoluteSize},z
end
end
end
return v
end

for x,y in pairs(self.blockOf)do
if not skip(x)then
local z=s:shapeOf(y)
if not isValue(z)then
local A,C=x.AbsolutePosition,x.AbsoluteSize

local D=Vector2.new(A.X,A.Y+C.Y)
local E=(D-q.top).Magnitude
if E<w and z~="cap"and q.first~="hat"then
local F,G=t:find(y)

local H=(F and G<#F)and q.wrap or nil
if F and not(q.last=="cap"and G<#F and not H)then
v,w={kind="after",block=y,wrap=H,pos=D,size=C},E
end
end

E=(A-q.bottom).Magnitude
if E<w and z~="hat"and q.last~="cap"then
local F,G,H=t:find(y)
if F and G==1 and F==t:get().scripts[H].blocks then
v,w={kind="before",block=y,pos=A,size=C},E
end
end

if q.wrap and q.slotPos and z~="hat"then
local F=(A-q.slotPos).Magnitude
if F<w then
local G,H,I=t:find(y)
if G and H==1 and G==t:get().scripts[I].blocks then
v,w={kind="wrap",block=y,wrap=q.wrap,pos=A,size=C},F
end
end
end
end
end
end
if q.first~="hat"then
for x,y in pairs(self.targets.slots)do
if not skip(x)then
local z=x.AbsolutePosition+Vector2.new(k.cSlotIndent*u,0)
local A=(z-q.top).Magnitude
local C=y.block.stacks[y.name]
local D=C and#C>0
local E=D and q.wrap or nil
if A<w and not(q.last=="cap"and D and not E)then
v,w={kind="slot",block=y.block,name=y.name,wrap=E,pos=z,size=Vector2.new(x.AbsoluteSize.X-k.cSlotIndent*u,0)},A
end
end
end
end
return v
end

function o:_showPreview(q)
local r=self.preview
if not q then r.Visible=false return end
local s,t=k.scale,r.Parent.AbsolutePosition
local u,v=q.pos,q.size
if q.kind=="input"then
r.BackgroundTransparency=0.5
else
r.BackgroundTransparency=0
u=Vector2.new(u.X,u.Y-2*s)
v=Vector2.new(math.max(v.X,60*s),4*s)
end
r.Position=UDim2.fromOffset((u.X-t.X)/s,(u.Y-t.Y)/s)
r.Size=UDim2.fromOffset(v.X/s,v.Y/s)
r.Visible=true
end


function o:hover(q,r)
self:_showPreview(self:_findTarget(self:_specOfOp(q,r.AbsolutePosition,r.AbsoluteSize)))
end

function o:hoverEnd()self:_showPreview(nil)end

local function depthOf(q)
local r=0
while q do r=r+1;q=q.Parent end
return r
end

local function isPress(q)
local r=q.UserInputType
return r==Enum.UserInputType.MouseButton1 or r==Enum.UserInputType.Touch
end




function o:_press(q,r,s)
if not isPress(q)then return end
local t=q.UserInputType==Enum.UserInputType.Touch


if self.busy and t then return end
local u=t and"touch"or"mouse"
local v=self.pending[u]
if not v then
v={blocks={},fields={}}
self.pending[u]=v
task.defer(function()
self.pending[u]=nil
local w,x,y,z=nil,-1,nil,-1
for A,C in ipairs(v.blocks)do
local D=depthOf(C)
if D>x and C.Parent then w,x=C,D end
end
for A,C in ipairs(v.fields)do
local D=depthOf(C)
if D>z and w and C:IsDescendantOf(w)then y,z=C,D end
end
if self:_grab(q,w,y)then return end
if t then return end
self.busy=true
local A=Vector2.new(q.Position.X,q.Position.Y)
n.track(q,function(C)
local D=self.canvas.CanvasPosition-(C-A)/k.scale
self.canvas.CanvasPosition=Vector2.new(math.max(0,D.X),math.max(0,D.Y))
A=C
end,function()self.busy=false end)
end)
end
if r=="block"then table.insert(v.blocks,s)
elseif r=="field"then table.insert(v.fields,s)end
end

function o:_wirePan()
self.pending={}
self.canvas.InputBegan:Connect(function(q)self:_press(q,"canvas")end)
end


function o:_wireHits()
for q in pairs(self.blockOf)do
q.InputBegan:Connect(function(r)self:_press(r,"block",q)end)
end
for q in pairs(self.targets.fields)do
q.InputBegan:Connect(function(r)self:_press(r,"field",q)end)
end
end

function o:render()
self.layer:ClearAllChildren()
self.blockOf={}
self.targets={inputs={},slots={},fields={}}
local q=l.new(self.registry,self.blockOf,self.targets)
for r,s in ipairs(self.program:get().scripts)do
local t=Instance.new("Frame")
t.Name="Script"..r
t.BackgroundTransparency=1
t.AutomaticSize=Enum.AutomaticSize.XY
t.Size=UDim2.new(0,0,0,0)

t.Position=UDim2.new(0,s.x,0,s.y+12)
t.Parent=self.layer
q:buildStack(s.blocks,t)
end
self:_wireHits()
self:_applyError()
end




function o:markError(q)
self.errorBlock=q
self:_applyError(true)
end

function o:clearError()
if not self.errorBlock then return end
self.errorBlock=nil
self:render()
end

function o:_applyError(q)
local r=self.errorBlock
if not r then return end
local s
for t,u in pairs(self.blockOf)do
if u==r then s=t break end
end
if not s then return end
m.markError(s,k.error,3)
if q then

task.defer(function()
if not s.Parent then return end
local t=self.canvas
local u,v=self:_toCanvas(s.AbsolutePosition),s.AbsoluteSize/k.scale
local w=t.AbsoluteSize/k.scale
local x=t.CanvasPosition
local y=(u.X<x.X or u.X+v.X>x.X+w.X)and math.max(0,u.X-24)or x.X
local z=(u.Y<x.Y or u.Y+v.Y>x.Y+w.Y)and math.max(0,u.Y-48)or x.Y
t.CanvasPosition=Vector2.new(y,z)
end)
end
end



function o:spawn(q,r,s)
local t=(self.program:count()%8)*32
local u=r and self:_toCanvas(r)-Vector2.new(0,12)or self.canvas.CanvasPosition+Vector2.new(24+t,24+t)
local v=self.program:addScript(self.registry:createBlock(q),math.max(0,math.floor(u.X)),math.max(0,math.floor(u.Y)),true)
local w=r and s and self:_findTarget(self:_specOfOp(q,r,s))
if not(w and self.program:attach(v,w))then self.program:changed()end
end

return o

end end
return(function(g,h)





local i=game:GetService("Players")
local j=game:GetService("HttpService")
local k=game:GetService("UserInputService")
local l=h(g.Lang)
local m=h(g.UI.Theme)
local n=h(g.UI.Program)
local o=h(g.UI.Palette)
local p=h(g.UI.Workspace)
local q=h(g.UI.Editor)
local r=h(g.UI.Toolbar)
local s=h(g.UI.Console)
local t=h(g.UI.Transfer)
local u=h(g.Plugin)


local v=true

local w=l.newRegistry()

local function B(x,y,z)
local A=w:createBlock(x)
for C,D in pairs(y or{})do A.inputs[C]=D end
for C,D in pairs(z or{})do A.stacks[C]=D end
return A
end


local x=n.new({scripts={
{x=24,y=24,blocks={
B("events_when_run"),
B("data_set",{NAME="i",VALUE=0}),
B("control_repeat",{TIMES=3},{SUBSTACK={
B("data_change",{NAME="i",BY=1}),
B("out_print",{TEXT=B("op_join",{A="i = ",B=B("data_get",{NAME="i"})})}),
}}),
}},
{x=24,y=240,blocks={
B("events_when_run"),
B("control_if_else",{COND=B("op_contains",{S="block",T="lock"})},{
THEN={B("out_print",{TEXT="found"})},
ELSE={B("out_print",{TEXT="missing"})},
}),
}},
}})

local y=Instance.new("ScreenGui")
y.Name="BlockScript"
y.ResetOnSpawn=false


y.ZIndexBehavior=Enum.ZIndexBehavior.Sibling


local function applyInset()y.IgnoreGuiInset=not k.TouchEnabled end
applyInset()
k:GetPropertyChangedSignal("TouchEnabled"):Connect(applyInset)



local function guiParent()
local z,A=pcall(function()return type(gethui)=="function"and gethui()or nil end)
if z and typeof(A)=="Instance"then
local C=A
while C do
if C:IsA("BasePlayerGui")then return A end
C=C.Parent
end
end
return i.LocalPlayer:WaitForChild("PlayerGui")
end
y.Parent=guiParent()

local z=Instance.new("Frame")
z.Name="Root"
z.BackgroundColor3=m.ground
z.BorderSizePixel=0
z.Parent=y

local A=Instance.new("UIScale")
A.Parent=z

local function fit()
local C=y.AbsoluteSize
m.scale=math.clamp(math.min(C.X/1100,C.Y/650),0.7,0.8)
A.Scale=m.scale
z.Size=UDim2.fromScale(1/m.scale,1/m.scale)
end
y:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()

local C=p.new(z,w,x)
C.editor=q.new(z,w,x)
local D=o.new(z,w,
function(D,E,F)C:spawn(D,E,F)end,
function(D,E)C:hover(D,E)end,
function()C:hoverEnd()end)


local function syncCustom()
if w.custom.sync(x:get().scripts)then D:refresh()end
end
x:onChanged(syncCustom)
local E



x.onSet=function(F,G,H,I)
if F.op=="custom_define"and G=="NAME"then

local J=w.custom.parse(tostring(I or"")).code
if J~=""and J~=w.custom.parse(tostring(H or"")).code then
for K,L in ipairs(x:get().scripts)do
local M=L.blocks[1]
if M and M~=F and M.op=="custom_define"
and w.custom.parse(tostring(M.inputs.NAME or"")).code==J then
F.inputs.NAME=H
E:add("A define named \""..tostring(I).."\" already exists. Name not changed.","error")
return
end
end
end
w.custom.sync(x:get().scripts)
w.custom.rename(x:get().scripts,F,H,I)
end
if w:shapeOf(F)=="cap"then
local J,K,L=x:find(F)
if J and J[K+1]then
local M=x:get().scripts[L]
x:detach(J[K+1],M.x+40,M.y+40)
end
end
end


E=s.new(z)
local F=t.new(z)
local G


local H,I={
["space"]=Enum.KeyCode.Space,["up arrow"]=Enum.KeyCode.Up,["down arrow"]=Enum.KeyCode.Down,
["right arrow"]=Enum.KeyCode.Right,["left arrow"]=Enum.KeyCode.Left,
},{}
local J={"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
for K=string.byte("a"),string.byte("z")do H[string.char(K)]=Enum.KeyCode[string.upper(string.char(K))]end
for K=0,9 do H[tostring(K)]=Enum.KeyCode[J[K+1] ]end
for K,L in pairs(H)do I[L]=K end

local K
K=l.newInterpreter(w,{
keyDown=function(L)
if not v then return false end
if k:GetFocusedTextBox()then return false end
if L=="any"then
for M,N in pairs(H)do
if k:IsKeyDown(N)then return true end
end
return false
end
local M=H[L]
return M~=nil and k:IsKeyDown(M)
end,
mouseDown=function()return v and k:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)end,

date=function()
local L=DateTime.now():ToLocalTime()
return{year=L.Year,month=L.Month,day=L.Day,hour=L.Hour,min=L.Minute,sec=L.Second}
end,
output=function(L,M)E:add(L,M)end,
clear=function()E:clear()end,
ask=function(L)return E:ask(L)end,
onError=function(L,M)
E:add("Error: "..L,"error")
if M then C:markError(M)end
end,
onFinish=function()G:setRunning(false)end,
})

k.InputBegan:Connect(function(L,M)
if not v or M or not K.running then return end
local N=I[L.KeyCode]
if N then K:fire("key",N)end
end)

local function stop()
K:stop()
E:cancel()
end

G=r.new(z,{
onRun=function()
E:cancel()
C:clearError()
E:clear()
K:run(x:get())
G:setRunning(K.running)
end,
onStop=stop,
onClear=function()
stop()
K:resetData()
C:clearError()
x:clear()
end,
onSave=function()
local L={blockscript=l.Validate.VERSION,scripts=x:get().scripts}
local M,N=pcall(j.JSONEncode,j,L)
F:open({
title="Save program",
hint="Copy this text and keep it. Load takes it back.",
text=M and N or"",
error=M and""or("Could not encode: "..string.sub(tostring(N),1,120)),
actions={{label="Select all",run=function(O,P)
P:CaptureFocus()
P.CursorPosition=#P.Text+1
P.SelectionStart=1
return true
end}},
})
end,
onLoad=function()
F:open({
title="Load program",
hint="Paste saved text. Loading replaces everything in the workspace.",
text="",
actions={{label="Replace workspace",run=function(L)
if string.match(L,"^%s*$")then return"Paste saved text first."end
if#L>l.Values.LIMITS.MAX_JSON_BYTES then return"Text is too large to load."end
local M,N=pcall(j.JSONDecode,j,L)
if not M then return"Not valid JSON: "..string.sub(tostring(N),1,120)end
local O,P=l.importProgram(w,N)
if not O then
syncCustom()
return P
end
stop()
K:resetData()
C:clearError()
x:replace(O)
return nil
end}},
})
end,
})




local L={Plugin=u,Registry=w,Palette=D,Program=x,
Interpreter=K,Gui=y,Visible=true}

function L:LoadPlugin(M)
local N=l.loadPlugin(w,M)
if N~=nil then return N end
local O,P=pcall(function()D:refresh()end)
if not O then return"palette refresh failed after loading plugin: "..tostring(P)end
return nil
end


function L:SetVisibility(M)
assert(type(M)=="boolean","SetVisibility expects a boolean")
v=M
self.Visible=M
y.Enabled=M
end

return L

end)(e,__require)