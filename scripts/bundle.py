#!/usr/bin/env python3
"""Bundle src/ into one Luau file with a small require shim (stands in for wax).
Usage: python3 scripts/bundle.py build/bundle.luau
Modules are resolved as Roblox instances: script.Parent / script.Child, init.lua = folder module."""
import os, sys

SHIM = '''local __nodes,__src,__cache={},{},{}
local __meta={__index=function(t,k) return rawget(t,"__kids")[k] end}
local function __node(name,parent)
	local n=setmetatable({Name=name,Parent=parent,__kids={}},__meta)
	if parent then rawget(parent,"__kids")[name]=n end
	return n
end
local __root=__node("BlockScript",nil)
local function __require(n)
	if type(n)~="table" or not __src[n] then return require(n) end
	local c=__cache[n]
	if c==nil then
		c={v=__src[n](n,__require)}
		__cache[n]=c
	end
	return c.v
end'''

def lit(p): return '{' + ','.join('"%s"' % x for x in p) + '}'

def main(out_path):
    mods = []
    def walk(d, path):
        for n in sorted(os.listdir(d)):
            p = os.path.join(d, n)
            if os.path.isdir(p):
                init = os.path.join(p, 'init.lua')
                mods.append((path + (n,), init if os.path.exists(init) else None))
                walk(p, path + (n,))
            elif n.endswith('.lua') and n not in ('init.lua', 'init.client.lua'):
                mods.append((path + (n[:-4],), p))
    walk('src', ())
    out = [SHIM]
    for path, _ in mods:
        out.append('do local n=__root for _,k in ipairs(%s) do n=rawget(n,"__kids")[k] or __node(k,n) end end' % lit(path))
    for path, f in mods:
        if f:
            out.append('do local n=__root for _,k in ipairs(%s) do n=rawget(n,"__kids")[k] end\n__src[n]=function(script,require)\n%s\nend end' % (lit(path), open(f).read()))
    out.append('return (function(script,require)\n%s\nend)(__root,__require)' % open('src/init.client.lua').read())
    os.makedirs(os.path.dirname(out_path) or '.', exist_ok=True)
    open(out_path, 'w').write('\n'.join(out))
    print(len(mods), 'modules ->', out_path)

if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else 'build/bundle.luau')
