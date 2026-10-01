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




local a


local b={function()local b,c,d=a(1)local e return(function(...)




local g=game:GetService("Players")
local h=game:GetService("HttpService")
local i=game:GetService("UserInputService")
local j=d(c.Lang)
local k=d(c.UI.Theme)
local l=d(c.UI.Program)
local m=d(c.UI.Palette)
local n=d(c.UI.Workspace)
local o=d(c.UI.Editor)
local p=d(c.UI.Toolbar)
local q=d(c.UI.Console)
local r=d(c.UI.Transfer)
local s=d(c.Plugin)


local t=true

local u=j.newRegistry()

local function B(v,w,x)
local y=u:createBlock(v)
for z,A in pairs(w or{})do y.inputs[z]=A end
for z,A in pairs(x or{})do y.stacks[z]=A end
return y
end


local v=l.new({scripts={
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

local w=Instance.new("ScreenGui")
w.Name="BlockScript"
w.ResetOnSpawn=false


local function applyInset()w.IgnoreGuiInset=not i.TouchEnabled end
applyInset()
i:GetPropertyChangedSignal("TouchEnabled"):Connect(applyInset)



local function guiParent()
local x,y=pcall(function()return type(gethui)=="function"and gethui()or nil end)
if x and typeof(y)=="Instance"then
local z=y
while z do
if z:IsA("BasePlayerGui")then return y end
z=z.Parent
end
end
return g.LocalPlayer:WaitForChild("PlayerGui")
end
w.Parent=guiParent()

local x=Instance.new("Frame")
x.Name="Root"
x.BackgroundColor3=k.ground
x.BorderSizePixel=0
x.Parent=w

local y=Instance.new("UIScale")
y.Parent=x

local function fit()
local z=w.AbsoluteSize
k.scale=math.clamp(math.min(z.X/1100,z.Y/650),0.7,0.8)
y.Scale=k.scale
x.Size=UDim2.fromScale(1/k.scale,1/k.scale)
end
w:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()

local z=n.new(x,u,v)
z.editor=o.new(x,u,v)
local A=m.new(x,u,
function(A,C,D)z:spawn(A,C,D)end,
function(A,C)z:hover(A,C)end,
function()z:hoverEnd()end)


local function syncCustom()
if u.custom.sync(v:get().scripts)then A:refresh()end
end
v:onChanged(syncCustom)
local C



v.onSet=function(D,E,F,G)
if D.op=="custom_define"and E=="NAME"then

local H=u.custom.parse(tostring(G or"")).code
if H~=""and H~=u.custom.parse(tostring(F or"")).code then
for I,J in ipairs(v:get().scripts)do
local K=J.blocks[1]
if K and K~=D and K.op=="custom_define"
and u.custom.parse(tostring(K.inputs.NAME or"")).code==H then
D.inputs.NAME=F
C:add("A define named \""..tostring(G).."\" already exists. Name not changed.","error")
return
end
end
end
u.custom.sync(v:get().scripts)
u.custom.rename(v:get().scripts,D,F,G)
end
if u:shapeOf(D)=="cap"then
local H,I,J=v:find(D)
if H and H[I+1]then
local K=v:get().scripts[J]
v:detach(H[I+1],K.x+40,K.y+40)
end
end
end


C=q.new(x)
local D=r.new(x)
local E


local F,G={
["space"]=Enum.KeyCode.Space,["up arrow"]=Enum.KeyCode.Up,["down arrow"]=Enum.KeyCode.Down,
["right arrow"]=Enum.KeyCode.Right,["left arrow"]=Enum.KeyCode.Left,
},{}
local H={"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
for I=string.byte("a"),string.byte("z")do F[string.char(I)]=Enum.KeyCode[string.upper(string.char(I))]end
for I=0,9 do F[tostring(I)]=Enum.KeyCode[H[I+1] ]end
for I,J in pairs(F)do G[J]=I end

local I
I=j.newInterpreter(u,{
keyDown=function(J)
if not t then return false end
if i:GetFocusedTextBox()then return false end
if J=="any"then
for K,L in pairs(F)do
if i:IsKeyDown(L)then return true end
end
return false
end
local K=F[J]
return K~=nil and i:IsKeyDown(K)
end,
mouseDown=function()return t and i:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)end,

date=function()
local J=DateTime.now():ToLocalTime()
return{year=J.Year,month=J.Month,day=J.Day,hour=J.Hour,min=J.Minute,sec=J.Second}
end,
output=function(J,K)C:add(J,K)end,
clear=function()C:clear()end,
ask=function(J)return C:ask(J)end,
onError=function(J,K)
C:add("Error: "..J,"error")
if K then z:markError(K)end
end,
onFinish=function()E:setRunning(false)end,
})

i.InputBegan:Connect(function(J,K)
if not t or K or not I.running then return end
local L=G[J.KeyCode]
if L then I:fire("key",L)end
end)

local function stop()
I:stop()
C:cancel()
end

E=p.new(x,{
onRun=function()
C:cancel()
z:clearError()
C:clear()
I:run(v:get())
E:setRunning(I.running)
end,
onStop=stop,
onClear=function()
stop()
I:resetData()
z:clearError()
v:clear()
end,
onSave=function()
local J={blockscript=j.Validate.VERSION,scripts=v:get().scripts}
local K,L=pcall(h.JSONEncode,h,J)
D:open({
title="Save program",
hint="Copy this text and keep it. Load takes it back.",
text=K and L or"",
error=K and""or("Could not encode: "..string.sub(tostring(L),1,120)),
actions={{label="Select all",run=function(M,N)
N:CaptureFocus()
N.CursorPosition=#N.Text+1
N.SelectionStart=1
return true
end}},
})
end,
onLoad=function()
D:open({
title="Load program",
hint="Paste saved text. Loading replaces everything in the workspace.",
text="",
actions={{label="Replace workspace",run=function(J)
if string.match(J,"^%s*$")then return"Paste saved text first."end
if#J>j.Values.LIMITS.MAX_JSON_BYTES then return"Text is too large to load."end
local K,L=pcall(h.JSONDecode,h,J)
if not K then return"Not valid JSON: "..string.sub(tostring(L),1,120)end
local M,N=j.importProgram(u,L)
if not M then
syncCustom()
return N
end
stop()
I:resetData()
z:clearError()
v:replace(M)
return nil
end}},
})
end,
})




local J={Plugin=s,Registry=u,Palette=A,Program=v,
Interpreter=I,Gui=w,Visible=true}

function J:LoadPlugin(K)
local L=j.loadPlugin(u,K)
if L~=nil then return L end
local M,N=pcall(function()A:refresh()end)
if not M then return"palette refresh failed after loading plugin: "..tostring(N)end
return nil
end


function J:SetVisibility(K)
assert(type(K)=="boolean","SetVisibility expects a boolean")
t=K
self.Visible=K
w.Enabled=K
end

return J

end)()end,function()local b,c,d=a(2)local e return(function(...)




local g=d(c.Core.Registry)
local h=d(c.Core.Interpreter)
local i=d(c.Core.Values)
local j=d(c.Core.Validate)
local k=d(c.Core.Plugins)

local l={Registry=g,Interpreter=h,Values=i,Validate=j,Plugins=k}

function l.newRegistry()
local m=g.new()
d(c.Blocks)(m)
return m
end

function l.newInterpreter(m,n)return h.new(m,n)end



function l.importProgram(m,n)
local o=j.checkSize(n)
if o then return nil,o end
if m.custom then m.custom.sync(type(n)=="table"and n.scripts or nil,true)end
return j.program(n,m)
end



function l.loadPlugin(m,n)return k.load(m,n)end

return l

end)()end,function()local b,c,d=a(3)local e return(function(...)


return function(g)
local h=d(c.Parent.Core.Values)
local i={
d(c.Events),
d(c.Control),
d(c.Operators),
d(c.Variables),
d(c.Lists),
d(c.Sensing),
d(c.Output),
d(c.Custom),
}
for j,k in ipairs(i)do
k(g,h)
end
end

end)()end,function()local b,c,d=a(4)local e return(function(...)return function(g,h)
g:defineCategory("Control",{name="Control",color={255,171,25}})

g:defineBlock({id="control_wait",category="Control",shape="stack",
label="wait {SECS} seconds",
inputs={SECS={type="number",default=1}},
run=function(i,j)i:wait(math.max(0,j.SECS))end})

g:defineBlock({id="control_repeat",footerIcon="loop",category="Control",shape="c",
label="repeat {TIMES}",stacks={"SUBSTACK"},
inputs={TIMES={type="number",default=10}},
run=function(i,j)
for k=1,math.floor(j.TIMES)do
if not i:alive()then return"STOP"end
local l=i:stack("SUBSTACK")
if l then return l end
i:loopStep()
end
end})


g:defineBlock({id="control_forever",footerIcon="loop",category="Control",shape="cap",
label="forever",stacks={"SUBSTACK"},
run=function(i)
while i:alive()do
local j=i:stack("SUBSTACK")
if j then return j end
i:loopStep()
end
return"STOP"
end})

g:defineBlock({id="control_if",category="Control",shape="c",
label="if {COND} then",stacks={"THEN"},
inputs={COND={type="boolean"}},
run=function(i,j)
if j.COND then return i:stack("THEN")end
end})

g:defineBlock({id="control_if_else",category="Control",shape="c",
label="if {COND} then",stacks={"THEN","ELSE"},
inputs={COND={type="boolean"}},
run=function(i,j)
return i:stack(j.COND and"THEN"or"ELSE")
end})

g:defineBlock({id="control_wait_until",category="Control",shape="stack",
label="wait until {COND}",
inputs={COND={type="boolean",lazy=true}},
run=function(i)
while i:alive()and not i:input("COND")do i:yield()end
end})

g:defineBlock({id="control_repeat_until",footerIcon="loop",category="Control",shape="c",
label="repeat until {COND}",stacks={"SUBSTACK"},
inputs={COND={type="boolean",lazy=true}},
run=function(i)
while i:alive()and not i:input("COND")do
local j=i:stack("SUBSTACK")
if j then return j end
i:loopStep()
end
end})

g:defineBlock({id="control_while",footerIcon="loop",category="Control",shape="c",
label="while {COND}",stacks={"SUBSTACK"},
inputs={COND={type="boolean",lazy=true}},
run=function(i)
while i:alive()and i:input("COND")do
local j=i:stack("SUBSTACK")
if j then return j end
i:loopStep()
end
end})


g:defineBlock({id="control_for_each",footerIcon="loop",category="Control",shape="c",
label="for {VAR} = 1 to {VALUE}",stacks={"SUBSTACK"},
inputs={VAR={type="variable",default="i"},VALUE={type="number",default=10}},
run=function(i,j)
local k=1
while i:alive()and k<=j.VALUE do
i.interp:setVar(j.VAR,k)
local l=i:stack("SUBSTACK")
if l then return l end
i:loopStep()
k=k+1
end
end})


g:defineBlock({id="control_for_in",footerIcon="loop",category="Control",shape="c",
label="for each {VAR} in {LIST}",stacks={"SUBSTACK"},
inputs={VAR={type="variable",default="item"},LIST={type="list",default="my list"}},
run=function(i,j)
local k=i.interp:list(j.LIST)
local l=1
while i:alive()and k[l]~=nil do
i.interp:setVar(j.VAR,k[l])
local m=i:stack("SUBSTACK")
if m then return m end
i:loopStep()
l=l+1
end
end})


g:defineBlock({id="control_all_at_once",category="Control",shape="c",
label="all at once",stacks={"SUBSTACK"},
run=function(i)return i:stack("SUBSTACK")end})

g:defineBlock({id="control_get_counter",category="Control",shape="reporter",label="counter",
run=function(i)return i.interp.counter end})
g:defineBlock({id="control_incr_counter",category="Control",shape="stack",label="increment counter",
run=function(i)i.interp.counter=i.interp.counter+1 end})
g:defineBlock({id="control_clear_counter",category="Control",shape="stack",label="clear counter",
run=function(i)i.interp.counter=0 end})


g:defineBlock({id="control_stop",category="Control",shape="cap",
label="stop {OPTION}",
inputs={OPTION={type="string",default="this script",options={"this script","all","other scripts"}}},
shapeOf=function(i)return i.inputs.OPTION=="other scripts"and"stack"or"cap"end,
run=function(i,j)
if j.OPTION=="all"then i:stopAll()return"STOP"end
if j.OPTION=="other scripts"then i:stopOthers()return nil end
return"STOP"
end})


g:defineBlock({id="control_error",category="Control",shape="cap",label="error {MESSAGE}",
inputs={MESSAGE={type="any",default="something went wrong",raw=true}},
run=function(i,j)error(h.toString(j.MESSAGE),0)end})



g:defineBlock({id="control_pcall",category="Control",shape="c",
label="pcall, error message in {VAR}",stacks={"TRY","CATCH"},
inputs={VAR={type="variable",default="err"}},
run=function(i,j)
local k=i.thread
local l,m,n,o,p=k.cur,k.execDepth,k.depth,k.frame,k.warp
local q,r=pcall(i.stack,i,"TRY")
if q then return r end
k.cur,k.execDepth,k.depth,k.frame,k.warp=l,m,n,o,p
i.interp:setVar(j.VAR,h.toString(r))
return i:stack("CATCH")
end})
end

end)()end,function()local b,c,d=a(5)local e return(function(...)











return function(g,h)
local i=h.LIMITS
g:defineCategory("Custom",{name="My Blocks",color={255,102,128}})

local j=i.MAX_CALL_DEPTH
local k="custom:"
local l={"normal","without pausing"}

local function trim(m)return(string.match(m,"^%s*(.-)%s*$"))end

local function nameOf(m)
if type(m)=="string"or type(m)=="number"then
local n=trim(h.toString(m))
if n~=""then return n end
end
end



local function parse(m)
local n,o,p={},{},1
local function literal(q)table.insert(n,(string.gsub(q,"%%","")))end
while p<=#m do
local q,r,s=string.find(m,"%(([^()<>]+)%)",p)
local t,u,v=string.find(m,"<([^()<>]+)>",p)
local w,x,y,z
if q and(not t or q<t)then w,x,y,z=q,r,s,"s"
elseif t then w,x,y,z=t,u,v,"b"end
if not w then literal(string.sub(m,p))break end
literal(string.sub(m,p,w-1))
y=trim(y)
if y==""then literal(string.sub(m,w,x))
else
if#o>=i.MAX_PARAMS then literal(string.sub(m,w,x))
else
table.insert(o,{name=y,kind=z})
table.insert(n,"%"..z)
end
end
p=x+1
end
return{code=trim((string.gsub(table.concat(n),"%s+"," "))),params=o}
end


local function kindsOf(m)
local n={}
for o in string.gmatch(m,"%%([sb])")do table.insert(n,o)end
return n
end

local function defineNameOf(m)
return nameOf(type(m.inputs)=="table"and m.inputs.NAME)
end

local function findDefine(m,n)
for o,p in ipairs(m and m.scripts or{})do
local q=p.blocks and p.blocks[1]
if q and q.op=="custom_define"then
local r=defineNameOf(q)
if r and parse(r).code==n then return p,q end
end
end
end

g:defineBlock({id="custom_define",category="Custom",shape="hat",bowler=true,label="define {NAME} {MODE}",
inputs={NAME={type="string",default="my block",reporters=false},
MODE={type="string",default="normal",options=l}},
hat={event="define"}})


g:defineBlock({id="custom_arg",category="Custom",shape="reporter",label="{NAME}",listed=false,
inputs={NAME={type="param",default=""}},
run=function(m,n)
local o=m.thread.frame
local p=o and o.vals[n.NAME]
if p==nil then return 0 end
return p
end})
g:defineBlock({id="custom_arg_bool",category="Custom",shape="boolean",label="{NAME}",listed=false,
inputs={NAME={type="param",default=""}},
run=function(m,n)
local o=m.thread.frame
return o~=nil and h.toBool(o.vals[n.NAME])
end})

local m={}

local function defineCall(n)
local o=kindsOf(n)
local p,q,r={},{},1
for s,t in ipairs(o)do
local u,v=string.find(n,"%%"..t,r)
table.insert(q,(string.gsub(string.sub(n,r,u-1),"[{}%%]","")))
table.insert(q,"{P"..s.."}")
p["P"..s]=t=="b"and{type="boolean"}or{type="any",default=""}
r=v+1
end
table.insert(q,(string.gsub(string.sub(n,r),"[{}%%]","")))
local s=table.concat(q)
if string.find(s,"^%s*$")then s="block"end
local t=g:defineBlock({id=k..n,category="Custom",shape="stack",label=s,listed=false,
inputs=p,
run=function(t,u)
local v=t.interp
local w,x=findDefine(v.program,n)
if not w then error("\""..n.."\" has no define block",0)end
local y=t.thread
y.depth=(y.depth or 0)+1
if y.depth>j then error("blocks nested too deep (recursion without an end?)",0)end
local z={parent=y.frame,vals={}}
for A,C in ipairs(parse(defineNameOf(x)).params)do z.vals[C.name]=u["P"..A]end
y.frame=z
local A=x.inputs.MODE=="without pausing"
if A then v:enterWarp(y)end
local C=v:runStack(y,w.blocks,2)
if A then v:exitWarp(y)end
y.frame=z.parent
y.depth=y.depth-1

if C and not t:alive()then return"STOP"end
end})
m[n]=t
return t
end

local function walk(n,o,p)
if type(n)~="table"or p>100 then return end
for q,r in ipairs(n)do
if type(r)=="table"then
o(r)
if type(r.inputs)=="table"then
for s,t in pairs(r.inputs)do
if type(t)=="table"and t.op then walk({t},o,p+1)end
end
end
if type(r.stacks)=="table"then
for s,t in pairs(r.stacks)do walk(t,o,p+1)end
end
end
end
end

local n={}
g.custom=n
n.parse=parse



function n.sync(o,p)
local q,r,s,t={},{},false,false
if type(o)=="table"then
for u,v in ipairs(o)do
if type(v)=="table"and type(v.blocks)=="table"then
local w=v.blocks[1]
if type(w)=="table"and w.op=="custom_define"then
local x=defineNameOf(w)
if x then
local y=parse(x)
q[y.code]=true
if#y.params>0 then s=true end
end
end
walk(v.blocks,function(x)
if type(x.op)=="string"and string.sub(x.op,1,#k)==k then
r[string.sub(x.op,#k+1)]=true
end
end,1)
end
end
end
for u in pairs(q)do r[u]=true end
local u=0
for v in pairs(r)do
if not m[v]and not g:get(k..v)then
u=u+1
if u>i.MAX_CUSTOM then break end
defineCall(v)
t=true
end
end
if not p then
local v,w={},false
for x in pairs(m)do
if not r[x]then v[k..x]=true;w=true end
end
if w then
for x in pairs(v)do m[string.sub(x,#k+1)]=nil end
g:removeBlocks(v)
t=true
end
end
for v,w in pairs(m)do
local x=q[v]==true
if(w.listed~=false)~=x then t=true end
w.listed=x
end

for v,w in ipairs({"custom_arg","custom_arg_bool"})do
local x=g:get(w)
if(x.listed~=false)~=s then t=true end
x.listed=s
end
return t
end





function n.rename(o,p,q,r)
local s,t=parse(nameOf(q)or""),parse(nameOf(r)or"")
local u=0
if type(o)~="table"then return u end


local v={}
for w,x in ipairs(s.params)do
local y=t.params[w]
if y and y.name~=x.name then v[x.name]=y.name end
end
if next(v)then
for w,x in ipairs(o)do
if type(x)=="table"and type(x.blocks)=="table"and x.blocks[1]==p then
walk(x.blocks,function(y)
if(y.op=="custom_arg"or y.op=="custom_arg_bool")and type(y.inputs)=="table"and v[y.inputs.NAME]then
y.inputs.NAME=v[y.inputs.NAME]
u=u+1
end
end,1)
end
end
end

if s.code==t.code or s.code==""or t.code==""then return u end
for w,x in ipairs(o)do
local y=type(x)=="table"and type(x.blocks)=="table"and x.blocks[1]
if y and y~=p and type(y)=="table"and y.op=="custom_define"then
local z=defineNameOf(y)
if z and parse(z).code==s.code then return u end
end
end
if not g:get(k..t.code)then defineCall(t.code)end
local w=g:get(k..t.code)
local x,y=k..s.code,k..t.code
for z,A in ipairs(o)do
if type(A)=="table"then
walk(A.blocks,function(C)
if C.op==x then
local D=type(C.inputs)=="table"and C.inputs or{}
C.op=y
C.inputs={}
for E,F in pairs(w.inputs)do
local G=D[E]
if G==nil then G=F.default end
C.inputs[E]=G
end
u=u+1
end
end,1)
end
end
return u
end
end

end)()end,function()local b,c,d=a(6)local e return(function(...)return function(g,h)
g:defineCategory("Events",{name="Events",color={255,191,0}})

g:defineBlock({id="events_when_run",category="Events",shape="hat",
label="when {@flag} clicked",hat={event="run"}})

g:defineBlock({id="events_when_broadcast",category="Events",shape="hat",
label="when I receive {MESSAGE}",
inputs={MESSAGE={type="string",default="message1",reporters=false}},
hat={event="broadcast",filter=function(i,j)return h.equals(i.MESSAGE,j)end}})


g:defineBlock({id="events_when_key",category="Events",shape="hat",
label="when {KEY} key pressed",
inputs={KEY={type="string",default="space",options=h.KEYS,reporters=false}},
hat={event="key",persistent=true,once=true,filter=function(i,j)return i.KEY=="any"or i.KEY==j end}})


g:defineBlock({id="events_when_timer",category="Events",shape="hat",
label="when timer > {VALUE}",
inputs={VALUE={type="number",default=10}},
hat={event="edge",poll=function(i,j)return j:timer()>i.VALUE end}})

g:defineBlock({id="events_broadcast",category="Events",shape="stack",
label="broadcast {MESSAGE}",
inputs={MESSAGE={type="string",default="message1"}},
run=function(i,j)i.interp:fire("broadcast",j.MESSAGE,i.thread)end})

g:defineBlock({id="events_broadcast_wait",category="Events",shape="stack",
label="broadcast {MESSAGE} and wait",
inputs={MESSAGE={type="string",default="message1"}},
run=function(i,j)
local k=i.interp:fire("broadcast",j.MESSAGE,i.thread)
local function pending()
for l,m in ipairs(k)do if not m.done then return true end end
return false
end
while i:alive()and pending()do i:yield()end
end})
end

end)()end,function()local b,c,d=a(7)local e return(function(...)return function(g,h)
g:defineCategory("Lists",{name="Lists",color={255,102,26}})

local function list(i,j)return i.interp:list(j)end
local i={type="list",default="my list"}

local function INDEX(j)return{type="any",default=j or 1}end

g:defineBlock({id="list_add",category="Lists",shape="stack",label="add {ITEM} to {LIST}",
inputs={ITEM={type="any",default="thing"},LIST=i},
run=function(j,k)
local l=list(j,k.LIST)
j.interp:checkListGrow(l,k.ITEM)
l[#l+1]=k.ITEM
end})

g:defineBlock({id="list_delete",category="Lists",shape="stack",label="delete {INDEX} of {LIST}",
inputs={INDEX=INDEX(),LIST=i},
run=function(j,k)
local l=list(j,k.LIST)
local m=h.listIndex(k.INDEX,#l,true)
if m=="all"then j.interp.lists[k.LIST]={}
elseif m then table.remove(l,m)end
end})

g:defineBlock({id="list_clear",category="Lists",shape="stack",label="delete all of {LIST}",
inputs={LIST=i},run=function(j,k)list(j,k.LIST)j.interp.lists[k.LIST]={}end})

g:defineBlock({id="list_insert",category="Lists",shape="stack",label="insert {ITEM} at {INDEX} of {LIST}",
inputs={ITEM={type="any",default="thing"},INDEX=INDEX(),LIST=i},
run=function(j,k)
local l=list(j,k.LIST)
local m=h.listIndex(k.INDEX,#l+1,false)
if m then
j.interp:checkListGrow(l,k.ITEM)
table.insert(l,m,k.ITEM)
end
end})

g:defineBlock({id="list_replace",category="Lists",shape="stack",label="replace item {INDEX} of {LIST} with {ITEM}",
inputs={INDEX=INDEX(),LIST=i,ITEM={type="any",default="thing"}},
run=function(j,k)
local l=list(j,k.LIST)
local m=h.listIndex(k.INDEX,#l,false)
if m then l[m]=h.limitString(k.ITEM)end
end})

g:defineBlock({id="list_item",category="Lists",shape="reporter",output="any",label="item {INDEX} of {LIST}",
inputs={INDEX=INDEX(),LIST=i},
run=function(j,k)
local l=list(j,k.LIST)
local m=h.listIndex(k.INDEX,#l,false)
if not m then return nil end
return l[m]
end})


g:defineBlock({id="list_indexof",category="Lists",shape="reporter",output="any",label="item # of {ITEM} in {LIST}",
inputs={ITEM={type="any",default="thing"},LIST=i},
run=function(j,k)
for l,m in ipairs(list(j,k.LIST))do if h.equals(m,k.ITEM)then return l end end
return nil
end})

g:defineBlock({id="list_length",category="Lists",shape="reporter",label="length of {LIST}",
inputs={LIST=i},run=function(j,k)return#list(j,k.LIST)end})

g:defineBlock({id="list_contains",category="Lists",shape="boolean",label="{LIST} contains {ITEM}",
inputs={LIST=i,ITEM={type="any",default="thing"}},
run=function(j,k)
for l,m in ipairs(list(j,k.LIST))do if h.equals(m,k.ITEM)then return true end end
return false
end})


g:defineBlock({id="list_contents",category="Lists",shape="reporter",label="{LIST}",
inputs={LIST=i},run=function(j,k)return h.listContents(list(j,k.LIST))end})
end

end)()end,function()local b,c,d=a(8)local e return(function(...)return function(g,h)
g:defineCategory("Operators",{name="Operators",color={89,192,89}})

local function binary(i,j,k,l,m,n)
g:defineBlock({id=i,category="Operators",shape=k,
label="{A} "..j.." {B}",
inputs={A={type=l,default=n and n[1]},B={type=l,default=n and n[2]}},
run=function(o,p)return m(p.A,p.B)end})
end

binary("op_add","+","reporter","number",function(i,j)return i+j end)
binary("op_sub","-","reporter","number",function(i,j)return i-j end)
binary("op_mul","*","reporter","number",function(i,j)return i*j end)
binary("op_div","/","reporter","number",function(i,j)return i/j end)
binary("op_mod","mod","reporter","number",function(i,j)
if j==0 then return 0/0 end
local k=math.fmod(i,j)
if k/j<0 then k=k+j end
return k
end)

binary("op_gt",">","boolean","any",function(i,j)return h.less(j,i)end,{0,50})
binary("op_lt","<","boolean","any",function(i,j)return h.less(i,j)end,{0,50})
binary("op_eq","=","boolean","any",function(i,j)return h.equals(i,j)end,{0,50})



local function logic(i,j,k)
g:defineBlock({id=i,category="Operators",shape="boolean",label="{A} "..j.." {B}",
inputs={A={type="boolean",raw=true,lazy=true},B={type="boolean",raw=true,lazy=true}},
run=function(l)
local m=l:input("A")
if h.toBool(m)==k then return m end
return l:input("B")
end})
end
logic("op_and","and",false)
logic("op_or","or",true)

g:defineBlock({id="op_not",category="Operators",shape="boolean",label="not {A}",
inputs={A={type="boolean"}},run=function(i,j)return not j.A end})



g:defineBlock({id="op_if_else",category="Operators",shape="reporter",label="if {COND} then {A} else {B}",
inputs={COND={type="boolean",lazy=true},A={type="any",default=1,lazy=true},B={type="any",default=0,lazy=true}},
run=function(i)
if i:input("COND")then return i:input("A")end
return i:input("B")
end})


g:defineBlock({id="op_random",category="Operators",shape="reporter",
label="pick random {FROM} to {TO}",
inputs={FROM={type="number",default=1},TO={type="number",default=10}},
run=function(i,j)

local k=2147483647
local function whole(l)l=math.max(-k,math.min(k,l))return l>=0 and math.floor(l)or-math.floor(-l)end
local l,m=whole(j.FROM),whole(j.TO)
if l>m then error("interval is empty",0)end
return math.random(l,m)
end})


local function str(i)
if type(i)=="string"then return i end
if type(i)=="number"then return h.toString(i)end
error("expected text, got "..h.typeName(i),0)
end


g:defineBlock({id="op_join",category="Operators",shape="reporter",label="join {A} {B}",
inputs={A={type="any",default="apple ",raw=true},B={type="any",default="banana",raw=true}},
run=function(i,j)
if type(j.A)~="string"and type(j.A)~="number"then error("attempt to concatenate "..h.typeName(j.A),0)end
if type(j.B)~="string"and type(j.B)~="number"then error("attempt to concatenate "..h.typeName(j.B),0)end
local k,l=str(j.A),str(j.B)
if#k+#l>h.LIMITS.MAX_STRING then error("string too long",0)end
return k..l
end})


g:defineBlock({id="op_letter",category="Operators",shape="reporter",label="letter {N} of {S}",
inputs={N={type="number",default=1},S={type="any",default="apple",raw=true}},
run=function(i,j)
local k=j.N>=0 and math.floor(j.N)or-math.floor(-j.N)
if k~=k or k==math.huge or k==-math.huge then return""end
return string.sub(str(j.S),k,k)
end})


g:defineBlock({id="op_length",category="Operators",shape="reporter",label="length of {S}",
inputs={S={type="any",default="apple",raw=true}},run=function(i,j)return#str(j.S)end})


g:defineBlock({id="op_contains",category="Operators",shape="boolean",label="{S} contains {T}",
inputs={S={type="any",default="apple",raw=true},T={type="any",default="a",raw=true}},
run=function(i,j)return string.find(str(j.S),str(j.T),1,true)~=nil end})


g:defineBlock({id="op_tonumber",category="Operators",shape="reporter",output="any",label="tonumber {A}",
inputs={A={type="any",default="10",raw=true}},
run=function(i,j)
if type(j.A)=="number"then return j.A end
if type(j.A)=="string"then return h.parseNumber(j.A)end
return nil
end})
g:defineBlock({id="op_tostring",category="Operators",shape="reporter",label="tostring {A}",
inputs={A={type="any",default=10,raw=true}},
run=function(i,j)return h.toString(j.A)end})


g:defineBlock({id="op_nil",category="Operators",shape="reporter",output="any",label="nil",
run=function()return nil end})


g:defineBlock({id="op_round",category="Operators",shape="reporter",label="round {A}",
inputs={A={type="number"}},run=function(i,j)return h.round(j.A)end})


g:defineBlock({id="op_pi",category="Operators",shape="reporter",label="pi",run=function()return math.pi end})

local i={
abs=math.abs,floor=math.floor,ceiling=math.ceil,sqrt=math.sqrt,
sin=math.sin,cos=math.cos,tan=math.tan,
asin=math.asin,acos=math.acos,atan=math.atan,
ln=math.log,log=function(i)return math.log(i)/math.log(10)end,
["e ^"]=math.exp,["10 ^"]=function(i)return 10^i end,
}
g:defineBlock({id="op_math",category="Operators",shape="reporter",label="{FN} of {A}",
inputs={FN={type="string",default="abs",options={"abs","floor","ceiling","sqrt","sin","cos","tan","asin","acos","atan","ln","log","e ^","10 ^"}},
A={type="number"}},
run=function(j,k)local l=i[k.FN]return l and l(k.A)or 0 end})
end

end)()end,function()local b,c,d=a(9)local e return(function(...)return function(g,h)
g:defineCategory("Output",{name="Output",color={15,189,140}})

g:defineBlock({id="out_print",category="Output",shape="stack",label="print {TEXT}",
inputs={TEXT={type="string",default="Hello!"}},
run=function(i,j)i:say(j.TEXT,"say")end})

g:defineBlock({id="out_clear",category="Output",shape="stack",label="clear output",
run=function(i)if i.interp.opts.clear then i.interp.opts.clear()end end})
end

end)()end,function()local b,c,d=a(10)local e return(function(...)return function(g,h)
g:defineCategory("Sensing",{name="Sensing",color={92,177,214}})

g:defineBlock({id="sensing_ask",category="Sensing",shape="stack",label="ask {PROMPT} and wait",
inputs={PROMPT={type="string",default="What's your name?"}},
run=function(i,j)
local k=i.interp.opts.ask
local l=i.thread
l.asking=true
local m,n=pcall(function()return k and h.toString(k(j.PROMPT))or""end)
l.asking=false
if not m then error(n,0)end
i.interp.answer=string.sub(n,1,h.LIMITS.MAX_STRING)
end})

g:defineBlock({id="sensing_answer",category="Sensing",shape="reporter",label="answer",
run=function(i)return i.interp.answer end})



g:defineBlock({id="sensing_keypressed",category="Sensing",shape="boolean",label="key {KEY} pressed?",
inputs={KEY={type="string",default="space",options=h.KEYS,reporters=true}},
run=function(i,j)return i.interp:keyDown(j.KEY)end})

g:defineBlock({id="sensing_mousedown",category="Sensing",shape="boolean",label="mouse down?",
run=function(i)return i.interp:mouseDown()end})

local i={"year","month","date","day of week","hour","minute","second"}
g:defineBlock({id="sensing_current",category="Sensing",shape="reporter",label="current {UNIT}",
inputs={UNIT={type="string",default="year",options=i}},
run=function(j,k)
local l=j.interp:localDate()
local m={year=l.year,month=l.month,date=l.day,["day of week"]=l.wday,
hour=l.hour,minute=l.min,second=l.sec}
return m[k.UNIT]or 0
end})

g:defineBlock({id="sensing_dayssince2000",category="Sensing",shape="reporter",label="days since 2000",
run=function(j)return j.interp:daysSince2000()end})

g:defineBlock({id="sensing_timer",category="Sensing",shape="reporter",label="timer",
run=function(j)return j.interp:timer()end})

g:defineBlock({id="sensing_reset_timer",category="Sensing",shape="stack",label="reset timer",
run=function(j)j.interp:resetTimer()end})
end

end)()end,function()local b,c,d=a(11)local e return(function(...)return function(g,h)
g:defineCategory("Variables",{name="Variables",color={255,140,26}})

g:defineBlock({id="data_set",category="Variables",shape="stack",label="set {NAME} to {VALUE}",
inputs={NAME={type="variable",default="my variable"},VALUE={type="any",default=0}},
run=function(i,j)i.interp:setVar(j.NAME,j.VALUE)end})

g:defineBlock({id="data_change",category="Variables",shape="stack",label="change {NAME} by {BY}",
inputs={NAME={type="variable",default="my variable"},BY={type="number",default=1}},
run=function(i,j)i.interp:setVar(j.NAME,h.toNumber(i.interp.vars[j.NAME])+j.BY)end})

g:defineBlock({id="data_get",category="Variables",shape="reporter",output="any",label="{NAME}",
inputs={NAME={type="variable",default="my variable"}},

run=function(i,j)return i.interp.vars[j.NAME]end})
end

end)()end,[13]=function()local b,c,d=a(13)local e return(function(...)

















local g=d(c.Parent.Values)

local h={}
h.__index=h

local i=g.LIMITS
local j=0.1


local function daysFromCivil(k,l,m)
if l<=2 then k=k-1 end
local n=math.floor(k/400)
local o=k-n*400
local p=math.floor((153*(l+(l>2 and-3 or 9))+2)/5)+m-1
local q=o*365+math.floor(o/4)-math.floor(o/100)+p
return n*146097+q-719468
end


local k={}
k.__index=k
function k:stack(l)return self.interp:runStack(self.thread,self.block.stacks[l]or{})end
function k:input(l)return self.interp:evalInput(self.thread,self.block,l)end
function k:alive()return not(self.thread.stopped or self.interp.halted)end
function k:tick()self.interp:tick(self.thread)end
function k:loopStep()self.interp:loopStep(self.thread)end
function k:yield()self.interp:pause(self.thread)end
function k:warp(l)if l then self.interp:enterWarp(self.thread)else self.interp:exitWarp(self.thread)end end
function k:stopOthers()self.interp:stopOthers(self.thread)end
function k:wait(l)self.interp:sleep(self.thread,l)end
function k:say(l,m)self.interp:say(l,m)end
function k:stopAll()self.interp:stop()end

function h.new(l,m)
m=m or{}
local n=setmetatable({},h)
n.registry=l
n.opts=m
n.spawn=m.spawn or(task and task.spawn)or function(o)o()end
n.defer=m.defer or(task and task.defer)or nil
n.cancel=m.cancel or(task and task.cancel)or nil
n.turn=m.turn or(task and task.defer and function()
local o=coroutine.running()
task.defer(o)
coroutine.yield()
end)or nil
n.wait=m.wait or(task and task.wait)or function()end
n.clock=m.clock or os.clock
n.budget=m.budget or 500
n.vars,n.lists,n.threads,n.watchers={},{},{},{}
n.program,n.halted,n.running=nil,false,false
n.active,n.steps,n.answer,n.timerStart,n.runId=0,0,"",0,0
n.counter=0
n.nthreads,n.starts,n.lines,n.frameStart=0,0,0,nil
n.uncounted,n.throttled=false,false
return n
end



function h:_frameCheck()
local l=self.clock()
local m=self.frameStart
if m==nil or l<m or l-m>=i.FRAME_WINDOW then
self.frameStart,self.starts,self.lines=l,0,0
end
return l
end


function h:_overBudget()
local l=self:_frameCheck()
return l-self.frameStart>=i.FRAME_SECONDS
end


function h:say(l,m)
local n=g.toString(l)
if#n>i.MAX_PRINT then
local o=i.MAX_PRINT
while o>0 do
local p=string.byte(n,o+1)
if p and p>=0x80 and p<0xC0 then o=o-1 else break end
end
n=string.sub(n,1,o).."..."
end
self:_frameCheck()
self.lines=self.lines+1
if self.lines>i.MAX_LINES_PER_FRAME then
if self.throttled then return end
self.throttled,n,m=true,"output throttled (too many lines per frame)","say"
end
if self.opts.output then self.opts.output(n,m or"say")else print(n)end
end


function h:setVar(l,m)
local n=self.vars
if n[l]==nil then
if#l>i.MAX_NAME then error("name too long",0)end
local o=0
for p in pairs(n)do o=o+1 end
if o>=i.MAX_VARS then error("too many variables",0)end
end
n[l]=g.limitString(m)
end

function h:list(l)
local m=self.lists[l]
if m then return m end
if#l>i.MAX_NAME then error("name too long",0)end
local n=0
for o in pairs(self.lists)do n=n+1 end
if n>=i.MAX_LISTS then error("too many lists",0)end
m={}
self.lists[l]=m
return m
end


function h:checkListGrow(l,m)
g.limitString(m)
if#l>=i.MAX_LIST then error("list too long",0)end
local n=0
for o,p in pairs(self.lists)do n=n+#p end
if n>=i.MAX_LISTS_TOTAL_ITEMS then error("too many list items",0)end
end

function h:timer()return self.clock()-self.timerStart end
function h:resetTimer()self.timerStart=self.clock()end



function h:enterWarp(l)
if(l.warp or 0)==0 then l.warpStart=self.clock()end
l.warp=(l.warp or 0)+1
end

function h:exitWarp(l)
l.warp=math.max(0,(l.warp or 0)-1)
end


function h:pause(l)
if l and(l.warp or 0)>0 then
if self.clock()-l.warpStart<i.WARP_SECONDS then return end
l.warpStart=self.clock()
end
self.wait()
self:_frameCheck()
end



function h:tick(l)
self.steps=self.steps+1
if self.steps>=self.budget then
self.steps=0
self:pause(l)
elseif self.steps%16==0 and self:_overBudget()then
self:pause(l)
end
end



function h:loopStep(l)
self:tick(l)
if(l.warp or 0)>0 then return end
if self:_overBudget()then
self.steps=0
self.wait()
self:_frameCheck()
elseif self.turn then
self.turn()
end
end


function h:resetData()
self.vars,self.lists,self.counter,self.answer={},{},0,""
end



function h:sleep(l,m)
local n,o=m,true
while o or n>0 do
o=false
local p=n<j and n or j
self.wait(p)
n=n-p
if l.stopped or self.halted then return end
end
end

function h:stopOthers(l)
local m={}
for n in pairs(self.threads)do
if n~=l then m[#m+1]=n end
end
for n,o in ipairs(m)do self:_kill(o)end
end


function h:_kill(l)
l.stopped=true
if not l.asking then self:_cancel(l.handle)end
self:_retire(l)
end


function h:_retire(l)
if l.retired then return end
l.retired,l.done=true,true
if l.runId~=self.runId then return end
if self.threads[l]then
self.threads[l]=nil
self.nthreads=self.nthreads-1
end
self.active=self.active-1
if self.active==0 then self:_finish()end
end


function h:_threadFor(l)
for m in pairs(self.threads)do
if m.script==l and not m.retired then return m end
end
end


function h:localDate()
local l=self.opts.date and self.opts.date()
if not l and DateTime then
local m=DateTime.now():ToLocalTime()
l={year=m.Year,month=m.Month,day=m.Day,hour=m.Hour,min=m.Minute,sec=m.Second}
end
l=l or os.date("*t")
local m=daysFromCivil(l.year,l.month,l.day)
return{year=l.year,month=l.month,day=l.day,wday=(m+4)%7+1,
hour=l.hour or 0,min=l.min or 0,sec=l.sec or 0,days=m}
end

function h:daysSince2000()
local l=self:localDate()
return l.days-daysFromCivil(2000,1,1)+(l.hour*3600+l.min*60+l.sec)/86400
end

function h:keyDown(l)return self.opts.keyDown~=nil and self.opts.keyDown(l)==true end
function h:mouseDown()return self.opts.mouseDown~=nil and self.opts.mouseDown()==true end

function h:fail(l,m)
self:stop()
if self.opts.onError then self.opts.onError(tostring(l),m)else warn("[BlockScript] "..tostring(l))end
end

function h:_finish()
if not self.running then return end
self.running=false
if self.opts.onFinish then self.opts.onFinish()end
end


function h:_cancel(l)
if l~=nil and self.cancel and l~=coroutine.running()then pcall(self.cancel,l)end
end

function h:stop()
self.halted=true
for l in pairs(self.threads)do
l.stopped,l.retired=true,true
if not l.asking then self:_cancel(l.handle)end
end
for l,m in ipairs(self.watchers)do self:_cancel(m)end
self.threads,self.watchers,self.nthreads={},{},0
self:_finish()
end



function h:execBlock(l,m)
local n=self.registry:get(m.op)
if not n then
l.cur=m
error("Unknown block: "..tostring(m.op),0)
end
local o=(l.execDepth or 0)+1
if o>i.MAX_EXEC_DEPTH then
l.cur=m
error("blocks nested too deep",0)
end
l.execDepth=o
local p=l.cur
l.cur=m
local q=setmetatable({interp=self,thread=l,block=m,def=n},k)
local r={}
for s,t in pairs(n.inputs)do
if not t.lazy then r[s]=self:evalInput(l,m,s)end
end
local s
if not(self.halted or l.stopped)then
self:tick(l)
s=n.run(q,r)
end
l.execDepth=o-1
l.cur=p
return s
end

function h:evalInput(l,m,n)
local o=self.registry:get(m.op)
local p=o.inputs[n]
local q=m.inputs[n]
if type(q)=="table"and q.op then q=self:execBlock(l,q)end
if p.raw then return q end
return g.coerce(p.type,q)
end


function h:runStack(l,m,n)
for o=n or 1,#m do
if l.stopped or self.halted then return"STOP"end
local p=self:execBlock(l,m[o])
if p then return p end
end
return nil
end




function h:_launch(l,m)
if self.defer then return self.defer(l)end
if m then return self.spawn(function()self.wait()l()end)end
return self.spawn(l)
end


function h:_startThread(l,m,n)
if self.nthreads>=i.MAX_THREADS then
self:fail("too many scripts running")
return nil
end
if not self.uncounted then
self:_frameCheck()
self.starts=self.starts+1
if self.starts>i.MAX_STARTS_PER_FRAME then
self:fail("too many scripts running")
return nil
end
end
local o={stopped=false,done=false,script=l,runId=self.runId}
self.threads[o]=true
self.nthreads=self.nthreads+1
self.active=self.active+1
local p=self.runId
o.handle=self:_launch(function()
if o.stopped or self.halted or p~=self.runId then return end
self:_frameCheck()
local q,r=pcall(self.runStack,self,o,l.blocks,m)
if not q and not self.halted and p==self.runId then self:fail(r,o.cur)end
self:_retire(o)
end,n)
return o
end

local function hatArgs(l,m,n)
local o,p={stopped=false},{}
for q in pairs(n.inputs)do p[q]=l:evalInput(o,m,q)end
return p
end



function h:_startWatchers()
local l=false
local m=self.runId
for n,o in ipairs(self.program.scripts)do
local p=o.blocks[1]
local q=p and self.registry:get(p.op)
if q and q.shape=="hat"and(q.hat.persistent or q.hat.poll)then
l=true
if q.hat.poll then
local r=self:_launch(function()
local r=false
while not self.halted and m==self.runId do
if not self:_threadFor(o)then
local s,t=pcall(function()return q.hat.poll(hatArgs(self,p,q),self)end)
if not s then self:fail(t,p)return end
if t and not r then self:_startThread(o,2,true)end
r=t and true or false
end
self.wait()
end
end,false)
if r~=nil then table.insert(self.watchers,r)end
end
end
end
if l then self.active=self.active+1 end
end



function h:fire(l,m,n)
local o={}
if not self.program then return o end
for p,q in ipairs(self.program.scripts)do
local r=q.blocks[1]
local s=r and self.registry:get(r.op)
if s and s.shape=="hat"and s.hat.event==l then
local t=true
if s.hat.filter then
local u,v=pcall(function()return s.hat.filter(hatArgs(self,r,s),m)end)
if not u then self:fail(v,r)break end
t=v
end
if t then
local u=self:_threadFor(q)
if u and s.hat.once then
t=false
elseif u then
self:_kill(u)
end
end
if t then
local u=self:_startThread(q,2,n~=nil)
if not u then break end
table.insert(o,u)
end
end
end
return o
end

function h:run(l)
self:stop()
self.program=l
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

return h

end)()end,[14]=function()local b,c,d=a(14)local e return(function(...)

local g={}

local function deepCopy(h,i)
if type(h)~="table"then return h end
i=i or{}
if i[h]then return i[h]end
local j={}
i[h]=j
for k,l in pairs(h)do j[deepCopy(k,i)]=deepCopy(l,i)end
return j
end


function g.load(h,i)
local j="plugin"
local k,l={},{}
local m,n=pcall(function()
assert(type(i)=="table"and type(i.GetData)=="function","not a plugin (no GetData)")
local m=i:GetData()
assert(type(m)=="table","GetData must return a table")
assert(type(m.Name)=="string"and m.Name~="","plugin needs a Name")
j=m.Name
h.plugins=h.plugins or{}
assert(not h.plugins[j],"plugin already loaded")


for n,o in ipairs(m.Categories or{})do
assert(type(o)=="table"and type(o.id)=="string","category needs a string id")
if not h.categories[o.id]then
h:defineCategory(o.id,o)
table.insert(k,o.id)
end
end
for n,o in ipairs(m.Blocks or{})do
assert(type(o)=="table"and type(o.id)=="string","block needs a string id")
assert(not h.blocks[o.id],"block id already exists: "..o.id)

local p={}
for q,r in pairs(o)do p[q]=deepCopy(r)end
h:defineBlock(p)
l[o.id]=true
end
end)
if not m then
h:removeBlocks(l)
for o,p in ipairs(k)do h:removeCategory(p)end

return j..": "..(string.gsub(tostring(n),"^[^\n:]*:%d+: ",""))
end
h.plugins[j]={categories=k,blocks=l}
return nil
end

return g

end)()end,[15]=function()local b,c,d=a(15)local e return(function(...)

























local g={}
g.__index=g

local h={hat=true,stack=true,cap=true,c=true,reporter=true,boolean=true}

local function parseLabel(i)
local j,k={},1
while true do
local l,m,n=string.find(i,"{(@?[%w_]+)}",k)
if not l then break end
if l>k then table.insert(j,{text=string.sub(i,k,l-1)})end
if string.sub(n,1,1)=="@"then table.insert(j,{icon=string.sub(n,2)})
else table.insert(j,{input=n})end
k=m+1
end
if k<=#i then table.insert(j,{text=string.sub(i,k)})end
return j
end

function g.new()
return setmetatable({blocks={},blockOrder={},categories={},categoryOrder={}},g)
end

function g:defineCategory(i,j)
assert(type(i)=="string","category id must be a string")
j=j or{}
if not self.categories[i]then table.insert(self.categoryOrder,i)end
self.categories[i]={id=i,name=j.name or i,color=j.color or{150,150,150}}
end

function g:defineBlock(i)
assert(type(i)=="table"and type(i.id)=="string","block needs a string id")
assert(not self.blocks[i.id],"duplicate block id: "..i.id)
assert(h[i.shape],"bad shape for "..i.id)
assert(self.categories[i.category],"unknown category for "..i.id)
i.inputs=i.inputs or{}
i.stacks=i.stacks or{}
i.label=i.label or i.id
i.segments=parseLabel(i.label)
if i.shape=="hat"then
assert(i.hat and i.hat.event,"hat block needs hat.event: "..i.id)
i.run=i.run or function()end
end
assert(type(i.run)=="function","block needs run(): "..i.id)
for j,k in ipairs(i.segments)do
if k.input then assert(i.inputs[k.input],i.id..": label uses undeclared input "..k.input)end
end
self.blocks[i.id]=i
table.insert(self.blockOrder,i.id)
return i
end


function g:removeBlocks(i)
local j,k={},0
for l,m in ipairs(self.blockOrder)do
if i[m]then self.blocks[m]=nil;k=k+1 else table.insert(j,m)end
end
self.blockOrder=j
return k
end


function g:removeCategory(i)
if not self.categories[i]then return false end
self.categories[i]=nil
local j={}
for k,l in ipairs(self.categoryOrder)do
if l~=i then table.insert(j,l)end
end
self.categoryOrder=j
return true
end

function g:get(i)return self.blocks[i]end


function g:shapeOf(i)
local j=self.blocks[i.op]
if j.shapeOf then return j.shapeOf(i)end
return j.shape
end



function g:accepts(i,j,k,l)
local m=i and i.inputs[j]
if not m then return false end
if k~="reporter"and k~="boolean"then return false end
local n=m.reporters
if n==nil then
n=not(m.options~=nil or m.type=="variable"or m.type=="list"or m.type=="param")
end
if not n then return false end
if m.type=="boolean"then return k=="boolean"or(l~=nil and l.output=="any")end
return true
end



function g:wrapSlot(i)
local j=i and self.blocks[i.op]
local k=j and j.stacks[1]
if not k then return nil end
local l=i.stacks and i.stacks[k]
if l and#l>0 then return nil end
return k
end

function g:listByCategory(i)
local j={}
for k,l in ipairs(self.blockOrder)do
if self.blocks[l].category==i and self.blocks[l].listed~=false then table.insert(j,self.blocks[l])end
end
return j
end


function g:createBlock(i)
local j=assert(self.blocks[i],"unknown block: "..tostring(i))
local k={op=i,inputs={},stacks={}}
for l,m in pairs(j.inputs)do k.inputs[l]=m.default end
for l,m in ipairs(j.stacks)do k.stacks[m]={}end
return k
end

return g

end)()end,[16]=function()local b,c,d=a(16)local e return(function(...)








local g=d(c.Parent.Values)
local h=g.LIMITS
local i={VERSION=1}

local j=h.MAX_DEPTH

local function isValueShape(k)return k=="reporter"or k=="boolean"end



function i.checkSize(k)
if type(k)~="table"or type(k.scripts)~="table"then return nil end
if#k.scripts>h.MAX_SCRIPTS then return"too many scripts (max "..h.MAX_SCRIPTS..")"end
local l=0
local function walk(m,n)
if type(m)~="table"then return nil end
l=l+1
if l>h.MAX_BLOCKS then return"too many blocks (max "..h.MAX_BLOCKS..")"end
if n>j then return"blocks nested too deep"end
if type(m.inputs)=="table"then
for o,p in pairs(m.inputs)do
if type(p)=="table"then local q=walk(p,n+1)if q then return q end end
end
end
if type(m.stacks)=="table"then
for o,p in pairs(m.stacks)do
if type(p)=="table"then
for q=1,#p do local r=walk(p[q],n+1)if r then return r end end
end
end
end
return nil
end
for m=1,#k.scripts do
local n=k.scripts[m]
if type(n)=="table"and type(n.blocks)=="table"then
for o=1,#n.blocks do local p=walk(n.blocks[o],1)if p then return p end end
end
end
return nil
end

local k

local function block(l,m,n,o,p)
if type(m)~="table"then return nil,n..": block must be an object"end
if o>j then return nil,n..": blocks nested too deep"end
local q=type(m.op)=="string"and l:get(m.op)
if not q then return nil,n..": unknown block "..tostring(m.op)end
local r=isValueShape(q.shape)
if p and not r then return nil,n..": "..q.id.." cannot go in an input"end
if not p and r then return nil,n..": "..q.id.." cannot be a stack block"end

local s=l:createBlock(m.op)
if m.inputs~=nil and type(m.inputs)~="table"then return nil,n..": inputs must be an object"end
for t,u in pairs(m.inputs or{})do
if q.inputs[t]then
local v=n.."."..tostring(t)
local w=type(u)
if w=="table"then
local x,y=block(l,u,v,o+1,true)
if not x then return nil,y end
if not l:accepts(q,t,l:get(x.op).shape,l:get(x.op))then
return nil,v..": "..x.op.." cannot go in the "..t.." slot of "..q.id
end
s.inputs[t]=x
elseif w=="string"or w=="number"or w=="boolean"then
if w=="string"and#u>h.MAX_LITERAL then return nil,v..": text longer than "..h.MAX_LITERAL.." characters"end
if w=="string"and m.op=="custom_define"and t=="NAME"and#u>h.MAX_NAME then
return nil,v..": name longer than "..h.MAX_NAME.." characters"
end
s.inputs[t]=u
else
return nil,v..": input must be a value or a block"
end
end
end

if m.stacks~=nil and type(m.stacks)~="table"then return nil,n..": stacks must be an object"end
for t,u in ipairs(q.stacks)do
local v=m.stacks and m.stacks[u]
if v~=nil then
if type(v)~="table"then return nil,n.."."..u..": stack must be a list"end
local w,x=k(l,v,n.."."..u,o+1,false)
if not w then return nil,x end
s.stacks[u]=w
end
end
return s
end


function k(l,m,n,o,p)
local q={}
for r=1,#m do
local s=n.."["..r.."]"
local t,u=block(l,m[r],s,o,false)
if not t then return nil,u end
local v=l:get(t.op)
if v.shape=="hat"and not(p and r==1)then
return nil,s..": "..v.id.." can only start a script"
end
if r<#m and l:shapeOf(t)=="cap"then
return nil,s..": nothing can follow "..v.id
end
q[r]=t
end
return q
end

function i.program(l,m)
if type(l)~="table"then return nil,"program must be an object"end
if type(l.blockscript)=="number"and l.blockscript>i.VERSION then
return nil,"saved by a newer BlockScript (format "..l.blockscript..")"
end
if type(l.scripts)~="table"then return nil,"program has no scripts list"end
local n=i.checkSize(l)
if n then return nil,n end
local o={}
for p=1,#l.scripts do
local q=l.scripts[p]
local r="scripts["..p.."]"
if type(q)~="table"or type(q.blocks)~="table"or#q.blocks==0 then
return nil,r..": needs a non-empty blocks list"
end
local s,t
local u=#q.blocks==1 and type(q.blocks[1])=="table"and type(q.blocks[1].op)=="string"and m:get(q.blocks[1].op)
if u and isValueShape(u.shape)then
local v,w=block(m,q.blocks[1],r..".blocks[1]",1,true)
if not v then return nil,w end
s={v}
else
s,t=k(m,q.blocks,r..".blocks",1,true)
if not s then return nil,t end
end
local v=type(q.x)=="number"and q.x or 0
local w=type(q.y)=="number"and q.y or 0
o[p]={x=math.max(0,v),y=math.max(0,w),blocks=s}
end
return{scripts=o}
end

return i

end)()end,[17]=function()local b,c,d=a(17)local e return(function(...)
local g={}



g.LIMITS={
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
local h=g.LIMITS


function g.typeName(i)
if i==nil then return"nil"end
return type(i)
end



function g.parseNumber(i)
local j=string.match(i,"^%s*(.-)%s*$")
if j==""or string.find(j,"[nNpP]")then return nil end
local k=tonumber(j)
if k==nil or k~=k then return nil end
return k+0.0
end



function g.toNumber(i)
if type(i)=="number"then return i+0.0 end
if type(i)=="string"then
local j=g.parseNumber(i)
if j~=nil then return j end
end
error("expected a number, got "..(type(i)=="string"and"text \""..string.sub(i,1,20).."\""or g.typeName(i)),0)
end


function g.limitString(i)
if type(i)=="string"and#i>h.MAX_STRING then error("string too long",0)end
return i
end


function g.toString(i)
if type(i)=="number"then
if i~=i then return"nan"end
if i==math.huge then return"inf"end
if i==-math.huge then return"-inf"end
return string.format("%.14g",i)
end
return tostring(i)
end


function g.round(i)
if i>=0 then return math.floor(i+0.5)end
return-math.floor(-i+0.5)
end



function g.chars(i)
local j={}
if utf8 and utf8.len(i)then
for k in string.gmatch(i,utf8.charpattern)do j[#j+1]=k end
else
for k=1,#i do j[k]=string.sub(i,k,k)end
end
return j
end


function g.length(i)
return(utf8 and utf8.len(i))or#i
end


function g.letter(i,j)
local k=g.length(i)
if j~=j or j<1 or j>k then return""end
if utf8 and utf8.len(i)then
local l=utf8.offset(i,j)
local m=utf8.offset(i,j+1)
return string.sub(i,l,(m or#i+1)-1)
end
return string.sub(i,j,j)
end




function g.listIndex(i,j,k)
if type(i)=="string"then
if i=="all"then return k and"all"or nil end
if i=="last"then return j>0 and j or nil end
if i=="random"or i=="any"then return j>0 and math.random(1,j)or nil end
return nil
end
if type(i)~="number"or i~=math.floor(i)or i<1 or i>j then return nil end
return math.floor(i)
end


function g.toBool(i)
return i~=nil and i~=false
end


function g.equals(i,j)return i==j end


function g.less(i,j)
local k,l=type(i),type(j)
if k==l and(k=="number"or k=="string")then return i<j end
error("attempt to compare "..g.typeName(i).." with "..g.typeName(j),0)
end


function g.listContents(i)
local j=true
for k,l in ipairs(i)do
if not(type(l)=="string"and g.length(l)==1)then j=false break end
end
local k,l={},0
for m,n in ipairs(i)do
local o=g.toString(n)
l=l+#o+1
if l>h.MAX_STRING then error("string too long",0)end
k[m]=o
end
return table.concat(k,j and""or" ")
end


g.KEYS={"space","up arrow","down arrow","right arrow","left arrow","any"}
for i=string.byte("a"),string.byte("z")do table.insert(g.KEYS,string.char(i))end
for i=0,9 do table.insert(g.KEYS,tostring(i))end


function g.coerce(i,j)
if i=="number"then return g.toNumber(j)end
if i=="string"or i=="variable"or i=="list"or i=="param"then return g.toString(j)end
if i=="boolean"then return g.toBool(j)end
return j
end

return g

end)()end,[18]=function()local b,c,d=a(18)local e return(function(...)










local g={}
g.__index=g

local h={hat=true,stack=true,cap=true,c=true,reporter=true,boolean=true}



local i={}
i.__index=i

function i:SetLabel(j)self.label=j;return self end
function i:SetShape(j)
assert(h[j],"bad shape: "..tostring(j))
self.shape=j
return self
end
function i:SetCategory(j)self.category=j;return self end
function i:SetRun(j)
assert(type(j)=="function","run must be a function")
self.run=j
return self
end
function i:SetInput(j,k)self.inputs[j]=k;return self end
function i:RemoveInput(j)self.inputs[j]=nil;return self end

function i:SetStacks(j)self.stacks=j;return self end
function i:SetHat(j)self.hat=j;return self end
function i:Set(j,k)self[j]=k;return self end


function i:ToDef()
local j={}
for k,l in pairs(self)do j[k]=l end
return j
end


function g.new(j)
j=j or{}
assert(type(j)=="table","Plugin.new expects a table")
local k=setmetatable({},g)
k._data={}
for l,m in pairs(j)do k._data[l]=m end
if k._data.Name==nil then k._data.Name="Unnamed plugin"end
if k._data.Description==nil then k._data.Description=""end
k._categories,k._categoryById={},{}
k._blocks,k._blockById={},{}
return k
end



function g:CreateCategory(j,k)
assert(type(j)=="string"and j~="","category id must be a non-empty string")
local l=self._categoryById[j]
if l then return l end
k=k or{}
l={id=j,name=k.name or j,color=k.color or{150,150,150}}
self._categoryById[j]=l
table.insert(self._categories,l)
return l
end





function g:CreateBlock(j,k)
assert(type(j)=="string"and j~="","block id must be a non-empty string")
assert(not self._blockById[j],"duplicate block id in plugin: "..j)
k=k or{}
assert(type(k)=="table","CreateBlock fields must be a table")
local l=setmetatable({},i)
for m,n in pairs(k)do l[m]=n end
l.id=j
l.shape=l.shape or"stack"
assert(h[l.shape],"bad shape for "..j..": "..tostring(l.shape))
l.category=l.category or(self._categories[#self._categories]and self._categories[#self._categories].id)
assert(l.category,"block "..j.." has no category: pass fields.category or call CreateCategory first")
l.label=l.label or j
l.inputs=l.inputs or{}
l.stacks=l.stacks or{}
self._blockById[j]=l
table.insert(self._blocks,l)
return l
end




function g:GetData()
local j={}
for k,l in pairs(self._data)do j[k]=l end
j.Categories=table.move(self._categories,1,#self._categories,1,{})
j.Blocks=table.move(self._blocks,1,#self._blocks,1,{})
return j
end

g.Block=i

return g

end)()end,[20]=function()local b,c,d=a(20)local e return(function(...)





local g={}

g.BASE="https://raw.githubusercontent.com/Horizon-Developments/scratch-luau/refs/heads/main/"


g.PATHS={
flag="assets/icons/flag.png",
loop="assets/icons/loop.png",
}

local h={}
local i={}

local function loader()
local j,k=pcall(function()return loadasset end)
if j and type(k)=="function"then return k end
return nil
end

local function fetch(j,k)
local l,m=g.PATHS[j],loader()
if not l or not m then h[j]=false;return k(nil)end
i[j]={k}
local function work()
local n,o=pcall(function()return m(g.BASE..l)end)
local p=n and type(o)=="string"and o~=""and o or nil
h[j]=p or false
local q=i[j]
i[j]=nil
for r,s in ipairs(q)do s(p)end
end
if task and task.spawn then task.spawn(work)else work()end
end


function g.get(j,k)
local l=h[j]
if l~=nil then return k(l or nil)end
if i[j]then table.insert(i[j],k)return end
fetch(j,k)
end

function g.apply(j,k)
g.get(k,function(l)
if l and j.Parent then j.Image=l end
end)
end


function g.icon(j,k,l,m)
local n=Instance.new("ImageLabel")
n.Name="Icon_"..k
n.BackgroundTransparency=1
n.BorderSizePixel=0
n.Size=UDim2.new(0,l,0,l)
n.ScaleType=Enum.ScaleType.Fit
n.LayoutOrder=m or 0
n.Image=""
n.Parent=j
g.apply(n,k)
return n
end

return g

end)()end,[21]=function()local b,c,d=a(21)local e return(function(...)






local g=d(c.Parent.Theme)
local h=d(c.Parent.Shapes)
local i=d(c.Parent.Assets)

local j={}
j.__index=j





function j.new(k,l,m)
return setmetatable({registry=k,map=l,targets=m},j)
end

function j:_target(k,l,m)
if self.targets then self.targets.inputs[k]={block=l,name=m}end
end


function j:_field(k,l,m)
if self.targets and self.targets.fields then self.targets.fields[k]={block=l,name=m}end
end

local function corner(k,l)
local m=Instance.new("UICorner")
m.CornerRadius=l
m.Parent=k
return m
end

local function padding(k,l,m,n,o)
local p=Instance.new("UIPadding")
p.PaddingLeft,p.PaddingRight=UDim.new(0,l),UDim.new(0,m)
p.PaddingTop,p.PaddingBottom=UDim.new(0,n),UDim.new(0,o)
p.Parent=k
end

local function listLayout(k,l,m,n)
local o=Instance.new("UIListLayout")
o.FillDirection=l
o.Padding=UDim.new(0,m)
o.SortOrder=Enum.SortOrder.LayoutOrder
o.VerticalAlignment=n or Enum.VerticalAlignment.Top
o.Parent=k
return o
end

local function frame(k,l,m)
local n=Instance.new("Frame")
n.Name=l
n.BackgroundColor3=m
n.BorderSizePixel=0
n.AutomaticSize=Enum.AutomaticSize.XY
n.Size=UDim2.new(0,0,0,0)
n.Parent=k
return n
end

local function label(k,l,m,n)
local o=Instance.new("TextLabel")
o.Name="Text"
o.BackgroundTransparency=1
o.AutomaticSize=Enum.AutomaticSize.XY
o.Size=UDim2.new(0,0,0,24)
o.Font=g.blockFont
o.TextSize=g.textSize
o.TextColor3=m
o.Text=l
o.LayoutOrder=n
o.Parent=k
return o
end




local function field(k,l,m,n)
local o=n and g.dropdown(n)or g.field
local p=frame(k,"Field",o)
p.LayoutOrder=m
p.Size=UDim2.new(0,0,0,24)
p.AutomaticSize=Enum.AutomaticSize.X
corner(p,UDim.new(0.5,0))
local q=Instance.new("TextLabel")
q.BackgroundTransparency=1
q.AutomaticSize=Enum.AutomaticSize.X
q.Size=UDim2.new(0,0,1,0)
q.Font=g.blockFont
q.TextSize=g.textSize
q.TextColor3=n and g.textOn(o)or g.fieldText
q.Text=tostring(l==nil and""or l)
q.Parent=p
padding(q,10,10,0,0)
local r=Instance.new("UISizeConstraint")
r.MinSize=Vector2.new(28,24)
r.Parent=p
return p
end


local function emptySlot(k,l,m)
local n=Instance.new("Frame")
n.Name="EmptySlot"
n.BackgroundTransparency=1
n.BorderSizePixel=0
n.LayoutOrder=l
n.Size=UDim2.new(0,40,0,24)
n.Parent=k
h.hexagon(n,g.recess(m),nil,1)
return n
end

function j:_row(k,l,m,n,o)
local p=Instance.new("Frame")
p.Name="Row"
p.BackgroundTransparency=1
p.AutomaticSize=Enum.AutomaticSize.XY
p.Size=UDim2.new(0,0,0,g.rowHeight)
p.Parent=n
listLayout(p,Enum.FillDirection.Horizontal,g.gap,Enum.VerticalAlignment.Center)


local q=o=="boolean"and g.pad+14 or g.pad
padding(p,q,q,4,4)
local r=g.textOn(m)

for s,t in ipairs(l.segments)do
if t.icon then
i.icon(p,t.icon,g.iconSize,s)
elseif t.text then

local u=t.text:gsub("^%s+",""):gsub("%s+$","")
if u~=""then label(p,u,r,s)end
else
local u=l.inputs[t.input]
local v=k.inputs[t.input]
if type(v)=="table"and v.op then
local w=self:build(v,p)
w.LayoutOrder=s
self:_target(w,k,t.input)
elseif u.type=="boolean"and v==nil then
self:_target(emptySlot(p,s,m),k,t.input)
else
local w=u.options~=nil or u.type=="variable"or u.type=="list"or u.type=="param"
local x=field(p,v,s,w and m or nil)
self:_target(x,k,t.input)
self:_field(x,k,t.input)
end
end
end
return p
end

function j:build(k,l)
local m=assert(self.registry:get(k.op),"unknown block: "..tostring(k.op))
local n=g.categoryColor(self.registry.categories[m.category])
local o=self.registry:shapeOf(k)

local p=frame(l,"Block_"..k.op,n)

local q=h.surface(p,o,n,g.edge(n),{bowler=m.bowler})
listLayout(q,Enum.FillDirection.Vertical,0)
if self.map then self.map[p]=k end

local r=self:_row(k,m,n,q,o)
r.LayoutOrder=1

if#m.stacks>0 then
for s,t in ipairs(m.stacks)do
if s>1 then

local u=Instance.new("Frame")
u.Name="Divider_"..t
u.BackgroundTransparency=1
u.AutomaticSize=Enum.AutomaticSize.XY
u.Size=UDim2.new(0,0,0,g.rowHeight)
u.LayoutOrder=s*2
u.Parent=q
padding(u,g.pad,g.pad,0,0)
local v=label(u,string.lower(t),g.textOn(n),1)
v.Position=UDim2.new(0,0,0.5,-12)
end
local u=Instance.new("Frame")
u.Name="Slot_"..t
u.BackgroundTransparency=1
u.AutomaticSize=Enum.AutomaticSize.XY
u.Size=UDim2.new(0,0,0,g.cSlotMinHeight)
u.LayoutOrder=s*2+1
u.Parent=q
if self.targets then self.targets.slots[u]={block=k,name=t}end
padding(u,g.cSlotIndent,0,0,0)
local v=self:buildStack(k.stacks[t]or{},u)
v.LayoutOrder=1
local w=Instance.new("UISizeConstraint")
w.MinSize=Vector2.new(60,g.cSlotMinHeight)
w.Parent=v
end
local s=Instance.new("Frame")
s.Name="Footer"
s.BackgroundTransparency=1
s.Size=UDim2.new(0,0,0,m.footerIcon and g.cFooterIcon or g.cFooter)
s.LayoutOrder=1000
s.Parent=q
if m.footerIcon then

local t=i.icon(s,m.footerIcon,g.iconSize)
t.Position=UDim2.new(0,g.pad,0.5,-g.iconSize/2)
end
end

return p
end


function j:buildStack(k,l)
local m=Instance.new("Frame")
m.Name="Stack"
m.BackgroundTransparency=1
m.AutomaticSize=Enum.AutomaticSize.XY
m.Size=UDim2.new(0,0,0,0)
m.Parent=l
listLayout(m,Enum.FillDirection.Vertical,0)
for n,o in ipairs(k)do
local p=self:build(o,m)
p.LayoutOrder=n

p.ZIndex=#k-n+1
end
return m
end

return j

end)()end,[22]=function()local b,c,d=a(22)local e return(function(...)





local g=d(c.Parent.Theme)

local h={}
h.__index=h

local i=500
local j=48
local k=44

local function corner(l)
local m=Instance.new("UICorner")
m.CornerRadius=g.radius
m.Parent=l
end

local l={
say=g.text,
error=g.error,
ask=g.textDim,
input=g.textDim,
}

function h.new(m)
local n=setmetatable({nodes={},count=0,pending=nil},h)

local o=Instance.new("Frame")
o.Name="Console"
o.BackgroundColor3=g.panel
o.BorderSizePixel=0
o.Position=UDim2.new(0,g.paletteWidth,1,-g.consoleHeight)
o.Size=UDim2.new(1,-g.paletteWidth,0,g.consoleHeight)
o.Parent=m
n.root=o

local p=Instance.new("TextLabel")
p.Name="Title"
p.BackgroundTransparency=1
p.Position=UDim2.fromOffset(12,0)
p.Size=UDim2.new(0.5,0,0,j)
p.Font=g.font
p.TextSize=g.textSize
p.TextColor3=g.textDim
p.TextXAlignment=Enum.TextXAlignment.Left
p.Text="Output"
p.Parent=o

local q=Instance.new("TextButton")
q.Name="ClearOutput"
q.AutoButtonColor=false
q.BackgroundColor3=g.ground
q.BorderSizePixel=0
q.AnchorPoint=Vector2.new(1,0.5)
q.Position=UDim2.new(1,-8,0,j/2)
q.Size=UDim2.fromOffset(120,44)
q.Font=g.font
q.TextSize=g.textSize
q.TextColor3=g.text
q.Text="Clear output"
q.Parent=o
corner(q)
q.Activated:Connect(function()n:clear()end)

local r=Instance.new("ScrollingFrame")
r.Name="Lines"
r.BackgroundColor3=g.ground
r.BorderSizePixel=0
r.Position=UDim2.fromOffset(8,j)
r.Size=UDim2.new(1,-16,1,-j-8)
r.CanvasSize=UDim2.new(0,0,0,0)
r.AutomaticCanvasSize=Enum.AutomaticSize.Y
r.ScrollingDirection=Enum.ScrollingDirection.Y
r.ScrollBarThickness=6
r.ScrollBarImageColor3=g.textDim
r.Parent=o
corner(r)
local s=Instance.new("UIListLayout")
s.SortOrder=Enum.SortOrder.LayoutOrder
s.Parent=r
local t=Instance.new("UIPadding")
t.PaddingLeft,t.PaddingRight=UDim.new(0,8),UDim.new(0,8)
t.PaddingTop,t.PaddingBottom=UDim.new(0,6),UDim.new(0,6)
t.Parent=r
n.scroll=r


local u=Instance.new("TextBox")
u.Name="Answer"
u.Visible=false
u.BackgroundColor3=g.field
u.BorderSizePixel=0
u.ClearTextOnFocus=false
u.Font=g.monoFont
u.TextSize=g.textSize
u.TextColor3=g.fieldText
u.PlaceholderText="Type an answer, then Enter"
u.PlaceholderColor3=g.textDim
u.Text=""
u.TextXAlignment=Enum.TextXAlignment.Left
u.AnchorPoint=Vector2.new(0,1)
u.Position=UDim2.new(0,8,1,-8)
u.Size=UDim2.new(1,-16,0,k)
u.Parent=o
corner(u)
local v=Instance.new("UIPadding")
v.PaddingLeft,v.PaddingRight=UDim.new(0,8),UDim.new(0,8)
v.Parent=u

local w=Instance.new("UIStroke")
w.Color=g.accent
w.Thickness=2
w.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
w.Parent=u
n.box=u
u.FocusLost:Connect(function(x)
if x then n:_submit(u.Text)end
end)

return n
end

function h:_scrollToEnd()
task.defer(function()
self.scroll.CanvasPosition=Vector2.new(0,1e6)
end)
end

function h:add(m,n)
n=n or"say"
self.count+=1
local o=Instance.new("TextLabel")
o.Name="Line"
o.BackgroundTransparency=1
o.AutomaticSize=Enum.AutomaticSize.Y
o.Size=UDim2.new(1,0,0,0)
o.LayoutOrder=self.count
o.Font=g.monoFont
o.TextSize=g.textSize
o.TextColor3=l[n]or g.text
o.TextWrapped=true
o.TextXAlignment=Enum.TextXAlignment.Left
o.TextYAlignment=Enum.TextYAlignment.Top
o.Text=tostring(m)
o.Parent=self.scroll
table.insert(self.nodes,o)
if#self.nodes>i then
table.remove(self.nodes,1):Destroy()
end
self:_scrollToEnd()
end

function h:clear()
for m,n in ipairs(self.nodes)do n:Destroy()end
self.nodes={}
end

function h:_showInput(m)
self.box.Visible=m
self.scroll.Size=m and UDim2.new(1,-16,1,-j-k-16)or UDim2.new(1,-16,1,-j-8)
if m then
self.box.Text=""
self.box:CaptureFocus()
else
self.box:ReleaseFocus()
end
end

function h:_submit(m)
local n=self.pending
if not n then return end
self.pending=nil
self:_showInput(false)
self:add("> "..m,"input")
task.spawn(n,m)
end


function h:ask(m)
self:cancel()
self:add(m,"ask")
self.pending=coroutine.running()
self:_showInput(true)
return coroutine.yield()
end

function h:cancel()
local m=self.pending
if not m then return end
self.pending=nil
self:_showInput(false)
task.spawn(m,"")
end

return h

end)()end,[23]=function()local b,c,d=a(23)local e return(function(...)local g=game:GetService("UserInputService")

local h={}


function h.track(i,j,k)
local l=i.UserInputType==Enum.UserInputType.Touch
local m,n
m=g.InputChanged:Connect(function(o)
if o==i or(not l and o.UserInputType==Enum.UserInputType.MouseMovement)then
j(Vector2.new(o.Position.X,o.Position.Y))
end
end)
n=g.InputEnded:Connect(function(o)
if o==i or(not l and o.UserInputType==i.UserInputType)then
m:Disconnect()
n:Disconnect()
if k then k(Vector2.new(o.Position.X,o.Position.Y))end
end
end)
end

return h

end)()end,[24]=function()local b,c,d=a(24)local e return(function(...)





local g=d(c.Parent.Theme)

local h={}
h.__index=h

local i=40
local j=168
local k=280

function h.new(l,m,n)
return setmetatable({parent=l,registry=m,program=n},h)
end

local function corner(l)
local m=Instance.new("UICorner")
m.CornerRadius=g.radius
m.Parent=l
end


function h:_rel(l)
return(l-self.parent.AbsolutePosition)/g.scale
end

function h:close()
if self.layer then
self.layer:Destroy()
self.layer=nil
end
end


function h:_backdrop()
self:close()
local l=Instance.new("TextButton")
l.Name="EditorBackdrop"
l.BackgroundTransparency=1
l.Text=""
l.AutoButtonColor=false
l.Size=UDim2.fromScale(1,1)
l.ZIndex=250
l.Parent=self.parent
l.Activated:Connect(function()self:close()end)
self.layer=l
return l
end

function h:_commit(l,m,n,o)
local p=o
if n.type=="number"or n.type=="any"then
local q=tonumber(o)
if q~=nil then
p=q
end
end
self:close()
self.program:setInput(l,m,p)
end

function h:_text(l,m,n,o,p)
local q=self:_backdrop()
local r,s=self:_rel(l.AbsolutePosition),l.AbsoluteSize/g.scale
local t=Instance.new("TextBox")
t.Name="FieldBox"
t.BackgroundColor3=g.field
t.BorderSizePixel=0
t.ClearTextOnFocus=false
t.Font=g.font
t.TextSize=g.textSize
t.TextColor3=g.fieldText
t.TextXAlignment=Enum.TextXAlignment.Left
t.Text=tostring(p==nil and""or p)
t.Position=UDim2.fromOffset(r.X,r.Y)
t.Size=UDim2.fromOffset(math.max(s.X,72),math.max(s.Y,24))
t.ZIndex=300
t.Parent=q
corner(t)
local u=Instance.new("UIPadding")
u.PaddingLeft,u.PaddingRight=UDim.new(0,6),UDim.new(0,6)
u.Parent=t

local v=Instance.new("UIStroke")
v.Color=g.accent
v.Thickness=2
v.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
v.Parent=t
local w=false
t.FocusLost:Connect(function()
if w then return end
w=true
self:_commit(m,n,o,t.Text)
end)
t:CaptureFocus()
end


function h:_names(l,m)
local n,o={},{}
local function add(p)
if type(p)=="string"and p~=""and not n[p]then
n[p]=true
table.insert(o,p)
end
end
local function walk(p)
for q,r in ipairs(p)do
local s=self.registry:get(r.op)
if s then
for t,u in pairs(s.inputs)do
local v=r.inputs[t]
if u.type==l then add(v)end
if type(v)=="table"and v.op then walk({v})end
end
end
for t,u in pairs(r.stacks)do walk(u)end
end
end
for p,q in ipairs(self.program:get().scripts)do walk(q.blocks)end
add(m)
table.sort(o,function(p,q)return string.lower(p)<string.lower(q)end)
return o
end


function h:_paramNames(l)
local m={}
local n,o=self.program:scriptOf(l)
local p=o and o.blocks[1]
if p and p.op=="custom_define"and type(p.inputs.NAME)=="string"then
for q,r in ipairs(self.registry.custom.parse(p.inputs.NAME).params)do table.insert(m,r.name)end
end
return m
end

function h:_menu(l,m,n,o,p,q,r)
local s=self:_backdrop()
local t=#p+(r and 1 or 0)
local u=math.min(t*i,k)
local v,w=self:_rel(l.AbsolutePosition),l.AbsoluteSize/g.scale
local x=self.parent.AbsoluteSize/g.scale
local y=math.clamp(v.X,4,math.max(4,x.X-j-4))
local z=v.Y+w.Y+2
if z+u>x.Y-4 then z=math.max(4,v.Y-u-2)end

local A=Instance.new("ScrollingFrame")
A.Name="FieldMenu"
A.BackgroundColor3=g.panel
A.BorderSizePixel=0
A.Position=UDim2.fromOffset(y,z)
A.Size=UDim2.fromOffset(j,u)
A.CanvasSize=UDim2.new(0,0,0,0)
A.AutomaticCanvasSize=Enum.AutomaticSize.Y
A.ScrollBarThickness=4
A.ScrollBarImageColor3=g.textDim
A.ZIndex=300
A.Parent=s
corner(A)

local C=Instance.new("UIStroke")
C.Color=g.textDim
C.Thickness=1
C.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
C.Parent=A
local D=Instance.new("UIListLayout")
D.SortOrder=Enum.SortOrder.LayoutOrder
D.Parent=A

local function item(E,F,G,H)
local I=Instance.new("TextButton")
I.Name="Item"
I.AutoButtonColor=false
I.BackgroundColor3=G and g.accent or g.panel
I.BackgroundTransparency=G and 0 or 1
I.BorderSizePixel=0
I.Size=UDim2.new(1,0,0,i)
I.LayoutOrder=F
I.Font=g.font
I.TextSize=g.textSize
I.TextColor3=g.text
I.TextXAlignment=Enum.TextXAlignment.Left
I.Text=E
I.ZIndex=301
I.Parent=A
local J=Instance.new("UIPadding")
J.PaddingLeft=UDim.new(0,12)
J.Parent=I
I.Activated:Connect(H)
end

for E,F in ipairs(p)do
item(tostring(F),E,tostring(F)==tostring(q),function()
self:close()
self.program:setInput(m,n,F)
end)
end
if r then
item("New name",#p+1,false,function()
self:_text(l,m,n,o,"")
end)
end
end


function h:open(l,m)
local n=self.registry:get(m.block.op)
local o=n and n.inputs[m.name]
if not o then return end
local p=m.block.inputs[m.name]
if o.options then
self:_menu(l,m.block,m.name,o,o.options,p,false)
elseif o.type=="param"and#self:_paramNames(m.block)>0 then
self:_menu(l,m.block,m.name,o,self:_paramNames(m.block),p,false)
elseif o.type=="variable"or o.type=="list"then
self:_menu(l,m.block,m.name,o,self:_names(o.type,p),p,true)
else
self:_text(l,m.block,m.name,o,p)
end
end

return h

end)()end,[25]=function()local b,c,d=a(25)local e return(function(...)

local g=d(c.Parent.Theme)
local h=d(c.Parent.BlockView)
local i=d(c.Parent.Drag)

local j={}
j.__index=j

local function corner(k)
local l=Instance.new("UICorner")
l.CornerRadius=g.radius
l.Parent=k
end

function j.new(k,l,m,n,o)
local p=setmetatable({registry=l,onSpawn=m,onHover=n,onHoverEnd=o,tabs={},selected=nil},j)

local q=Instance.new("Frame")
q.Name="Palette"
q.BackgroundColor3=g.panel
q.BorderSizePixel=0
q.Size=UDim2.new(0,g.paletteWidth,1,0)
q.Parent=k
p.root,p.parent=q,k

local r=Instance.new("ScrollingFrame")
r.Name="Tabs"
r.BackgroundTransparency=1
r.BorderSizePixel=0
r.Size=UDim2.new(0,g.tabWidth,1,0)
r.CanvasSize=UDim2.new(0,0,0,0)
r.AutomaticCanvasSize=Enum.AutomaticSize.Y
r.ScrollBarThickness=0
r.Parent=q
p.tabCol=r
local s=Instance.new("UIListLayout")
s.Padding=UDim.new(0,4)
s.SortOrder=Enum.SortOrder.LayoutOrder
s.Parent=r
local t=Instance.new("UIPadding")
t.PaddingTop,t.PaddingLeft,t.PaddingRight=UDim.new(0,8),UDim.new(0,8),UDim.new(0,4)
t.Parent=r

local u=Instance.new("ScrollingFrame")
u.Name="Blocks"
u.BackgroundTransparency=1
u.BorderSizePixel=0
u.Position=UDim2.new(0,g.tabWidth,0,0)
u.Size=UDim2.new(1,-g.tabWidth,1,0)
u.CanvasSize=UDim2.new(0,0,0,0)
u.AutomaticCanvasSize=Enum.AutomaticSize.XY
u.ScrollingDirection=Enum.ScrollingDirection.XY
u.ScrollBarThickness=6
u.ScrollBarImageColor3=g.textDim
u.Parent=q
local v=Instance.new("UIListLayout")
v.Padding=UDim.new(0,4)
v.SortOrder=Enum.SortOrder.LayoutOrder
v.Parent=u
local w=Instance.new("UIPadding")
w.PaddingTop,w.PaddingLeft,w.PaddingRight,w.PaddingBottom=UDim.new(0,8),UDim.new(0,8),UDim.new(0,8),UDim.new(0,8)
w.Parent=u
p.list=u

for x,y in ipairs(l.categoryOrder)do
p:_addTab(r,y,x)
end
if l.categoryOrder[1]then p:select(l.categoryOrder[1])end
return p
end

function j:_addTab(k,l,m)
local n=self.registry.categories[l]
local o=Instance.new("TextButton")
o.Name="Tab_"..l
o.AutoButtonColor=false
o.BackgroundColor3=g.panel
o.BorderSizePixel=0
o.Size=UDim2.new(1,0,0,g.tabHeight)
o.LayoutOrder=m
o.Font=g.font
o.TextSize=g.textSize
o.TextColor3=g.text
o.TextXAlignment=Enum.TextXAlignment.Left
o.Text=n.name
o.Parent=k
corner(o)
local p=Instance.new("UIPadding")
p.PaddingLeft=UDim.new(0,14)
p.Parent=o

local q=Instance.new("Frame")
q.Name="CategoryKey"
q.BackgroundColor3=g.categoryColor(n)
q.BorderSizePixel=0
q.Size=UDim2.new(0,4,1,-12)
q.Position=UDim2.new(0,-8,0,6)
q.Parent=o
o.Activated:Connect(function()self:select(l)end)
self.tabs[l]=o
end

function j:select(k)
self.selected=k
for l,m in pairs(self.tabs)do
m.BackgroundColor3=(l==k)and g.accent or g.panel
end
for l,m in ipairs(self.list:GetChildren())do
if m:IsA("GuiObject")then m:Destroy()end
end
self.list.CanvasPosition=Vector2.new(0,0)

local l=h.new(self.registry)
for m,n in ipairs(self.registry:listByCategory(k))do

local o=Instance.new("Frame")
o.Name="Item_"..n.id
o.BackgroundTransparency=1
o.AutomaticSize=Enum.AutomaticSize.XY
o.Size=UDim2.new(0,0,0,0)
o.LayoutOrder=m
o.Parent=self.list
local p=Instance.new("UIPadding")
p.PaddingTop,p.PaddingBottom=UDim.new(0,4),UDim.new(0,4)
p.Parent=o
local q=l:build(self.registry:createBlock(n.id),o)


local r=Instance.new("TextButton")
r.Name="Hit"
r.BackgroundTransparency=1
r.Text=""
r.ZIndex=10
r.Parent=o
local function fit()r.Size=UDim2.fromOffset(q.AbsoluteSize.X/g.scale,q.AbsoluteSize.Y/g.scale)end
q:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
r.InputBegan:Connect(function(s)
local t=s.UserInputType
if t==Enum.UserInputType.MouseButton1 or t==Enum.UserInputType.Touch then
self:_drag(s,n.id,q)
end
end)
end
end


function j:refresh()

for k,l in ipairs(self.registry.categoryOrder)do
if not self.tabs[l]then self:_addTab(self.tabCol,l,k)end
end
if self.selected then self:select(self.selected)
elseif self.registry.categoryOrder[1]then self:select(self.registry.categoryOrder[1])end
end

function j:_ghost(k)
local l=Instance.new("Frame")
l.Name="DragGhost"
l.BackgroundTransparency=1
l.AutomaticSize=Enum.AutomaticSize.XY
l.Size=UDim2.new(0,0,0,0)
l.ZIndex=100
l.Parent=self.parent
local m=h.new(self.registry):build(self.registry:createBlock(k),l)

local n=Instance.new("Frame")
n.BackgroundColor3=Color3.new(0,0,0)
n.BackgroundTransparency=0.6
n.BorderSizePixel=0
n.Position=UDim2.fromOffset(3,4)
n.ZIndex=0
n.Parent=l
corner(n)
local function fit()n.Size=UDim2.fromOffset(m.AbsoluteSize.X/g.scale,m.AbsoluteSize.Y/g.scale)end
m:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
return l,m
end


function j:_drag(k,l,m)
local n=Vector2.new(k.Position.X,k.Position.Y)
local o=n-m.AbsolutePosition
local p=k.UserInputType==Enum.UserInputType.Touch
local q,r,s
i.track(k,function(t)
if not q then
local u=t-n
if s or u.Magnitude<8 then return end
if p and math.abs(u.Y)>math.abs(u.X)then
s=true
return
end
self.list.ScrollingEnabled=false
q,r=self:_ghost(l)
end
q.Position=UDim2.fromOffset((t.X-o.X-self.parent.AbsolutePosition.X)/g.scale,(t.Y-o.Y-self.parent.AbsolutePosition.Y)/g.scale)
if self.onHover then
if t.X>self.root.AbsolutePosition.X+self.root.AbsoluteSize.X then self.onHover(l,r)
elseif self.onHoverEnd then self.onHoverEnd()end
end
end,function(t)
self.list.ScrollingEnabled=true
local u=r and r.AbsoluteSize
if q then q:Destroy()end
if self.onHoverEnd then self.onHoverEnd()end
if s then return end
if not q or t.X>self.root.AbsolutePosition.X+self.root.AbsoluteSize.X then
self.onSpawn(l,q and t-o,u)
end
end)
end

return j

end)()end,[26]=function()local b,c,d=a(26)local e return(function(...)


local g={}
g.__index=g

function g.new(h)
return setmetatable({data=h or{scripts={}},listeners={}},g)
end

function g:get()return self.data end

function g:onChanged(h)
table.insert(self.listeners,h)
end

function g:changed()
for h,i in ipairs(self.listeners)do i(self.data)end
end

function g:addScript(h,i,j,k)
table.insert(self.data.scripts,{x=i,y=j,blocks={h}})
if not k then self:changed()end
return#self.data.scripts
end

function g:count()return#self.data.scripts end


function g:replace(h)
self.data=h
self:changed()
end

function g:clear()
self.data={scripts={}}
self:changed()
end

local function locate(h,i)
for j,k in ipairs(h)do
if k==i then return h,j end
for l,m in pairs(k.stacks)do
local n,o=locate(m,i)
if n then return n,o end
end
end
end

function g:find(h)
for i,j in ipairs(self.data.scripts)do
local k,l=locate(j.blocks,h)
if k then return k,l,i end
end
end


function g:detach(h,i,j)
local k,l,m=self:find(h)
if l==1 and k==self.data.scripts[m].blocks then return m end
local n=table.move(k,l,#k,1,{})
for o=#k,l,-1 do k[o]=nil end
table.insert(self.data.scripts,{x=i,y=j,blocks=n})
self:changed()
return#self.data.scripts
end


local function locateInput(h,i)
for j,k in ipairs(h)do
for l,m in pairs(k.inputs)do
if m==i then return k,l end
if type(m)=="table"and m.op then
local n,o=locateInput({m},i)
if n then return n,o end
end
end
for l,m in pairs(k.stacks)do
local n,o=locateInput(m,i)
if n then return n,o end
end
end
end

function g:findInput(h)
for i,j in ipairs(self.data.scripts)do
local k,l=locateInput(j.blocks,h)
if k then return k,l end
end
end


function g:detachInput(h,i,j,k)
local l,m=self:findInput(h)
if not l then return nil end
l.inputs[m]=k
table.insert(self.data.scripts,{x=i,y=j,blocks={h}})
self:changed()
return#self.data.scripts
end









function g:attach(h,i)
local j=self.data.scripts[h]
if not j or not i or not i.block or locate(j.blocks,i.block)then return false end
local k=i.wrap
if k~=nil then
local l=j.blocks[1]
local m=type(l)=="table"and type(l.stacks)=="table"and l.stacks[k]
if type(m)~="table"or#m>0 then
if i.kind=="wrap"then return false end
k=nil
end
elseif i.kind=="wrap"then
return false
end


local l,m,n
if i.kind=="after"then
l,m=self:find(i.block)
if not l then return false end
elseif i.kind=="before"or i.kind=="wrap"then
local o,p,q=self:find(i.block)
if not o or p~=1 or o~=self.data.scripts[q].blocks then return false end
n=self.data.scripts[q]
elseif i.kind=="slot"then
if not self:scriptOf(i.block)then return false end
elseif i.kind=="input"then
if not self:scriptOf(i.block)or#j.blocks~=1 then return false end
else
return false
end
if n==j then return false end
table.remove(self.data.scripts,h)
local o=j.blocks
if i.kind=="after"then
if k then
local p=table.move(l,m+1,#l,1,{})
for q=#l,m+1,-1 do l[q]=nil end
if#p>0 then o[1].stacks[k]=p end
end
for p,q in ipairs(o)do table.insert(l,m+p,q)end
elseif i.kind=="before"then
for p=#o,1,-1 do table.insert(n.blocks,1,o[p])end
n.x,n.y=j.x,j.y
elseif i.kind=="wrap"then
o[1].stacks[k]=n.blocks
n.blocks=o
n.x,n.y=j.x,j.y
elseif i.kind=="slot"then
local p=i.block.stacks[i.name]
if not p then p={};i.block.stacks[i.name]=p end
if k and#p>0 then
o[1].stacks[k]=p
i.block.stacks[i.name]=o
else
for q=#o,1,-1 do table.insert(p,1,o[q])end
end
elseif i.kind=="input"then
local p=i.block.inputs[i.name]
i.block.inputs[i.name]=o[1]
if type(p)=="table"and p.op then

table.insert(self.data.scripts,{x=j.x+40,y=j.y+40,blocks={p}})
end
end
self:changed()
return true
end



local function contains(h,i)
for j,k in ipairs(h)do
if k==i then return true end
for l,m in pairs(k.inputs)do
if type(m)=="table"and m.op and contains({m},i)then return true end
end
for l,m in pairs(k.stacks)do
if contains(m,i)then return true end
end
end
return false
end

function g:scriptOf(h)
for i,j in ipairs(self.data.scripts)do
if contains(j.blocks,h)then return i,j end
end
end




function g:setInput(h,i,j)
local k=h.inputs[i]
h.inputs[i]=j
if self.onSet then self.onSet(h,i,k,j)end
self:changed()
end

function g:moveScript(h,i,j)
local k=self.data.scripts[h]
k.x,k.y=i,j
self:changed()
end

function g:removeScript(h)
table.remove(self.data.scripts,h)
self:changed()
end

return g

end)()end,[27]=function()local b,c,d=a(27)local e return(function(...)







local g=d(c.Parent.Theme)

local h={}

local function frame(i,j,k,l,m)
local n=Instance.new("Frame")
n.Name=j
n.BackgroundColor3=k
n.BorderSizePixel=0
n.Size=l
if m then n.Position=m end
n.Parent=i
return n
end

local function corner(i,j)
local k=Instance.new("UICorner")
k.CornerRadius=j
k.Parent=i
return k
end



local function holder(i,j,k)
local l=Instance.new("Frame")
l.Name=j
l.BackgroundTransparency=1
l.BorderSizePixel=0
l.Size=UDim2.new(0,0,0,0)
l.LayoutOrder=k
l.Parent=i
return l
end




function h.hexagon(i,j,k,l)
local m=Instance.new("Frame")
m.Name="Hex"
m.BackgroundTransparency=1
m.BorderSizePixel=0
m.Size=UDim2.new(1,0,1,0)
m.ZIndex=l or 1
m.Parent=i

local function layer(n,o)
local p=Instance.new("Frame")
p.Name=n
p.BackgroundTransparency=1
p.BorderSizePixel=0
p.Parent=m
local q=frame(p,"Mid",o,UDim2.new(0,0,0,0))
local r=frame(p,"Left",o,UDim2.new(0,0,0,0))
local s=frame(p,"Right",o,UDim2.new(0,0,0,0))
for t,u in ipairs({r,s})do
u.AnchorPoint=Vector2.new(0.5,0.5)
u.Rotation=45
end
return{root=p,mid=q,left=r,right=s}
end
local n=k and layer("Edge",k)
local o=layer("Fill",j)

local function place(p,q,r,s,t)
p.root.Position=UDim2.fromOffset(q,r)
p.root.Size=UDim2.fromOffset(s,t)
local u=t/2
local v=t/math.sqrt(2)
p.mid.Position=UDim2.fromOffset(u,0)
p.mid.Size=UDim2.fromOffset(math.max(0,s-t),t)
p.left.Size=UDim2.fromOffset(v,v)
p.left.Position=UDim2.fromOffset(u,u)
p.right.Size=UDim2.fromOffset(v,v)
p.right.Position=UDim2.fromOffset(s-u,u)
end

local function update()
local p=g.scale>0 and g.scale or 1
local q,r=m.AbsoluteSize.X/p,m.AbsoluteSize.Y/p
if r<=0 then return end
local s=k and(m:GetAttribute("Inset")or 1)or 0
if n then place(n,0,0,q,r)end
place(o,s,s,math.max(0,q-2*s),math.max(0,r-2*s))
end
m:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
m:GetAttributeChangedSignal("Inset"):Connect(update)
update()
return m
end




function h.surface(i,j,k,l,m)
m=m or{}
if j=="boolean"then
i.BackgroundTransparency=1
h.hexagon(i,k,l,1)
local n=Instance.new("Frame")
n.Name="Content"
n.BackgroundTransparency=1
n.BorderSizePixel=0
n.AutomaticSize=Enum.AutomaticSize.XY
n.Size=UDim2.new(0,0,0,0)
n.ZIndex=2
n.Parent=i
return n
end

i.BackgroundColor3=k
if j=="reporter"then
corner(i,UDim.new(0.5,0))
elseif m.bowler then
corner(i,g.bowlerRadius)
else
corner(i,g.blockRadius)
end
local n=Instance.new("UIStroke")
n.Name="Edge"
n.Color=l
n.Thickness=1
n.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
n.Parent=i
if j=="reporter"then return i end

local o=j~="hat"
local p=j~="cap"
local q,r,s=g.notchX,g.notchW,g.notchH

if j=="hat"and not m.bowler then


local t=g.hatHeight
local u=holder(i,"Top",0)
local v=Instance.new("Frame")
v.Name="Dome"
v.BackgroundTransparency=1
v.BorderSizePixel=0
v.ClipsDescendants=true
v.Position=UDim2.new(0,-1,0,-(t+1))
v.Size=UDim2.new(0,g.hatWidth+2,0,t+1+4)
v.Parent=u
corner(frame(v,"Edge",l,UDim2.new(1,0,0,2*(t+1)),UDim2.new(0,0,0,0)),UDim.new(0.5,0))
corner(frame(v,"Fill",k,UDim2.new(1,-2,0,2*t),UDim2.new(0,1,0,1)),UDim.new(0.5,0))
elseif o then

local t=holder(i,"Top",0)
corner(frame(t,"Notch",l,UDim2.new(0,r,0,s),UDim2.new(0,q,0,0)),UDim.new(0,3))
end

if p then


local t=holder(i,"Bottom",10000)
local u=frame(t,"TabEdge",l,UDim2.new(0,r+2,0,s+2),UDim2.new(0,q-1,0,-1))
corner(u,UDim.new(0,4))
u.ZIndex=1
local v=frame(t,"Tab",k,UDim2.new(0,r,0,s+2),UDim2.new(0,q,0,-2))
corner(v,UDim.new(0,3))
v.ZIndex=2
end
return i
end


function h.markError(i,j,k)
local l=i:FindFirstChildOfClass("UIStroke")
if l then
l.Color=j
l.Thickness=k
return
end
local m=i:FindFirstChild("Hex")
if m then
local n=m:FindFirstChild("Edge")
if n then
for o,p in ipairs(n:GetChildren())do p.BackgroundColor3=j end
end
m:SetAttribute("Inset",k)
end
end

return h

end)()end,[28]=function()local b,c,d=a(28)local e return(function(...)

local g={
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

function g.categoryColor(h)
local i=h and h.color or{150,150,150}
return Color3.fromRGB(i[1],i[2],i[3])
end



function g.edge(h)
return Color3.new(h.R*0.78,h.G*0.78,h.B*0.78)
end


function g.dropdown(h)
return Color3.new(h.R*0.5,h.G*0.5,h.B*0.5)
end


local function luminance(h)
local function f(i)return i<=0.03928 and i/12.92 or((i+0.055)/1.055)^2.4 end
return 0.2126*f(h.R)+0.7152*f(h.G)+0.0722*f(h.B)
end
g.luminance=luminance



function g.textOn(h)
if g.whiteBlockText then return Color3.new(1,1,1)end
local i=luminance(h)
local j=1.05/(i+0.05)
local k=(i+0.05)/(luminance(g.fieldText)+0.05)
return j>k and Color3.new(1,1,1)or g.fieldText
end


function g.recess(h)
return Color3.new(h.R*0.6,h.G*0.6,h.B*0.6)
end

return g

end)()end,[29]=function()local b,c,d=a(29)local e return(function(...)


local g=d(c.Parent.Theme)

local h={}
h.__index=h

local i=3

local function button(j,k,l,m,n,o,p)
local q=Instance.new("TextButton")
q.Name=k
q.AutoButtonColor=false
q.BackgroundColor3=n
q.BorderSizePixel=0
q.Size=UDim2.fromOffset(m,44)
q.LayoutOrder=p
q.Font=g.font
q.TextSize=g.textSize
q.TextColor3=o
q.Text=l
q.Parent=j
local r=Instance.new("UICorner")
r.CornerRadius=g.radius
r.Parent=q
return q
end

function h.new(j,k)
local l=setmetatable({handlers=k,confirmToken=0},h)

local m=Instance.new("Frame")
m.Name="Toolbar"
m.BackgroundColor3=g.panel
m.BorderSizePixel=0
m.Position=UDim2.new(0,g.paletteWidth,0,0)
m.Size=UDim2.new(1,-g.paletteWidth,0,g.toolbarHeight)
m.Parent=j
l.bar=m

local n=Instance.new("UIListLayout")
n.FillDirection=Enum.FillDirection.Horizontal
n.VerticalAlignment=Enum.VerticalAlignment.Center
n.SortOrder=Enum.SortOrder.LayoutOrder
n.Padding=UDim.new(0,8)
n.Parent=m
local o=Instance.new("UIPadding")
o.PaddingLeft=UDim.new(0,8)
o.Parent=m


l.run=button(m,"Run","Run",96,g.accent,g.fieldText,1)
l.stop=button(m,"Stop","Stop",96,g.ground,g.textDim,2)
l.clear=button(m,"ClearWorkspace","Clear workspace",152,g.ground,g.text,3)

l.save=button(m,"Save","Save",88,g.ground,g.text,4)
l.load=button(m,"Load","Load",88,g.ground,g.text,5)

l.run.Activated:Connect(function()
l:_resetClear()
k.onRun()
end)
l.stop.Activated:Connect(function()
l:_resetClear()
k.onStop()
end)
l.save.Activated:Connect(function()
l:_resetClear()
k.onSave()
end)
l.load.Activated:Connect(function()
l:_resetClear()
k.onLoad()
end)

l.clear.Activated:Connect(function()
if l.confirming then
l:_resetClear()
k.onClear()
return
end
l.confirming=true
l.clear.Text="Tap again to delete all"
l.clear.TextColor3=g.error
l.confirmToken+=1
local p=l.confirmToken
task.delay(i,function()
if l.confirmToken==p then l:_resetClear()end
end)
end)
return l
end

function h:_resetClear()
self.confirmToken+=1
self.confirming=false
self.clear.Text="Clear workspace"
self.clear.TextColor3=g.text
end

function h:setRunning(j)
self.stop.TextColor3=j and g.text or g.textDim
end

return h

end)()end,[30]=function()local b,c,d=a(30)local e return(function(...)






local g=d(c.Parent.Theme)

local h={}
h.__index=h

local i,j=560,380

local function corner(k)
local l=Instance.new("UICorner")
l.CornerRadius=g.radius
l.Parent=k
end

local function label(k,l,m,n,o,p)
local q=Instance.new("TextLabel")
q.BackgroundTransparency=1
q.Position=UDim2.fromOffset(16,m)
q.Size=UDim2.new(1,-32,0,n)
q.Font=g.font
q.TextSize=g.textSize
q.TextColor3=o
q.TextXAlignment=Enum.TextXAlignment.Left
q.TextYAlignment=Enum.TextYAlignment.Top
q.TextWrapped=p or false
q.Text=l
q.Parent=k
return q
end

function h.new(k)
return setmetatable({parent=k},h)
end

function h:close()
if self.layer then
self.layer:Destroy()
self.layer=nil
end
end

function h:open(k)
self:close()

local l=Instance.new("TextButton")
l.Name="TransferLayer"
l.BackgroundTransparency=1
l.Text=""
l.AutoButtonColor=false
l.Size=UDim2.fromScale(1,1)
l.ZIndex=400
l.Parent=self.parent
self.layer=l

local m=Instance.new("Frame")
m.Name="Panel"
m.BackgroundColor3=g.panel
m.BorderSizePixel=0
m.AnchorPoint=Vector2.new(0.5,0.5)

m.Position=UDim2.new(0.5,g.paletteWidth/2,0.5,0)
m.Size=UDim2.fromOffset(i,j)
m.Parent=l
corner(m)

local n=Instance.new("UIStroke")
n.Color=g.textDim
n.Thickness=1
n.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
n.Parent=m

label(m,k.title or"",10,24,g.text)
label(m,k.hint or"",36,20,g.textDim)

local o=Instance.new("TextBox")
o.Name="Text"
o.BackgroundColor3=g.field
o.BorderSizePixel=0
o.Position=UDim2.fromOffset(16,64)
o.Size=UDim2.new(1,-32,0,212)
o.MultiLine=true
o.TextWrapped=true
o.ClearTextOnFocus=false
o.Font=g.font
o.TextSize=g.textSize
o.TextColor3=g.fieldText
o.TextXAlignment=Enum.TextXAlignment.Left
o.TextYAlignment=Enum.TextYAlignment.Top
o.Text=k.text or""
o.Parent=m
corner(o)
local p=Instance.new("UIPadding")
p.PaddingLeft,p.PaddingRight,p.PaddingTop,p.PaddingBottom=UDim.new(0,8),UDim.new(0,8),UDim.new(0,6),UDim.new(0,6)
p.Parent=o


local q=label(m,k.error or"",282,34,g.error,true)

local r=Instance.new("Frame")
r.BackgroundTransparency=1
r.Position=UDim2.new(0,16,1,-56)
r.Size=UDim2.new(1,-32,0,44)
r.Parent=m
local s=Instance.new("UIListLayout")
s.FillDirection=Enum.FillDirection.Horizontal
s.SortOrder=Enum.SortOrder.LayoutOrder
s.Padding=UDim.new(0,8)
s.Parent=r

local function button(t,u,v,w)
local x=Instance.new("TextButton")
x.AutoButtonColor=false
x.BackgroundColor3=g.ground
x.BorderSizePixel=0
x.Size=UDim2.fromOffset(u,40)
x.LayoutOrder=v
x.Font=g.font
x.TextSize=g.textSize
x.TextColor3=g.text
x.Text=t
x.Parent=r
corner(x)
x.Activated:Connect(w)
end

for t,u in ipairs(k.actions or{})do
button(u.label,176,t,function()
local v=u.run(o.Text,o)
if v==nil then
self:close()
elseif type(v)=="string"then
q.Text=v
else
q.Text=""
end
end)
end
button("Close",96,100,function()self:close()end)
end

return h

end)()end,[31]=function()local b,c,d=a(31)local e return(function(...)

local g=game:GetService("Players")
local h=d(c.Parent.Theme)
local i=d(c.Parent.BlockView)
local j=d(c.Parent.Shapes)
local k=d(c.Parent.Drag)

local l={}
l.__index=l

function l.new(m,n,o)
local p=setmetatable({registry=n,program=o,blockOf={}},l)

local q=Instance.new("ScrollingFrame")
q.Name="Workspace"
q.BackgroundColor3=h.ground
q.BorderSizePixel=0

q.Size=UDim2.new(1,-h.paletteWidth,1,-(h.toolbarHeight+h.consoleHeight))
q.Position=UDim2.new(0,h.paletteWidth,0,h.toolbarHeight)
q.ScrollingDirection=Enum.ScrollingDirection.XY
q.CanvasSize=UDim2.new(0,0,0,0)
q.AutomaticCanvasSize=Enum.AutomaticSize.XY
q.ScrollBarThickness=8
q.ScrollBarImageColor3=h.textDim
q.Parent=m
p.canvas=q

local r=Instance.new("Frame")
r.Name="Scripts"
r.BackgroundTransparency=1
r.Size=UDim2.new(1,0,1,0)
r.Parent=q
p.layer=r


local s=Instance.new("Frame")
s.Name="SnapPreview"
s.BackgroundColor3=h.accent
s.BorderSizePixel=0
s.Visible=false
s.ZIndex=200
s.Parent=m
p.preview,p.targets=s,{inputs={},slots={},fields={}}

p:_wirePan()
o:onChanged(function()p:render()end)
p:render()
return p
end

function l:_toCanvas(m)
return(m-self.canvas.AbsolutePosition)/h.scale+self.canvas.CanvasPosition
end



function l:_grab(m)
local n=Vector2.new(m.Position.X,m.Position.Y)

local o=self.canvas
while o and not o:IsA("BasePlayerGui")do o=o.Parent end
o=o or g.LocalPlayer.PlayerGui
local p=o:GetGuiObjectsAtPosition(n.X,n.Y)[1]
local q
while p and not self.blockOf[p]do
if not q and self.targets.fields[p]then q=p end
p=p.Parent
end
if not p then return false end
local r=self.blockOf[p]
local s,t,u,v
self.canvas.ScrollingEnabled=false
k.track(m,function(w)
if not t then
if(w-n).Magnitude<6 then return end
local x=self:_toCanvas(p.AbsolutePosition)
if self.program:find(r)then
s=self.program:detach(r,x.X,x.Y-12)
else
local y,z=self.program:findInput(r)
local A=y and self.registry:get(y.op).inputs[z]
s=self.program:detachInput(r,x.X,x.Y-12,A and A.default)
end
if not s then return end
local y=self.program:get().scripts[s]
u,v=y.x,y.y
t=self.layer["Script"..s]
t.ZIndex=10
end
local x=(w-n)/h.scale
t.Position=UDim2.fromOffset(math.max(0,u+x.X),math.max(0,v+x.Y)+12)
self:_showPreview(self:_findTarget(self:_specOfHolder(s,t),t))
end,function(w)
self.canvas.ScrollingEnabled=true
self:_showPreview(nil)
if not t then

if q and self.editor then self.editor:open(q,self.targets.fields[q])end
return
end
local x=self:_findTarget(self:_specOfHolder(s,t),t)
local y=(w-n)/h.scale
if w.X<self.canvas.AbsolutePosition.X then
self.program:removeScript(s)
elseif not(x and self.program:attach(s,x))then
self.program:moveScript(s,math.max(0,u+y.X),math.max(0,v+y.Y))
end
end)
return true
end


local m=40

local function isValue(n)return n=="reporter"or n=="boolean"end


function l:_specOfHolder(n,o)
local p=self.program:get().scripts[n].blocks
local q,r=self.registry:shapeOf(p[1]),self.registry:shapeOf(p[#p])
local s=o.AbsolutePosition

local t=self.registry:wrapSlot(p[1])
local u
if t then
for v,w in pairs(self.targets.slots)do
if w.block==p[1]and w.name==t then
u=v.AbsolutePosition+Vector2.new(h.cSlotIndent*h.scale,0)
break
end
end
end
return{first=q,last=r,count=#p,top=s,bottom=s+Vector2.new(0,o.AbsoluteSize.Y),
def=self.registry:get(p[1].op),wrap=t,slotPos=u}
end


function l:_specOfOp(n,o,p)
local q=self.registry:createBlock(n)
local r=self.registry:shapeOf(q)
local s=self.registry:wrapSlot(q)

local t=s and(o+Vector2.new(h.cSlotIndent*h.scale,h.rowHeight*h.scale))or nil
return{first=r,last=r,count=1,top=o,bottom=o+Vector2.new(0,p.Y),
def=self.registry:get(n),wrap=s,slotPos=t}
end


function l:_findTarget(n,o)
local p,q,r=self.registry,self.program,h.scale
local s,t=nil,m*r
local function skip(u)return o and(u==o or o:IsAncestorOf(u))end

if isValue(n.first)then
if n.count~=1 then return nil end
for u,v in pairs(self.targets.inputs)do
local w=(u.AbsolutePosition-n.top).Magnitude
if w<t and not skip(u)then

if p:accepts(p:get(v.block.op),v.name,n.first,n.def)then
s,t={kind="input",block=v.block,name=v.name,pos=u.AbsolutePosition,size=u.AbsoluteSize},w
end
end
end
return s
end

for u,v in pairs(self.blockOf)do
if not skip(u)then
local w=p:shapeOf(v)
if not isValue(w)then
local x,y=u.AbsolutePosition,u.AbsoluteSize

local z=Vector2.new(x.X,x.Y+y.Y)
local A=(z-n.top).Magnitude
if A<t and w~="cap"and n.first~="hat"then
local C,D=q:find(v)

local E=(C and D<#C)and n.wrap or nil
if C and not(n.last=="cap"and D<#C and not E)then
s,t={kind="after",block=v,wrap=E,pos=z,size=y},A
end
end

A=(x-n.bottom).Magnitude
if A<t and w~="hat"and n.last~="cap"then
local C,D,E=q:find(v)
if C and D==1 and C==q:get().scripts[E].blocks then
s,t={kind="before",block=v,pos=x,size=y},A
end
end

if n.wrap and n.slotPos and w~="hat"then
local C=(x-n.slotPos).Magnitude
if C<t then
local D,E,F=q:find(v)
if D and E==1 and D==q:get().scripts[F].blocks then
s,t={kind="wrap",block=v,wrap=n.wrap,pos=x,size=y},C
end
end
end
end
end
end
if n.first~="hat"then
for u,v in pairs(self.targets.slots)do
if not skip(u)then
local w=u.AbsolutePosition+Vector2.new(h.cSlotIndent*r,0)
local x=(w-n.top).Magnitude
local y=v.block.stacks[v.name]
local z=y and#y>0
local A=z and n.wrap or nil
if x<t and not(n.last=="cap"and z and not A)then
s,t={kind="slot",block=v.block,name=v.name,wrap=A,pos=w,size=Vector2.new(u.AbsoluteSize.X-h.cSlotIndent*r,0)},x
end
end
end
end
return s
end

function l:_showPreview(n)
local o=self.preview
if not n then o.Visible=false return end
local p,q=h.scale,o.Parent.AbsolutePosition
local r,s=n.pos,n.size
if n.kind=="input"then
o.BackgroundTransparency=0.5
else
o.BackgroundTransparency=0
r=Vector2.new(r.X,r.Y-2*p)
s=Vector2.new(math.max(s.X,60*p),4*p)
end
o.Position=UDim2.fromOffset((r.X-q.X)/p,(r.Y-q.Y)/p)
o.Size=UDim2.fromOffset(s.X/p,s.Y/p)
o.Visible=true
end


function l:hover(n,o)
self:_showPreview(self:_findTarget(self:_specOfOp(n,o.AbsolutePosition,o.AbsoluteSize)))
end

function l:hoverEnd()self:_showPreview(nil)end

function l:_wirePan()
self.canvas.InputBegan:Connect(function(n)
local o=n.UserInputType
if o~=Enum.UserInputType.MouseButton1 and o~=Enum.UserInputType.Touch then return end
if self:_grab(n)or o==Enum.UserInputType.Touch then return end
local p=Vector2.new(n.Position.X,n.Position.Y)
k.track(n,function(q)
local r=self.canvas.CanvasPosition-(q-p)/h.scale
self.canvas.CanvasPosition=Vector2.new(math.max(0,r.X),math.max(0,r.Y))
p=q
end)
end)
end

function l:render()
self.layer:ClearAllChildren()
self.blockOf={}
self.targets={inputs={},slots={},fields={}}
local n=i.new(self.registry,self.blockOf,self.targets)
for o,p in ipairs(self.program:get().scripts)do
local q=Instance.new("Frame")
q.Name="Script"..o
q.BackgroundTransparency=1
q.AutomaticSize=Enum.AutomaticSize.XY
q.Size=UDim2.new(0,0,0,0)

q.Position=UDim2.new(0,p.x,0,p.y+12)
q.Parent=self.layer
n:buildStack(p.blocks,q)
end
self:_applyError()
end




function l:markError(n)
self.errorBlock=n
self:_applyError(true)
end

function l:clearError()
if not self.errorBlock then return end
self.errorBlock=nil
self:render()
end

function l:_applyError(n)
local o=self.errorBlock
if not o then return end
local p
for q,r in pairs(self.blockOf)do
if r==o then p=q break end
end
if not p then return end
j.markError(p,h.error,3)
if n then

task.defer(function()
if not p.Parent then return end
local q=self.canvas
local r,s=self:_toCanvas(p.AbsolutePosition),p.AbsoluteSize/h.scale
local t=q.AbsoluteSize/h.scale
local u=q.CanvasPosition
local v=(r.X<u.X or r.X+s.X>u.X+t.X)and math.max(0,r.X-24)or u.X
local w=(r.Y<u.Y or r.Y+s.Y>u.Y+t.Y)and math.max(0,r.Y-48)or u.Y
q.CanvasPosition=Vector2.new(v,w)
end)
end
end



function l:spawn(n,o,p)
local q=(self.program:count()%8)*32
local r=o and self:_toCanvas(o)-Vector2.new(0,12)or self.canvas.CanvasPosition+Vector2.new(24+q,24+q)
local s=self.program:addScript(self.registry:createBlock(n),math.max(0,math.floor(r.X)),math.max(0,math.floor(r.Y)),true)
local t=o and p and self:_findTarget(self:_specOfOp(n,o,p))
if not(t and self.program:attach(s,t))then self.program:changed()end
end

return l

end)()end}


local c={{1,4,{"BlockScript"},{{2,2,{"Lang"},{{12,1,{"Core"},{{13,2,{"Interpreter"}},{17,2,{"Values"}},{14,2,{"Plugins"}},{16,2,{"Validate"}},{15,2,{"Registry"}}}},{3,2,{"Blocks"},{{6,2,{"Events"}},{10,2,{"Sensing"}},{11,2,{"Variables"}},{9,2,{"Output"}},{4,2,{"Control"}},{7,2,{"Lists"}},{5,2,{"Custom"}},{8,2,{"Operators"}}}}}},{18,2,{"Plugin"}},{19,1,{"UI"},{{28,2,{"Theme"}},{31,2,{"Workspace"}},{26,2,{"Program"}},{30,2,{"Transfer"}},{20,2,{"Assets"}},{25,2,{"Palette"}},{22,2,{"Console"}},{23,2,{"Drag"}},{21,2,{"BlockView"}},{24,2,{"Editor"}},{29,2,{"Toolbar"}},{27,2,{"Shapes"}}}}}}}


local d=nil


local e="0.4.2"
local g="WaxRuntime"




local h,i,j,k,l,m,n,o,p,q,r,s,t,u,v=
string,task,setmetatable,error,next,table,unpack,coroutine,script,type,require,pcall,tostring,tonumber,_VERSION

local w=m.insert
local x=m.remove
local y=m.freeze or function(y)return y end

local z=o.wrap

local A=h.sub
local C=h.match
local D=h.gmatch



if v and A(v,1,4)=="Lune"then
local E,F=s(r,"@lune/task")
if E and F then
i=F
end
end

local E=i and i.defer


local F=E or function(F,...)
z(F)(...)
end


local G={
[1]="Folder",
[2]="ModuleScript",
[3]="Script",
[4]="LocalScript",
[5]="StringValue",
}

local H={}

local I={}
local J={}
local K={}
local L={}


local M={}



local N={}


local O={
GetFullName={{},function(O)
local P=O.Name
local Q=O.Parent

while Q do
P=Q.Name.."."..P


Q=Q.Parent
end

return P
end},

GetChildren={{},function(O)
local P={}

for Q in l,N[O]do
w(P,Q)
end

return P
end},

GetDescendants={{},function(O)
local P={}

for Q in l,N[O]do
w(P,Q)

for R,S in l,Q:GetDescendants()do
w(P,S)
end
end

return P
end},

FindFirstChild={{"string","boolean?"},function(O,P,Q)
local R=N[O]

for S in l,R do
if S.Name==P then
return S
end
end

if Q then
for S in l,R do


return S:FindFirstChild(P,true)
end
end
end},

FindFirstAncestor={{"string"},function(O,P)
local Q=O.Parent
while Q do
if Q.Name==P then
return Q
end

Q=Q.Parent
end
end},


WaitForChild={{"string","number?"},function(O,P)
return O:FindFirstChild(P)
end},
}


local P={}
for Q,R in l,O do
local S=R[1]
local T=R[2]

local U={}
for V,W in l,S do
local X,Y=C(W,"^([^%?]+)(%??)")
U[V]={X,Y}
end

P[Q]=function(V,...)
if not N[V]then
k("Expected ':' not '.' calling member function "..Q,2)
end

local W={...}
for X,Y in l,U do
local Z=W[X]
local _=q(Z)
local aa,ab=Y[1],Y[2]

if Z==nil and not ab then
k("Argument "..Z.." missing or nil",3)
end

if aa~="any"and _~=aa and not(_=="nil"and ab)then
k("Argument "..X.." expects type \""..aa.."\", got \"".._.."\"",2)
end
end

return T(V,...)
end
end

local function CreateRef(aa,ab,Q)



local R


local S=j({},{__mode="k"})


local function InvalidMember(T)
k(T.." is not a valid (virtual) member of "..aa.." \""..ab.."\"",3)
end
local function ReadOnlyProperty(T)
k("Unable to assign (virtual) property "..T..". Property is read only",3)
end

local T={}
local U={}

U.__metatable=false

U.__index=function(V,W)
if W=="ClassName"then
return aa
elseif W=="Name"then
return ab
elseif W=="Parent"then
return Q
elseif aa=="StringValue"and W=="Value"then

return R
else
local X=P[W]

if X then
return X
end
end


for X in l,S do
if X.Name==W then
return X
end
end


InvalidMember(W)
end

U.__newindex=function(V,W,X)

if W=="ClassName"then
ReadOnlyProperty(W)
elseif W=="Name"then
ab=X
elseif W=="Parent"then

if X==T then
return
end

if Q~=nil then

N[Q][T]=nil
end

Q=X

if X~=nil then

N[X][T]=true
end
elseif aa=="StringValue"and W=="Value"then

R=X
else

InvalidMember(W)
end
end

U.__tostring=function()
return ab
end

j(T,U)

N[T]=S

if Q~=nil then
N[Q][T]=true
end

return T
end


local function CreateRefFromObject(aa,ab)
local Q=aa[1]
local R=aa[2]
local S=aa[3]
local T=aa[4]

local U=G[R]

local V=S and x(S,1)or U

local W=CreateRef(U,V,ab)
H[Q]=W

if S then
for X,Y in l,S do
W[X]=Y
end
end

if T then
for X,Y in l,T do
CreateRefFromObject(Y,W)
end
end

return W
end

local aa=CreateRef("Folder","["..g.."]")
for ab,Q in l,c do
CreateRefFromObject(Q,aa)
end


for ab,Q in l,b do
local R=H[ab]

I[R]=Q
J[R]=ab

local S=R.ClassName
if S=="LocalScript"or S=="Script"then
w(L,R)
end
end

local function LoadScript(ab)
local Q=ab.ClassName


local R=K[ab]
if R and Q=="ModuleScript"then
return n(R)
end

local S=I[ab]

local function FormatError(T)
T=t(T)

local U=ab:GetFullName()


local V,W=C(T,"[^:]+:(%d+): (.+)")

if not V or not d then
return U..":*: "..(W or T)
end

V=u(V)

local X=J[ab]
local Y=d[X]

local Z=V-Y+1
if Z<0 then
Z="?"
end

return U..":"..Z..": "..W
end


if Q=="LocalScript"or Q=="Script"then
local T,U=s(S)
if not T then
k(FormatError(U),0)
end
else
local T={s(S)}

local U=x(T,1)
if not U then
local V=x(T,1)
k(FormatError(V),0)
end

K[ab]=T
return n(T)
end
end



function a(ab)
local Q=H[ab]

local function RealCall(R,...)
local S={s(R,...)}

local T=x(S,1)
if not T then
k(S[1],3)
end

return n(S)
end


local R=y(j({},{
__index=M,
__newindex=function(R,S,T)
M[S]=T
end,
__len=function()
return#M
end,
__iter=function()
return l,M
end,
}))

local S=y({

version=e,
envname=g,

shared=R,


script=p,
require=r,
})

local T=Q

local function Global_require(U,...)
local V=q(U)

local W="Attempted to call require with a non-ModuleScript"
local X="Attempted to call require with self"

if V=="table"and N[U]then
if U.ClassName~="ModuleScript"then
k(W,2)
elseif U==Q then
k(X,2)
end

return LoadScript(U)
elseif V=="string"and A(U,1,1)~="@"then


if#U==0 then
k("Attempted to call require with empty string",2)
end

local Y=Q

if A(U,1,1)=="/"then
Y=aa
elseif A(U,1,2)=="./"then
U=A(U,3)
end

local Z
for _ in D(U,"([^/]*)/?")do
local ac=_
if _==".."then
ac="Parent"
end


if ac~=""then
local ad=Y:FindFirstChild(ac)
if not ad then
local ae=Y.Parent
if ae then
ad=ae:FindFirstChild(ac)
end
end

if ad then
Y=ad
elseif _~=Z and _~="init"and _~="init.server"and _~="init.client"then
k("Virtual script path \""..U.."\" not found",2)
end
end


Z=_
end

if Y.ClassName~="ModuleScript"then
k(W,2)
elseif Y==Q then
k(X,2)
end

return LoadScript(Y)
end

return RealCall(r,U,...)
end


return S,T,Global_require
end

for ab,ac in l,L do
F(LoadScript,ac)
end