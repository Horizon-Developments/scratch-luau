return function(R, V)
	R:defineCategory("Lists", { name = "Lists", color = { 255, 102, 26 } })

	local function list(ctx, name) return ctx.interp:list(name) end -- creates on first use, within the list caps
	local LIST = { type = "list", default = "my list" }
	-- Index slots take a number or Scratch's words: last, random (or any), and all (delete only).
	local function INDEX(default) return { type = "any", default = default or 1 } end

	R:defineBlock({ id = "list_add", category = "Lists", shape = "stack", label = "add {ITEM} to {LIST}",
		inputs = { ITEM = { type = "any", default = "thing" }, LIST = LIST },
		run = function(ctx, a)
			local l = list(ctx, a.LIST)
			ctx.interp:checkListGrow(l, a.ITEM)
			l[#l + 1] = a.ITEM
		end })

	R:defineBlock({ id = "list_delete", category = "Lists", shape = "stack", label = "delete {INDEX} of {LIST}",
		inputs = { INDEX = INDEX(), LIST = LIST },
		run = function(ctx, a)
			local l = list(ctx, a.LIST)
			local i = V.listIndex(a.INDEX, #l, true)
			if i == "all" then ctx.interp.lists[a.LIST] = {}
			elseif i then table.remove(l, i) end
		end })

	R:defineBlock({ id = "list_clear", category = "Lists", shape = "stack", label = "delete all of {LIST}",
		inputs = { LIST = LIST }, run = function(ctx, a) list(ctx, a.LIST) ctx.interp.lists[a.LIST] = {} end })

	R:defineBlock({ id = "list_insert", category = "Lists", shape = "stack", label = "insert {ITEM} at {INDEX} of {LIST}",
		inputs = { ITEM = { type = "any", default = "thing" }, INDEX = INDEX(), LIST = LIST },
		run = function(ctx, a)
			local l = list(ctx, a.LIST)
			local i = V.listIndex(a.INDEX, #l + 1, false) -- last = one past the end, so it appends
			if i then
				ctx.interp:checkListGrow(l, a.ITEM)
				table.insert(l, i, a.ITEM)
			end
		end })

	R:defineBlock({ id = "list_replace", category = "Lists", shape = "stack", label = "replace item {INDEX} of {LIST} with {ITEM}",
		inputs = { INDEX = INDEX(), LIST = LIST, ITEM = { type = "any", default = "thing" } },
		run = function(ctx, a)
			local l = list(ctx, a.LIST)
			local i = V.listIndex(a.INDEX, #l, false)
			if i then l[i] = V.limitString(a.ITEM) end
		end })

	R:defineBlock({ id = "list_item", category = "Lists", shape = "reporter", output = "any", label = "item {INDEX} of {LIST}",
		inputs = { INDEX = INDEX(), LIST = LIST },
		run = function(ctx, a)
			local l = list(ctx, a.LIST)
			local i = V.listIndex(a.INDEX, #l, false)
			if not i then return nil end -- out of range is nil, like l[i]
			return l[i]
		end })

	-- 1-based position of the first item equal (==) to ITEM, nil if none (table.find).
	R:defineBlock({ id = "list_indexof", category = "Lists", shape = "reporter", output = "any", label = "item # of {ITEM} in {LIST}",
		inputs = { ITEM = { type = "any", default = "thing" }, LIST = LIST },
		run = function(ctx, a)
			for i, v in ipairs(list(ctx, a.LIST)) do if V.equals(v, a.ITEM) then return i end end
			return nil
		end })

	R:defineBlock({ id = "list_length", category = "Lists", shape = "reporter", label = "length of {LIST}",
		inputs = { LIST = LIST }, run = function(ctx, a) return #list(ctx, a.LIST) end })

	R:defineBlock({ id = "list_contains", category = "Lists", shape = "boolean", label = "{LIST} contains {ITEM}",
		inputs = { LIST = LIST, ITEM = { type = "any", default = "thing" } },
		run = function(ctx, a)
			for _, v in ipairs(list(ctx, a.LIST)) do if V.equals(v, a.ITEM) then return true end end
			return false
		end })

	-- The list itself as text (Scratch's list reporter): joined with spaces, or with nothing if every item is one letter.
	R:defineBlock({ id = "list_contents", category = "Lists", shape = "reporter", label = "{LIST}",
		inputs = { LIST = LIST }, run = function(ctx, a) return V.listContents(list(ctx, a.LIST)) end })
end
