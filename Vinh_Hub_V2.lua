if not game:IsLoaded() then game.Loaded:Wait() end

local ps = game:GetService("Players")
repeat task.wait() until ps.LocalPlayer

local lp, rv = ps.LocalPlayer, getrenv().shared
while lp:GetAttribute("IsLoaded") ~= true do lp:GetAttributeChangedSignal("IsLoaded"):Wait() end
repeat task.wait(0.1) until rv.LoadingController and rv.LoadingController:IsLoaded()

local qk = {Right = "D", Left = "A", Up = "W"}

local function pd() return rv.PlayerDataV2Controller:Fetch() end

local function zx(t, nw)
	local fp, g = `Avenoric/Configs/FishingMaster/{lp.Name}_Log.txt`, getgenv().__FmLq
	if not g then
		g = {pq = {}, dt = false}
		getgenv().__FmLq = g
	end
	local m, ts = (tostring(t):gsub("%s*\n%s*", " <- ")), os.date("%Y-%m-%d %H:%M:%S")
	local la = g.pq[#g.pq]
	if la and la[2] == m then
		la[1], la[3] = ts, la[3] + 1
	else
		table.insert(g.pq, {ts, m, 1})
	end
	local function wr()
		g.dt = false
		local n = nw and #g.pq or #g.pq - 1
		if n <= 0 then return end
		local b = {}
		for i = 1, n do
			local x = g.pq[i]
			b[i] = `{x[1]} | {x[2]}{x[3] > 1 and ` x{x[3]}` or ""}`
		end
		local s = table.concat(b, "\n") .. "\n"
		local ok = pcall(function()
			for _, x in {"Avenoric", "Avenoric/Configs", "Avenoric/Configs/FishingMaster"} do
				if not isfolder(x) then makefolder(x) end
			end
			if appendfile and isfile(fp) then appendfile(fp, s) else writefile(fp, (isfile(fp) and readfile(fp) or "") .. s) end
		end)
		if ok then
			for _ = 1, n do table.remove(g.pq, 1) end
		end
	end
	if nw then
		wr()
		return
	end
	if g.dt then return end
	g.dt = true
	task.delay(2, wr)
end

local function sk()
	local d, o = pd(), {}
	local r = d and d.Rods and d.Rods[d.RodEquip]
	for s, id in r and r.BookSlots or {} do
		if type(id) == "string" and id ~= "" and id ~= "None" then table.insert(o, {s, id}) end
	end
	table.sort(o, function(a, b) return a[1] < b[1] end)
	return o
end

local function eq()
	local d, c = pd(), lp.Character
	local rd = d and d.RodEquip
	if type(rd) ~= "string" or rd == "" or rd == "None" then return nil, "No Rod" end
	if not c then return nil, "No Character" end
	local function hd() return c:FindFirstChild(rd) and c[rd]:IsA("Tool") end
	if hd() then return true end
	rv.HeldToolController.SetHeldSlot:Fire(1)
	local dl = os.clock() + 5
	repeat task.wait(0.1) until hd() or os.clock() > dl
	if hd() then return true end
	return nil, "Equip Timeout"
end

local function tg(h)
	local w = workspace:FindFirstChild("World")
	local il, ip = w and w:FindFirstChild("Islands"), RaycastParams.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for i = 0, 15 do
		local a = math.rad(i * 22.5)
		for _, r in {60, 50, 40, 30} do
			local p = Vector3.new(h.Position.X + math.sin(a) * r, 3, h.Position.Z + math.cos(a) * r)
			if not il or not workspace:Raycast(p + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), ip) then return p end
		end
	end
	return nil
end

local function fp(s)
	local lm, st = s.fp[1], s.fp[2]
	local el = workspace:GetServerTimeNow() - st
	local pk = (2 * math.max(0, math.ceil((el * 2.4 - 1) / 2)) + 1) / 2.4
	if pk < lm then task.wait(pk - el) end
	rv.FishingController.FishFirstPull:Fire()
end

local function rl(f, s, ks)
	local fc, mv, sq, nc = rv.FishingController, rv.RodController.Moveset, 0, 0
	while f.st == "Running" and not s.cr and not s.rr do
		local t = os.clock()
		if s.q and t >= s.q[2] then fc.FishQTEResponse:Fire(qk[s.q[1]]); s.q = nil end
		if not (lp:GetAttribute("IsUsingSkill") or lp:GetAttribute("UnitSkillActive") or lp:GetAttribute("PlayerSkillReserved")) then
			for _, x in ks do
				local c = s.cd[x[1]]
				if not c or c[1] == "Ready" or (c[1] == "Cooldown" or c[1] == "Pending") and t >= c[2] then
					mv:Fire(x[1], x[2])
					s.cd[x[1]], s.q = {"Pending", t + 1}, nil
					break
				end
			end
		end
		if t >= nc and t >= s.sw and t >= s.bs then
			sq = sq % 65535 + 1
			fc.FishReelPull:Fire(sq)
			nc = math.max(nc, t - 0.01) + 1 / 6 + 0.005
		end
		task.wait()
	end
	return nil
end

local ra = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine", "Huge"}

local function md(...)
	local x = game:GetService("ReplicatedStorage")
	for _, n in {...} do x = x:FindFirstChild(n) or error(`Module Missing: {n}`) end
	return require(x)
end

local function fl() return md("Shared", "Lib", "FishStorageRules").GetState(pd()).isFull end

local function zn(p) return typeof(p) == "Vector3" and `{math.floor(p.X)}, {math.floor(p.Y)}, {math.floor(p.Z)}` or "None" end

local function ze(id)
	local ok, x = pcall(function() return md("Data", "Catalog").Fish.GetById(id) end)
	return ok and x and `{x.name} ({x.rarity})` or tostring(id)
end

local function zv(f, c, k, t)
	f.zv = f.zv or {}
	if f.zv[c] == k then return end
	f.zv[c] = k
	zx(t or k)
end

local function ns(id, p)
	local b, bd, bx
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == id then
			local pa = (x:FindFirstChildWhichIsA("ProximityPrompt", true) or {}).Parent
			local q = pa and (pa:IsA("BasePart") and pa.Position or pa:IsA("Attachment") and pa.WorldPosition) or x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position
			if q and (not bd or (q - p).Magnitude < bd) then b, bd, bx = q, (q - p).Magnitude, x end
		end
	end
	return b, bx
end

local sn = 0

local function sq(p, t)
	if sn >= 4 then return false end
	local dn = false
	sn += 1
	task.spawn(function()
		pcall(function() lp:RequestStreamAroundAsync(p, t) end)
		sn, dn = sn - 1, true
	end)
	local dl = os.clock() + t + 1
	repeat task.wait(0.1) until dn or os.clock() > dl
	return dn
end

local fz, cj, ut = {Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll}, nil, nil

local function lc()
	local c = lp.Character
	local r, h = c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
	if r and h and h.Health > 0 and r:IsA("BasePart") then return c, r, h end
	return nil
end

local function pz(p, cf)
	p.CFrame = cf
	p.AssemblyLinearVelocity, p.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

local function uc(j)
	if j.ca then j.ca:Disconnect(); j.cr:Disconnect() end
	for p, v in j.cc do pcall(function() p.CanCollide = v end) end
	for e, v in j.ss do pcall(function() j.h:SetStateEnabled(e, v) end) end
	j.c, j.h, j.ca, j.cr, j.cc, j.ss, j.pl = nil, nil, nil, nil, {}, {}, {}
end

local function ac(j, c, h)
	uc(j)
	j.c, j.h, j.pd = c, h, true
	for _, e in fz do j.ss[e] = h:GetStateEnabled(e); h:SetStateEnabled(e, false) end
	j.ca = c.DescendantAdded:Connect(function() j.pd = true end)
	j.cr = c.DescendantRemoving:Connect(function() j.pd = true end)
end

local function nx(j)
	local c, _, h = lc()
	if not c then return end
	if j.s >= 1e5 and j.oc and c ~= j.oc then error("Respawn", 0) end
	if c ~= j.c then ac(j, c, h) end
	if j.pd then
		j.pd, j.pl = false, {}
		for _, d in c:GetDescendants() do
			if d:IsA("BasePart") then
				if j.cc[d] == nil then j.cc[d] = d.CanCollide end
				table.insert(j.pl, d)
			end
		end
	end
	for _, p in j.pl do if p.CanCollide then p.CanCollide = false end end
	if h.Sit or h.SeatPart then h.Sit = false end
end

local function hx(j, dt)
	local c, r, h = lc()
	if not c then
		if j.c then uc(j) end
		j.st = "Respawn"
		return
	end
	if j.s >= 1e5 and j.oc and c ~= j.oc then error("Respawn", 0) end
	if c ~= j.c then ac(j, c, h) end
	local d = j.p - r.Position
	local ar, fd = d.Magnitude <= j.s * dt, Vector3.new(d.X, 0, d.Z)
	j.lk = ar and j.fk or fd.Magnitude > 1e-3 and fd.Unit or j.lk
	j.st = ar and "Arrived" or "Moving"
	pz(r, CFrame.lookAlong(ar and j.p or r.Position + d.Unit * j.s * dt, j.lk))
end

local function cz(j, st, why)
	if j.dn then return end
	j.dn = true
	j.cs:Disconnect(); j.ch:Disconnect()
	pcall(uc, j)
	pcall(function()
		local _, r = lc()
		if r then r.AssemblyLinearVelocity, r.AssemblyAngularVelocity = Vector3.zero, Vector3.zero end
		if r and not j.nl and r.Position.Y < -10 then pz(r, CFrame.new(ut(r.Position) or Vector3.new(r.Position.X, 12, r.Position.Z)) * r.CFrame.Rotation) end
	end)
	j.st, j.why = st, why
	if cj == j then cj = nil end
end

local function mo(p, s, fk)
	if typeof(p) ~= "Vector3" or p.Magnitude ~= p.Magnitude or p.Magnitude == math.huge then return nil, "Move Failed: Bad Point" end
	if typeof(fk) == "Vector3" and not (fk.Magnitude > 1e-3) then fk = nil end
	if cj then
		cj.nl = true
		cj:Stop()
	end
	local c, r, h = lc()
	if s < 1e5 and p.Y < -10 then p = ut(p) or Vector3.new(p.X, 12, p.Z) end
	if r and s < 1e5 and r.Position.Y < -10 then
		local u = ut(r.Position)
		if u then pz(r, CFrame.new(u) * r.CFrame.Rotation) end
	end
	local j = {st = "Moving", p = p, s = s, oc = c, cc = {}, ss = {}, pl = {}, lk = r and Vector3.new(r.CFrame.LookVector.X, 0, r.CFrame.LookVector.Z).Unit or -Vector3.zAxis}
	j.fk = fk or j.lk
	function j.Stop(x) cz(x or j, "Stopped") end
	if c then ac(j, c, h) end
	local rs = game:GetService("RunService")
	j.cs = rs.Stepped:Connect(function()
		local ok, e = pcall(nx, j)
		if not ok then cz(j, "Failed", `Move Failed: {e}`) end
	end)
	j.ch = rs.Heartbeat:Connect(function(dt)
		local ok, e = pcall(hx, j, dt)
		if not ok then cz(j, "Failed", `Move Failed: {e}`) end
	end)
	cj = j
	return j
end

local ap, hv, aq, xf

local function gf(f, p, fk)
	for _ = 1, 4 do
		local _, r = lc()
		if not r then return nil, "No Character" end
		local d = p - r.Position
		if Vector3.new(d.X, 0, d.Z).Magnitude <= 2 then return true end
		if f.st ~= "Running" then return nil end
		local hi, j, e = Vector3.new(d.X, 0, d.Z).Magnitude > 50, nil, nil
		for i = hi and 1 or 3, 3 do
			local _, r2 = lc()
			if not r2 then return nil, "No Character" end
			local q = i == 1 and Vector3.new(r2.Position.X, 1000, r2.Position.Z) or i == 2 and Vector3.new(p.X, 1000, p.Z) or p
			if hi and i == 3 then sq(p, 10) end
			j, e = mo(q, hi and i ~= 2 and 1e6 or 30, fk)
			if not j then return nil, e end
			local dl = os.clock() + (q - r2.Position).Magnitude / 30 + 5
			repeat task.wait() until j.st == "Arrived" or j.dn or f.st ~= "Running" or os.clock() > dl
			if j.st ~= "Arrived" or f.st ~= "Running" then break end
		end
		local why = j.why
		j:Stop()
		if why then return nil, why end
		if f.st ~= "Running" then return nil end
		task.wait(0.5)
	end
	local _, r = lc()
	if r and Vector3.new(p.X - r.Position.X, 0, p.Z - r.Position.Z).Magnitude <= 2 then return true end
	return nil, "Move Timeout"
end

local go = gf

local function gd(c, p)
	local rp = RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, {c}
	local r = workspace:Raycast(p + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), rp)
	return r and Vector3.new(p.X, r.Position.Y + 3, p.Z) or p
end

local function lk(sr, kp)
	local d, ct, sc, st, hl = pd(), md("Data", "Catalog"), rv.SellController, {}, {}
	for _, r in sr do st[r] = true end
	for u, x in d.Inventory.Fishes do
		local fi = ct.Fish.GetById(x.fishId)
		if x.locked ~= true and (kp[u] or not (fi and st[fi.rarity] and (not x.isHuge or st.Huge))) then
			local s, v = sc:ToggleLock(u)
			if s ~= 0 or v ~= true then return hl, `Lock Failed: {x.fishId}` end
			table.insert(hl, u)
		end
	end
	return hl, nil
end

local function zb(sr, kp)
	local d, ct, st, n = pd(), md("Data", "Catalog"), {}, 0
	for _, r in sr do st[r] = true end
	for u, x in d.Inventory.Fishes do
		local fi = ct.Fish.GetById(x.fishId)
		if x.locked ~= true and not kp[u] and fi and st[fi.rarity] and (not x.isHuge or st.Huge) then n += 1 end
	end
	return n
end

local function uk(hl)
	local d, sc = pd(), rv.SellController
	for _, u in hl do
		local x = d.Inventory.Fishes[u]
		if x then
			local s, v = sc:ToggleLock(u)
			if s == 0 and v == true then s, v = sc:ToggleLock(u) end
			if s ~= 0 or v ~= false then return nil, `Unlock Failed: {x.fishId}` end
		end
	end
	return true, nil
end

local function tr(f)
	local c = lp.Character
	local h = c and c:FindFirstChild("HumanoidRootPart")
	if not h then return nil, "No Character" end
	local o, sw = h.CFrame, rv.Swimming and rv.Swimming:IsSwimming()
	local np = xf("npc_fish_seller", rv.IslandRegionController:GetCurrentIslandId()) or ns("npc_fish_seller", o.Position)
	if not np then
		sq(o.Position, 5)
		np = ns("npc_fish_seller", o.Position)
	end
	if not np then
		zx(`[Sell] No Fish Seller Near {zn(o.Position)}`)
		return "Auto Fish Failed: No Fish Seller"
	end
	local hl, e = lk(f.sr(), f.kp())
	zx(`[Sell] Start | Seller {zn(np)} | Rarity {table.concat(f.sr(), "/")} | Locked To Keep {#hl}{e and ` | {e}` or ""}`)
	if e then
		local _, ue = uk(hl)
		return nil, ue or e
	end
	local hd = f.hf and f.hf() and not f.bu
	local mv, sp = hd and hv or go, hd and Vector3.new(np.X, math.max(6, np.Y - 9.95), np.Z) or aq(c, np, o.Position)
	local w, we, s
	for _ = 1, 3 do
		w, we = mv(f, sp, hd and Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit or Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit, math.min(sp.Y, 10))
		if hd and not w and f.st == "Running" then zx(`[Hidden] Sell Move Failed: {we or "Unknown"}`) end
		if not w or f.st ~= "Running" then break end
		task.wait(0.5)
		s = rv.SellController:SellAll()
		zx(`[Sell] SellAll Answer {tostring(s)}`)
		if s ~= 1 then break end
	end
	local uo, ue = uk(hl)
	if f.st == "Running" and not sw then mv(f, hd and f.hp and f.hi == rv.IslandRegionController:GetCurrentIslandId() and f.hp or o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit, math.min(sp.Y, 10)) end
	if sw then f.rp = true end
	zx(`[Sell] End | Answer {tostring(s)} | Move {w and "Ok" or we or "Stopped"} | Unlock {uo and "Ok" or ue}`)
	if f.st ~= "Running" then return nil, nil end
	if not uo then return nil, ue end
	if not w then return nil, we or "Move Failed" end
	if s == 3 then return "Auto Fish Failed: Satchel Full" end
	if s ~= 0 then return nil, `Sell Status {s}` end
	return nil, nil
end

local iz, ix, bn, bi = {}, {}, {}, {}
for _, x in {{"Starter Island", "island_starter"}, {"Jungle Island", "island_jungle"}, {"Desert Island", "island_desert"}, {"Snow Island", "island_snow"}, {"Volcanic Island", "island_volcano"}, {"Fossil Island", "island_fossil"}, {"Lotus Island", "island_lotus"}} do
	table.insert(iz, x[1])
	ix[x[1]] = x[2]
end
for _, x in {{"Truck", "truck"}, {"Red Truck", "red_truck"}} do
	table.insert(bn, x[1])
	bi[x[1]] = x[2]
end

local function ic() return rv.IslandRegionController:GetCurrentIslandId() end

local function rs(id, wd)
	local c, r = lc()
	local w = workspace:FindFirstChild("World")
	local il = w and w:FindFirstChild("Islands")
	local fo = il and il:FindFirstChild(id or ic())
	if not (c and fo) then return nil end
	local ip, o, rd, ct, rr, k = RaycastParams.new(), {}, Random.new(), r.Position, 150, 150
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	if wd then
		for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
			if x:IsA("BasePart") and x:GetAttribute("islandId") == fo.Name then ct, rr, k = x.Position, x.Size.X / 2, 400 end
		end
	end
	for i = 1, k do
		if i % 50 == 0 then task.wait() end
		local a, d = rd:NextNumber(0, math.pi * 2), rd:NextNumber(10, rr)
		local h = workspace:Raycast(Vector3.new(ct.X + math.sin(a) * d, 150, ct.Z + math.cos(a) * d), Vector3.new(0, -200, 0), ip)
		if h and h.Instance:IsDescendantOf(fo) and h.Position.Y > 3.5 and h.Position.Y < 20 then
			local g = h.Position
			for i = 0, 7 do
				local b = math.rad(i * 45)
				if not workspace:Raycast(Vector3.new(g.X + math.sin(b) * 12, 103, g.Z + math.cos(b) * 12), Vector3.new(0, -100, 0), ip) and tg({Position = g}) then
					table.insert(o, g + Vector3.new(0, 3, 0))
					break
				end
			end
		end
	end
	return #o > 0 and o[rd:NextInteger(1, #o)] or nil
end

local function ul(id)
	local c, d = md("Data", "Config", "IslandConfig")[id], pd()
	return c and c.defaultUnlocked == true or d and d.UnlockedIslands and d.UnlockedIslands[id] == true or false
end

local function rg(id)
	for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if x:IsA("BasePart") and x:GetAttribute("islandId") == id then return x.Position end
	end
	return nil
end

local hs = game:GetService("HttpService")

local function vi(p)
	local id = ic()
	if id ~= "" then return id end
	for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if x:IsA("BasePart") and (x.Position - p).Magnitude < x.Size.X / 2 then return x:GetAttribute("islandId") end
	end
	return ""
end

local function uh(id)
	local c, r = lc()
	local w = workspace:FindFirstChild("World")
	local il = w and w:FindFirstChild("Islands")
	local fo = il and il:FindFirstChild(id)
	if not (c and fo) then return nil end
	local ct, rr = r.Position, 250
	for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if x:IsA("BasePart") and x:GetAttribute("islandId") == id then ct, rr = x.Position, x.Size.X / 2 end
	end
	local ip, o, rd = RaycastParams.new(), {}, Random.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for _ = 1, 400 do
		local a, d = rd:NextNumber(0, math.pi * 2), math.sqrt(rd:NextNumber()) * rr
		local h = workspace:Raycast(Vector3.new(ct.X + math.sin(a) * d, 500, ct.Z + math.cos(a) * d), Vector3.new(0, -520, 0), ip)
		if h and h.Instance:IsDescendantOf(fo) and h.Position.Y > 3.5 then table.insert(o, h.Position) end
	end
	table.sort(o, function(a, b) return a.Y > b.Y end)
	for i, g in o do
		if i % 20 == 0 then task.wait() end
		local q = Vector3.new(g.X, -35, g.Z)
		if tg({Position = q}) then return q, g.Y end
	end
	return nil
end

ut = function(p)
	local w = workspace:FindFirstChild("World")
	local il, ip = w and w:FindFirstChild("Islands"), RaycastParams.new()
	if not il then return nil end
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	local h = workspace:Raycast(Vector3.new(p.X, 500, p.Z), Vector3.new(0, -520, 0), ip)
	return h and h.Position + Vector3.new(0, 3, 0)
end

hv = function(f, p, fk, ty)
	local _, r0 = lc()
	if r0 and ((p - r0.Position) * Vector3.new(1, 0, 1)).Magnitude > 50 then ty = 1000 end
	for i = 1, 3 do
		local _, r = lc()
		if not r then return nil, "No Character" end
		local q = i == 1 and Vector3.new(r.Position.X, ty, r.Position.Z) or i == 2 and Vector3.new(p.X, ty, p.Z) or p
		if i == 3 and ty == 1000 then sq(p, 10) end
		local j, e = mo(q, i == 2 and 30 or 1e6, fk)
		if not j then return nil, e end
		local dl = os.clock() + (q - r.Position).Magnitude / 30 + 5
		repeat task.wait() until j.st == "Arrived" or j.dn or f.st ~= "Running" or os.clock() > dl
		if j.dn then return nil, j.why or "Move Failed" end
		if f.st ~= "Running" then return nil end
		if j.st ~= "Arrived" then return nil, "Move Timeout" end
	end
	return true
end

ap = function(c, np, p, d)
	if d == 0 then return np end
	local u = Vector3.new(p.X, np.Y, p.Z) - np
	return gd(c, np + (u.Magnitude > 0.1 and u.Unit or Vector3.xAxis) * (d or 6))
end

aq = function(c, np, p, rd, ip)
	local w = workspace:FindFirstChild("World")
	local il = w and w:FindFirstChild("Islands")
	rd = rd or 10
	if not ip and il then
		ip = RaycastParams.new()
		ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	end
	if ip then
		local u = Vector3.new(p.X - np.X, 0, p.Z - np.Z)
		local a0 = u.Magnitude > 0.1 and math.atan2(u.X, u.Z) or 0
		local function gs(i, hz)
			local a = a0 + math.rad((i % 2 == 0 and 1 or -1) * math.ceil(i / 2) * 22.5)
			local h = workspace:Raycast(np + Vector3.new(math.sin(a), 0, math.cos(a)) * hz + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), ip)
			return h and h.Material ~= Enum.Material.Water and math.abs(h.Position.Y + 3 - np.Y) <= 6 and h.Position + Vector3.new(0, 3, 0) or nil
		end
		for i = 0, 15 do
			local hz = rd - 0.05
			for _ = 1, 4 do
				local s = gs(i, hz)
				if not s then break end
				local m = (s - np).Magnitude
				if m <= rd and m >= rd - 0.1 then return s end
				hz = math.sqrt(math.max((rd - 0.05) ^ 2 - (s.Y - np.Y) ^ 2, 0))
			end
		end
		for k = math.floor(rd) - 1, 4, -1 do
			for i = 0, 15 do
				local s = gs(i, k)
				if s and (s - np).Magnitude <= rd then return s end
			end
		end
	end
	return ap(c, np, p, 0)
end

local function an(f, c, np, p, rd)
	if f.hf() then
		local sp = Vector3.new(np.X, math.max(6, np.Y - (rd or 10) + 0.05), np.Z)
		return hv(f, sp, nil, math.min(sp.Y, 10))
	end
	local sp = aq(c, np, p, rd)
	return go(f, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
end

local function bv(k)
	local a = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
	local m = a and a:FindFirstChild("Cars")
	m = m and m:FindFirstChild(k)
	m = m and m:FindFirstChild("Model")
	return m and m:GetAttribute("Speed")
end

local function gb(f, k)
	local c, r = lc()
	local cf = workspace:FindFirstChild("Cars")
	if not c then return nil, "No Character" end
	if not cf then return nil, "No Cars Folder" end
	local nm = tostring(lp.UserId)
	local om = cf:FindFirstChild(nm)
	local ct = md("Data", "Catalog", "Car")
	local function pc() return ct[k] and ct[k].price or 0 end
	local function ok(x) return x and x:FindFirstChild("Main") and x:FindFirstChild("DSeat") and x:GetAttribute("Speed") == bv(k) and ((x.Main.Position - r.Position) * Vector3.new(1, 0, 1)).Magnitude < 500 end
	if ok(om) then
		zx(`[Boat] Use Own {k} At {zn(om.Main.Position)}`)
		return om
	end
	if pc() > (pd().Coin or 0) then k = "truck" end
	if ok(om) then
		zx(`[Boat] Use Own {k} At {zn(om.Main.Position)}`)
		return om
	end
	local mp, mx = ns("npc_car_merchant", r.Position)
	if not mp then
		zx(`[Boat] No Boat Merchant Near {zn(r.Position)}`)
		return nil, "No Boat Merchant"
	end
	local g, e = go(f, aq(c, mp, r.Position))
	if not g then
		zx(`[Boat] Walk To Merchant {zn(mp)} Failed: {e or "Stopped"}`)
		return nil, e
	end
	local P = md("Stardust").Packet
	P("SpawnCarEvent", P.String):Fire(`{k}/{mx:GetAttribute("IslandId")}`)
	local dl = os.clock() + 8
	repeat
		task.wait(0.2)
		local x = cf:FindFirstChild(nm)
		if x and x ~= om and x:FindFirstChild("Main") and x:FindFirstChild("DSeat") then
			zx(`[Boat] Spawned {k} At {mx:GetAttribute("IslandId")} {zn(x.Main.Position)}`)
			return x
		end
	until os.clock() > dl or f.st ~= "Running"
	zx(`[Boat] Spawn {k} At {mx:GetAttribute("IslandId")}: {f.st == "Running" and "Timeout" or "Stopped"}`)
	return nil, f.st == "Running" and "Boat Spawn Timeout" or nil
end

local function pq(m, v)
	for _, x in m and m:GetDescendants() or {} do
		if x:IsA("ProximityPrompt") then x.Enabled = v end
	end
end

local function sb(f, m)
	local c, r, h = lc()
	if not c then return nil, "No Character" end
	local ds = m:FindFirstChild("DSeat")
	local pp = m:FindFirstChild("RaidDrivePrompt", true) or ds and ds:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not (ds and pp) then return nil, "No Boat Seat" end
	pq(m, true)
	if ds.Occupant == h then return true end
	local q = (r.Position - ds.Position) * Vector3.new(1, 0, 1)
	local g, e = go(f, ds.Position + Vector3.new(0, 3, 0) + (q.Magnitude > 0.1 and q.Unit or Vector3.xAxis) * 3)
	if not g then
		zx(`[Boat] Walk To Seat Failed: {e or "Stopped"}`)
		return nil, e
	end
	if cj then cj:Stop() end
	local dl, lc2 = os.clock() + 20, false
	repeat
		fireproximityprompt(pp)
		local d1 = os.clock() + 1
		repeat task.wait(0.1) until ds.Occupant == h or os.clock() > d1
		if ds.Occupant ~= h and not lc2 then
			lc2 = true
			rv.FishingController.FishLootConfirm:Fire()
			rv.FishingController.FishCancel:Fire()
		end
	until ds.Occupant == h or os.clock() > dl
	zx(`[Boat] Sit: {ds.Occupant == h and "Ok" or "Timeout"}{pp.Name == "RaidDrivePrompt" and " (Raid Drive)" or ""}{lc2 and " (Loot Confirm Sent)" or ""}`)
	if ds.Occupant ~= h then return nil, "Sit Timeout" end
	return true
end

local function dv(f, m, id, pt)
	local _, _, h = lc()
	local mn, ds = m:FindFirstChild("Main"), m:FindFirstChild("DSeat")
	local ap, ao = mn and mn:FindFirstChild("AlignPosition"), mn and mn:FindFirstChild("AlignOrientation")
	local cp = id and rg(id)
	if not (h and ds and ap and ao) then return nil, "Bad Boat" end
	if not cp and (id or not pt) then return nil, "No Island Region" end
	local sp, y, cc, sx = m:GetAttribute("Speed") or 30, ap.Position.Y, {}, {}
	for _, x in {m, lp.Character} do
		for _, p in x:GetDescendants() do
			if p:IsA("BasePart") then cc[p] = p.CanCollide end
			if p:IsA("Seat") or p:IsA("VehicleSeat") then table.insert(sx, p) end
		end
	end
	local w = workspace:FindFirstChild("World")
	local il, rp = w and w:FindFirstChild("Islands"), RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	local tp, to, er, cn, on, sh = Vector3.new(mn.Position.X, 0, mn.Position.Z), pt and Vector3.new(pt.X, 0, pt.Z) or Vector3.new(cp.X, 0, cp.Z), nil, nil, false, nil
	local hd, hl = (to - tp).Magnitude > 1e-3 and (to - tp).Unit or Vector3.new(mn.CFrame.LookVector.X, 0, mn.CFrame.LookVector.Z).Unit, math.max(mn.Size.X, mn.Size.Z) / 2 + 3
	cn = game:GetService("RunService").Stepped:Connect(function(_, dt)
		local ok, e = pcall(function()
			for _, x in sx do
				local c = x.Occupant and x.Occupant.Parent
				if c and c ~= lp.Character then
					for _, p in c:GetDescendants() do
						if p:IsA("BasePart") and cc[p] == nil then cc[p] = p.CanCollide end
					end
				end
			end
			for p in cc do
				if p.CanCollide then p.CanCollide = false end
			end
			local q = to - tp
			if q.Magnitude > 0.05 and not sh then
				hd = q.Unit
				local nx2 = tp + hd * math.min(q.Magnitude, sp * dt)
				local r = not pt and on and il and workspace:Raycast(Vector3.new(nx2.X, 103, nx2.Z) + hd * hl, Vector3.new(0, -100, 0), rp)
				if r then sh = r.Position else tp = nx2 end
			end
			ap.Position, ao.CFrame = Vector3.new(tp.X, y, tp.Z), CFrame.Angles(0, math.atan2(-hd.X, -hd.Z), 0)
		end)
		if not ok then er = `Boat Drive Failed: {e}`; cn:Disconnect() end
	end)
	local lb, lt, dl, dn = math.huge, os.clock(), os.clock() + (to - tp).Magnitude / sp * 1.5 + 30, false
	local t0 = os.clock()
	zx(`[Boat] Drive To {id or "Point"} | From {zn(mn.Position)} | To {zn(to)} | {pt and "Point" or "Island"} | Speed {sp}`)
	while f.st == "Running" and not er do
		task.wait(0.25)
		if ds.Occupant ~= h then er = "Left Boat"; break end
		on = ic() == id
		if sh then
			task.wait(0.5)
			dn = true
			break
		end
		if on and not pt then
			local mp, mx = ns("npc_car_merchant", mn.Position)
			local nq = mp and mx:GetAttribute("IslandId") == id and Vector3.new(mp.X, 0, mp.Z)
			if nq and nq ~= to then to, lb = nq, math.huge end
		end
		local d = (Vector3.new(mn.Position.X, 0, mn.Position.Z) - to).Magnitude
		if d < lb - 1 then lb, lt = d, os.clock() end
		if d < (pt and 3 or 15) or on and not pt and os.clock() - lt > 2 then dn = true; break end
		if os.clock() - lt > 4 then er = "Boat Stuck" end
		if os.clock() > dl then er = "Boat Timeout" end
	end
	if cn.Connected then cn:Disconnect() end
	for p, v in cc do pcall(function() p.CanCollide = v end) end
	local dd = os.clock() + 3
	while ds.Occupant == h and os.clock() < dd do
		h.Sit, h.Jump = false, true
		task.wait(0.2)
	end
	local _, r = lc()
	zx(`[Boat] Drive End: {er or dn and "Arrived" or "Stopped"} | At {zn(mn.Position)} | {math.floor(os.clock() - t0)} s{sh and " | Shore" or ""}`)
	local hj = r and mo(r.Position, 30)
	task.wait(1)
	if er or not dn then
		if hj then hj:Stop() end
		return nil, er
	end
	return true, sh
end

local zy = {on = false, rq = false, nt = 0, ss = 0, fr = {}, wl = {}, hu = {}, nm = {}, hp = -1e9}
local zj = `Avenoric/Configs/FishingMaster/{lp.Name}_Safe.json`
pcall(function()
	local d = hs:JSONDecode(readfile(zj))
	if type(d) ~= "table" or d.JobId ~= game.JobId then return end
	for k, t in {RealPlayers = zy.wl, HubUsers = zy.hu} do
		for _, x in type(d[k]) == "table" and d[k] or {} do
			if type(x) == "table" and tonumber(x.UserId) then t[tonumber(x.UserId)], zy.nm[tonumber(x.UserId)] = x.Seen or true, x.Name end
		end
	end
end)
local function zf()
	local o = {JobId = game.JobId, RealPlayers = {}, HubUsers = {}}
	for k, t in {RealPlayers = zy.wl, HubUsers = zy.hu} do
		for u in t do
			local p = game:GetService("Players"):GetPlayerByUserId(u)
			zy.nm[u] = p and p.Name or zy.nm[u]
			table.insert(o[k], {Name = zy.nm[u] or "?", UserId = u, Seen = type(t[u]) == "string" and t[u] or nil})
		end
	end
	pcall(function()
		for _, x in {"Avenoric", "Avenoric/Configs", "Avenoric/Configs/FishingMaster"} do
			if not isfolder(x) then makefolder(x) end
		end
		writefile(zj, hs:JSONEncode(o))
	end)
end
local wz = {island_starter = Vector3.new(-37.4, 11.1, 305.9), island_jungle = Vector3.new(-1161.1, 10.8, -61.9), island_desert = Vector3.new(-44.1, 10.1, -935.4), island_snow = Vector3.new(1171.7, 9.4, -266.5), island_volcano = Vector3.new(1772.5, 9.2, 1069.3), island_fossil = Vector3.new(-543.2, 10.6, 2172.3), island_lotus = Vector3.new(1180.8, 11.9, 2392.7)}

local function wm(id)
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == "npc_car_merchant" and x:GetAttribute("IslandId") == id then return x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or wz[id] end
	end
	return wz[id]
end

local wv
if getgenv and getgenv().__FmW then pcall(getgenv().__FmW.Destroy, getgenv().__FmW) end
pcall(function()
	local pg, lt = lp:WaitForChild("PlayerGui"), rv.LoadingController
	local x = pg:WaitForChild("Loading", 10):Clone()
	local fr = x.Frame
	x.Name, x.Enabled, x.ResetOnSpawn, x.DisplayOrder = hs:GenerateGUID(false), false, false, 1000
	fr.BackgroundTransparency, fr.Background.Gradient.ImageTransparency, fr.Background.Rectangle.BackgroundTransparency, fr.ImageLabel.ImageTransparency = 0, 0, 0, 0
	fr.tips.Position, fr.Bar.Position = lt._originalTipsPos, lt._originalBarPos
	fr.Bar.MasteryText.Text = "Teleporting..."
	x.Parent = pg
	wv = x
end)
if getgenv then getgenv().__FmW = wv end

local wg, wk, wp, wo = 0, nil, 0, {}
local wt = {"Tips: Cast your bobber near ripple spots to catch rare fish!", "Tips: Different rods provide unique luck and strength boosts.", "Tips: Keep an eye on the tension bar to avoid snapping your line!", "Tips: Upgrade your bait at the bait shop to attract bigger fish.", "Tips: Perfect catches grant extra experience and rare materials.", "Tips: Check the weather! Some mythical fish only appear in storms.", "Tips: Visit the fish merchant to convert your catches into Coins & Gems.", "Tips: Explore distant islands once you discover their fast travel points.", "Tips: Rare auras and rod skins can be equipped to show off your style.", "Tips: Complete daily quests for bonus rewards and crates.", "Tips: Fill out your fish Index to track every species you've caught!"}

local function wc(v, ok)
	if not (wv and wv.Parent) then return end
	wg += 1
	local g, fr, ts, lt = wg, wv.Frame, game:GetService("TweenService"), rv.LoadingController
	local b, bg = fr.Bar, fr.Background
	pcall(function()
		if v then
			if wk then wk:Disconnect() end
			for _, x in wo do x:Cancel() end
			fr.BackgroundTransparency, bg.Gradient.ImageTransparency, bg.Rectangle.BackgroundTransparency, fr.ImageLabel.ImageTransparency = 0, 0, 0, 0
			b.Position, fr.tips.Position = UDim2.new(lt._originalBarPos.X.Scale, lt._originalBarPos.X.Offset, 1.25, 0), UDim2.new(lt._originalTipsPos.X.Scale, lt._originalTipsPos.X.Offset, 1.35, 0)
			b.Fill.Size, b.MasteryText.Text, wp, wv.Enabled = UDim2.fromScale(0, 1), "Loading game...", 0, true
			local cp, tp = 0, 0
			wk = game:GetService("RunService").RenderStepped:Connect(function(dt)
				tp = wp
				if tp > cp then cp = math.min(cp + math.max((tp - cp) * math.clamp(dt * 10, 0, 1), 5e-4), tp) end
				local t = os.clock()
				b.Fill.Size, b.Fish.Position, b.Fish.Rotation = UDim2.fromScale(cp, 1), UDim2.new(cp, 0, 0.5, math.sin(t * 10) * 3), math.sin(t * 12) * 10
			end)
			wo = {ts:Create(b.Shine, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.25})}
			wo[1]:Play()
			ts:Create(b, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = lt._originalBarPos}):Play()
			task.delay(0.08, function() ts:Create(fr.tips, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = lt._originalTipsPos}):Play() end)
			local ti3, op = math.random(1, #wt), lt._originalTipsPos
			fr.tips.Text = wt[ti3]
			task.spawn(function()
				while true do
					task.wait(2.5)
					if wg ~= g then return end
					ti3 = ti3 % #wt + 1
					local x = ts:Create(fr.tips, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(op.X.Scale, op.X.Offset, op.Y.Scale - 0.035, op.Y.Offset)})
					x:Play()
					x.Completed:Wait()
					if wg ~= g then return end
					fr.tips.Text, fr.tips.Position = wt[ti3], UDim2.new(op.X.Scale, op.X.Offset, op.Y.Scale + 0.035, op.Y.Offset)
					ts:Create(fr.tips, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = op}):Play()
				end
			end)
			task.spawn(function()
				for k, x in {"Starting up...", "Building interface...", "Loading your data...", "Preparing gameplay..."} do
					task.wait(1)
					if wg ~= g then return end
					wp, b.MasteryText.Text = k * 0.22, x
				end
			end)
			return
		end
		if ok then wp = 1 end
		b.MasteryText.Text = ok and "Ready!" or "Teleport Failed"
		task.spawn(function()
			task.wait(ok and 0.4 or 1)
			if wg ~= g then return end
			ts:Create(fr.tips, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(lt._originalTipsPos.X.Scale, lt._originalTipsPos.X.Offset, 1.35, 0)}):Play()
			task.delay(0.06, function() ts:Create(b, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(lt._originalBarPos.X.Scale, lt._originalBarPos.X.Offset, 1.25, 0)}):Play() end)
			local q = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			ts:Create(bg.Gradient, q, {ImageTransparency = 1}):Play()
			ts:Create(bg.Rectangle, q, {BackgroundTransparency = 1}):Play()
			ts:Create(fr.ImageLabel, q, {ImageTransparency = 1}):Play()
			ts:Create(fr, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			task.wait(1.5)
			if wg ~= g then return end
			if wk then wk:Disconnect() end
			for _, x in wo do x:Cancel() end
			wv.Enabled = false
		end)
	end)
end

local function wy(f, id, mp, h, o)
	if cj then cj:Stop() end
	local r = h.Parent and h.Parent:FindFirstChild("HumanoidRootPart")
	if not r then return nil, "Warp Failed: No Character" end
	local sp, cf, ok, rg = md("Shared", "Lib", "SpawnPointDialogue"), CFrame.new(r.Position + Vector3.new(0, 1000, 0)), false, false
	o.rc = rv.IslandRegionController.RegionChanged.OnClientEvent:Connect(function(x) if x == id then rg = true end end)
	o.hb = game:GetService("RunService").Heartbeat:Connect(function()
		if r.Parent then r.AssemblyLinearVelocity, r.CFrame = Vector3.zero, cf end
	end)
	task.wait(0.3)
	cf = CFrame.new(mp.X, 1000, mp.Z)
	task.wait(0.6)
	cf = CFrame.new(mp + Vector3.new(4, 3, 0))
	task.wait(0.2)
	local d0 = os.clock() + 3
	repeat task.wait() until rg or os.clock() > d0 or f.st ~= "Running"
	o.rc:Disconnect()
	local dl, na = os.clock() + 4.5, 0
	while not ok and os.clock() < dl and f.st == "Running" do
		na += 1
		local b, dn = {}, false
		task.spawn(function() sp.CreateAction(true, b, b).on_select(function(x)
			if x == true then ok = true end
			dn = true
		end) end)
		local d2 = os.clock() + 3
		repeat task.wait() until dn or os.clock() > d2
		if not ok then task.wait(0.1) end
	end
	if ok then
		local d3 = os.clock() + 3
		repeat task.wait() until (pd() or {}).SpawnIsland == id or os.clock() > d3 or f.st ~= "Running"
	end
	o.hb:Disconnect()
	zx(`[Warp] {id} | Region Event {rg and "Yes" or "No"} | Set Spawn {ok and "Ok" or "Failed"} After {na} Tries | Spawn Island {(pd() or {}).SpawnIsland or "?"}`)
	if f.st ~= "Running" then return nil end
	if not ok then return nil, "Warp Failed: Spawn Not Set" end
	if (pd() or {}).SpawnIsland ~= id then return nil, "Warp Failed: Spawn Island Unchanged" end
	local bc, tk, d4 = md("Controllers", "BackpackController"), false, os.clock() + 10
	while f.st == "Running" and os.clock() < d4 do
		local s, v = pcall(function() return bc.TeleportToSpawn:Fire() end)
		tk = s and v == true
		if tk then break end
		task.wait(0.5)
	end
	if f.st ~= "Running" then return nil end
	if not tk then return nil, "Warp Failed: Respawn Refused" end
	dl = os.clock() + 8
	repeat task.wait(0.2) until ic() == id and lc() or os.clock() > dl
	local _, wr = lc()
	zx(`[Warp] {id} | Respawn Ok | Island Now {ic() ~= "" and ic() or "Sea"} | At {zn(wr and wr.Position)}`)
	if ic() ~= id then return nil, "Warp Failed: Not On Island" end
	return true
end

local wb = true

local function wx(f, id)
	if not wb or not ul(id) then return nil end
	local mp = wm(id)
	if not mp then return nil, "Warp Failed: No Boat Merchant" end
	local ok, e = nil, nil
	zx(`[Warp] Start {ic() ~= "" and ic() or "Sea"} -> {id}`)
	wc(true)
	while f.st == "Running" do
		local dl, h = os.clock() + 8, nil
		repeat
			local _, _, x = lc()
			h = x
			if not h then task.wait(0.2) end
		until h or os.clock() > dl or f.st ~= "Running"
		if not h then continue end
		local o: {hb: RBXScriptConnection?, rc: RBXScriptConnection?} = {}
		local s
		s, ok, e = pcall(wy, f, id, mp, h, o)
		if o.hb then o.hb:Disconnect() end
		if o.rc then o.rc:Disconnect() end
		if not s then ok, e = nil, `Warp Failed: {ok}` end
		if ok or f.st ~= "Running" then break end
		zx(`[Warp] {id}: {e or "Warp Failed"}, Retrying`)
		task.wait(1)
	end
	wc(false, ok)
	zx(`[Warp] {id}: {ok and "Arrived" or e or "Stopped"}`)
	return ok, e
end

do
	local xp = {island_starter = {npc_car_merchant = Vector3.new(-37.4, 11.1, 305.9), npc_daily_quest = Vector3.new(-4, 11.1, 305.3), npc_fish_seller = Vector3.new(-31.8, 19.6, 407), npc_gacha_aura = Vector3.new(-55.7, 55.3, 538.6), npc_gacha_book = Vector3.new(-32.8, 19.7, 432.3), npc_gacha_unit = Vector3.new(-177.2, 27, 420.5), npc_premium_skill = Vector3.new(-169.8, 22.2, 489), npc_rod_shop = Vector3.new(-29.7, 12, 354.2)}, island_desert = {npc_car_merchant = Vector3.new(-44.1, 10.1, -935.4), npc_daily_quest = Vector3.new(4.7, 10.4, -1078.1), npc_fish_seller = Vector3.new(35.5, 10.6, -1151.2), npc_rod_shop = Vector3.new(64.9, 10.4, -1130.4), npc_sage_yijiu = Vector3.new(3.6, 75.6, -1264.2), npc_unlock_island_3 = Vector3.new(-56.8, 10, -1021.6), npc_white_tiger = Vector3.new(87.1, 43.4, -1355.9)}, island_lotus = {npc_car_merchant = Vector3.new(1180.8, 11.9, 2392.7), npc_chu_xin_rod = Vector3.new(1096.9, 22.1, 2522.5), npc_daily_quest = Vector3.new(1170.5, 12, 2449), npc_fish_seller = Vector3.new(1142.1, 34, 2621.6), npc_gacha_aura = Vector3.new(1147.5, 34, 2658.5), npc_gacha_book = Vector3.new(1211.8, 24.5, 2486.5), npc_gacha_unit = Vector3.new(1291.4, 24.3, 2616.4), npc_lotus_rod_forge = Vector3.new(1109.1, 35.3, 2653.9), npc_premium_skill = Vector3.new(1158.8, 34, 2594), npc_rainbow_bait_crafter = Vector3.new(1010.8, 28.8, 2691.3), npc_super_boss_summoner = Vector3.new(982.4, 24.3, 2634.7), npc_unlock_island_7 = Vector3.new(1125.1, 12, 2416.7)}, island_jungle = {npc_car_merchant = Vector3.new(-1161.1, 10.8, -61.9), npc_daily_quest = Vector3.new(-1302.9, 11.1, -63.2), npc_fish_seller = Vector3.new(-1278.6, 10.9, -182.5), npc_rod_shop = Vector3.new(-1227.4, 11.9, -145.7), npc_unlock_island_2 = Vector3.new(-1268.8, 11.3, -110)}, island_snow = {npc_car_merchant = Vector3.new(1171.7, 9.4, -266.5), npc_daily_quest = Vector3.new(1309.7, 28.3, -361.4), npc_fish_seller = Vector3.new(1264.3, 27.7, -348.6), npc_giang_lao_snow = Vector3.new(1529.4, 143.6, -348.4), npc_phoenix = Vector3.new(1385, 11.7, -513.7), npc_raid_ticket = Vector3.new(1395.4, 27.6, -280.7), npc_rod_shop = Vector3.new(1331.6, 28.5, -330.1), npc_unlock_island_4 = Vector3.new(1239.5, 9.7, -322.6)}, island_volcano = {npc_azure_dragon = Vector3.new(2118.3, 121.9, 1295.5), npc_bamboo_rod = Vector3.new(1945.3, 18.9, 1295.6), npc_car_merchant = Vector3.new(1772.5, 9.2, 1069.3), npc_crimson_bead_rod = Vector3.new(1840.8, 9.8, 1101.2), npc_daily_quest = Vector3.new(1951.7, 9.6, 1071.7), npc_duan_gan_volcano = Vector3.new(1847.4, 12.8, 1227.3), npc_fish_seller = Vector3.new(1929.2, 9.7, 1094.7), npc_unlock_island_5 = Vector3.new(1885.8, 12.2, 1067.6)}, island_fossil = {npc_car_merchant = Vector3.new(-543.2, 10.6, 2172.3), npc_daily_quest = Vector3.new(-663, 15.5, 2316.5), npc_dread_fish_rod = Vector3.new(-886.2, 243.7, 2467.4), npc_fei_tian_fossil = Vector3.new(-872.8, 17.1, 2171.2), npc_fish_seller = Vector3.new(-757.8, 19, 2345.2), npc_ha_dieu_de_fossil = Vector3.new(-675.7, 72.9, 2267.1), npc_supreme_king = Vector3.new(-603.8, 186.4, 2541.9), npc_unlock_island_6 = Vector3.new(-555.2, 9.4, 2230.8)}}

	xf = function(id, il, a)
		if xp[il] and xp[il][id] then return xp[il][id] end
		if not a then return nil end
		for _, v in xp do
			if v[id] then return v[id] end
		end
		return nil
	end
end

local function wn(f, tp, tg)
	local _, r = lc()
	if not wb or not r then return nil end
	local bu, bd = nil, math.huge
	for id, p in wz do
		local d = ((p - tp) * Vector3.new(1, 0, 1)).Magnitude
		if d < bd and ul(id) then bu, bd = id, d end
	end
	local sv = ((r.Position - tp) * Vector3.new(1, 0, 1)).Magnitude - bd
	if not bu or ic() == bu or sv < 300 then return nil end
	zx(`[Travel] Warp To {bu} Before Sailing To {tg} | Saves {math.floor(sv)} Studs`)
	return wx(f, bu)
end

local function ti(f, id, k)
	if ic() == id then return true end
	local w, we = wx(f, id)
	if w or f.st ~= "Running" then return w end
	if we then f.nq = {Title = "Teleport", Text = `{we}, Sailing`} end
	if not ul(id) and (wz[id] or rg(id)) then wn(f, wz[id] or rg(id), id) end
	if f.st ~= "Running" then return nil end
	zx(`[Travel] Sail {ic() ~= "" and ic() or "Sea"} -> {id}{we and ` | Warp: {we}` or not ul(id) and " | Island Locked" or not wb and " | Instant Teleport Off" or ""}`)
	local function fx(x)
		zx(`[Travel] Sail To {id} Failed: {x or "Stopped"}`)
		return nil, x
	end
	local m, e = gb(f, k)
	if not m then return fx(e) end
	local g
	g, e = sb(f, m)
	if not g then return fx(e) end
	g, e = dv(f, m, id)
	if not g then return fx(e) end
	local c, r = lc()
	if not c then return fx("No Character") end
	local mp, mx = ns("npc_car_merchant", r.Position)
	local cp = mp and mx:GetAttribute("IslandId") == id and mp or e and e + ((e - r.Position) * Vector3.new(1, 0, 1)).Unit * 12 or rg(id)
	g, e = go(f, ap(c, cp, r.Position))
	if not g then return fx(e) end
	task.wait(0.5)
	if ic() ~= id then return fx("Not On Island") end
	zx(`[Travel] Sail Arrived {id}`)
	return true
end

local function zm(p, wi)
	if zy.wl[p.UserId] then return true end
	local hm = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	local an = hm and hm:FindFirstChildOfClass("Animator")
	for _, t in an and an:GetPlayingAnimationTracks() or {} do
		if t.WeightCurrent > 0.05 and t.Animation and wi[t.Animation.AnimationId] then
			zy.wl[p.UserId] = wi[t.Animation.AnimationId]
			local h = p.Character:FindFirstChild("HumanoidRootPart")
			zx(`[Safe] Real Player Seen: {p.Name} ({p.UserId}) | {wi[t.Animation.AnimationId]} | At {zn(h and h.Position)}`)
			zf()
			return true
		end
	end
	return false
end

local function zg(p)
	if zy.hu[p.UserId] then return true end
	local hm = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	local an = hm and hm:FindFirstChildOfClass("Animator")
	for _, t in an and an:GetPlayingAnimationTracks() or {} do
		if t.Animation and t.Animation.AnimationId:match("%d+$") == "180435571" and math.abs(t.Speed - 0.37) < 0.01 and t.WeightTarget < 0.05 then
			zy.hu[p.UserId] = true
			zx(`[Safe] Hub User Seen: {p.Name} ({p.UserId})`)
			zf()
			return true
		end
	end
	return false
end

local function zq(p)
	local hm = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	local an = hm and hm:FindFirstChildOfClass("Animator")
	for _, t in an and an:GetPlayingAnimationTracks() or {} do
		if t.Animation and t.Animation.AnimationId:match("%d+$") == "180435571" and math.abs(t.Speed - 0.41) < 0.01 and t.WeightTarget < 0.05 then return true end
	end
	return false
end

local function zw()
	local c, r = lc()
	local id = r and vi(r.Position) or ""
	local am = c and c:FindFirstChild("Animate")
	if not am then return false end
	local g = id ~= "" and os.clock() >= zy.ss and rg(id)
	if g then
		zy.ss = os.clock() + 10
		task.spawn(sq, Vector3.new(g.X, 2, g.Z), 5)
	end
	local wi, nr, cs = {}, false, game:GetService("CollectionService")
	for _, n in {"walk", "run", "jump"} do
		for _, x in am:FindFirstChild(n) and am[n]:GetChildren() or {} do
			if x:IsA("Animation") then wi[x.AnimationId] = n == "jump" and "Jump" or "Walk" end
		end
	end
	for _, p in game:GetService("Players"):GetPlayers() do
		local h = p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if h then
			if zy.fr[p.UserId] == nil then
				local ok, v = pcall(lp.IsFriendsWith, lp, p.UserId)
				zy.fr[p.UserId] = ok and v == true
			end
			for _, x in zy.fr[p.UserId] == false and not zg(p) and zm(p, wi) and id ~= "" and cs:GetTagged("IslandRegion") or {} do
				if x:IsA("BasePart") and x:GetAttribute("islandId") == id and (x.Position - h.Position).Magnitude < x.Size.X / 2 then nr, zy.by = true, {p.Name, p.UserId, id, zy.wl[p.UserId]} end
			end
		end
	end
	return nr
end

local function zh()
	zy.nt = os.clock() + 30
	local b = zy.by or {}
	zx(`[Safe] Hop From {game.JobId:sub(1, 8)} | Real Player {b[1] or "?"} ({b[2] or "?"}) | Seen {b[4] == "Jump" and "Jumping" or "Walking"} | {b[3] or "?"} | {#game:GetService("Players"):GetPlayers()} Players`, true)
	local ok, r = pcall(function() return hs:JSONDecode((game :: any):HttpGet(`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Asc&limit=100`)) end)
	if not ok or type(r) ~= "table" or type(r.data) ~= "table" then return nil, "Hop Failed: Server List" end
	local o = {}
	for _, s in r.data do
		if type(s) == "table" and type(s.id) == "string" and s.id ~= game.JobId and tonumber(s.playing) and tonumber(s.maxPlayers) and s.playing < s.maxPlayers then table.insert(o, s.id) end
	end
	if #o == 0 then return nil, "Hop Failed: No Server" end
	local tp = game:GetService("TeleportService")
	local ds = o[math.random(1, math.min(5, #o))]
	zy.hp = os.clock()
	zx(`[Safe] Teleporting To {ds:sub(1, 8)}`, true)
	local tk, e = pcall(tp.TeleportToPlaceInstance, tp, game.PlaceId, ds, lp)
	if not tk then return nil, `Hop Failed: {e}` end
	task.wait(15)
	return nil, "Hop Failed: Teleport Timeout"
end

local function sa()
	local cs, n = game:GetService("CollectionService"), 0
	for _, x in cs:GetTagged("IslandRegion") do
		if x:IsA("BasePart") then sq(Vector3.new(x.Position.X, 2, x.Position.Z), 10) end
	end
	for _, x in cs:GetTagged("BossRegion") do
		if x:IsA("BasePart") then n += 1 end
	end
	return n
end

local function bq()
	local ev, pl, up, sa, ek, ew = rv.EventController and rv.EventController._active_events, md("Data", "Catalog", "Boss").Pools, false, nil, nil, nil
	for k, v in type(ev) == "table" and ev or {} do
		if pl[k] then
			local t = type(v) == "table" and tonumber(v.started_at)
			up, sa = true, t and math.max(sa or 0, t) or sa
			if not ew or t and t >= (tonumber(ew.started_at) or 0) then ek, ew = k, type(v) == "table" and v or {} end
		end
	end
	return up, sa, ek, ew
end

local function br(f)
	if not bq() then
		f.bx = nil
		return nil
	end
	local function fd()
		local n = 0
		for _, x in game:GetService("CollectionService"):GetTagged("BossRegion") do
			local fx = x:IsA("BasePart") and x:FindFirstChild("BossSpawnerFX")
			n += 1
			if fx and fx:GetAttribute("BossSpawnerFXActive") == true and x ~= f.bx then return x, n end
		end
		return nil, n
	end
	local x, n = fd()
	if x or n >= 12 or os.clock() < (f.sc or 0) then return x end
	for _, z in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if f.st ~= "Running" then break end
		if z:IsA("BasePart") then
			sq(Vector3.new(z.Position.X, 2, z.Position.Z), 10)
			x = fd()
			if x then return x end
		end
	end
	f.sc = os.clock() + 5
	return nil
end

local function zd(m)
	local mn = m and m:FindFirstChild("Main")
	if not mn then return nil end
	local cf, sz, rp, st, pt, bn = mn.CFrame, mn.Size, RaycastParams.new(), {}, {}, {}
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {m}
	for _, x in m:GetDescendants() do
		if x:IsA("Seat") or x:IsA("VehicleSeat") then table.insert(st, x) end
	end
	for z = 0, sz.Z / 2, 0.5 do
		for x = -sz.X / 2, sz.X / 2, 0.5 do
			local o = cf:PointToWorldSpace(Vector3.new(x, 0, z))
			local h = workspace:Raycast(Vector3.new(o.X, cf.Position.Y + 20, o.Z), Vector3.new(0, -40, 0), rp)
			if h and h.Instance.CanCollide and h.Normal.Y > 0.95 then
				local k = math.floor(h.Position.Y * 2 + 0.5)
				bn[k] = (bn[k] or 0) + 1
				table.insert(pt, {h.Position, k})
			end
		end
	end
	local fk, fn = nil, 0
	for k, n in bn do
		if n > fn then fk, fn = k, n end
	end
	local c, b, bd = cf:PointToWorldSpace(Vector3.new(0, 0, sz.Z / 4)), nil, math.huge
	for _, v in pt do
		if math.abs(v[2] - fk) <= 1 then
			local fr = true
			for _, q in st do
				local l = q.CFrame:PointToObjectSpace(v[1])
				if math.abs(l.X) < q.Size.X / 2 + 0.75 and math.abs(l.Z) < q.Size.Z / 2 + 0.75 then fr = false; break end
			end
			local d = ((v[1] - c) * Vector3.new(1, 0, 1)).Magnitude
			if fr and d < bd then b, bd = v[1], d end
		end
	end
	return b
end

local function oz(m)
	local _, r, h = lc()
	if not (r and m and m.Parent) or h.SeatPart or rv.Swimming and rv.Swimming:IsSwimming() then return false end
	local rp = RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {m}
	return workspace:Raycast(r.Position, Vector3.new(0, -6, 0), rp) ~= nil
end

local function sd(f, m)
	local p = zd(m)
	if not p then return false end
	local g = gf(f, p + Vector3.new(0, 3, 0))
	if not g or f.st ~= "Running" then return false end
	if not mo(p + Vector3.new(0, 3, 0), 30) then return false end
	task.wait(1)
	return oz(m)
end

local function bw(f)
	local _, r = lc()
	if not r then return nil, "No Character" end
	local x = f.br
	local id = x and x.Parent and x.Parent.Parent and x.Parent.Parent.Name or ic()
	local np = ns("npc_fish_seller", r.Position)
	if not np and rg(id) then
		sq(Vector3.new(rg(id).X, 2, rg(id).Z), 10)
		np = ns("npc_fish_seller", r.Position)
	end
	if not np then return nil, "No Fish Seller" end
	local w = workspace:FindFirstChild("World")
	local il, ip = w and w:FindFirstChild("Islands"), RaycastParams.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	local d = (r.Position - np) * Vector3.new(1, 0, 1)
	local u, pt = d.Magnitude > 1 and d.Unit or Vector3.xAxis, nil
	for k = 10, math.max(300, d.Magnitude), 5 do
		local q = np + u * k
		if not workspace:Raycast(Vector3.new(q.X, 103, q.Z), Vector3.new(0, -100, 0), ip) then
			pt = q
			break
		end
	end
	if not pt then return nil, "No Water Near Fish Seller" end
	zx(`[Boss] Satchel Full, Sell Trip | Seller {zn(np)} | Water {zn(pt)}`)
	local m, e = gb(f, f.bk())
	if not m then return nil, e end
	local ok
	ok, e = sb(f, m)
	if not ok then return nil, e end
	ok, e = dv(f, m, id, pt)
	if ok then sd(f, m) end
	return ok, e
end

local function hz(f, y)
	local _, r = lc()
	if not r then return nil, "No Character" end
	local function sw() return rv.Swimming and rv.Swimming:IsSwimming() end
	if cj and not cj.dn and not sw() and r.Position.Y > y - 2 then return true end
	local j, e = mo(Vector3.new(r.Position.X, y, r.Position.Z), 30)
	if not j then return nil, e end
	local dl = os.clock() + 4
	repeat task.wait(0.1) until j.st == "Arrived" and not sw() or j.dn or f.st ~= "Running" or os.clock() > dl
	if j.dn then return nil, j.why or "Hover Failed" end
	if f.st ~= "Running" then return nil end
	if sw() then return nil, "Hover Failed: Still Swimming" end
	return true
end

local function bo(f)
	local x
	if f.rn() and ul("island_lotus") and os.clock() >= (f.bl or 0) then
		local cf, nw = md("Data", "Config", "SuperBossConfig").Bosses.celestial_rainbow, workspace:GetServerTimeNow()
		if (f.s.rt or 0) > 0 then zv(f, "rt", f.s.rt, `[Rainbow] Spawned Signal At {os.date("%H:%M:%S", f.s.rt)}`) end
		local w = workspace:FindFirstChild("World")
		local il = w and w:FindFirstChild("Islands") and w.Islands:FindFirstChild("island_lotus")
		local sb = il and il:FindFirstChild("SuperBoss")
		if il and not sb and nw - (f.s.rt or -1e9) < cf.lifetimeSeconds and os.clock() >= (f.rs or 0) then
			f.rs = os.clock() + 10
			sq(Vector3.new(1143, 2, 2674), 10)
			sb = il:FindFirstChild("SuperBoss")
		end
		for _, y in sb and sb:GetChildren() or {} do
			local fx = y:IsA("BasePart") and y:FindFirstChild("BossSpawnerFX")
			if fx and fx:GetAttribute("BossSpawnerFXActive") == true then x = y end
		end
		local sc = (pd().SuperBoss or {})[cf.id] or {}
		if x and md("Shared", "Lib", "raidWindow").Used(sc.JoinWindowStart or 0, sc.JoinCount or 0, nw, md("Data", "Config", "SuperBossConfig").WindowSeconds) >= cf.joinsPerWindow then
			zv(f, "bs", "rnone", "[Rainbow] Skip: No Attempts Left Today")
			x = nil
		end
	end
	if not x and not f.ab() then return nil end
	if not x then
		local up, sa, ek, ew = bq()
		if f.s.bv ~= nil then
			zx(`[Boss] Server Claim Signal: {tostring(f.s.bv)}`)
			f.s.bv = nil
		end
		if not up then
			f.s.bc = false
			if (tonumber(pd().LastBossKillSlot) or 0) < workspace:GetServerTimeNow() // 2400 * 2400 and os.clock() >= (f.bl or 0) then f.bx = nil end
			zv(f, "bs", "none", "[Boss] No Boss Event")
			return nil
		end
		local ex = ew and math.max(tonumber(ew.expire_at) or 0, tonumber(ew.admin_override_expire_at) or 0) or 0
		zv(f, "be", `{ek}{sa}`, `[Boss] Event {ek} | Started {sa and os.date("%H:%M:%S", sa) or "?"} | Ends {ex > 0 and os.date("%H:%M:%S", ex) or "?"}{ew and ew.admin_override_expire_at and " | Admin" or ""}`)
		local lk, ws = tonumber(pd().LastBossKillSlot) or 0, sa or workspace:GetServerTimeNow() // 2400 * 2400
		if f.s.bc then
			zv(f, "bs", "claimed", "[Boss] Skip: Server Says Claimed")
			return nil
		end
		if lk >= ws then
			zv(f, "bs", `killed{ws}`, `[Boss] Skip: Already Killed This Window (Last Kill {lk} >= Start {ws})`)
			return nil
		end
		if os.clock() < (f.bl or 0) then
			zv(f, "bs", `lock{f.bl}`, `[Boss] Skip: Miss Lockout {math.ceil(f.bl - os.clock())} s Left`)
			return nil
		end
		x = br(f)
		if not x then
			zv(f, "bs", "nf", `[Boss] Skip: Active Region Not Found ({#game:GetService("CollectionService"):GetTagged("BossRegion")} Regions Loaded)`)
			return nil
		end
	end
	local id, q = x.Parent and x.Parent.Parent and x.Parent.Parent.Name, Vector3.new(x.Position.X, 3, x.Position.Z)
	local _, r, h = lc()
	if not r then return nil, "No Character" end
	zv(f, "bs", `x{x:GetFullName()}`, `[Boss] Active Region {x.Name} On {id or "?"} | Center {zn(q)} | Me {zn(r.Position)} On {ic() ~= "" and ic() or "Sea"}`)
	f.br = x
	local sw = rv.Swimming and rv.Swimming:IsSwimming()
	local cm = workspace:FindFirstChild("Cars")
	cm = cm and cm:FindFirstChild(tostring(lp.UserId))
	local cn = cm and cm:FindFirstChild("Main") and ((cm.Main.Position - q) * Vector3.new(1, 0, 1)).Magnitude <= 50
	if (((r.Position - q) * Vector3.new(1, 0, 1)).Magnitude <= 45 or cn and oz(cm)) and not h.SeatPart then
		if cn and (oz(cm) and cj and not cj.dn or sd(f, cm)) then
			f.bm = cm
			pq(cm, false)
			zv(f, "bp", "deck", `[Boss] At Spot On Boat Deck | {zn(r.Position)}`)
			return q
		end
		if f.st ~= "Running" then return nil end
		local ok, e = hz(f, q.Y + 9)
		if not ok then return nil, e end
		zv(f, "bp", "hover", `[Boss] At Spot Hovering | {zn(r.Position)}{cn and " | Deck Failed" or " | No Boat Near"}`)
		return q
	end
	f.zv.bp = nil
	if not (f.hm or f.bb or sw or h.SeatPart) and ic() ~= "" and f.ao() and zb(f.sr(), f.kp()) > 0 then
		local hd, sf = tr(f)
		zx(`[Boss] Sell Before Boss: {hd or sf or "Done"}`)
		if f.st ~= "Running" then return nil end
		_, r, h = lc()
		if not r then return nil, "No Character" end
	end
	if not (f.hm or f.bb or sw or h.SeatPart) and ic() ~= "" then
		f.hm = {r.CFrame, ic()}
		zx(`[Boss] Home Saved {ic()} | {zn(r.Position)}`)
	end
	if f.bg ~= x then
		f.bg = x
		zx(`[Boss] Going To {x.Name} On {id or "?"}`)
	end
	if id and ic() ~= id and (wx(f, id) or not ul(id) and wn(f, q, id)) then
		_, r, h = lc()
		if not r then return nil, "No Character" end
	end
	if f.st ~= "Running" then return nil end
	local d = (r.Position - q) * Vector3.new(1, 0, 1)
	local m, e = gb(f, f.bk())
	if not m then return nil, e end
	local ok
	ok, e = sb(f, m)
	if not ok then return nil, e end
	local w, cs = workspace:FindFirstChild("World"), workspace:FindFirstChild("Cars")
	local il, ip, a0, pt = w and w:FindFirstChild("Islands"), RaycastParams.new(), math.floor(lp.UserId * 0.6180339887 % 1 * 8), nil
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for i = 0, 7 do
		local p, fr = q + Vector3.new(math.sin((a0 + i) * math.pi / 4), 0, math.cos((a0 + i) * math.pi / 4)) * 40, true
		for _, x in cs and cs:GetChildren() or {} do
			local mn = x.Name ~= tostring(lp.UserId) and x:FindFirstChild("Main")
			if mn and ((mn.Position - p) * Vector3.new(1, 0, 1)).Magnitude < 28 then fr = false; break end
		end
		if fr and (not il or not workspace:Raycast(p + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), ip)) then pt = p; break end
	end
	ok, e = dv(f, m, id, pt or q + (d.Magnitude > 1 and d.Unit or Vector3.xAxis) * 40)
	if not ok then return nil, e end
	f.bb = true
	if sd(f, m) then
		f.bm = m
		pq(m, false)
		zx(`[Boss] Trip Done, On Boat Deck | {zn(m.Main.Position)}{pt and "" or " | No Free Spot, Fallback"}`)
		return q
	end
	if f.st ~= "Running" then return nil end
	ok, e = hz(f, q.Y + 9)
	if not ok then return nil, e end
	zx(`[Boss] Trip Done, Deck Failed, Hovering | {zn(q)}`)
	return q
end

local qd = {
	{"unlock_island_2", "island_starter", "island_jungle", "Jungle Island", {RequiredCoin = 40000}},
	{"unlock_island_3", "island_jungle", "island_desert", "Desert Island", {RequiredCoin = 180000}},
	{"unlock_island_4", "island_desert", "island_snow", "Snow Island", {RequiredCoin = 900000, RequiredFish = 3}, {"Legendary", "island_desert"}},
	{"unlock_island_5", "island_snow", "island_volcano", "Volcanic Island", {RequiredCoin = 4000000, RequiredFishes = {frozen_crown_dragonfish = 1, frosttusk_seal = 1, frostmaw_monster = 1}}},
	{"unlock_island_6", "island_volcano", "island_fossil", "Fossil Island", {RequiredCoin = 15000000, RequiredFishes = {ancient_trihorn_fish = 1, stormblade_shark = 1, lavascale_dragonfish = 1}}},
}

local qt, qz, qm = {
	{"crimson_bead_rod", "island_volcano", "island_volcano", "Crimson Bead Rod", {RequiredFished = 0}, nil, "legacy_rod"},
	{"bamboo_rod", "island_volcano", "island_volcano", "Bamboo Rod", {RequiredBamboo = 0}, nil, "crimson_bead_rod", "island_jungle"},
	{"heaven_piercer_turtle_rod", "island_fossil", "island_fossil", "Heaven Piercer Turtle Rod", {RequiredFish = 0}, {"Legendary", "island_fossil"}, nil, "island_fossil"},
	{"zen_staff_rod", "island_fossil", "island_fossil", "Zen Staff Rod", {RequiredFish = 0}, nil, nil, "island_fossil"},
	{"dread_fish_rod", "island_fossil", "island_fossil", "Dread Fish Rod", {RequiredFish = 0}, {"Mythical", "island_fossil"}, nil, "island_fossil"},
	{"taiji_hooking_art_v2", "island_snow", "island_snow", "Taiji Hooking Art V2 Upgrade", {RequiredKills = 0}, nil, nil, nil, nil, nil, nil, nil, true},
	{"godslayer_rod_chain", "island_lotus", "island_lotus", "Godslayer Rod Chain", {}, nil, nil, nil, nil, {
		{"godslayer_rod_v1_inheritance", "island_lotus", "island_lotus", "Godslayer Rod V1", {RequiredFish = 0}, nil, nil, "island_lotus"},
		{"golden_beast_rod_inheritance", "island_lotus", "island_lotus", "Golden Beast Rod", nil, nil, nil, "island_lotus"},
		{"diamond_dragon_rod_inheritance", "island_lotus", "island_lotus", "Diamond Dragon Rod"},
		{"godslayer_rod_v2_inheritance", "island_lotus", "island_lotus", "Godslayer Rod V2", {}, nil, nil, nil, nil, nil, "island_snow"},
	}},
	{"heaven_earth_reversal", "island_volcano", "island_volcano", "Heaven & Earth Reversal", {}, nil, nil, "island_volcano", nil, nil, nil, true},
	{"taiji_nine_palaces_hook", "island_fossil", "island_fossil", "Taiji Nine Palaces Hook", {}, nil, nil, "island_fossil", nil, nil, "island_snow", true},
	{"one_hook_supreme_v2", "island_desert", "island_desert", "One Hook Supreme V2 Upgrade", {}, nil, nil, "island_desert", nil, nil, nil, true},
	{"rod_gate_70_percent", "island_starter", "island_fossil", "Rod Gate 70% Upgrade", {}, nil, nil, "*", nil, nil, nil, true},
	{"primordial_eight_trigrams_art", "island_snow", "island_snow", "Primordial Eight Trigrams Art", {}, nil, nil, "*", nil, nil, nil, true},
	{"ultimate_taiji_nine_palaces", "island_lotus", "island_snow", "Ultimate Taiji Nine Palaces Hook Art", {}, nil, nil, "*", nil, nil, nil, true},
	{"triple_break", "island_starter", "island_fossil", "Triple Break", {}, nil, nil, "*", nil, nil, nil, true},
}, {}, {}
for _, q in qt do
	if not (q[12] or q[13]) then table.insert(qz, q[4]) end
	qm[q[4]] = q
end

local qg, qgz = {
	{"white_tiger", "island_desert", "island_desert", "White Tiger Soul", {RequiredFish = 3}, {"Legendary", "island_desert", 1000}, nil, "island_desert", true},
	{"phoenix", "island_snow", "island_snow", "Phoenix Soul", {RequiredFish = 3}, {"Legendary", "island_snow"}, nil, "island_snow", true},
	{"azure_dragon", "island_volcano", "island_volcano", "Azure Dragon Soul", {RequiredFish = 0, CatchWithSkill = 0}, {"Legendary", "island_volcano"}, nil, "island_volcano", true},
	{"supreme_king", "island_fossil", "island_fossil", "Supreme King Soul", {CatchWithSkill = 0, RequiredBooks = {}}, nil, nil, "island_fossil", true},
}, {}
for _, q in qg do table.insert(qgz, q[4]) end

local function qe(id, p)
	local r, c = table.clone(type(p) == "table" and p or {}), (md("Data", "Config", "QuestConfig").Data or {})[id]
	if not c then return r end
	local function st(k, v) if k ~= nil and v ~= nil and r[k] == nil then r[k] = v end end
	st("RequiredCoin", c.cost and c.cost.coin)
	st("RequiredFish", c.fish and c.fish.count)
	st("RequiredFishes", c.namedFish)
	st("RequiredBooks", c.books)
	st("RequiredBookCount", c.books and c.books.taiji_hooking_art)
	st("RequiredBamboo", c.items and c.items.bamboo_fragment)
	st("RequiredGem", c.cost and c.cost.gem)
	st("RequiredAny", c.fishAny)
	st("RequiredWeights", c.namedFishMinWeight)
	st("RequiredItems", c.items)
	st("Tr", c.tracker and {c.tracker} or c.trackers)
	if c.tracker then st(({CurrentFished = "RequiredFished", CurrentFish = "RequiredFish", CurrentKills = "RequiredKills", CurrentUsedSkill = "CatchWithSkill"})[c.tracker.field], c.tracker.target) end
	return r
end

local function qc(q, d, pr)
	local ct, n, ks, df, id, rr, qf = md("Data", "Catalog"), {}, {}, {}, q[1], q[6], md("Data", "Config", "QuestConfig")
	local wk, sw, fa = id == "unlock_island_6" and qf.UnlockIsland6MinWeightKg or pr.RequiredWeights or {}, ((qf.Data or {})[id] or {}).namedFishStrictWeight == true, pr.RequiredAny
	local function wo(x)
		local w, v = wk[x.fishId], x.weight or 0
		if not w then return id ~= "unlock_island_6" end
		return sw and v > w or not sw and v >= w
	end
	if rr then
		for _, x in (ct.Island.GetById(rr[2]) or {}).fishes or {} do df[x.fishId] = true end
	end
	local rf = rr and {["*"] = pr.RequiredFish or 1} or pr.RequiredFishes or {}
	for u, x in d.Inventory and d.Inventory.Fishes or {} do
		local fi = ct.Fish.GetById(x.fishId)
		local k = rr and fi and fi.rarity == rr[1] and df[x.fishId] and (x.weight or 0) >= (rr[3] or 0) and "*" or not rr and rf[x.fishId] and wo(x) and x.fishId
		if k and (n[k] or 0) < rf[k] then n[k], ks[u] = (n[k] or 0) + 1, true end
	end
	local ok, na = (d.Coin or 0) >= (pr.RequiredCoin or 0) and (d.Gem or 0) >= (pr.RequiredGem or 0), 0
	for k, v in rf do
		if (n[k] or 0) < v then ok = false end
	end
	if type(fa) == "table" then
		for _, lk in {false, true} do
			for u, x in d.Inventory and d.Inventory.Fishes or {} do
				local fi = ct.Fish.GetById(x.fishId)
				if na < (fa.count or 1) and not ks[u] and (x.locked == true) == lk and fi and (not fa.kind or fi.kind == fa.kind) and (not fa.rarity or fi.rarity == fa.rarity) and (not fa.minWeightExclusive or (x.weight or 0) > fa.minWeightExclusive) then na, ks[u] = na + 1, true end
			end
		end
		if na < (fa.count or 1) then ok = false end
	end
	if id == "crimson_bead_rod" and (pr.CurrentFished or 0) < (pr.RequiredFished or 1) then ok = false end
	if (id == "zen_staff_rod" or id == "godslayer_rod_v1_inheritance") and (pr.CurrentFish or 0) < (pr.RequiredFish or 1) then ok = false end
	if id == "bamboo_rod" and md("Shared", "getItemCount")(d, "bamboo_fragment") < (pr.RequiredBamboo or 1) then ok = false end
	if id == "taiji_hooking_art_v2" and ((pr.CurrentKills or 0) < (pr.RequiredKills or 1) or (((d.Inventory or {}).Books or {}).taiji_hooking_art or 0) < (pr.RequiredBookCount or 1)) then ok = false end
	if (id == "azure_dragon" or id == "supreme_king") and (pr.CurrentUsedSkill or 0) < (pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5)) then ok = false end
	if id == "phoenix" or id == "supreme_king" or id == "godslayer_rod_v2_inheritance" then
		for b, v in id == "phoenix" and qf.PhoenixRequiredBooks or id == "supreme_king" and (pr.RequiredBooks or {rod_gate_20_percent = 1}) or pr.RequiredBooks or {} do
			if (((d.Inventory or {}).Books or {})[b] or 0) < v then ok = false end
		end
	end
	if q[12] then
		for b, v in pr.RequiredBooks or {} do
			if (((d.Inventory or {}).Books or {})[b] or 0) < v then ok = false end
		end
		for k, v in pr.RequiredItems or {} do
			if md("Shared", "getItemCount")(d, k) < v then ok = false end
		end
		for _, t in pr.Tr or {} do
			if (tonumber(pr[t.field]) or 0) < t.target then ok = false end
		end
	end
	return ok, ks
end

local function qn(f)
	for _, q in qd do
		if not ul(q[3]) then return ul(q[2]) and not f.qx[q[1]] and q or nil end
	end
	return nil
end

local function qw(f, k, t, h)
	if f.qw[k] then return end
	f.qw[k], f.nq = true, {Title = h or "Rod Quest", Text = t}
end

local function qp(f)
	local q, d = f.qs(), pd()
	if not q or f.qx[q[1]] then return nil end
	if q[10] then
		local ir, c, ci = md("Shared", "Lib", "questRules").IsCompleted, q[10], ((d.Quest or {}).Current or {}).Id
		local x = not ir(d, c[1][1]) and c[1] or nil
		for _, y in x and {} or c do
			if y[1] == ci and not ir(d, ci) then x = y end
		end
		for i = 2, 3 do
			if not x and not ir(d, c[i][1]) and qc(c[i], d, qe(c[i][1], {})) then x = c[i] end
		end
		x = x or not ir(d, c[2][1]) and c[2] or not ir(d, c[3][1]) and c[3] or not ir(d, c[4][1]) and c[4] or nil
		if not x then
			f.qx[q[1]], f.nq = true, {Title = "Rod Quest", Text = `{q[4]} Already Done`}
			return nil
		end
		if not ul(x[2]) then return qw(f, `i{q[1]}`, `Rod Quest Waiting: Island Locked`) end
		if x[1] == "diamond_dragon_rod_inheritance" and not f.ab() then qw(f, `a{x[1]}`, "Rod Quest Waiting: Turn On Auto Boss For Boss Fish") end
		if x[1] == "godslayer_rod_v2_inheritance" and (((d.Inventory or {}).Books or {}).ultimate_taiji_nine_palaces or 0) < 1 then return qw(f, `b{x[1]}`, "Rod Quest Waiting: No Ultimate Taiji Nine Palaces Hook Art Book") end
		q = x
		if f.qx[q[1]] then return nil end
	end
	if d.Quest and d.Quest.Done and d.Quest.Done[q[1]] then
		f.qx[q[1]], f.nq = true, {Title = "Rod Quest", Text = `{q[4]} Already Done`}
		return nil
	end
	if not ul(q[2]) then return qw(f, `i{q[1]}`, `Rod Quest Waiting: Island Locked`) end
	if q[7] and not (d.Rods and d.Rods[q[7]]) then return qw(f, `r{q[1]}`, `Rod Quest Waiting: No {q[7] == "legacy_rod" and "Legacy Rod" or "Crimson Bead Rod"}`) end
	if q[1] == "taiji_hooking_art_v2" and (((d.Inventory or {}).Books or {}).taiji_hooking_art or 0) < 1 then return qw(f, `b{q[1]}`, "Rod Quest Waiting: No Taiji Hooking Art Book") end
	local cq = (d.Quest or {}).Current or {}
	if q[12] and cq.Id == q[1] then
		local pr = qe(q[1], cq.Progress)
		for _, t in pr.Tr or {} do
			if t.rodId and not (d.Rods or {})[t.rodId] and (tonumber(pr[t.field]) or 0) < t.target then qw(f, `r{q[1]}`, `Rod Quest Waiting: No {(md("Data", "Catalog").Rod.GetById(t.rodId) or {}).name or t.rodId}`) end
			if t.islandId and not ul(t.islandId) and (tonumber(pr[t.field]) or 0) < t.target then qw(f, `l{q[1]}{t.islandId}`, `Rod Quest Waiting: {q[4]} Needs {(md("Data", "Catalog").Island.GetById(t.islandId) or {}).name or t.islandId} Unlocked`) end
			if t.raid == true and (tonumber(pr[t.field]) or 0) < t.target then qw(f, `s{q[1]}`, `Rod Quest Waiting: {q[4]} Needs {t.target} {(md("Data", "Catalog").Skill.GetById(t.skillId or "") or {}).name or "Skill"} Uses In A Sea Raid`) end
			if t.fishKind == "Boss" and not (f.ab() or f.rn()) and (tonumber(pr[t.field]) or 0) < t.target then qw(f, `k{q[1]}`, "Rod Quest Waiting: Turn On Auto Boss Or Auto Rainbow Boss") end
		end
		local c4 = (md("Data", "Config", "QuestConfig").Data or {})[q[1]] or {}
		for _, x in c4.drops or {} do
			if x.fishId and md("Shared", "getItemCount")(d, x.itemId) < ((c4.items or {})[x.itemId] or 1) and not (x.fishId == "celestial_rainbow" and f.rn() or x.fishId ~= "celestial_rainbow" and f.ab()) then qw(f, `d{x.itemId}`, `Rod Quest Waiting: Turn On {x.fishId == "celestial_rainbow" and "Auto Rainbow Boss" or "Auto Boss"} For {(md("Data", "Catalog").Material.GetById(x.itemId) or {}).name or x.itemId}`) end
		end
	end
	return q
end

local function qk(d, ys)
	local r, dn, so = {}, (d.Quest or {}).Done or {}, (d.Inventory or {}).Souls or {}
	for _, q in qg do
		if table.find(ys or {}, q[4]) and not dn[q[1]] and so[q[1]] ~= true then table.insert(r, q) end
	end
	return r
end

local function qy(f)
	local d = pd()
	local cq = (d.Quest or {}).Current or {}
	local ls = qk(d, f.ys())
	for i, q in ls do
		if q[1] == cq.Id then table.insert(ls, 1, table.remove(ls, i)); break end
	end
	for _, q in ls do
		local id, pr = q[1], cq.Id == q[1] and qe(q[1], cq.Progress) or {}
		local fb = (pr.CurrentUsedSkill or 0) < (pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5))
		local mb = {}
		for b, v in id == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or id == "supreme_king" and not fb and (pr.RequiredBooks or {rod_gate_20_percent = 1}) or {} do
			if (((d.Inventory or {}).Books or {})[b] or 0) < v then table.insert(mb, (md("Data", "Catalog").Skill.GetById(b) or {}).name or b) end
		end
		table.sort(mb)
		if f.qx[id] then
			continue
		elseif not ul(q[2]) then
			qw(f, `yi{id}`, `Soul Quest Waiting: {q[4]} Island Locked`, "Soul Quest")
		elseif #mb > 0 then
			qw(f, `yb{id}`, `Soul Quest Waiting: {q[4]} Needs Books: {table.concat(mb, ", ")}`, "Soul Quest")
		elseif fb and (id == "azure_dragon" or id == "supreme_king") and (((d.Inventory or {}).Books or {})[id == "azure_dragon" and "one_hook_supreme" or "rod_gate_20_percent"] or 0) < 1 then
			qw(f, `ye{id}`, `Soul Quest Waiting: No {id == "azure_dragon" and "One Hook Supreme" or "Rod Gate 20%"} Book`, "Soul Quest")
		else
			return q
		end
	end
	return nil
end

local function qv(q)
	local d = pd()
	if not q then return {} end
	local cq = d.Quest and d.Quest.Current
	local _, ks = qc(q, d, cq and cq.Id == q[1] and qe(q[1], cq.Progress) or q[5] or qe(q[1], {}))
	return ks
end

local function gn(q, ni, il)
	local id, g = ni or ((md("Data", "Config", "QuestConfig").Data or {})[q[1]] or {}).npcId or `npc_{q[1]}`, rg(il or q[3])
	local p = ns(id, Vector3.zero)
	if not p and g then
		sq(Vector3.new(g.X, 2, g.Z), 10)
		p = ns(id, Vector3.zero)
	end
	return p
end

local function ub(b, v)
	local d = pd()
	local nd, re, li = v - md("Utils", "skillBookAvailability").GetCounts(d, b).available, d.Rods and d.Rods[d.RodEquip], nil
	for s, id in re and re.BookSlots or {} do
		if nd > 0 and id == b then
			local i = tonumber(tostring(s):match("%d+"))
			local x = i and rv.EquipmentsController.EquipMoveset:Fire("", i)
			if x ~= "Success" then return nil, `Unequip Book Failed: {x or "No Response"}` end
			local dl = os.clock() + 3
			repeat task.wait(0.2) until (((pd().Rods or {})[d.RodEquip] or {}).BookSlots or {})[s] ~= b or os.clock() > dl
			nd, li = nd - 1, i
			zx(`[Gear] Turn In Book Off {d.RodEquip} Slot{i}: {b}`)
		end
	end
	if nd > 0 then return nil, "Unequip Book Failed: Book On Another Rod" end
	return true, nil, li
end

local function uz(f, q, ac)
	local qr, iu = rv.QuestController, q[1]:find("^unlock_island_") ~= nil
	local tt, px = iu and "Island Guide" or q[9] and "Soul Quest" or "Rod Quest", iu and "Unlock Island Failed" or q[9] and "Soul Quest Failed" or "Rod Quest Failed"
	local rw2 = ((((md("Data", "Config", "QuestConfig").Data or {})[q[1]] or {}).reward or {}).book) or ""
	local function vb() return ((pd().Inventory or {}).Books or {})[rw2] or 0 end
	local v0 = vb()
	local function dn() return md("Shared", "Lib", "questRules").IsCompleted(pd(), q[1]) or rw2 ~= "" and vb() > v0 or q[9] and ((pd().Inventory or {}).Souls or {})[q[1]] == true end
	if not ac then
		local a, m = qr:Accept(q[1])
		zx(`[Quest] Accept {q[1]}: {tostring(a)} {m or ""}`)
		if a ~= true then
			f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {m or "Accept Refused"}`}
			return true
		end
		local dl = os.clock() + 3
		repeat task.wait(0.2) until (pd().Quest or {}).Current and pd().Quest.Current.Id == q[1] or os.clock() > dl
		local cq = (pd().Quest or {}).Current
		if not (cq and cq.Id == q[1]) then return nil, "Quest Not Saved" end
		if q[11] then
			f.nq = {Title = tt, Text = `{q[4]} Quest Accepted`}
			return true
		end
		if not qc(q, pd(), qe(q[1], cq.Progress)) then
			f.nq = {Title = tt, Text = `{q[4]} Quest Accepted, Requirements Not Met`}
			return true
		end
	end
	local cq = (pd().Quest or {}).Current
	local _, ks = qc(q, pd(), cq and cq.Id == q[1] and qe(q[1], cq.Progress) or q[5] or qe(q[1], {}))
	for u in ks do
		local x = pd().Inventory.Fishes[u]
		if x and x.locked == true then
			local s, v = rv.SellController:ToggleLock(u)
			if s ~= 0 or v ~= false then
				f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: Unlock Fish Failed`}
				return true
			end
		end
	end
	local bi2
	for b, v in q[1] == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or qe(q[1], cq and cq.Id == q[1] and cq.Progress or {}).RequiredBooks or {} do
		local bo2, be2, bs2 = ub(b, v)
		if not bo2 then
			f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {be2}`}
			return true
		end
		if b == "taiji_hooking_art" then bi2 = bs2 end
	end
	local cp, m = qr:Complete(q[1])
	zx(`[Quest] Complete {q[1]}: {tostring(cp)} {m or ""}`)
	if cp ~= true then
		f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {m or "Complete Refused"}`}
		return true
	end
	local dl = os.clock() + 5
	repeat task.wait(0.2) until dn() or os.clock() > dl
	if not dn() then
		f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: Not Completed`}
		return true
	end
	if q[1] == "taiji_hooking_art_v2" then
		f.qx[q[1]] = true
		local d2 = pd()
		for sl, x in ((d2.Rods or {})[d2.RodEquip] or {}).BookSlots or {} do
			if not bi2 and x == "taiji_hooking_art" then bi2 = tonumber(tostring(sl):match("%d+")) end
		end
		local x = bi2 and rv.EquipmentsController.EquipMoveset:Fire("taiji_hooking_art_v2", bi2)
		if bi2 and x ~= "Success" then
			f.nq = {Title = tt, Text = `Got {q[4]}, Equip V2 Failed: {x or "No Response"}`}
			return true
		end
	end
	if q[9] and ({human = true, [""] = true})[pd().SoulEquip or ""] then
		local eo = rv.EquipmentsController.EquipmentEquip:Fire("soul", q[1])
		f.nq = {Title = tt, Text = eo == true and `Got {q[4]}, Equipped` or `Got {q[4]}, Equip Soul Failed`}
		return true
	end
	if q[12] then f.qx[q[1]] = true end
	f.nq = {Title = tt, Text = `{iu and "Unlocked" or "Got"} {q[4]}`}
	return true
end

local function ug(f, q, ac)
	local cd = (md("Data", "Config", "QuestConfig").Data or {})[q[1]] or {}
	local il, ni = ac and q[11] or q[3], ac and q[11] and cd.turnInNpcId or cd.npcId or `npc_{q[1]}`
	local ok, e = ti(f, il, f.bk())
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	local np = gn(q, ni, il)
	if not np then return nil, "No Island Guide" end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	ok, e = an(f, c, np, rt.Position)
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	if f.st ~= "Running" then return nil end
	return uz(f, q, ac)
end

local function uq(f, q)
	if not q then return nil end
	local d = pd()
	local cq = d.Quest and d.Quest.Current
	local ci = cq and cq.Id or ""
	local up, un, uc, cd = `Avenoric/Configs/FishingMaster/{lp.Name}_Unit.txt`, d.Units or {}, rv.UnitController, (md("Data", "Config", "QuestConfig").Data or {})[ci] or {}
	local ow, ue, uu = un.Owned or {}, un.Equipped or {}, (cd.tracker or {}).equippedUnitId or ((cd.drops or {})[1] or {}).equippedUnitId
	if uu and q[1] == ci then
		local hv, cx, un2 = false, nil, (md("Data", "Catalog").Unit.GetById(uu) or {}).name or uu
		for _, u in ue do
			if (ow[u] or {}).UnitId == uu then hv = true end
		end
		for u, x in ow do
			if not cx and x.UnitId == uu then cx = u end
		end
		if not hv and not cx then return qw(f, `uc{uu}`, `Rod Quest Waiting: No {un2} Unit`) end
		if not hv then
			local ou, o0 = #ue >= (un.Capacity or 1) and ue[#ue] or "", nil
			if isfile and isfile(up) then
				local rk, s0 = pcall(readfile, up)
				o0 = rk and s0 and s0:match("^([^\n]*)\n")
			end
			if ou ~= "" then
				local ok, r = uc:Unequip(ou)
				zx(`[Unit] Unequip {(ow[ou] or {}).UnitId or ou} For {un2}: {tostring(ok)} {r or ""}`)
				if not ok then
					f.qx[q[1]], f.nq = true, {Title = "Rod Quest", Text = `Rod Quest Failed: Unequip Unit {r or "No Response"}`}
					return true
				end
			end
			pcall(writefile, up, `{o0 or ou}\n{cx}`)
			local ok, r = uc:Equip(cx)
			zx(`[Unit] Equip {un2}: {tostring(ok)} {r or ""}`)
			if not ok then
				if ou ~= "" then uc:Equip(ou) end
				if not o0 then pcall(delfile, up) end
				f.qx[q[1]], f.nq = true, {Title = "Rod Quest", Text = `Rod Quest Failed: Equip {un2} {r or "No Response"}`}
				return true
			end
			f.nq = {Title = "Rod Quest", Text = `{un2} Joined The Team`}
		end
	elseif not uu and not f.qw.ur and isfile and isfile(up) then
		local rk, s = pcall(readfile, up)
		local ou, cx = (rk and s or ""):match("^([^\n]*)\n([^\n]*)")
		local ok, r = true, nil
		if cx and table.find(ue, cx) then ok, r = uc:Unequip(cx) end
		if ok and ou and ou ~= "" and ow[ou] and not table.find((pd().Units or {}).Equipped or {}, ou) then ok, r = uc:Equip(ou) end
		zx(`[Unit] Restore {ou and (ow[ou] or {}).UnitId or "None"}: {tostring(ok)} {r or ""}`)
		if ok then
			pcall(delfile, up)
			f.nq = {Title = "Rod Quest", Text = "Unit Team Restored"}
		else
			qw(f, "ur", `Restore Unit Failed: {r or "No Response"}`)
		end
	end
	if ci ~= "" and ci ~= q[1] then return nil end
	local pr = ci == q[1] and qe(q[1], cq.Progress) or q[5] or qe(q[1], {})
	if not qc(q, d, pr) then
		if (q[1]:find("_inheritance$") or q[12]) and qc(q, d, setmetatable({RequiredCoin = 0, RequiredGem = 0, RequiredBooks = {}}, {__index = pr})) then
			local ms = {}
			if (d.Coin or 0) < (pr.RequiredCoin or 0) then table.insert(ms, `{pr.RequiredCoin} Coins`) end
			if (d.Gem or 0) < (pr.RequiredGem or 0) then table.insert(ms, `{pr.RequiredGem} Gems`) end
			for b, v in pr.RequiredBooks or {} do
				if (((d.Inventory or {}).Books or {})[b] or 0) < v then table.insert(ms, `{v} {(md("Data", "Catalog").Skill.GetById(b) or {}).name or b} Book`) end
			end
			qw(f, `m{q[1]}`, `Rod Quest Waiting: {q[4]} Needs {table.concat(ms, ", ")}`)
		end
		return nil
	end
	local _, rt = lc()
	if not rt then return nil, "No Character" end
	local o, oi = rt.CFrame, ic()
	zx(`[Quest] Trip {q[1]} To {ci == q[1] and q[11] or q[3]} | From {oi ~= "" and oi or "Sea"} | {ci == q[1] and "Accepted" or "Not Accepted"}`)
	local ok, e = ug(f, q, ci == q[1])
	local hk, he = true, nil
	if f.st == "Running" and oi ~= "" and ic() ~= oi then hk, he = ti(f, oi, f.bk()) end
	if hk and f.st == "Running" and ic() == oi and not f.hf() then hk, he = go(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
	zx(`[Quest] Trip {q[1]} End: {ok and "Ok" or e or "Stopped"} | Return {hk and "Ok" or he or "Stopped"}`)
	f.rp = f.rp or not hk
	return true, not ok and e or not hk and f.st == "Running" and (he or "Return Failed") or nil
end

local function lr(f, o, oi)
	local ok, e = true, nil
	if f.st == "Running" and oi ~= "" and ic() ~= oi then ok, e = ti(f, oi, f.bk()) end
	if ok and f.st == "Running" and ic() == oi and not f.hf() then ok, e = go(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
	f.rp = f.rp or not ok
	return ok, e
end

local function lz(f)
	local gp = Vector3.new(1125.1, 12, 2416.7)
	local ok, e = ti(f, "island_lotus", f.bk())
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	sq(gp, 10)
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	local np = ns("npc_unlock_island_7", gp) or gp
	ok, e = go(f, aq(c, np, rt.Position), Vector3.new(np.X - rt.Position.X, 0, np.Z - rt.Position.Z).Unit)
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	return f.st == "Running" or nil
end

local function lw(f)
	local ci, P = md("Shared", "getItemCount"), md("Stardust").Packet
	local cp, bf = P("Quest/CollectSnowFlower"):Response(P.Boolean8, P.String), 0
	zx(`[Lotus] Flowers Start | {ci(pd(), "snow_flower")} / 10`)
	while f.st == "Running" do
		local d = pd()
		local cq, ev = (d.Quest or {}).Current or {}, rv.EventController and rv.EventController._active_events
		local pr, n = cq.Progress or {}, ci(d, "snow_flower")
		if n >= 10 or cq.Id ~= "unlock_island_7" or pr.Step ~= 1 or not (type(ev) == "table" and ev.weather_rainbow_rain) then break end
		local wt = (pr.NextFlowerSpawnAt or 0) - workspace:GetServerTimeNow()
		if wt > 0 then
			task.wait(math.min(wt + 0.2, 6))
			continue
		end
		local function fp()
			local w = workspace:FindFirstChild("World")
			local sf = w and w:FindFirstChild("SnowFlowerSpawns")
			return sf and sf:FindFirstChild(tostring(pr.SpawnIndex))
		end
		local pt = fp()
		if not pt then
			sq(rg("island_snow") or Vector3.new(1310, 28, -361), 10)
			pt = fp()
		end
		if not (pt and pt:IsA("BasePart")) then return nil, `Lotus Flowers Failed: Spawn {pr.SpawnIndex} Missing` end
		local ok, e = go(f, pt.Position + Vector3.new(0, 3, 0))
		if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
		if f.st ~= "Running" then break end
		local a, m = cp:Fire()
		zx(`[Lotus] Flower {pr.SpawnIndex}: {tostring(a)} {m or ""}`)
		if a == true then
			bf = 0
			local dl = os.clock() + 3
			repeat task.wait(0.15) until ci(pd(), "snow_flower") > n or os.clock() > dl
		else
			bf += 1
			if bf >= 3 then return nil, `Lotus Flowers Failed: {m or "Refused"}` end
		end
		task.wait(0.8)
	end
	zx(`[Lotus] Flowers End | {ci(pd(), "snow_flower")} / 10`)
	return true
end

local function le()
	local d = pd()
	local cq = (d.Quest or {}).Current or {}
	return cq.Id == "unlock_island_7" and (cq.Progress or {}).Step == 2 and not ul("island_lotus") and md("Shared", "getItemCount")(d, "magma_essence") < 10
end

local function lq(f)
	if not (ul("island_fossil") and not ul("island_lotus")) or f.qx.unlock_island_7 then return nil end
	local d, ci = pd(), md("Shared", "getItemCount")
	local cq = (d.Quest or {}).Current or {}
	local ev = rv.EventController and rv.EventController._active_events
	local pr, n, m = cq.Progress or {}, ci(d, "snow_flower"), ci(d, "magma_essence")
	if cq.Id ~= "" and cq.Id ~= "unlock_island_7" then return nil end
	if cq.Id == "unlock_island_7" and pr.Step == 3 then
		local cs = ((md("Data", "Config", "QuestConfig").Data or {}).unlock_island_7 or {}).cost or {}
		local xg, xc, hg, hc = cs.gem or 200, cs.coin or 10000000, d.Gem or 0, d.Coin or 0
		if hg < xg or hc < xc then
			local function cm(x) return (tostring(math.floor(x)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")) end
			local ms = {}
			if hg < xg then table.insert(ms, `Gems {cm(hg)} / {cm(xg)}`) end
			if hc < xc then table.insert(ms, `Coins {cm(hc)} / {cm(xc)}`) end
			zv(f, "lq", `p{hg}{hc}`, `[Lotus] Step 3 | Not Enough {table.concat(ms, ", ")}`)
			qw(f, "l3", `Lotus Island Waiting: Not Enough {table.concat(ms, ", ")}`, "Island Guide")
			return nil
		end
	elseif cq.Id == "unlock_island_7" and pr.Step ~= 1 and not (pr.Step == 2 and m >= 10) then
		zv(f, "lq", `s{pr.Step}{m}`, pr.Step == 2 and `[Lotus] Step 2 | Magma Essence {m} / 10` or `[Lotus] Step {pr.Step} | Not Handled Yet`)
		return nil
	end
	local rn = type(ev) == "table" and ev.weather_rainbow_rain
	if cq.Id == "" and not rn then zv(f, "lq", "norain", "[Lotus] Accept Waiting: No Rainbow Rain") end
	local gt, wk = cq.Id == "" and rn or pr.Step == 1 and n >= 10 or pr.Step == 2 and m >= 10 or pr.Step == 3, cq.Id == "unlock_island_7" and pr.Step == 1 and n < 10 and rn
	if wk and (pr.WeatherSlot ~= math.floor(rn.started_at or 0) or type(pr.SpawnIndex) ~= "number" or pr.SpawnIndex < 1) then
		zv(f, "lq", `t{pr.WeatherSlot}{pr.SpawnIndex}{rn.started_at}`, `[Lotus] No Flower Target | Slot {pr.WeatherSlot} | Index {pr.SpawnIndex} | Rain {rn.started_at}`)
		wk = false
	end
	if not (gt or wk) then return nil end
	local _, rt = lc()
	if not rt then return nil, "No Character" end
	local o, oi = rt.CFrame, ic()
	local ok, e
	if wk then
		zx(`[Lotus] Flower Trip | {n} / 10 | From {oi ~= "" and oi or "Sea"}`)
		ok, e = true, nil
		if ic() ~= "island_snow" then ok, e = ti(f, "island_snow", f.bk()) end
		if ok and f.st == "Running" then ok, e = lw(f) end
	else
		zx(`[Lotus] Guide Trip | {cq.Id == "" and "Accept" or pr.Step == 3 and "Pay" or `Advance Step {pr.Step}`} | Flowers {n} | Essence {m} | From {oi ~= "" and oi or "Sea"}`)
		ok, e = lz(f)
		if ok then
			local qr = rv.QuestController
			if cq.Id == "" then
				local a, m = qr:Accept("unlock_island_7")
				zx(`[Quest] Accept unlock_island_7: {tostring(a)} {m or ""}`)
				if a ~= true then f.qx.unlock_island_7, f.nq = true, {Title = "Island Guide", Text = `Unlock Island Failed: {m or "Accept Refused"}`} end
				ok = a == true
			end
			local p2 = ((pd().Quest or {}).Current or {}).Progress or {}
			if ok and (p2.Step == 1 and ci(pd(), "snow_flower") >= 10 or p2.Step == 2 and ci(pd(), "magma_essence") >= 10) then
				local a, ms = qr:Advance("unlock_island_7")
				zx(`[Quest] Advance unlock_island_7 Step {p2.Step}: {tostring(a)} {ms or ""}`)
				if a ~= true then f.qx.unlock_island_7, f.nq = true, {Title = "Island Guide", Text = `Unlock Island Failed: {ms or "Advance Refused"}`} end
				local s0, dl = p2.Step, os.clock() + 3
				repeat task.wait(0.2) until a ~= true or (((pd().Quest or {}).Current or {}).Progress or {}).Step ~= s0 or os.clock() > dl
				p2 = ((pd().Quest or {}).Current or {}).Progress or {}
			end
			local cs = ((md("Data", "Config", "QuestConfig").Data or {}).unlock_island_7 or {}).cost or {}
			if ok and p2.Step == 3 and (pd().Gem or 0) >= (cs.gem or 200) and (pd().Coin or 0) >= (cs.coin or 10000000) then
				local a, ms = qr:Complete("unlock_island_7")
				zx(`[Quest] Complete unlock_island_7: {tostring(a)} {ms or ""}`)
				f.qx.unlock_island_7, f.nq = a ~= true or nil, {Title = "Island Guide", Text = a == true and "Unlocked Lotus Island" or `Unlock Island Failed: {ms or "Complete Refused"}`}
			end
			ok = true
		end
	end
	local hk, he = lr(f, o, oi)
	zx(`[Lotus] Trip End: {ok and "Ok" or e or "Stopped"} | Return {hk and "Ok" or he or "Stopped"}`)
	return true, not ok and e or not hk and f.st == "Running" and (he or "Return Failed") or nil
end

local function dy(f)
	local d, du = pd(), md("Shared", "Lib", "DailyQuestUtil")
	local dq = d.DailyQuest
	if type(dq) ~= "table" or type(dq.Active) ~= "table" then return nil end
	local a = dq.Active
	zv(f, "dq", `{a.Template}{a.IslandId}{a.Progress}`, a.Template ~= "" and `[Daily] Active {a.Template} On {a.IslandId ~= "" and a.IslandId or "Any"} | {a.Progress or 0} / {a.Target or "?"}` or "[Daily] No Active Quest")
	if a.Template ~= "" then
		if not du.IsSkillGachaQuest(a) or f.qw.dp then return nil end
		local sc = rv.SkillGachaController
		local q = sc.GetQuote:Fire(1)
		if type(q) ~= "table" or not q.ok then return nil, `Daily Quest Pull Failed: {type(q) == "table" and q.reason or "No Quote"}` end
		if (d.Coin or 0) < q.coin_cost then
			if not f.qw.dc then f.qw.dc, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Waiting: Not Enough Coin"} end
			return nil
		end
		f.qw.dc = nil
		sc._requestId = (tonumber(sc._requestId) or 0) + 1
		local r, p0 = sc.Pull:Fire("Coin", 1, sc._requestId), a.Progress or 0
		if type(r) ~= "table" or not r.ok then return nil, `Daily Quest Pull Failed: {type(r) == "table" and r.reason or "No Response"}` end
		local function mv()
			local x = pd().DailyQuest.Active
			return x.Template == "" or (x.Progress or 0) > p0
		end
		local dl = os.clock() + 5
		repeat task.wait(0.2) until mv() or os.clock() > dl
		if not mv() then f.qw.dp, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Failed: Pull Not Counted"} end
		return true
	end
	if os.clock() < (f.dx or 0) or (((d.Quest or {}).Current or {}).Id or "") ~= "" then return nil end
	if du.AcceptsLeft(dq, md("Shared", "Lib", "DailyRewardUtil").get_now()) <= 0 then
		if not f.qw.dd then f.qw.dd, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Done For Today"} end
		return nil
	end
	local id = f.fi() or ic()
	if id == "" or not ul(id) then return nil end
	zx(`[Daily] Going To {id} For A New Quest | {du.AcceptsLeft(dq, md("Shared", "Lib", "DailyRewardUtil").get_now())} Left`)
	local ok, e = ti(f, id, f.bk())
	if not ok then return true, e or f.st == "Running" and "Move Failed" or nil end
	local w = workspace:FindFirstChild("World")
	local fo = w and w:FindFirstChild("Islands") and w.Islands:FindFirstChild(id)
	local function nf()
		for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
			if fo and x:GetAttribute("InteractiveId") == "npc_daily_quest" and x:IsDescendantOf(fo) then return x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or nil end
		end
		return nil
	end
	local np, g = nf(), rg(id)
	if not np and g then
		sq(Vector3.new(g.X, 2, g.Z), 10)
		np = nf()
	end
	if not np then
		f.dx = os.clock() + 60
		return true, "Daily Quest Failed: No Quest NPC"
	end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	ok, e = an(f, c, np, rt.Position)
	if not ok then return true, e or f.st == "Running" and "Move Failed" or nil end
	if f.st ~= "Running" then return true end
	local ak, m = rv.QuestController:AcceptDaily()
	f.rp = true
	if ak == true then
		zx(`[Daily] Accepted: {m}`)
		return true
	end
	f.dx, f.nq = os.clock() + 60, {Title = "Daily Quest", Text = `Daily Quest Failed: {m ~= "" and m or "Accept Refused"}`}
	return true
end

local function ss(f)
	local s, fc = f.s, rv.FishingController
	if f.ag() then
		local gq, gz = pcall(f.lo)
		if not gq then
			zx(`[Gear] Error: {gz}`)
			f.lx = os.clock() + 60
		end
	end
	local ks = sk()
	if #ks == 0 then return "Auto Fish Failed: No Skill Equipped" end
	local rz, rze = nil, nil
	if f.tk() then
		local g3, a3, b3 = pcall(f.rz)
		if g3 then rz, rze = a3, b3 else rze = `Raid Error: {a3}` end
	else
		f.ir = false
	end
	if rze then
		zx(`[Raid] {rze}`)
		return nil, rze
	end
	if rz == true then return nil end
	local ev = rv.EventController and rv.EventController._active_events
	local lv = f.au() and not rz and type(ev) == "table" and ev.weather_rainbow_rain
	if lv then
		local u, ue = lq(f)
		if u or ue then return nil, ue end
	end
	local bp, be = typeof(rz) == "Vector3" and rz or nil, nil
	if not bp and (f.ab() or f.rn()) then bp, be = bo(f) end
	f.bu = bp ~= nil
	if not bp and f.bm then
		pq(f.bm, true)
		f.bm, f.rp = nil, true
		if cj then cj:Stop() end
	end
	if be then
		zx(`[Boss] Trip Error: {be}`)
		return nil, be
	end
	if not bp and f.bb then f.bb, f.rp = false, true end
	if not bp and f.hm then
		local o, oi = f.hm[1], f.hm[2]
		zx(`[Boss] Going Home To {oi} | {zn(o.Position)} | From {ic() ~= "" and ic() or "Sea"} | Auto Boss {f.ab() and "On" or "Off"}`)
		local ok, e = true, nil
		if ic() ~= oi then ok, e = ti(f, oi, f.bk()) end
		if ok and f.st == "Running" and not f.hf() then ok, e = go(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
		if f.st ~= "Running" then return nil end
		if not ok then
			zx(`[Boss] Going Home Failed: {e or "Return Failed"}`)
			return nil, e or "Return Failed"
		end
		f.hm, f.rp = nil, false
		return nil
	end
	if not bp then
		if f.au() and not lv then
			local u, ue = lq(f)
			if u or ue then return nil, ue end
		end
		for _, q in {f.au() and qn(f) or false, f.qa() and qp(f) or false, f.ya() and qy(f) or false} do
			local u, ue = uq(f, q or nil)
			if u or ue then return nil, ue end
		end
		if f.dq() then
			local u, ue = dy(f)
			if u or ue then return nil, ue end
		end
		if f.rn() then
			local u, ue = f.ru()
			if u or ue then return nil, ue end
		end
		if f.tk() then
			local u, ue = f.rk()
			if u or ue then return nil, ue end
		end
		if f.fg() then
			local u, ue = f.rf()
			if u or ue then return nil, ue end
		end
	end
	local rq = not bp and f.qa() and qp(f)
	local rc = rq and rq[8] and ((pd().Quest or {}).Current or {}).Id or ""
	rc = rq and (rc == rq[1] or rc == "" and rq[1]:find("_inheritance$")) and rq[8]
	if rc == "*" then
		local d3, ct3 = pd(), md("Data", "Catalog")
		local p3, c3 = qe(rq[1], d3.Quest.Current.Progress), (md("Data", "Config", "QuestConfig").Data or {})[rq[1]] or {}
		rc = nil
		for _, t in p3.Tr or {} do
			local il = t.islandId
			for _, x in t.fishId and not il and ct3.Island.GetAll() or {} do
				for _, y in x.fishes or {} do
					if y.fishId == t.fishId then il = x.id end
				end
			end
			if not rc and il and ul(il) and (tonumber(p3[t.field]) or 0) < t.target then rc = il end
		end
		for _, x in c3.drops or {} do
			if not rc and x.islandId and ul(x.islandId) and md("Shared", "getItemCount")(d3, x.itemId) < ((c3.items or {})[x.itemId] or 1) then rc = x.islandId end
		end
	end
	local da = not bp and f.dq() and (pd().DailyQuest or {}).Active
	local yq = not bp and f.ya() and qy(f)
	local lu = not bp and f.au() and le() and "island_volcano"
	local nu, nl
	if not bp and f.au() then
		for _, n in iz do
			if ul(ix[n]) then nl = ix[n] end
		end
		if qn(f) or not ul("island_lotus") then nu, nl = nl, nil end
	end
	local tm, fm2
	if not bp and f.tk() then
		local _, mi, _, nd = f.tq()
		tm = nd and mi
	end
	if not bp and f.fg() then fm2 = select(3, f.fy()) end
	local fi = not bp and (lu or rc or da and da.Template ~= "" and da.IslandId ~= "" and da.IslandId or yq and yq[8] or nu or tm or fm2 or nl or f.fi())
	if fi and ic() ~= fi then
		zx(`[Fish] Go To {fi} For {lu and "Lotus Magma Essence" or rc and `Rod Quest {rq[1]}` or da and da.Template ~= "" and da.IslandId ~= "" and `Daily {da.Template}` or yq and yq[8] and `Soul {yq[1]}` or nu and "Unlock Island" or tm and "Raid Ticket Fish" or fm2 and "Rod Forge Fish" or nl and "Newest Island" or "Farm Island"} | From {ic() ~= "" and ic() or "Sea"}{ul(fi) and "" or " | Locked"}`)
		if not ul(fi) then return "Auto Fish Failed: Island Locked" end
		local ok, e = ti(f, fi, f.bk())
		if not ok then return nil, e end
		f.rp = true
		return nil
	end
	if f.ao() and fl() and not f.ir then
		if bp then
			local ok, e = bw(f)
			if not ok then return nil, e end
		end
		local hd, sf = tr(f)
		if hd or sf or f.st ~= "Running" then return hd, sf end
		task.wait(1)
		if fl() then return "Auto Fish Failed: Satchel Full" end
		if bp then return nil end
	end
	local ok, e = eq()
	if not ok then return nil, e end
	local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not h then return nil, "No Character" end
	if f.hp and not f.hf() then
		if cj and cj.p == f.hp then cj:Stop() end
		f.hp, f.rp = nil, true
	end
	local hi = not bp and f.hf()
	if hi then
		local id = vi(h.Position)
		if f.rp or not f.hp or f.hi ~= id then
			local gy
			f.hp, f.hi = nil, id
			if id ~= "" then f.hp, gy = uh(id) end
			if f.hp then
				f.rp = false
				zx(`[Hidden] Spot {math.floor(f.hp.X)}, {math.floor(f.hp.Z)} Under Ground Y {math.floor(gy)} On {id}`)
			elseif id ~= "" then
				zx(`[Hidden] No Spot On {id}, Normal Spot`)
			end
		end
		if f.hp and not (cj and not cj.dn and cj.p == f.hp) then
			local q = tg({Position = f.hp})
			local fk = q and ((q - f.hp) * Vector3.new(1, 0, 1)).Unit
			local u = h.Position.Y < -10 and ut(h.Position)
			if u then
				mo(u, 1e6)
				task.wait(0.1)
			end
			local mk, me = go(f, ut(f.hp) or Vector3.new(f.hp.X, 12, f.hp.Z), fk)
			if f.st ~= "Running" then return nil end
			if not mk then return nil, me or "Move Failed" end
			local j = mo(f.hp, 1e6, fk)
			local dl = os.clock() + 2
			repeat task.wait() until not j or j.st == "Arrived" or j.dn or os.clock() > dl
			if not (j and j.st == "Arrived") then return nil, j and j.why or "Hide Failed" end
		end
	end
	if not bp and not (hi and f.hp) and (f.rp or rv.Swimming and rv.Swimming:IsSwimming() or not tg(h)) then
		f.rp = false
		local g = rs(vi(h.Position)) or vi(h.Position) ~= "" and rs(vi(h.Position), true)
		if not g and vi(h.Position) == "" then
			local nb, nd = nil, math.huge
			for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
				local id = x:GetAttribute("islandId")
				if x:IsA("BasePart") and type(id) == "string" and ul(id) and (x.Position - h.Position).Magnitude < nd then nb, nd = id, (x.Position - h.Position).Magnitude end
			end
			if nb then
				f.rp = true
				zx(`[Fish] Off Island At {zn(h.Position)}, Going To Nearest {nb}`)
				local ok, e = ti(f, nb, f.bk())
				return nil, not ok and (e or "Move Failed") or nil
			end
		end
		if not g then
			zx(`[Fish] No Open Water Spot On {vi(h.Position) ~= "" and vi(h.Position) or "Sea"} | {zn(h.Position)}`)
			return "Auto Fish Failed: No Open Water"
		end
		local q = tg({Position = g})
		local mk, me = go(f, g, q and ((q - g) * Vector3.new(1, 0, 1)).Unit)
		zx(`[Fish] New Spot {zn(g)} On {vi(g) ~= "" and vi(g) or "?"}: {mk and "Ok" or me or "Stopped"}`)
		if not mk then return nil, me end
	end
	if not bp and rv.Swimming and rv.Swimming:IsSwimming() then
		f.rp = true
		return nil, "Swimming"
	end
	local p = bp or tg(h)
	if not p then
		zx(`[Fish] No Open Water To Cast | {zn(h.Position)}`)
		return "Auto Fish Failed: No Open Water"
	end
	s.wa, s.fp, s.rl, s.q, s.cr, s.rr, s.sw, s.bs, s.id = nil, nil, nil, nil, nil, nil, 0, 0, nil
	s.xh, s.xm, s.xp = nil, nil, 1
	local zt, zl = os.clock(), `{bp and "[Boss]" or "[Fish]"} Cast {ic() ~= "" and ic() or "Sea"} {zn(p)}`
	fc.FishCast:Fire(1, p)
	local dl = os.clock() + 3
	repeat task.wait() until s.wa or s.fp or s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	if not (s.wa or s.fp or s.rl or s.cr or s.rr) then
		if f.st == "Running" then fc.FishLootConfirm:Fire() end
		zx(`{zl} | No Cast Ack`)
		return nil, "No Cast Ack"
	end
	dl = os.clock() + 25
	repeat task.wait() until s.fp or s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	if s.fp and not (s.rl or s.cr or s.rr) and f.st == "Running" then
		fp(s)
		repeat task.wait() until s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	end
	local fo = s.id and md("Data", "Catalog").Fish.GetById(s.id)
	local bf = fo and fo.kind == "Boss"
	if bf then zx(`[Boss] Hooked {ze(s.id)} | HP {s.xh or "?"} / {s.xm or "?"}`) end
	local zq, zk, zc = not bp and f.qa() and qp(f), ks, (pd().Quest or {}).Current or {}
	local zp = qe(zc.Id, zc.Progress)
	local zs = zq and zc.Id == zq[1] and (zq[1] == "zen_staff_rod" and fo and fo.rarity == "Legendary" and ic() == "island_fossil" and "taiji_hooking_art_v2" or zq[1] == "taiji_hooking_art_v2" and "taiji_hooking_art") or not bp and f.ya() and (zp.CurrentUsedSkill or 0) < (zp.CatchWithSkill or 1) and (zc.Id == "azure_dragon" and "one_hook_supreme" or zc.Id == "supreme_king" and fo and fo.rarity == "Legendary" and ic() == "island_fossil" and "rod_gate_20_percent")
	local zr = zq or bp and f.qa() and qp(f)
	if not zs and zr and zr[12] and zc.Id == zr[1] and fo then
		local re2 = pd().RodEquip
		for _, dg in {false, true} do
			for _, t in zp.Tr or {} do
				if not zs and t.skillId and (t.event == "SkillDamage") == dg and t.event ~= "SkillUse" and t.raid ~= true and (not bp or t.fishKind == "Boss") and (tonumber(zp[t.field]) or 0) < t.target and (not t.islandId or t.islandId == ic()) and (not t.rarity or t.rarity == fo.rarity) and (not t.fishId or t.fishId == s.id) and (not t.fishKind or t.fishKind == fo.kind) and (not t.rodId or t.rodId == re2) then zs = t.skillId end
			end
		end
	end
	if zs then
		zk = {}
		for _, x in ks do
			if x[2] == zs then table.insert(zk, x) end
		end
		if #zk == 0 then
			local rq2 = zr and zc.Id == zr[1]
			zk = ks
			qw(f, `z{zs}`, `{rq2 and "Rod" or "Soul"} Quest Waiting: Equip {({taiji_hooking_art = "Taiji Hooking Art", taiji_hooking_art_v2 = "Taiji Hooking Art V2", one_hook_supreme = "One Hook Supreme", rod_gate_20_percent = "Rod Gate 20%"})[zs] or (md("Data", "Catalog").Skill.GetById(zs) or {}).name or zs}`, rq2 and "Rod Quest" or "Soul Quest")
		end
	end
	local up = hi and f.hp and s.rl and f.st == "Running" and cj and not cj.dn and cj.p == f.hp and cj.fk
	local uj = up and mo(Vector3.new(f.hp.X, 1000, f.hp.Z), 1e6, up)
	local re = s.rl and f.st == "Running" and rl(f, s, zk) or not (s.cr or s.rr) and f.st == "Running" and "Bite Timeout"
	if uj and not uj.dn then mo(f.hp, 1e6, up) end
	zx(`{zl} | Bite {s.id and ze(s.id) or "None"} | {s.cr and (s.cr[1] and "Caught" or "Lost") or s.rr and `Reset {s.rr}` or re or "Stopped"}{s.id and ` | HP {s.xh or "?"} / {s.xm or "?"}{s.xp == 2 and " Phase 2" or ""}` or ""} | {math.floor(os.clock() - zt)} s`)
	if bf and not (s.cr and s.cr[1]) then
		f.bl = os.clock() + 180
		zx(`[Boss] Fight Ended Without Catch ({s.rr or "No Reset"}), Lockout 180 s`)
	end
	if f.st ~= "Running" or re then
		if s.cr and s.cr[1] and not s.cr[2] then task.wait(0.75); fc.FishLootConfirm:Fire() end
		if not (s.cr or s.rr) then fc.FishCancel:Fire(); task.wait(1) end
		return nil, re
	end
	if bp and s.rr == "IslandLocked" then
		f.bx, f.bb, f.rp = f.br, false, true
		zx("[Boss] Region On A Locked Island, Skipped")
		return nil
	end
	if s.rr == "NoSkillEquipped" then return "Auto Fish Failed: No Skill Equipped" end
	if s.rr == "SatchelFull" and not f.ao() then return "Auto Fish Failed: Satchel Full" end
	if s.rr == "SessionActive" then
		fc.FishLootConfirm:Fire()
		fc.FishCancel:Fire()
		task.wait(1)
	end
	if f.ir and f.rss and s.rr == "Swimming" then
		table.insert(f.rbs, f.rss - Vector3.new(0, 3, 0))
		zx(`[Raid] Stand {zn(f.rss)}: Swimming, Marked Bad`)
		f.rsk, f.rss = false, false
	end
	if f.ir and f.rsk and (s.rr == "RaidSpotTaken" or s.rr == "RaidNoSpot") then
		zx(`[Raid] Fish Spot {f.rsk}: {s.rr}, Trying Another`)
		f.rt[f.rsk], f.rsk = os.clock() + 30, false
	end
	if s.rr then return nil, s.rr end
	if s.cr[1] then
		f.c += 1
		if not s.cr[2] then task.wait(0.75); fc.FishLootConfirm:Fire() end
	end
	task.wait(0.6)
	return nil
end

local function rn(f)
	local n = 0
	while f.st == "Running" do
		if f.fq then
			f.st = "Stopped"
			break
		end
		if f.iw() then
			task.wait(0.5)
			continue
		end
		if zy.on and zy.rq and not (f.bu or f.bb or f.hm or f.ir) then
			zy.rq = false
			local _, e = zh()
			if e then zx(`[Safe] {e}`, true) end
			f.nq = {Title = "Safe", Text = e}
			continue
		end
		local hw = zy.on and zy.rq and "w" or ""
		zv(f, "sh", hw, hw == "w" and `[Safe] Hop Waiting For Boss Trip{f.bu and " | At Boss" or ""}{f.bb and " | On Boat" or ""}{f.hm and " | Home Not Restored" or ""}` or "[Safe] Hop Wait Over")
		f.bz = true
		local hd, sf = ss(f)
		f.bz = false
		if hd then
			zx(`[Fish] Stop: {hd}`)
			f.why = hd
			return
		end
		if sf then zx(`[Fish] Soft Failure: {sf}`) end
		n = sf and n + 1 or 0
		if n >= 5 then
			n, f.rp, f.nq = 0, true, {Title = "Auto Fish", Text = `Auto Fish Retry: {sf}`}
			if cj then cj:Stop() end
			task.wait(1)
		elseif sf then
			task.wait(1)
		end
	end
end

local L = (function()
local ps, uis, tws, gs, hs = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("GuiService"), game:GetService("HttpService")
local ge = getgenv and getgenv() or _G
local c = {bg = Color3.fromRGB(25, 16, 18), cd = Color3.fromRGB(39, 19, 22), hv = Color3.fromRGB(58, 23, 28), pr = Color3.fromRGB(76, 25, 32), tx = Color3.fromRGB(244, 240, 232), dm = Color3.fromRGB(168, 164, 156), ac = Color3.fromRGB(235, 45, 65), er = Color3.fromRGB(255, 104, 112)}
local fn, fb, ww, wh, nw, th = Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold, 580, 340, 150, 40
local ip = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
local ir, ib = Font.new(ip), Font.new(ip, Enum.FontWeight.Bold)
local mb, tc, mm, kb = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement, Enum.UserInputType.Keyboard
local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local L = {Flags = {}}

local function mk(k, p, ch)
	local o = Instance.new(k)
	for i, v in p do
		if i ~= "Parent" then o[i] = v end
	end
	for _, x in ch or {} do x.Parent = o end
	o.Parent = p.Parent
	return o
end

local function rc(r) return mk("UICorner", {CornerRadius = UDim.new(0, r)}) end
local function sk(t, col) return mk("UIStroke", {Color = col or c.tx, Transparency = t, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}) end
local function pd(l, r, t, b) return mk("UIPadding", {PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0)}) end
local function ll(g) return mk("UIListLayout", {Padding = UDim.new(0, g), SortOrder = Enum.SortOrder.LayoutOrder}) end
local function tw(o, p, d) tws:Create(o, d and TweenInfo.new(d, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or ti, p):Play() end

local function tl(p, ch)
	local d = {BackgroundTransparency = 1, Font = fn, TextColor3 = c.tx, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Text = ""}
	for i, v in p do d[i] = v end
	return mk("TextLabel", d, ch)
end

local function ig(p, ch)
	local d = {BackgroundTransparency = 1, FontFace = ir, TextColor3 = c.tx, TextSize = 16, Text = ""}
	for i, v in p do d[i] = v end
	return mk("TextLabel", d, ch)
end

local function bt(p, ch)
	local d = {BackgroundTransparency = 1, AutoButtonColor = false, Text = "", BorderSizePixel = 0}
	for i, v in p do d[i] = v end
	return mk("TextButton", d, ch)
end

local function hov(b, base)
	b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundColor3 = c.hv}) end end)
	b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = base()}) end)
	b.MouseButton1Down:Connect(function() tw(b, {BackgroundColor3 = c.pr}, 0.05) end)
	b.MouseButton1Up:Connect(function() tw(b, {BackgroundColor3 = uis.MouseEnabled and c.hv or base()}) end)
end

local function gui()
	local sg = mk("ScreenGui", {Name = hs:GenerateGUID(false), IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999})
	if not pcall(function() sg.Parent = gethui and gethui() or game:GetService("CoreGui") end) then sg.Parent = ps.LocalPlayer:WaitForChild("PlayerGui") end
	return sg
end

local function fit(sg, f, sc, w, h)
	local s, i = sg.AbsoluteSize, gs:GetGuiInset().Y
	local v = math.clamp(math.min((s.X - 24) / w, (s.Y - i - 24) / h), 0.5, 1)
	sc.Scale = v
	f.Position = UDim2.fromOffset(s.X / 2, i + (s.Y - i) / 2)
	return v
end

local function cfn(s)
	if s == nil then return true end
	if type(s) ~= "string" or s == "" then return false end
	for seg in (s .. "/"):gmatch("([^/]*)/") do
		if not seg:match("^[%w _%-]+$") then return false end
	end
	return true
end

local function mkd(p)
	local d = ""
	for seg in p:gmatch("([^/]+)/") do
		d = d == "" and seg or d .. "/" .. seg
		if not isfolder(d) then makefolder(d) end
	end
end

function L:Window(o)
	o = o or {}
	if not cfn(o.Config) then error("Window Failed: Bad Config", 0) end
	if ge.__AvW then pcall(ge.__AvW.Destroy, ge.__AvW) end
	local W = {Tabs = {}, Current = nil, cn = {}, key = o.Key == nil and Enum.KeyCode.LeftControl or o.Key, sx = false, sl = "", kw = false, fc = nil, sv = 1, fd = nil, w = ww, h = wh}
	local sg = gui()
	W.Gui = sg
	local mn = mk("Frame", {Name = "Main", Size = UDim2.fromOffset(ww, wh), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = c.bg, BorderSizePixel = 0, Parent = sg}, {rc(12), sk(0.85)})
	W.Main = mn
	local sc = mk("UIScale", {Parent = mn})
	local tb = mk("Frame", {Size = UDim2.new(1, 0, 0, th), BackgroundTransparency = 1, Parent = mn})
	tl({Text = tostring(o.Title or "Avenoric"), Font = fb, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -116, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = tb})
	local function cap(x, g)
		local b = bt({Size = UDim2.fromOffset(40, 28), Position = UDim2.new(1, x, 0, 6), BackgroundColor3 = c.hv, Parent = tb}, {rc(6)})
		local i = ig({Text = g, TextSize = 14, TextColor3 = c.dm, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, Parent = b})
		b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundTransparency = 0}) end end)
		b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 1}) end)
		return b, i
	end
	local xb, xi = cap(-46, "x")
	local nb = cap(-88, "minus")
	local tsf = mk("Frame", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12), Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 100, Parent = sg}, {ll(8)})

	function W:Notify(n)
		n = n or {}
		if n.Title == nil and n.Text == nil then error("Notify Failed: No Text", 0) end
		local t = n.Time == nil and 4 or n.Time
		if type(t) ~= "number" or t ~= t or t <= 0 then error("Notify Failed: Bad Time", 0) end
		local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = c.cd, BorderSizePixel = 0, ZIndex = 100, Parent = tsf}, {rc(8), sk(0.9), pd(18, 14, 10, 10)})
		mk("Frame", {Position = UDim2.fromOffset(-12, 2), Size = UDim2.new(0, 3, 1, -4), BackgroundColor3 = n.Error and c.er or c.ac, BorderSizePixel = 0, ZIndex = 101, Parent = f}, {rc(2)})
		local lay = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 101, Parent = f}, {ll(2)})
		tl({Text = tostring(n.Title or "Avenoric"), Font = fb, Size = UDim2.new(1, 0, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 102, LayoutOrder = 1, Parent = lay})
		if n.Text ~= nil then tl({Text = tostring(n.Text), TextSize = 13, TextColor3 = c.dm, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, ZIndex = 102, LayoutOrder = 2, Parent = lay}) end
		local us = mk("UIScale", {Scale = 0.9, Parent = f})
		tw(us, {Scale = 1})
		task.delay(t, function() if f.Parent then f:Destroy() end end)
		return f
	end

	local function run(f, ...)
		if not f then return end
		local ok, e = pcall(f, ...)
		if ok then return end
		warn("Callback Failed: " .. tostring(e))
		W:Notify({Title = "Callback Failed", Text = tostring(e), Error = true})
	end

	local cp, cd, dirty, pend, dead = o.Config and `Avenoric/Configs/{o.Config}.json`, {}, false, false, false
	if cp and isfile and isfile(cp) then
		local ok, d = pcall(function() return hs:JSONDecode(readfile(cp)) end)
		if ok and type(d) == "table" then cd = d else
			pcall(function() writefile(cp .. ".bad", readfile(cp)); delfile(cp) end)
			W:Notify({Title = "Config Load Failed", Text = "Invalid Json", Error = true})
		end
	end
	local function save()
		if not cp or not dirty then return end
		dirty = false
		pcall(function()
			mkd(cp)
			writefile(cp, hs:JSONEncode(cd))
		end)
	end
	local function put(e, v)
		if not e.Flag then return end
		L.Flags[e.Flag] = v
		if not cp then return end
		if e.sv then cd[e.Flag] = e.sv(v) else cd[e.Flag] = v end
		dirty = true
		if pend or dead then return end
		pend = true
		task.delay(0.5, function() pend = false; save() end)
	end
	local function done(e)
		if not e.Flag then return end
		L.Flags[e.Flag] = e:Get()
		local s = cd[e.Flag]
		if s == nil then return end
		pcall(function()
			if e.ld then s = e.ld(s) end
			e:Set(s)
		end)
	end

	local nv = mk("Frame", {Position = UDim2.fromOffset(12, th + 4), Size = UDim2.new(0, nw, 1, -(th + 16)), BackgroundTransparency = 1, Parent = mn})
	local sbx = mk("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = c.cd, BorderSizePixel = 0, ClipsDescendants = true, Parent = nv}, {rc(6), sk(0.9)})
	local sst = sbx:FindFirstChildOfClass("UIStroke")
	ig({Text = "magnifying-glass", TextSize = 14, TextColor3 = c.dm, Position = UDim2.fromOffset(9, 0), Size = UDim2.fromOffset(16, 32), Parent = sbx})
	local sb = mk("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -36, 1, 0), Font = fn, TextSize = 13, TextColor3 = c.tx, PlaceholderText = "Search", PlaceholderColor3 = c.dm, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Text = "", Parent = sbx})
	sb.Focused:Connect(function() tw(sst, {Color = c.ac, Transparency = 0}) end)
	sb.FocusLost:Connect(function() tw(sst, {Color = c.tx, Transparency = 0.9}) end)
	local tf = mk("ScrollingFrame", {Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 1, -40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, Parent = nv}, {ll(4)})
	local pg = mk("Frame", {Position = UDim2.fromOffset(nw + 20, th + 4), Size = UDim2.new(1, -(nw + 32), 1, -(th + 16)), BackgroundTransparency = 1, ClipsDescendants = true, Parent = mn})
	local function page()
		local p = mk("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = c.dm, ScrollBarImageTransparency = 0.5, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = pg}, {ll(4), pd(2, 8, 2, 4)})
		for _, k in {"CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize"} do p:GetPropertyChangedSignal(k):Connect(function() W.fd() end) end
		return p
	end
	local sr = page()
	local function fade(top)
		local f = mk("Frame", {Size = UDim2.new(1, -8, 0, 20), Position = top and UDim2.new() or UDim2.new(0, 0, 1, -20), BackgroundColor3 = c.bg, BorderSizePixel = 0, ZIndex = 5, Visible = false, Parent = pg})
		mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new(top and 0 or 1, top and 1 or 0), Parent = f})
		return f
	end
	local ft, fb2 = fade(true), fade(false)
	local function fd()
		local p = W.sx and sr or W.Current and W.Current.Page
		if not p then ft.Visible, fb2.Visible = false, false; return end
		ft.Visible, fb2.Visible = p.CanvasPosition.Y > 1, p.AbsoluteCanvasSize.Y - p.AbsoluteWindowSize.Y - p.CanvasPosition.Y > 1
	end
	W.fd = fd
	local ov = bt({Size = UDim2.fromScale(1, 1), ZIndex = 50, Visible = false, Parent = mn})
	ov.Activated:Connect(function() if W.fc then W.fc() end end)
	local fl = bt({Size = UDim2.fromOffset(44, 44), BackgroundColor3 = Color3.fromRGB(18, 18, 21), BackgroundTransparency = 0.08, Parent = sg}, {rc(22)})
	ig({Text = "studio", FontFace = ib, TextSize = 24, TextColor3 = Color3.fromRGB(247, 247, 248), Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(24, 24), Active = false, Parent = fl})

	local function cl()
		local s, n, hw, hh = sg.AbsoluteSize, gs:GetGuiInset().Y, W.w * sc.Scale / 2, W.h * sc.Scale / 2
		mn.Position = UDim2.fromOffset(math.clamp(mn.Position.X.Offset, hw, s.X - hw), math.clamp(mn.Position.Y.Offset, n + hh, s.Y - hh))
	end
	local function rsz(w, h)
		local s, n = sg.AbsoluteSize, gs:GetGuiInset().Y
		W.w, W.h = math.clamp(math.round(tonumber(w) or W.w), 420, math.max(420, s.X - 24)), math.clamp(math.round(tonumber(h) or W.h), 260, math.max(260, s.Y - n - 24))
		mn.Size = UDim2.fromOffset(W.w, W.h)
		W.sv = math.clamp(math.min((s.X - 24) / W.w, (s.Y - n - 24) / W.h), 0.5, 1)
		sc.Scale = W.sv
		cl()
	end
	local function fx()
		W.sv = fit(sg, mn, sc, W.w, W.h)
		fl.Position = UDim2.fromOffset(16, gs:GetGuiInset().Y + 8)
	end
	function W:Resize(w, h) rsz(w, h) end
	fx()
	local dr
	local function hd(p, ax, ay)
		local b = bt({AnchorPoint = p.AnchorPoint, Position = p.Position, Size = p.Size, ZIndex = 3, Parent = mn})
		table.insert(W.cn, b.InputBegan:Connect(function(i)
			if i.UserInputType ~= mb and i.UserInputType ~= tc then return end
			local w0, h0, d0, s0 = W.w, W.h, i.Position, sc.Scale
			local lx, ly = mn.Position.X.Offset - W.w * s0 / 2, mn.Position.Y.Offset - W.h * s0 / 2
			dr = {i = i, mv = function(q)
				rsz(ax and w0 + (q.X - d0.X) / s0 or W.w, ay and h0 + (q.Y - d0.Y) / s0 or W.h)
				mn.Position = UDim2.fromOffset(lx + W.w * sc.Scale / 2, ly + W.h * sc.Scale / 2)
				cl()
			end}
		end))
	end
	hd({AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0), Size = UDim2.fromOffset(16, 16)}, true, true)
	hd({AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, -16, 0, 10)}, false, true)
	hd({AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, th), Size = UDim2.new(0, 10, 1, -(th + 16))}, true, false)
	table.insert(W.cn, sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(fx))

	function W:Show()
		mn.Visible, sc.Scale = true, W.sv
	end
	function W:Hide() mn.Visible = false end
	local function tg() if mn.Visible then W:Hide() else W:Show() end end
	fl.Activated:Connect(tg)
	nb.Activated:Connect(function() W:Hide() end)
	local arm, an = false, 0
	xb.Activated:Connect(function()
		if arm then (W :: any):Destroy(); return end
		arm, an = true, an + 1
		local n = an
		tw(xb, {BackgroundColor3 = c.er, BackgroundTransparency = 0})
		xi.TextColor3 = Color3.new(1, 1, 1)
		task.delay(3, function()
			if an ~= n or not arm then return end
			arm = false
			tw(xb, {BackgroundColor3 = c.hv, BackgroundTransparency = 1})
			xi.TextColor3 = c.dm
		end)
	end)

	table.insert(W.cn, tb.InputBegan:Connect(function(i)
		if i.UserInputType ~= mb and i.UserInputType ~= tc then return end
		local p0, d0 = mn.Position, i.Position
		dr = {i = i, mv = function(p)
			local s, n, hw, hh = sg.AbsoluteSize, gs:GetGuiInset().Y, mn.AbsoluteSize.X / 2, mn.AbsoluteSize.Y / 2
			mn.Position = UDim2.fromOffset(math.clamp(p0.X.Offset + p.X - d0.X, hw, s.X - hw), math.clamp(p0.Y.Offset + p.Y - d0.Y, n + hh, s.Y - hh))
		end}
	end))
	table.insert(W.cn, uis.InputChanged:Connect(function(i)
		if not dr or (i.UserInputType ~= mm and i ~= dr.i) then return end
		dr.mv(i.Position)
	end))
	table.insert(W.cn, uis.InputEnded:Connect(function(i)
		if not dr or (i ~= dr.i and i.UserInputType ~= mb) then return end
		if dr.up then dr.up() end
		dr = nil
	end))
	table.insert(W.cn, uis.InputBegan:Connect(function(i)
		if i.UserInputType ~= kb or W.kw or not W.key or i.KeyCode ~= W.key or uis:GetFocusedTextBox() then return end
		tg()
	end))

	local function jump(e)
		local p = e.Tab.Page
		p.CanvasPosition = Vector2.new(0, math.max(0, (e.Row.AbsolutePosition.Y - p.AbsolutePosition.Y) / sc.Scale + p.CanvasPosition.Y - 4))
		local st = e.Row:FindFirstChildOfClass("UIStroke")
		if not st then return end
		tw(st, {Color = c.ac, Transparency = 0})
		task.delay(0.8, function() tw(st, {Color = c.tx, Transparency = 0.92}, 0.4) end)
	end

	function W:Search(s)
		s = tostring(s or "")
		W.sl = s
		if sb.Text ~= s then sb.Text = s end
		for _, x in sr:GetChildren() do
			if x:IsA("GuiButton") then x:Destroy() end
		end
		if s == "" then
			if not W.sx then return nil end
			W.sx, sr.Visible = false, false
			if W.Current then W.Current.Page.Visible = true end
			fd()
			return nil
		end
		local n, q = 0, s:lower()
		for _, T in W.Tabs do
			for _, e in T.Rows do
				if e.Kind ~= "Section" and e.Kind ~= "Label" and e.Name:lower():find(q, 1, true) then
					n += 1
					local b = bt({Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = c.cd, LayoutOrder = n, Parent = sr}, {rc(6), sk(0.92), pd(12, 12)})
					tl({Text = e.Name, Size = UDim2.new(0.6, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b})
					tl({Text = e.Sec and `{T.Name} · {e.Sec}` or T.Name, TextSize = 12, TextColor3 = c.dm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0.4, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = b})
					hov(b, function() return c.cd end)
					b.Activated:Connect(function()
						W:Search("")
						T:Select()
						task.defer(jump, e)
					end)
				end
			end
		end
		if not W.sx then
			W.sx, sr.Visible = true, true
			if W.Current then W.Current.Page.Visible = false end
		end
		fd()
		return n
	end
	sb:GetPropertyChangedSignal("Text"):Connect(function() if sb.Text ~= W.sl then W:Search(sb.Text) end end)

	function W:Tab(t)
		t = t or {}
		local T = {Rows = {}, Name = tostring(t.Name or "Tab"), W = W, n = 0, sec = nil}
		local b = bt({Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = c.cd, LayoutOrder = #W.Tabs + 1, Parent = tf}, {rc(6)})
		local bar = mk("Frame", {Size = UDim2.fromOffset(3, 16), Position = UDim2.fromOffset(0, 10), BackgroundColor3 = c.ac, BorderSizePixel = 0, Visible = false, Parent = b}, {rc(2)})
		local ico = t.Icon and ig({Text = tostring(t.Icon), TextColor3 = c.dm, Position = UDim2.fromOffset(10, 0), Size = UDim2.fromOffset(20, 36), TextXAlignment = Enum.TextXAlignment.Center, Parent = b})
		local nm = tl({Text = T.Name, TextColor3 = c.dm, Position = UDim2.fromOffset(ico and 38 or 12, 0), Size = UDim2.new(1, -(ico and 46 or 20), 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b})
		local p = page()
		T.Page, T.Btn = p, b
		local function paint(on)
			tw(b, {BackgroundTransparency = on and 0 or 1})
			bar.Visible, nm.TextColor3 = on, on and c.tx or c.dm
			if ico then ico.TextColor3, ico.FontFace = on and c.tx or c.dm, on and ib or ir end
		end
		T.pt = paint
		b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundColor3 = c.hv, BackgroundTransparency = 0}) end end)
		b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = c.cd, BackgroundTransparency = W.Current == T and 0 or 1}) end)
		function T:Select()
			if W.sx then W:Search("") end
			if W.Current == T then return end
			if W.Current then W.Current.Page.Visible = false; W.Current.pt(false) end
			W.Current, p.Visible = T, true
			paint(true)
			fd()
		end
		b.Activated:Connect(function() T:Select() end)
		table.insert(W.Tabs, T)
		if not W.Current then T:Select() else paint(false) end

		local function add(e)
			T.n += 1
			e.Row.LayoutOrder = T.n
			table.insert(T.Rows, e)
			return e
		end
		local function row(k, r)
			if type(r.Name) ~= "string" then error(`{k} Failed: Bad Name`, 0) end
			if r.Flag ~= nil and type(r.Flag) ~= "string" then error(`{k} Failed: Bad Flag`, 0) end
			local f = bt({Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = c.cd, Parent = p}, {rc(6), sk(0.92), pd(12, 12)})
			hov(f, function() return c.cd end)
			local l = tl({Text = r.Name, Size = UDim2.new(0.5, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = f})
			local e = {Row = f, Kind = k, Name = r.Name, Flag = r.Flag, Tab = T, Sec = T.sec, Label = l}
			function e:Get() return (e :: any).v end
			return add(e), f, l
		end
		local function txt(e, l)
			function e:Set(s) l.Text = tostring(s) end
			function e:Get() return l.Text end
			return e
		end

		function T:Section(r)
			r = r or {}
			local l = tl({Text = tostring(r.Name or ""), Font = fb, TextSize = 13, Size = UDim2.new(1, 0, 0, 30), TextYAlignment = Enum.TextYAlignment.Bottom, Parent = p}, {pd(4, 0, 0, 4)})
			T.sec = l.Text
			return txt(add({Row = l, Kind = "Section", Name = l.Text, Tab = T}), l)
		end

		function T:Label(r)
			r = r or {}
			local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = c.cd, BorderSizePixel = 0, Parent = p}, {rc(6), sk(0.92), pd(12, 12, 10, 10)})
			local l = tl({Text = tostring(r.Text or ""), TextSize = 13, TextColor3 = c.dm, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, Parent = f})
			return txt(add({Row = f, Kind = "Label", Name = l.Text, Tab = T, Sec = T.sec}), l)
		end

		function T:Button(r)
			r = r or {}
			local e, f, l = row("Button", r)
			ig({Text = "chevron-small-right", TextSize = 14, TextColor3 = c.dm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(16, 44), TextXAlignment = Enum.TextXAlignment.Center, Parent = f})
			f.Activated:Connect(function() run(r.Callback) end)
			return txt(e, l)
		end

		function T:Toggle(r)
			r = r or {}
			local e, f = row("Toggle", r)
			local sw = mk("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(40, 20), BackgroundColor3 = c.ac, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = f}, {rc(10), sk(0.2, c.dm)})
			local st = sw:FindFirstChildOfClass("UIStroke")
			local kn = mk("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 4, 0.5, 0), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = c.dm, BorderSizePixel = 0, Parent = sw}, {rc(6)})
			local sl = tl({Text = "Off", TextSize = 13, TextColor3 = c.dm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -48, 0, 0), Size = UDim2.fromOffset(40, 44), TextXAlignment = Enum.TextXAlignment.Right, Parent = f})
			e.v, e.ld = r.Default == true, function(s) return s == true end
			local function draw(a)
				local on, g = e.v, a and tw or function(x, q) for i, v in q do x[i] = v end end
				g(sw, {BackgroundTransparency = on and 0 or 1})
				g(st, {Transparency = on and 1 or 0.2})
				g(kn, {Position = UDim2.new(0, on and 24 or 4, 0.5, 0), BackgroundColor3 = on and c.bg or c.dm})
				sl.Text = on and "On" or "Off"
			end
			draw(false)
			function e:Set(v)
				v = v == true
				if v == e.v then return end
				e.v = v
				draw(true)
				put(e, v)
				run(r.Callback, v)
			end
			f.Activated:Connect(function() e:Set(not e.v) end)
			done(e)
			return e
		end

		function T:Slider(r)
			r = r or {}
			local lo, hi, st = tonumber(r.Min), tonumber(r.Max), r.Step == nil and 1 or tonumber(r.Step)
			if not (lo and hi and hi > lo) then error("Slider Failed: Bad Range", 0) end
			if not (st and st > 0) then error("Slider Failed: Bad Step", 0) end
			local e, f = row("Slider", r)
			local vl = tl({Text = "", TextSize = 13, TextColor3 = c.dm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(44, 44), TextXAlignment = Enum.TextXAlignment.Right, Parent = f})
			local hit = bt({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -52, 0.5, 0), Size = UDim2.fromOffset(120, 28), Parent = f})
			local tr = mk("Frame", {AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = c.hv, BorderSizePixel = 0, Parent = hit}, {rc(2)})
			local fi = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = c.ac, BorderSizePixel = 0, Parent = tr}, {rc(2)})
			local kn = mk("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = c.ac, BorderSizePixel = 0, Parent = hit}, {rc(7), mk("UIStroke", {Color = c.bg, Thickness = 2})})
			local function q(v) return math.clamp(lo + math.round((v - lo) / st) * st, lo, hi) end
			local d0 = r.Default
			e.v, e.ld = q(type(d0) == "number" and d0 == d0 and d0 or lo), tonumber
			local function draw()
				local a = (e.v - lo) / (hi - lo)
				fi.Size, kn.Position, vl.Text = UDim2.new(a, 0, 1, 0), UDim2.new(a, 0, 0.5, 0), ("%g"):format(e.v)
			end
			draw()
			function e:Set(v)
				if type(v) ~= "number" or v ~= v then error("Slider Set Failed: Not A Number", 0) end
				v = q(v)
				if v == e.v then return end
				e.v = v
				draw()
				put(e, v)
				run(r.Callback, v)
			end
			local function at(x) e:Set(lo + math.clamp((x - hit.AbsolutePosition.X) / hit.AbsoluteSize.X, 0, 1) * (hi - lo)) end
			hit.InputBegan:Connect(function(i)
				if i.UserInputType ~= mb and i.UserInputType ~= tc then return end
				p.ScrollingEnabled = false
				dr = {i = i, mv = function(v) at(v.X) end, up = function() p.ScrollingEnabled = true end}
				at(i.Position.X)
			end)
			done(e)
			return e
		end

		function T:Dropdown(r)
			r = r or {}
			if type(r.Options) ~= "table" then error("Dropdown Failed: Bad Options", 0) end
			local e, f = row("Dropdown", r)
			local mu = r.Multi == true
			e.Options = {}
			local function opts(l)
				local seen = {}
				e.Options = {}
				for _, s in l do
					if type(s) == "string" and not seen[s] then seen[s] = true; table.insert(e.Options, s) end
				end
			end
			opts(r.Options)
			local box = bt({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(150, 28), BackgroundColor3 = c.bg, Parent = f}, {rc(4), sk(0.9)})
			local bl = tl({Text = "", TextSize = 13, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = box})
			local ch = ig({Text = "chevron-small-down", TextSize = 14, TextColor3 = c.dm, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 0), Size = UDim2.fromOffset(16, 28), TextXAlignment = Enum.TextXAlignment.Center, Parent = box})
			local function norm(v)
				if mu then
					if type(v) ~= "table" then error("Dropdown Set Failed: Not A Table", 0) end
					local want, out = {}, {}
					for _, s in v do want[s] = true end
					for _, s in e.Options do
						if want[s] then table.insert(out, s) end
					end
					return out
				end
				if v == nil then return nil end
				if table.find(e.Options, v) then return v end
				error("Dropdown Set Failed: Unknown Option", 0)
			end
			local function same(a, b)
				if not mu then return a == b end
				if #a ~= #b then return false end
				for i, s in a do
					if b[i] ~= s then return false end
				end
				return true
			end
			e.v = if mu then (if type(r.Default) == "table" then norm(r.Default) else {}) else (if table.find(e.Options, r.Default) then r.Default else nil)
			if mu then e.ld = function(s) return type(s) == "table" and s or {} end else e.sv, e.ld = function(v) return if v == nil then false else v end, function(s) return s ~= false and s or nil end end
			local function has(s) return mu and table.find(e.v, s) ~= nil or not mu and e.v == s end
			local function draw()
				local any = mu and #e.v > 0 or not mu and e.v ~= nil
				bl.Text, bl.TextColor3 = any and (mu and table.concat(e.v, ", ") or e.v) or "None", any and c.tx or c.dm
			end
			draw()
			function e:Get() return mu and table.clone(e.v) or e.v end
			local function emit(v)
				e.v = v
				draw()
				put(e, e:Get())
				run(r.Callback, e:Get())
			end
			function e:Set(v)
				v = norm(v)
				if same(v, e.v) then return end
				emit(v)
			end
			function e:Refresh(l)
				if type(l) ~= "table" then error("Dropdown Refresh Failed: Bad Options", 0) end
				opts(l)
				local v = mu and norm(e.v) or (table.find(e.Options, e.v) and e.v or nil)
				if not same(v, e.v) then emit(v) end
				draw()
			end
			local fy
			local function close()
				if not fy then return end
				fy:Destroy()
				fy, ov.Visible, ch.Text, W.fc = nil, false, "chevron-small-down", nil
			end
			local function open()
				if fy then close(); return end
				if W.fc then W.fc() end
				W.fc, ov.Visible, ch.Text = close, true, "chevron-small-up"
				local s, bp = sc.Scale, (box.AbsolutePosition - mn.AbsolutePosition) / sc.Scale
				local h = math.max(math.min(#e.Options, 5), 1) * 32 + 8
				local y = bp.Y + 32
				if y + h > W.h - 8 then y = bp.Y - h - 4 end
				fy = mk("Frame", {Position = UDim2.fromOffset(bp.X, y), Size = UDim2.fromOffset(box.AbsoluteSize.X / s, h), BackgroundColor3 = c.cd, BorderSizePixel = 0, Parent = ov}, {rc(6), sk(0.85), pd(4, 4, 4, 4)})
				local ls = mk("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = c.dm, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, Parent = fy}, {ll(0)})
				if #e.Options == 0 then tl({Text = "No Options", TextSize = 13, TextColor3 = c.dm, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -10, 0, 32), Parent = ls}) end
				for n, s in e.Options do
					local sel = has(s)
					local b = bt({Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = c.hv, BackgroundTransparency = sel and 0 or 1, LayoutOrder = n, Parent = ls}, {rc(4)})
					tl({Text = s, TextSize = 13, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -36, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = b})
					local ck = ig({Text = "check", TextSize = 14, TextColor3 = c.ac, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(16, 32), TextXAlignment = Enum.TextXAlignment.Center, Visible = sel, Parent = b})
					b.MouseEnter:Connect(function() if uis.MouseEnabled then tw(b, {BackgroundTransparency = 0}) end end)
					b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = has(s) and 0 or 1}) end)
					b.Activated:Connect(function()
						if not mu then e:Set(s); close(); return end
						local v, i = e:Get(), table.find(e.v, s)
						if i then table.remove(v, i) else table.insert(v, s) end
						e:Set(v)
						ck.Visible = has(s)
						tw(b, {BackgroundTransparency = ck.Visible and 0 or 1})
					end)
				end
			end
			box.Activated:Connect(open)
			hov(box, function() return c.bg end)
			done(e)
			return e
		end

		function T:TextBox(r)
			r = r or {}
			local e, f = row("TextBox", r)
			local bx = mk("Frame", {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(150, 28), BackgroundColor3 = c.bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = f}, {rc(4), sk(0.9)})
			local st = bx:FindFirstChildOfClass("UIStroke")
			local x = mk("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 1, 0), Font = fn, TextSize = 13, TextColor3 = c.tx, PlaceholderText = tostring(r.Placeholder or ""), PlaceholderColor3 = c.dm, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Text = type(r.Default) == "string" and r.Default or "", Parent = bx})
			e.v, e.ld = x.Text, tostring
			function e:Set(v)
				v = tostring(v)
				x.Text = v
				if v == e.v then return end
				e.v = v
				put(e, v)
				run(r.Callback, v)
			end
			x.Focused:Connect(function() tw(st, {Color = c.ac, Transparency = 0}) end)
			x.FocusLost:Connect(function()
				tw(st, {Color = c.tx, Transparency = 0.9})
				e:Set(x.Text)
			end)
			done(e)
			return e
		end

		local function kc(v)
			if v == nil then return nil end
			if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return v end
			return false
		end

		function T:Keybind(r)
			r = r or {}
			local d = kc(r.Default)
			if d == false then error("Keybind Failed: Bad Key", 0) end
			local e, f = row("Keybind", r)
			local cb = bt({AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = c.bg, Parent = f}, {rc(4), sk(0.9), pd(10, 10)})
			local kl = tl({Text = "", TextSize = 12, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center, Parent = cb})
			local wt = false
			e.v, e.sv, e.ld = d, function(v) return v and v.Name or false end, function(s) return type(s) == "string" and Enum.KeyCode[s] or nil end
			local function draw()
				kl.Text, kl.TextColor3 = wt and "..." or (e.v and e.v.Name or "None"), (wt or e.v) and c.tx or c.dm
			end
			draw()
			function e:Set(v)
				local k = kc(v)
				if k == false then error("Keybind Set Failed: Bad Key", 0) end
				if k == e.v then return end
				e.v = k
				draw()
				put(e, k)
			end
			hov(cb, function() return c.bg end)
			cb.Activated:Connect(function()
				wt = not wt
				W.kw = wt
				draw()
			end)
			table.insert(W.cn, uis.InputBegan:Connect(function(i, gp)
				if i.UserInputType ~= kb then return end
				if wt then
					wt, W.kw = false, false
					if i.KeyCode == Enum.KeyCode.Backspace then e:Set(nil) elseif i.KeyCode ~= Enum.KeyCode.None then e:Set(i.KeyCode) end
					draw()
					return
				end
				if gp or not e.v or i.KeyCode ~= e.v or uis:GetFocusedTextBox() then return end
				run(r.Callback)
			end))
			done(e)
			return e
		end

		return T
	end

	function W:Destroy()
		dead = true
		for _, x in W.cn do x:Disconnect() end
		W.cn = {}
		save()
		sg:Destroy()
		if ge.__AvW == W then ge.__AvW = nil end
	end

	ge.__AvW = W
	return W
end

return L
end)()

local ge = getgenv()
local gi = (function()
	local dc, p = crypt and crypt.base64decode or base64_decode, "Avenoric/Assets/NgaoLogo.png"
	if not (dc and getcustomasset and writefile) then return nil end
	local ok, r = pcall(function()
		if not isfolder("Avenoric") then makefolder("Avenoric") end
		if not isfolder("Avenoric/Assets") then makefolder("Avenoric/Assets") end
		writefile(p, dc("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"))
		return getcustomasset(p)
	end)
	return ok and type(r) == "string" and r or nil
end)()
if ge.__FmD then pcall(function() ge.__FmD:Destroy() end) end
ge.__FmD = nil
local gw = L:Window({Title = "Vinh hub v2 anti ban", Config = `FishingMaster/{lp.Name}`})
do
	local on = gw.Notify
	gw.Notify = function(s, q)
		if type(q) == "table" then zx(`[{q.Title or "Hub"}] {q.Text or ""}`) end
		return on(s, q)
	end
	local ok, ex = pcall(function() return table.concat({identifyexecutor()}, " ") end)
	local uis = game:GetService("UserInputService")
	zx(`[Hub] Loaded | Place {game.PlaceVersion} | Server {game.JobId:sub(1, 8)} | {#ps:GetPlayers()} Players | {ok and ex or "Unknown Executor"} | {uis.TouchEnabled and not uis.KeyboardEnabled and "Mobile" or "PC"}`)
end
do
	for _, x in gw.Gui:GetChildren() do
		local t = x:IsA("GuiButton") and x:FindFirstChildWhichIsA("TextLabel")
		if t and t.Text == "studio" then x.Visible = false end
	end
	if ge.__FmNg then pcall(ge.__FmNg) end
	local tws, cs = game:GetService("TweenService"), {}
	local ok0, b0 = pcall(function() return lp.PlayerGui:WaitForChild("HUD", 5).Frame.Buttons end)
	local hu, ht = ok0 and b0 or nil, 0
	local hb = hu and hu:FindFirstAncestorOfClass("ScreenGui")
	local sh = Instance.new("ScreenGui")
	sh.Name, sh.ResetOnSpawn, sh.IgnoreGuiInset, sh.ZIndexBehavior, sh.DisplayOrder = hs:GenerateGUID(false), false, true, Enum.ZIndexBehavior.Sibling, 998
	if hb then
		sh.IgnoreGuiInset = hb.IgnoreGuiInset
		pcall(function() sh.ScreenInsets = hb.ScreenInsets end)
	end
	if not pcall(function() sh.Parent = gethui() end) then sh.Parent = lp.PlayerGui end
	local se, fl = hu and hu:FindFirstChild("Settings"), nil
	if se then
		fl = se:Clone()
		for _, d in fl:GetDescendants() do
			if d:IsA("LuaSourceContainer") or d.Name == "HasNotification" then d:Destroy() end
		end
		local t = fl:FindFirstChild("Title", true)
		if t and t:IsA("TextLabel") then t.Text = "Vinh" end
		if gi then
			for _, d in fl:GetDescendants() do
				if d:IsA("ImageLabel") and d.Name == "Icon" then
					d.Image = gi
					local u = Instance.new("UICorner")
					u.CornerRadius, u.Parent = UDim.new(1, 0), d
				end
			end
		end
		fl.Name, fl.AnchorPoint, fl.LayoutOrder, fl.Parent = "Vinh", Vector2.zero, 0, sh
	else
		fl = Instance.new("ImageButton")
		fl.Name, fl.Size, fl.BackgroundColor3, fl.BackgroundTransparency, fl.AutoButtonColor, fl.Image = "Vinh", UDim2.fromOffset(44, 44), Color3.fromRGB(18, 18, 21), 0.08, false, gi or ""
		local u = Instance.new("UICorner")
		u.CornerRadius, u.Parent = UDim.new(0, 22), fl
		fl.Parent = sh
	end
	local fu = fl:FindFirstChildOfClass("UIScale")
	if not fu then
		fu = Instance.new("UIScale")
		fu.Parent = fl
	end
	local hz = se ~= nil
	local function hp()
		if hz and not (hu and hu.Parent and hu:IsDescendantOf(game)) and os.clock() - ht > 1 then
			ht = os.clock()
			local ok, b = pcall(function() return lp.PlayerGui.HUD.Frame.Buttons end)
			hu = ok and b or nil
			hb = hu and hu:FindFirstAncestorOfClass("ScreenGui")
		end
		local s, i = hz and hu and hu:FindFirstChild("Settings"), hz and hu and hu:FindFirstChild("Index")
		if s and i and hb then
			local u, g = s:FindFirstChildOfClass("UIScale"), sh.AbsolutePosition
			local z, c1 = s.AbsoluteSize / math.max(u and u.Scale or 1, 0.01), s.AbsolutePosition + s.AbsoluteSize / 2
			local p = c1 * 2 - (i.AbsolutePosition + i.AbsoluteSize / 2) - z / 2 - g
			fl.Size, fl.Position = UDim2.fromOffset(z.X, z.Y), UDim2.fromOffset(p.X, p.Y)
			fl.Visible = hb.Enabled and hu.Parent.Visible and hu.Visible and s.Visible
		else
			fl.Size, fl.Position, fl.Visible = UDim2.fromOffset(44, 44), UDim2.fromOffset(16, game:GetService("GuiService"):GetGuiInset().Y + 8), true
		end
	end
	hp()
	table.insert(cs, game:GetService("RunService").RenderStepped:Connect(hp))
	local fm, fv = fl:FindFirstChild("Image"), false
	local fk = fm and fm:FindFirstChild("Icon")
	local function fa(x, ro)
		tws:Create(fu, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Scale = x}):Play()
		if fk and ro then tws:Create(fk, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Rotation = ro}):Play() end
	end
	table.insert(cs, fl.MouseEnter:Connect(function()
		fv = true
		fa(1.05, 5)
	end))
	table.insert(cs, fl.MouseLeave:Connect(function()
		fv = false
		fa(1, 0)
	end))
	table.insert(cs, fl.MouseButton1Down:Connect(function() fa(0.9) end))
	table.insert(cs, fl.MouseButton1Up:Connect(function() fa(fv and 1.05 or 1) end))
	table.insert(cs, fl.Activated:Connect(function() if gw.Main.Visible then gw:Hide() else gw:Show() end end))
	local function dn()
		for _, c in cs do c:Disconnect() end
		table.clear(cs)
		pcall(function() sh:Destroy() end)
		if ge.__FmNg == dn then ge.__FmNg = nil end
	end
	ge.__FmNg = dn
	table.insert(cs, gw.Gui.Destroying:Connect(dn))
end
local gr = false
local function wg(k, fn)
	if gr then
		fn()
		return
	end
	task.spawn(function()
		repeat task.wait(0.1) until gr
		if L.Flags[k] == true then fn() end
	end)
end
local gt, ft = gw:Tab({Name = "General", Icon = "shrimp"}), nil

local xl: {[any]: any} = {}

local function xt()
	local d, r = pd(), lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	local n, f, i = 0, ge.__FmF, ic()
	for _ in (d.Inventory or {}).Fishes or {} do n += 1 end
	local fu = md("Shared", "Lib", "FishStorageRules").GetState(d).isFull
	local p = r and `{math.floor(r.Position.X)}, {math.floor(r.Position.Y)}, {math.floor(r.Position.Z)}` or "None"
	return `[State] Island {i ~= "" and i or "Sea"} | Pos {p} | Coin {d.Coin or 0} | Satchel {n}{fu and " Full" or ""} | Quest {((d.Quest or {}).Current or {}).Id or ""} | Daily {((d.DailyQuest or {}).Active or {}).Template or ""} | Rod {d.RodEquip or "?"} | Farm {f and f.st or "Off"}{f and f.bu and " At Boss" or ""}`
end

local function cx(fn, ...)
	local r, dn
	task.spawn(function(...)
		local tb
		r = table.pack(xpcall(fn, function(x)
			tb = debug.traceback(tostring(x), 2)
			return x
		end, ...))
		if not r[1] and not xl[r[2]] and (tb ~= xl.lt or os.clock() - (xl.tt or 0) > 60) then
			xl.lt, xl.tt = tb, os.clock()
			zx(`[Error] {tb or r[2]}`)
			local ok, s = pcall(xt)
			if ok then zx(s) end
		end
		dn = true
	end, ...)
	repeat task.wait() until dn
	return table.unpack(r, 1, r.n)
end

local function fb(f)
	local s, fc = f.s, rv.FishingController
	for n, cb in {
		FishWaitingAck = function() s.wa = true end,
		FishFirstPullStart = function(id, hp, mx, lm, st) s.fp, s.id, s.xh, s.xm = {lm, st}, id, hp, mx end,
		FishFirstPullResult = function(m) s.pm = m end,
		FishReelStartAck = function(id, hp, mx) s.rl, s.id, s.xh, s.xm = true, s.id or id, s.xh or hp, s.xm or mx end,
		FishReelHPUpdate = function(hp) s.xh = hp end,
		FishReelPhaseHP = function(hp, mx) s.xh, s.xm, s.xp = hp, mx, 2 end,
		FishQTEPrompt = function(d) s.q = {d, os.clock() + 0.2 + math.random() * 0.15} end,
		FishQTECancel = function() s.q = nil end,
		FishSkillWindow = function(w) s.sw = os.clock() + w end,
		FishBossStun = function(w) s.bs = os.clock() + w end,
		FishCatchResult = function(ok, _, _, _, _, sp) s.cr = {ok, sp} end,
		FishReset = function(r) s.rr = r end,
	} do table.insert(f.cs, fc[n].OnClientEvent:Connect(cb)) end
	table.insert(f.cs, rv.BossRegionController.BossSpawnClaimed.OnClientEvent:Connect(function(v) s.bc, s.bv = v == true, v end))
	table.insert(f.cs, md("Data", "Packets", "SuperBossPackets").Spawned.OnClientEvent:Connect(function() s.rt = workspace:GetServerTimeNow() end))
	table.insert(f.cs, md("Data", "Packets", "DailyQuestPackets").Completed.OnClientEvent:Connect(function(g, c)
		if f.dq() then f.nq = {Title = "Daily Quest", Text = `Daily Quest Done: +{g} Gem, +{c} Coin`} end
	end))
	table.insert(f.cs, rv.RodController.ReplicatedSkillCooldown.OnClientEvent:Connect(function(t)
		if typeof(t) ~= "table" then return end
		for k, v in t do
			if type(v) == "table" and type(v.phase) == "string" then s.cd[k] = {v.phase, os.clock() + (tonumber(v.remaining) or 0)} end
		end
	end))
	local tb
	local ok, e = xpcall(rn, function(x)
		tb = debug.traceback(tostring(x), 2)
		return x
	end, f)
	for _, c in f.cs do c:Disconnect() end
	local _, hr = lc()
	local hq = (f.hp or f.hf()) and hr and hr.Position.Y > -10 and ut(hr.Position)
	if hq and (hr.Position.Y < hq.Y - 4 or hr.Position.Y > 500) then
		mo(hq, 1e6)
		task.wait(0.1)
	end
	if cj then cj:Stop() end
	if not ok then
		zx(`[Auto Fish] Crash: {tb or e}`)
		xl[e] = true
		error(e, 0)
	end
end

local function fs()
	local o = ge.__FmF
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local f = {st = "Running", s = {cd = {}, sw = 0, bs = 0, rt = 0}, cs = {}, c = 0, rp = true, dn = false, bu = false, qx = {}, qw = {}, nq = false, zv = {sh = ""}, rx = 0, tx = 0, fx = 0, lx = 0, ry = 0, ir = false, rt = {}, rsk = false, rss = false, rcs = false, rbs = {}}
	function f.ao() return L.Flags.as == true end
	function f.au() return L.Flags.au == true end
	function f.qa() return L.Flags.qa == true or L.Flags.ka == true end
	function f.qs() return L.Flags.ka == true and qm[L.Flags.ks] or L.Flags.ka ~= true and qm[L.Flags.qs] or nil end
	function f.ya() return L.Flags.ya == true end
	function f.ys() return L.Flags.ys or {} end
	function f.kp(nf)
		local k = f.au() and qv(qn(f)) or {}
		for u in f.qa() and qv(qp(f)) or {} do k[u] = true end
		local d = pd()
		local cq = (d.Quest or {}).Current or {}
		for _, q in f.ya() and qk(d, f.ys()) or {} do
			for u in select(2, qc(q, d, cq.Id == q[1] and qe(q[1], cq.Progress) or {RequiredFish = 3})) do k[u] = true end
		end
		if f.tk() then
			local k2, _, _, nd = f.tq()
			for u in nd and k2 or {} do k[u] = true end
		end
		if f.fg() and not nf then
			local _, st3 = f.fy()
			for _, u in st3 and st3.fishUids or {} do k[u] = true end
		end
		for _, q in f.qa() and (f.qs() or {})[10] or {} do
			if md("Shared", "Lib", "questRules").IsCompleted(d, q[1]) then continue end
			for u in select(2, qc(q, d, qe(q[1], cq.Id == q[1] and cq.Progress or {}))) do k[u] = true end
		end
		return k
	end
	function f.sr() return L.Flags.sr or {} end
	function f.fi() return ix[L.Flags.fi] end
	function f.ab() return L.Flags.ab == true end
	function f.hf() return L.Flags.hf == true end
	function f.dq() return L.Flags.dq == true end
	function f.rn()
		if L.Flags.rw == true then return true end
		if L.Flags.ka ~= true then return false end
		local q, d = f.qs(), pd()
		local c4 = q and ((d.Quest or {}).Current or {}).Id == q[1] and (md("Data", "Config", "QuestConfig").Data or {})[q[1]] or {}
		for _, x in c4.drops or {} do
			if x.fishId == "celestial_rainbow" and md("Shared", "getItemCount")(d, x.itemId) < ((c4.items or {})[x.itemId] or 1) then return true end
		end
		return false
	end
	function f.tk() return L.Flags.tk == true end
	function f.nv(il, ni, tg, fn, ux, tt)
		local ok, e = ti(f, il, f.bk())
		if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
		local _, lr = lc()
		local gu = lr and lr.Position.Y < -10 and ut(lr.Position)
		if gu then
			mo(gu, 1e6)
			task.wait(0.1)
		end
		local np = gn({}, ni, il)
		if not np then
			f.nq = {Title = tt, Text = `{tt} Failed: No NPC`}
			return nil
		end
		for _, u in ux or {} do
			local s2, v = rv.SellController:ToggleLock(u)
			if s2 ~= 0 or v ~= false then
				f.nq = {Title = tt, Text = `{tt} Failed: Unlock Fish Failed`}
				return nil
			end
		end
		local c, rt = lc()
		if not rt then return nil, "No Character" end
		ok, e = an(f, c, np, rt.Position)
		if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
		if f.st ~= "Running" then return nil end
		local _, st, m = fn()
		f.rp = true
		return st, nil, m
	end
	function f.tq()
		local d, ct, rc2 = pd(), md("Data", "Catalog"), md("Data", "Config", "RaidConfig")
		local ex, ks, mi, n, fs2 = rc2.Exchange, {}, nil, 0, (pd().Inventory or {}).Fishes or {}
		local r, wu, nw = d.Raid or {}, md("Shared", "Lib", "raidWindow").Used, workspace:GetServerTimeNow()
		local nd = ul(rc2.RequiredIsland) and wu(r.ExchangeWindowStart or 0, r.ExchangeCount or 0, nw, rc2.WindowSeconds) < rc2.ExchangesPerWindow and md("Shared", "getItemCount")(d, rc2.TicketId) < rc2.RunsPerWindow - wu(r.RunWindowStart or 0, r.RunCount or 0, nw, rc2.WindowSeconds)
		for _, il in ex.Islands do
			local sp, cs = {}, {}
			for _, x in (ct.Island.GetById(il) or {}).fishes or {} do sp[x.fishId] = true end
			for u, x in fs2 do
				local fo = ct.Fish.GetById(x.fishId)
				if sp[x.fishId] and fo and fo.rarity == ex.Rarity and x.locked ~= true and x.isHuge ~= true then table.insert(cs, u) end
			end
			table.sort(cs, md("Shared", "Lib", "QuestFishRules").CheapestFirst(fs2))
			for i = 1, math.min(#cs, ex.PerIsland) do ks[cs[i]] = true end
			if #cs >= ex.PerIsland then
				n += 1
			elseif not mi and ul(il) then
				mi = il
			end
		end
		return ks, mi, n == #ex.Islands, nd
	end
	function f.rk()
		local rc2 = md("Data", "Config", "RaidConfig")
		if not ul(rc2.RequiredIsland) then return qw(f, "tl", "Raid Ticket Waiting: Snow Island Locked", "Raid Ticket") end
		if os.clock() < (f.tx or 0) then return nil end
		local _, _, ok, nd = f.tq()
		if not (ok and nd) then return nil end
		zx(`[Raid] Going To {rc2.InteractiveIds.TicketNpc} For A Ticket | From {ic() ~= "" and ic() or "Sea"}`)
		local pt = md("Data", "Packets", "RaidPackets").ExchangeTicket
		local st, e = f.nv(rc2.RequiredIsland, rc2.InteractiveIds.TicketNpc, "Raid Ticket", function()
			local s3 = pt:Fire()
			return s3 ~= 3, s3
		end, nil, "Raid Ticket")
		if st == nil then
			f.tx = os.clock() + 60
			return true, e
		end
		local nm = ({[0] = "Ok", "Left", "Not Loaded", "Not Near", "No Ticket", "Daily Limit", "Full", "Busy", "Not Member", "Forfeited", "Wrong Order", "Wrong Phase", "Already Claimed", "Unknown", "Missing Fish", "Error", "On Other Pad", "Starting", "No Gems", "No Books", "Book Full", "Already Traded", "Island Locked"})[st or -1] or tostring(st or "No Response")
		zx(`[Raid] Exchange Ticket: {nm}`)
		if st == 0 then
			f.nq = {Title = "Raid Ticket", Text = "Raid Ticket Exchanged"}
			return true
		end
		f.tx, f.nq = os.clock() + 300, {Title = "Raid Ticket", Text = `Raid Ticket Failed: {nm}`}
		return true
	end
	function f.rz()
		local rc, cf, en = rv.RaidController, md("Data", "Config", "RaidConfig"), md("Data", "Enums", "RaidEnums")
		local rp, ph, d, sn = md("Data", "Packets", "RaidPackets"), rv.RaidController and rv.RaidController._phase or 0, pd(), {}
		for k, v in en.Status do sn[v] = (k:gsub("(%l)(%u)", "%1 %2")) end
		f.ir = ph >= en.Phase.Counting
		local c, r = lc()
		if not r then return nil, "No Character" end
		local function lg(t) zx(`[Raid] {t}`) end
		local function ix2(id, p)
			local o = {}
			for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
				local q = x:GetAttribute("InteractiveId") == id and (x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position)
				if q then table.insert(o, {x, q}) end
			end
			table.sort(o, function(a, b) return (a[2] - p).Magnitude < (b[2] - p).Magnitude end)
			return o
		end
		local function fr2(p)
			if zy.fr[p.UserId] == nil then
				local ok, v = pcall(lp.IsFriendsWith, lp, p.UserId)
				zy.fr[p.UserId] = ok and v == true
			end
			return zy.fr[p.UserId]
		end
		local function pk(ps)
			local md2, b0, bs = L.Flags.rt or "Solo", nil, -1
			for _, x in ps do
				local m, n, fz2 = x[1], 0, false
				while m.Parent and m.Parent.Name ~= "Raids" do m = m.Parent end
				local a = m:GetAttribute("RaidPhase")
				for _, p in game:GetService("Players"):GetPlayers() do
					local h = p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
					if h and (h.Position - x[2]).Magnitude <= cf.PadLeaveRadius then n, fz2 = n + 1, fz2 or fr2(p) end
				end
				local op = a == nil or a == en.Phase.Waiting or a == en.Phase.Counting
				local sc = op and n == 0 and (a == nil or a == en.Phase.Waiting) and 0 or op and n < cf.MaxMembers and (md2 == "Anyone" and n or md2 == "With Friends" and fz2 and 10 + n) or nil
				if sc and sc > bs then b0, bs = {x[1], x[2], m.Name, n}, sc end
			end
			return b0
		end
		local function tr2(q)
			local cs, m, b = workspace:FindFirstChild("Cars"), nil, 600
			for _, x in cs and cs:GetChildren() or {} do
				local dd = x:IsA("Model") and x.Name:find("^RaidTruck_") and (x:GetPivot().Position - r.Position).Magnitude
				if dd and dd < b then m, b = x, dd end
			end
			if not m then return nil, "No Truck" end
			local ip, w = RaycastParams.new(), nil
			ip.FilterType, ip.FilterDescendantsInstances, ip.RespectCanCollide = Enum.RaycastFilterType.Exclude, {c, cs, workspace:FindFirstChild("Ocean")}, true
			for rr = 20, 120, 10 do
				for i = 0, 31 do
					local p = q + Vector3.new(math.cos(i * math.pi / 16) * rr, 0, math.sin(i * math.pi / 16) * rr)
					local h = not w and workspace:Raycast(Vector3.new(p.X, 200, p.Z), Vector3.new(0, -400, 0), ip)
					if not w and (not h or h.Material == Enum.Material.Water or h.Position.Y < 2) then w = p end
				end
				if w then break end
			end
			if not w then return nil, "No Water Near Guide" end
			lg(`Truck {m.Name} | {math.floor(b)} Studs To Truck | {math.floor((w - m:GetPivot().Position).Magnitude)} Studs To Water Near Guide`)
			local ok, e = sb(f, m)
			if not ok then return nil, e end
			return dv(f, m, nil, w)
		end
		if ph < en.Phase.AwaitReady then
			if ph >= en.Phase.Counting then
				task.wait(1)
				return true
			end
			local ci, dr = md("Shared", "getItemCount"), d.Raid or {}
			if os.clock() < (f.ry or 0) or ci(d, cf.TicketId) < 1 or not ul(cf.RequiredIsland) or md("Shared", "Lib", "raidWindow").Used(dr.RunWindowStart or 0, dr.RunCount or 0, workspace:GetServerTimeNow(), cf.WindowSeconds) >= cf.RunsPerWindow then return nil end
			lg(`Join Trip | Tickets {ci(d, cf.TicketId)} | Team {L.Flags.rt or "Solo"} | From {ic() ~= "" and ic() or "Sea"}`)
			local ok, e = ti(f, cf.RequiredIsland, f.bk())
			if not ok then
				f.ry = os.clock() + 60
				return nil, e or "Snow Trip Failed"
			end
			c, r = lc()
			if not r then return nil, "No Character" end
			local ps = ix2(cf.InteractiveIds.Pad, r.Position)
			if #ps == 0 then
				sq(rg(cf.RequiredIsland) or r.Position, 10)
				ps = ix2(cf.InteractiveIds.Pad, r.Position)
			end
			local pd3 = pk(ps)
			if not pd3 then
				lg(`No Pad For Team {L.Flags.rt or "Solo"} | {#ps} Pads Seen`)
				f.ry = os.clock() + 30
				return qw(f, "rpf", "Raid Waiting: No Free Pad", "Raid")
			end
			ok, e = go(f, pd3[2] + Vector3.new(0, 3, 0))
			if not ok then
				f.ry = os.clock() + 30
				return nil, e or "Move Failed"
			end
			local s1 = rp.JoinPad:Fire()
			lg(`Join Pad {pd3[3]} ({pd3[4]} Others): {sn[s1] or tostring(s1)}`)
			if s1 ~= 0 then
				f.ry, f.nq = os.clock() + 60, {Title = "Raid", Text = `Raid Join Failed: {sn[s1] or "No Response"}`}
				return true
			end
			local t0 = os.clock()
			repeat task.wait(0.5) until (rc._phase or 0) >= en.Phase.AwaitReady or (rc._phase or 0) == en.Phase.Waiting and os.clock() - t0 > 5 or f.st ~= "Running" or os.clock() - t0 > cf.CountdownSeconds + cf.LockMaxSeconds + 30
			lg(`Pad Wait End: Phase {rc._phase or "?"} After {math.floor(os.clock() - t0)} s`)
			return true
		end
		local sl = workspace:FindFirstChild("RaidSlots")
		sl = sl and sl:FindFirstChild(`Slot{rc._slot or 0}`)
		local st2, dn2 = rc._started or 0, rc._done or 0
		local nk = ph == en.Phase.AwaitReady and 1 or ph == en.Phase.Running and st2 == dn2 and dn2 < #cf.Islands and dn2 + 1 or nil
		if nk or ph == en.Phase.Won then
			local ia = nk and sl and sl:FindFirstChild("Indicators")
			ia = ia and ia:FindFirstChild(tostring(nk))
			ia = ia and (ia:IsA("Attachment") and ia or ia:FindFirstChildWhichIsA("Attachment", true))
			local g = ix2(cf.InteractiveIds.StartNpc, ia and ia.WorldPosition or r.Position)[1]
			if not g then
				lg(`No Raid Guide | Phase {ph} | Island {nk or "Claim"}`)
				task.wait(2)
				return true
			end
			if nk and nk > 1 and (g[2] - r.Position).Magnitude > 150 then
				local ok, e = tr2(g[2])
				lg(ok and `Truck To Island {nk}: Arrived` or `Truck To Island {nk} Failed: {e or "Stopped"}`)
				if f.st ~= "Running" then return nil end
				c, r = lc()
				if not r then return nil, "No Character" end
			end
			if (g[2] - r.Position).Magnitude > 10 then
				lg(`Going To Raid Guide {nk and `Island {nk}` or "Claim"} | {math.floor((g[2] - r.Position).Magnitude)} Studs`)
				local i3 = RaycastParams.new()
				i3.FilterType, i3.FilterDescendantsInstances, i3.RespectCanCollide = Enum.RaycastFilterType.Exclude, {c, workspace:FindFirstChild("Cars"), workspace:FindFirstChild("Ocean")}, true
				local ok, e = go(f, aq(c, g[2], r.Position, 10, i3), Vector3.new(g[2].X - r.Position.X, 0, g[2].Z - r.Position.Z).Unit)
				if not ok then return nil, e or "Move Failed" end
			end
			local s2 = (ph == en.Phase.Won and rp.Claim or rp.StartIsland):Fire()
			lg(`{ph == en.Phase.Won and "Claim" or `Start Island {nk}`}: {sn[s2] or tostring(s2)}`)
			if ph == en.Phase.Won and s2 == 0 then f.nq = {Title = "Raid", Text = "Raid Reward Claimed"} end
			task.wait(s2 == 0 and 1 or 2)
			return true
		end
		if ph ~= en.Phase.Running then
			task.wait(1)
			return true
		end
		local sp = {}
		for _, x in sl and sl:GetDescendants() or {} do
			if x.Name == cf.Template.FishSpots then
				for _, y in x:GetChildren() do
					local q = y:IsA("BasePart") and y.Position or y:IsA("Attachment") and y.WorldPosition or y:IsA("Model") and y:GetPivot().Position
					if q then table.insert(sp, q) end
				end
			end
		end
		if not (f.rcs and f.rcs[1] == sl and f.rcs[3] == st2 and #f.rcs[2] == #sp) then lg(`Fish Spots Found: {#sp} In Slot {rc._slot or "?"} | Island {st2}`) end
		f.rcs = {sl, sp, st2}
		local q0, k0, b1 = nil, nil, math.huge
		for _, q in f.rcs[2] do
			local k = `{math.floor(q.X)},{math.floor(q.Z)}`
			if (f.rt[k] or 0) < os.clock() and (q - r.Position).Magnitude < b1 then q0, k0, b1 = q, k, (q - r.Position).Magnitude end
		end
		if not q0 then
			lg("No Free Fish Spot")
			task.wait(2)
			return true
		end
		if f.rsk ~= k0 or not f.rss or (r.Position - f.rss).Magnitude > 8 then
			local ip = RaycastParams.new()
			ip.FilterType, ip.FilterDescendantsInstances, ip.RespectCanCollide = Enum.RaycastFilterType.Exclude, {c, workspace:FindFirstChild("Cars"), workspace:FindFirstChild("Ocean")}, true
			local gp
			local function fl3(h)
				if not (h and h.Material ~= Enum.Material.Water and h.Position.Y > q0.Y + 1 and h.Normal.Y > 0.8) then return false end
				for _, b in f.rbs do
					if ((b - h.Position) * Vector3.new(1, 0, 1)).Magnitude < 5 then return false end
				end
				for _, o in {Vector3.new(1.5, 0, 0), Vector3.new(-1.5, 0, 0), Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5)} do
					local h2 = workspace:Raycast(h.Position + o + Vector3.new(0, 5, 0), Vector3.new(0, -10, 0), ip)
					if not (h2 and math.abs(h2.Position.Y - h.Position.Y) < 1 and h2.Normal.Y > 0.7) then return false end
				end
				return true
			end
			for rr = 12, 72, 6 do
				for i = 0, 31 do
					local a = i * math.pi / 16
					local h = not gp and workspace:Raycast(q0 + Vector3.new(math.cos(a) * rr, 100, math.sin(a) * rr), Vector3.new(0, -200, 0), ip)
					if not gp and fl3(h) then gp = h.Position + Vector3.new(0, 3, 0) end
				end
			end
			local hv2 = not gp
			gp = gp or q0 + Vector3.new(16, 9, 0)
			lg(`Fish Spot {k0} | {hv2 and "Hover" or "Stand"} {math.floor(gp.X)}, {math.floor(gp.Y)}, {math.floor(gp.Z)} | {math.floor(b1)} Studs Away`)
			local ok, e = go(f, gp, Vector3.new(q0.X - gp.X, 0, q0.Z - gp.Z).Unit)
			if ok and hv2 then ok, e = hz(f, gp.Y) end
			if not ok then return nil, e or "Move Failed" end
			f.rsk, f.rss = k0, gp
		end
		return q0
	end
	function f.fg() return L.Flags.fg == true end
	function f.ag() return L.Flags.ag == true end
	function f.fy()
		local d, cf = pd(), md("Data", "Config", "RodForgeConfig")
		local rs3, tg3 = d.Rods or {}, nil
		if L.Flags.fm == "Reforge V1 To Perfect" then
			local fs3 = md("Shared", "Lib", "RodModifiers").GetForgedStats(cf.Order[1], rs3[cf.Order[1]])
			if not (fs3 and fs3.quality == cf.QualityNames[#cf.QualityNames]) then tg3 = cf.Order[1] end
		else
			local hi = 0
			for i, id in cf.Order do
				if rs3[id] ~= nil then hi = i end
			end
			tg3 = cf.Order[hi + 1]
		end
		if not tg3 then return nil end
		local st3, rc3, il3 = md("Shared", "Lib", "RodForgeRules").GetStatus(d, tg3), cf.Recipes[tg3], nil
		if st3 and st3.fishCount < rc3.fishCount then
			if rc3.fishKind == "Island7Legendary" then
				il3 = "island_lotus"
			elseif rc3.fishKind == "Islands23Legendary" then
				local ct, jg, n = md("Data", "Catalog"), {}, 0
				for _, x in (ct.Island.GetById("island_jungle") or {}).fishes or {} do jg[x.fishId] = true end
				for _, x in (d.Inventory or {}).Fishes or {} do
					local fo = ct.Fish.GetById(x.fishId)
					if jg[x.fishId] and x.locked ~= true and fo and fo.rarity == "Legendary" then n += 1 end
				end
				il3 = n < rc3.fishCount / 2 and "island_jungle" or "island_desert"
			end
		end
		return tg3, st3, il3 and ul(il3) and il3 or nil
	end
	function f.rf()
		if not ul("island_lotus") then return qw(f, "fl", "Rod Forge Waiting: Lotus Island Locked", "Rod Forge") end
		if os.clock() < (f.fx or 0) then return nil end
		local tg3, st3 = f.fy()
		if not tg3 then return qw(f, "fd", L.Flags.fm == "Reforge V1 To Perfect" and `{(md("Data", "Catalog").Rod.GetById("godslayer_rod_v1") or {}).name or "Godslayer Rod"} Is Perfect` or "Rod Forge Chain Done", "Rod Forge") end
		local rc3, rn3 = md("Data", "Config", "RodForgeConfig").Recipes[tg3], (md("Data", "Catalog").Rod.GetById(tg3) or {}).name or tg3
		if not (st3 and st3.ready) then
			if st3 and st3.fishCount >= rc3.fishCount and (rc3.mythicalBookCount == 0 or st3.bookId) and st3.hasPreviousRod and not (st3.hasCoin and st3.hasGem) then qw(f, `fc{tg3}`, `Rod Forge Waiting: {rn3} Needs {rc3.coinCost} Coins, {rc3.gemCost} Gems`, "Rod Forge") end
			return nil
		end
		local kp = f.kp(true)
		for _, u in st3.fishUids do
			if kp[u] then return qw(f, "fk", "Rod Forge Waiting: Fish Kept For Quest", "Rod Forge") end
		end
		zx(`[Forge] Going To npc_lotus_rod_forge For {tg3}{st3.bookId and ` | Book {st3.bookId}` or ""} | From {ic() ~= "" and ic() or "Sea"}`)
		local P = md("Stardust").Packet
		local pt = P("RodForge/Forge", P.String):Response(P.Boolean8, P.String)
		local ok, e, m = f.nv("island_lotus", "npc_lotus_rod_forge", "Rod Forge", function()
			local a, b = pt:Fire(tg3)
			local lb = tostring(b or ""):lower()
			return a == true or not (lb:find("close") or lb:find("near") or lb:find("far")), a, b
		end, nil, "Rod Forge")
		if ok == nil then
			f.fx = os.clock() + 60
			return true, e
		end
		zx(`[Forge] {tg3}: {tostring(ok)} {m or ""}`)
		if ok == true then
			local q3 = ((pd().Rods or {})[tg3] or {}).ForgedStats
			f.nq = {Title = "Rod Forge", Text = `Forged {rn3} ({q3 and q3.quality or "?"})`}
			return true
		end
		f.fx, f.nq = os.clock() + 300, {Title = "Rod Forge", Text = `Rod Forge Failed: {m or "Refused"}`}
		return true
	end
	function f.ru()
		local d, cf = pd(), md("Data", "Config", "SuperBossConfig").Bosses.celestial_rainbow
		if not ul("island_lotus") then return qw(f, "rl", "Rainbow Boss Waiting: Lotus Island Locked", "Rainbow Boss") end
		if os.clock() < (f.rx or 0) then return nil end
		local sc, wu, nw = (d.SuperBoss or {})[cf.id] or {}, md("Shared", "Lib", "raidWindow").Used, workspace:GetServerTimeNow()
		local ws = md("Data", "Config", "SuperBossConfig").WindowSeconds
		if wu(sc.JoinWindowStart or 0, sc.JoinCount or 0, nw, ws) >= cf.joinsPerWindow then return nil end
		local fs2, ni, pk, ux = (d.Inventory or {}).Fishes or {}, cf.summonerNpcId, "Summon", {}
		if md("Shared", "getItemCount")(d, cf.baitId) > 0 then
			if nw - (f.s.rt or -1e9) < cf.lifetimeSeconds then return nil end
		else
			if wu(sc.CraftWindowStart or 0, sc.CraftCount or 0, nw, ws) >= cf.craftsPerWindow then return nil end
			local sp, kp = md("Shared", "Lib", "QuestFishRules").SpeciesOf(cf.recipe.islandId, cf.recipe.rarity), f.kp()
			if #sp ~= cf.recipe.species then return nil end
			for _, fi in sp do
				local lu, ll
				for u, x in fs2 do
					if x.fishId == fi and x.locked ~= true and (not lu or (x.weight or 0) < (fs2[lu].weight or 0)) then lu = u end
					if x.fishId == fi and x.locked == true and not kp[u] and (not ll or (x.weight or 0) < (fs2[ll].weight or 0)) then ll = u end
				end
				if lu and kp[lu] then return qw(f, "rk", "Rainbow Bait Waiting: Fish Kept For Quest", "Rainbow Boss") end
				if not lu and not ll then return nil end
				if not lu then table.insert(ux, ll) end
			end
			ni, pk = cf.crafterNpcId, "CraftBait"
		end
		zx(`[Rainbow] Going To {ni} For {pk} | From {ic() ~= "" and ic() or "Sea"}`)
		local pt = md("Data", "Packets", "SuperBossPackets")[pk]
		local st, e = f.nv(cf.islandId, ni, `Rainbow {pk}`, function()
			local s3 = pt:Fire()
			return s3 ~= 2, s3
		end, ux, "Rainbow Boss")
		if st == nil then
			f.rx = os.clock() + 60
			return true, e
		end
		local nm = ({[0] = "Ok", "Not Loaded", "Not Near", "No Bait", "Daily Limit", "Missing Fish", "Busy", "Error", "Island Locked"})[st or -1] or tostring(st or "No Response")
		zx(`[Rainbow] {pk}: {nm}`)
		if st == 0 then
			if pk == "Summon" then f.s.rt = workspace:GetServerTimeNow() end
			f.nq = {Title = "Rainbow Boss", Text = pk == "Summon" and "Celestial Rainbow Summoned" or "Rainbow Bait Crafted"}
			return true
		end
		f.rx, f.nq = os.clock() + 60, {Title = "Rainbow Boss", Text = `Rainbow {pk == "Summon" and "Summon" or "Bait"} Failed: {nm}`}
		return true
	end
	function f.lo()
		if os.clock() < (f.lx or 0) then return end
		local ct, ba, eq2, sp = md("Data", "Catalog"), md("Utils", "skillBookAvailability"), rv.EquipmentsController, `Avenoric/Configs/FishingMaster/{lp.Name}_Books.txt`
		local function fe(e)
			zx(`[Gear] {e}`)
			f.lx = os.clock() + 60
			qw(f, "gr", e, "Gear")
		end
		local function bs(id) return ((pd().Rods or {})[id] or {}).BookSlots or {} end
		local function ra(id, r)
			local c, a = ct.Rod.GetById(id), 0
			for _, x in c and md("Shared", "Lib", "RodModifiers").Resolve(c, r) or {} do
				if x.stat == "attackDamage" and x.op == "add" then a += x.value end
			end
			return a
		end
		local function sl(id)
			local c, o = ct.Rod.GetById(id), {}
			local lv = md("Shared", "Lib", "getRequiredExp_Level").getLevel(((pd().Rods or {})[id] or {}).MasteryXp or 0)
			for n, u in c and c.slotUnlockLevels or {} do
				if n <= (c.skillSlots or 0) and u <= lv then table.insert(o, n) end
			end
			return o
		end
		local function pb(b, i, id)
			local x = eq2.EquipMoveset:Fire(b, i)
			if x ~= "Success" then return nil, `Book Equip Failed: {x or "No Response"}` end
			local dl = os.clock() + 3
			repeat task.wait(0.2) until (bs(id)[`Slot{i}`] or "") == b or b == "" and bs(id)[`Slot{i}`] == "None" or os.clock() > dl
			return true
		end
		local function cr(id)
			for s, b in bs(id) do
				local i = tonumber(tostring(s):match("%d+"))
				if i and b ~= "" and b ~= "None" then
					local ok, e = pb("", i, id)
					if not ok then return nil, e end
				end
			end
			return true
		end
		local function er(id)
			if pd().RodEquip == id then return true end
			if eq2.EquipmentEquip:Fire("rod", id) ~= true then return nil, "Rod Equip Failed: Refused" end
			local dl = os.clock() + 5
			repeat task.wait(0.2) until pd().RodEquip == id or os.clock() > dl
			if pd().RodEquip ~= id then return nil, "Rod Equip Failed: Timeout" end
			return true
		end
		local function bf(d, id, rm)
			local on, fm, b0, v0 = {}, 0, nil, -1
			for _, b in bs(id) do on[b] = true end
			for b in (d.Inventory or {}).Books or {} do
				if (ct.Skill.GetById(b) or {}).rarity == "Mythical" then fm += ba.GetCounts(d, b).available end
			end
			for b in (d.Inventory or {}).Books or {} do
				local c = ct.Skill.GetById(b)
				local v = c and c.damageCoef or 0
				if c and not on[b] and ba.GetCounts(d, b).available > 0 and not (c.rarity == "Mythical" and fm <= rm) and (v > v0 or v == v0 and b < b0) then b0, v0 = b, v end
			end
			return b0
		end
		local function rb()
			local ok, s = pcall(function() return isfile(sp) and readfile(sp) or nil end)
			return ok and type(s) == "string" and s:split("\n") or nil
		end
		local function sv(id, s)
			if rb() then return end
			pcall(writefile, sp, `{id}\n{s.Slot1 or ""}\n{s.Slot2 or ""}\n{s.Slot3 or ""}\n{s.Slot4 or ""}\n`)
			zx(`[Gear] Saved Books Of {id}`)
		end
		local d = pd()
		local cq, il = (d.Quest or {}).Current or {}, ic()
		local q = (cq.Id or "") ~= "" and f.qa() and qp(f) or nil
		if not (q and q[1] == cq.Id) then q = (cq.Id or "") ~= "" and f.ya() and qy(f) or nil end
		if q and q[1] ~= cq.Id then q = nil end
		local pr, qr, rq, fi = q and qe(q[1], cq.Progress) or {}, nil, {}, {}
		for _, x in q and ct.Island.GetAll() or {} do
			for _, y in x.fishes or {} do fi[y.fishId] = x.id end
		end
		for _, pi in {true, false} do
			for _, dg in {false, true} do
				for _, x in pr.Tr or {} do
					if x.raid ~= true and (tonumber(pr[x.field]) or 0) < x.target then
						if x.rodId and (d.Rods or {})[x.rodId] then qr = qr or x.rodId end
						if x.skillId and ((x.islandId or fi[x.fishId or ""]) == il) == pi and (x.event == "SkillDamage") == dg and not table.find(rq, x.skillId) then table.insert(rq, x.skillId) end
					end
				end
			end
		end
		local h, t, ta, cl, gx, rm, bd = d.RodEquip, d.RodEquip, -1, {}, {}, 0, false
		local nq = qr ~= nil or #rq > 0
		for id, r in d.Rods or {} do
			local a = ra(id, r)
			if a > ta or a == ta and id == h then t, ta = id, a end
		end
		t = qr or t
		local sn = not nq and rb()
		if t ~= h then
			for s, b in bs(h) do cl[s] = b end
			if nq then sv(h, cl) end
			local ok, e = cr(h)
			if ok then ok, e = er(t) end
			if ok then zx(`[Gear] Rod {h} -> {t}`) else fe(e); bd, t = true, pd().RodEquip end
		end
		for id, r in bd and {} or pd().Rods or {} do
			for _, b in id ~= t and r.BookSlots or {} do
				if b ~= "" and b ~= "None" and not table.find(gx, id) then table.insert(gx, id) end
			end
		end
		for _, id in gx do
			local ok, e = er(id)
			if ok then ok, e = cr(id) end
			local o2, e2 = er(t)
			if not (ok and o2) then fe(e or e2); bd, t = true, pd().RodEquip; break end
			zx(`[Gear] Books Taken Off {id}`)
		end
		if bd then sn, rq = nil, {} end
		if sn then cl = {Slot1 = sn[2], Slot2 = sn[3], Slot3 = sn[4], Slot4 = sn[5]} end
		if f.fg() then
			local tg3 = f.fy()
			rm = tg3 and (md("Data", "Config", "RodForgeConfig").Recipes[tg3] or {}).mythicalBookCount or 0
		end
		for _, r in rq do
			local d2, s2, sx, lv, hv = pd(), bs(t), nil, math.huge, false
			for _, x in s2 do
				if x == r then hv = true end
			end
			if not hv and (((d2.Inventory or {}).Books or {})[r] or 0) < 1 then
				qw(f, `gb{r}`, `{q[9] and "Soul" or "Rod"} Quest Waiting: No {(ct.Skill.GetById(r) or {}).name or r} Book`, q[9] and "Soul Quest" or "Rod Quest")
			elseif not hv and ba.GetCounts(d2, r).available > 0 then
				for _, n in sl(t) do
					local x = s2[`Slot{n}`] or ""
					if not sx and (x == "" or x == "None") then sx, lv = n, -1 end
				end
				for _, n in lv > 0 and sl(t) or {} do
					local x = s2[`Slot{n}`] or ""
					local v = (ct.Skill.GetById(x) or {}).damageCoef or 0
					if not table.find(rq, x) and v < lv then sx, lv = n, v end
				end
				if sx then
					sv(t, s2)
					local o = rb()
					if o then
						o[6] = `{o[6] or ""},{r}`
						pcall(writefile, sp, table.concat(o, "\n"))
					end
					local ok, e = pb(r, sx, t)
					if not ok then fe(e); return end
					zx(`[Gear] Quest {q[1]} {t} Slot{sx}: {r}`)
				end
			end
		end
		if sn then
			local pl = (sn[6] or ""):split(",")
			for _, n in sl(t) do
				local k = `Slot{n}`
				local v = bs(t)[k] or ""
				if v ~= "" and v ~= cl[k] and table.find(pl, v) then
					local ok, e = pb("", n, t)
					if not ok then fe(e); return end
					zx(`[Gear] Quest Book Off {t} {k}: {v}`)
				end
			end
		end
		for _, n in sl(t) do
			local d2, k = pd(), `Slot{n}`
			local v, c0, on = bs(t)[k] or "", cl[k], false
			for _, x in bs(t) do
				if x == c0 then on = true end
			end
			if v == "" or v == "None" then
				local b = type(c0) == "string" and c0 ~= "" and c0 ~= "None" and not on and ba.GetCounts(d2, c0).available > 0 and c0 or bf(d2, t, rm)
				if b then
					local ok, e = pb(b, n, t)
					if not ok then fe(e); return end
					zx(`[Gear] {t} {k}: {b}`)
				end
			end
		end
		if sn then
			pcall(delfile, sp)
			zx(`[Gear] Books Restored From {sn[1] or "?"}`)
		end
	end
	function f.bk() return bi[L.Flags.sb] or "truck" end
	function f.iw()
		local j, id, g, b, t, u, o = ge.__FmI, ix[L.Flags.si], ge.__FmG, ge.__FmR, ge.__FmT, ge.__FmU, ge.__FmO
		return g and not g.dn and (g.bz or g.rq and not f.bu) or b and not b.dn and (b.bz or b.rq and not f.bu) or j and not j.dn and (j.bz or id and ic() ~= id) or t and not t.dn and t.bz or u and not u.dn and (u.bz or u.rq and not f.bu) or o and not o.dn and (o.bz or o.rq and not f.bu) or false
	end
	ge.__FmF = f
	task.spawn(function()
		while not f.dn do
			local x = f.nq
			if x then
				f.nq = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(fb, f)
	if not ok then f.why = `Auto Fish Failed: {e}` end
	f.dn = true
	if ge.__FmF ~= f or not f.why then return end
	task.spawn(function()
		local sk, sv = pcall(xt)
		if sk then zx(sv) end
	end)
	gw:Notify({Title = "Auto Fish", Text = f.why})
	ft:Set(false)
end

local function ib(j)
	local n = 0
	while j.st == "Running" do
		local id, fm = ix[L.Flags.si], ge.__FmF
		if not id then j.why = "Auto Island Failed: No Island Selected"; return end
		if ic() == id then j.ar = true; return end
		if not (fm and not fm.dn and fm.bz or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz) then
			j.bz = true
			local ok, e = ti(j, id, bi[L.Flags.sb] or "truck")
			j.bz = false
			if ok then j.ar = true; return end
			n = j.st == "Running" and n + 1 or n
			if n >= 3 then j.why = `Auto Island Failed: {e}`; return end
		end
		task.wait(1)
	end
end

local it
local function is()
	local o = ge.__FmI
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", ar = false}
	ge.__FmI = j
	local ok, e = cx(ib, j)
	if not ok then j.why = `Auto Island Failed: {e}` end
	j.dn = true
	if ge.__FmI ~= j or not (j.why or j.ar) then return end
	if j.why then gw:Notify({Title = "Auto Island", Text = j.why}) end
	it:Set(false)
end

local nz, nl, nj = {
	{"Fish Merchant - Starter Island", "npc_fish_seller", "island_starter"},
	{"Rod Merchant - Starter Island", "npc_rod_shop", "island_starter"},
	{"Boat Merchant - Starter Island", "npc_car_merchant", "island_starter"},
	{"Skill Master", "npc_gacha_book", "island_starter"},
	{"Auras Dealer", "npc_gacha_aura", "island_starter"},
	{"Unit Summoner", "npc_gacha_unit", "island_starter"},
	{"Skill Market", "npc_premium_skill", "island_starter"},
	{"Daily Quests - Starter Island", "npc_daily_quest", "island_starter"},
	{"Jungle Island Guide", "npc_unlock_island_2", "island_jungle"},
	{"Fish Merchant - Jungle Island", "npc_fish_seller", "island_jungle"},
	{"Rod Merchant - Jungle Island", "npc_rod_shop", "island_jungle"},
	{"Boat Merchant - Jungle Island", "npc_car_merchant", "island_jungle"},
	{"Daily Quests - Jungle Island", "npc_daily_quest", "island_jungle"},
	{"Desert Island Guide", "npc_unlock_island_3", "island_desert"},
	{"Fish Merchant - Desert Island", "npc_fish_seller", "island_desert"},
	{"Rod Merchant - Desert Island", "npc_rod_shop", "island_desert"},
	{"Boat Merchant - Desert Island", "npc_car_merchant", "island_desert"},
	{"Daily Quests - Desert Island", "npc_daily_quest", "island_desert"},
	{"White Tiger Guardian", "npc_white_tiger", "island_desert"},
	{"Sage Yijiu", "npc_sage_yijiu", "island_desert"},
	{"Snow Island Guide", "npc_unlock_island_4", "island_snow"},
	{"Fish Merchant - Snow Island", "npc_fish_seller", "island_snow"},
	{"Rod Merchant - Snow Island", "npc_rod_shop", "island_snow"},
	{"Boat Merchant - Snow Island", "npc_car_merchant", "island_snow"},
	{"Daily Quests - Snow Island", "npc_daily_quest", "island_snow"},
	{"Phoenix Guardian", "npc_phoenix", "island_snow"},
	{"Taiji Master", "npc_giang_lao_snow", "island_snow"},
	{"Ticket Keeper", "npc_raid_ticket", "island_snow"},
	{"Volcanic Island Guide", "npc_unlock_island_5", "island_volcano"},
	{"Fish Merchant - Volcanic Island", "npc_fish_seller", "island_volcano"},
	{"Boat Merchant - Volcanic Island", "npc_car_merchant", "island_volcano"},
	{"Daily Quests - Volcanic Island", "npc_daily_quest", "island_volcano"},
	{"Crimson Bead Craftsman", "npc_crimson_bead_rod", "island_volcano"},
	{"Bamboo Rod Craftsman", "npc_bamboo_rod", "island_volcano"},
	{"Azure Dragon Guardian", "npc_azure_dragon", "island_volcano"},
	{"Duan Gan", "npc_duan_gan_volcano", "island_volcano"},
	{"Fossil Island Guide", "npc_unlock_island_6", "island_fossil"},
	{"Fish Merchant - Fossil Island", "npc_fish_seller", "island_fossil"},
	{"Boat Merchant - Fossil Island", "npc_car_merchant", "island_fossil"},
	{"Daily Quests - Fossil Island", "npc_daily_quest", "island_fossil"},
	{"Heaven Piercer Craftsman", "npc_ha_dieu_de_fossil", "island_fossil"},
	{"Zen Staff Craftsman", "npc_fei_tian_fossil", "island_fossil"},
	{"Dread Fish Craftsman", "npc_dread_fish_rod", "island_fossil"},
	{"Supreme King Guardian", "npc_supreme_king", "island_fossil"},
	{"Lotus Island Guide", "npc_unlock_island_7", "island_lotus"},
	{"Fish Merchant - Lotus Island", "npc_fish_seller", "island_lotus"},
	{"Boat Merchant - Lotus Island", "npc_car_merchant", "island_lotus"},
	{"Daily Quests - Lotus Island", "npc_daily_quest", "island_lotus"},
	{"Skill Master - Lotus Island", "npc_gacha_book", "island_lotus"},
	{"Auras Dealer - Lotus Island", "npc_gacha_aura", "island_lotus"},
	{"Unit Summoner - Lotus Island", "npc_gacha_unit", "island_lotus"},
	{"Skill Market - Lotus Island", "npc_premium_skill", "island_lotus"},
	{"Chu Xin - Rod Quests", "npc_chu_xin_rod", "island_lotus"},
	{"Lotus Rod Forger", "npc_lotus_rod_forge", "island_lotus"},
	{"Rainbow Bait Crafter", "npc_rainbow_bait_crafter", "island_lotus"},
	{"Super Boss Summoner", "npc_super_boss_summoner", "island_lotus"},
}, {}, {}
for _, v in nz do
	table.insert(nl, v[1])
	nj[v[1]] = v
end

local function ne(v)
	local w = workspace:FindFirstChild("World")
	local fo = w and w:FindFirstChild("Islands") and w.Islands:FindFirstChild(v[3])
	if not fo then return nil end
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == v[2] and x:IsDescendantOf(fo) then
			local pa = (x:FindFirstChildWhichIsA("ProximityPrompt", true) or {}).Parent
			return pa and (pa:IsA("BasePart") and pa.Position or pa:IsA("Attachment") and pa.WorldPosition) or x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or nil
		end
	end
	return nil
end

local function nw(j)
	local v, n = nj[L.Flags.sv], 0
	if not v then j.why = "Teleport Failed: No NPC Selected"; return end
	while j.st == "Running" do
		local fm = ge.__FmF
		if not (fm and not fm.dn and fm.bz or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz) then
			j.bz = true
			local ok, e = ti(j, v[3], bi[L.Flags.sb] or "truck")
			local c, r = lc()
			local np = ok and r and ne(v)
			if ok and r and not np then
				local g = rg(v[3])
				sq(g and Vector3.new(g.X, 2, g.Z) or r.Position, 10)
				np = ne(v)
			end
			if ok and not r then ok, e = nil, "No Character" end
			if ok and not np then ok, e = nil, "NPC Not Found" end
			if ok and j.st == "Running" then
				local sp = aq(c, np, r.Position)
				ok, e = go(j, sp,Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
			end
			j.bz = false
			if ok and j.st == "Running" then j.ar = true; return end
			if e == "NPC Not Found" then j.why = `Teleport Failed: {e}`; return end
			n = j.st == "Running" and n + 1 or n
			if n >= 3 then j.why = `Teleport Failed: {e or "Move Failed"}`; return end
		end
		task.wait(1)
	end
end

local nk
local function ny()
	local o = ge.__FmT
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", ar = false}
	ge.__FmT = j
	local ok, e = cx(nw, j)
	if not ok then j.why = `Teleport Failed: {e}` end
	j.dn = true
	if ge.__FmT ~= j or not (j.why or j.ar) then return end
	if j.why then gw:Notify({Title = "Teleport", Text = j.why}) end
	nk:Set(false)
end

local ga, gm = {"Skill Master", "Ocean Chest", "Dragon Chest", "Aura", "Unit"}, {["Ocean Chest"] = "crate_ocean_chest", ["Dragon Chest"] = "crate_dragon_chest"}

local function fw()
	local x = ge.__FmF
	return x and not x.dn and (x.bz or x.bu) or false
end

local function gl(j)
	local sc = rv.SkillGachaController
	while j.st == "Running" do
		local k, cr = L.Flags.gr == "x10" and 10 or 1, gm[L.Flags.gk]
		local cc = cr and md("Data", "Config", "CrateConfig").GetCrate(cr)
		if cr and not cc then
			j.why = "Auto Roll Failed: No Chest"
			return
		end
		local ag, ut = L.Flags.gk == "Aura" and md("Data", "Config", "AuraGachaConfig").Pull, L.Flags.gk == "Unit" and rv.UnitGachaController
		local nm = cc and cc.DisplayName or ag and "Aura" or ut and "Unit" or "Skill Master"
		local function ca()
			local d = pd()
			if cc then return (((d.CrateGacha or {}).Credits or {})[cr] or 0) >= k or ((cc.Currency == "Coin" and d.Coin or d.Gem) or 0) >= (cc.Prices[k] or math.huge) end
			if ag then return ((d.AuraGacha or {}).Credits or 0) >= k or (d.Gem or 0) >= math.ceil(ag.CostGem * k * (ag.BulkDiscount[k] or 1)) end
			local q = (ut or sc).GetQuote:Fire(k)
			if type(q) ~= "table" or not q.ok then return nil, type(q) == "table" and q.reason or "No Quote" end
			if ut and (q.storage_available or 0) < k then return nil, "Storage Full" end
			return (d.Coin or 0) >= q.coin_cost
		end
		local af, ae = ca()
		if ae then
			j.why = `Auto Roll Failed: {ae}`
			return
		end
		if not af then
			task.wait(5)
			continue
		end
		j.rq = true
		while j.st == "Running" and fw() do task.wait(0.5) end
		if j.st ~= "Running" then return end
		j.bz, j.rq = true, false
		local r
		while j.st == "Running" do
			local rc = ut or not (cc or ag) and sc
			if rc then rc._requestId = (tonumber(rc._requestId) or 0) + 1 end
			r = cc and rv.CrateGachaController.OpenPacket:Fire(cr, k) or ag and rv.AuraGachaController.Pull:Fire(k) or ut and ut.Pull:Fire(k, ut._requestId) or not (cc or ag or ut) and sc.Pull:Fire("Coin", k, sc._requestId)
			for _ = 1, rc and (type(r) ~= "table" or r.reason == "pending") and 5 or 0 do
				task.wait(3)
				local x = rc.Recover:Fire(rc._requestId)
				if type(x) == "table" and x.reason ~= "pending" and x.reason ~= "none" then r = x; break end
			end
			if type(r) ~= "table" or not r.ok then break end
			local ct, t = md("Data", "Catalog"), {}
			for _, x in r.results or {} do
				local sv = cc and ct.RodSkin.GetById(x.rod_skin_id) or ag and ct.Aura.GetById(x.aura_id) or ut and ct.Unit.GetById(x.unit_id) or not (cc or ag or ut) and ct.Skill.GetById(x.skill_id)
				table.insert(t, `{sv and sv.name or x.rod_skin_id or x.aura_id or x.unit_id or x.skill_id} ({x.rarity})`)
			end
			j.nt = {Title = nm, Text = table.concat(t, ", ")}
			task.wait(1)
			if not ca() then break end
		end
		j.bz = false
		if j.st ~= "Running" then return end
		if type(r) ~= "table" then
			j.why = "Auto Roll Failed: No Response"
			return
		end
		if not r.ok and r.reason ~= "insufficient_coin" and r.reason ~= "insufficient_gem" then
			j.why = `Auto Roll Failed: {r.reason}`
			return
		end
		task.wait(1)
	end
end

local gs
local function gg()
	local o = ge.__FmG
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false, bz = false, rq = false}
	ge.__FmG = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(gl, j)
	if not ok then j.why = `Auto Roll Failed: {e}` end
	j.dn = true
	if ge.__FmG ~= j or not j.why then return end
	gw:Notify({Title = "Auto Roll", Text = j.why})
	gs:Set(false)
end

local mz, mi = {}, {}
pcall(function()
	local ct, t = md("Data", "Catalog"), {}
	for id, v in md("Data", "Config", "SkillMarketConfig").Listings do
		local x = ct.Skill.GetById(id)
		table.insert(t, {x and x.name or id, id, v.price or 0})
	end
	table.sort(t, function(a, b) return a[3] < b[3] or a[3] == b[3] and a[1] < b[1] end)
	for _, x in t do
		table.insert(mz, x[1])
		mi[x[1]] = x[2]
	end
end)

local function ml(j)
	local rp, mc = game:GetService("ReplicatedStorage"), rv.SkillMarketController
	local cf, ba, en, sx = md("Data", "Config", "SkillMarketConfig"), md("Utils", "skillBookAvailability"), md("Data", "Config", "EntitlementConfig"), {}
	while j.st == "Running" do
		local st, ea = rp:GetAttribute("SkillMarketStock"), rp:GetAttribute("SkillMarketEndsAt")
		local sl, kl = type(ea) == "number" and ea - cf.IntervalSeconds or 0, type(st) == "string" and st:split(",") or {}
		for _, nm in L.Flags.mm or {} do
			if j.st ~= "Running" then return end
			local id, d = mi[nm], pd()
			local sm = type(d.SkillMarket) == "table" and d.SkillMarket or {}
			if id and table.find(kl, id) and not sx[`{sl}{id}`] and not (sm.SlotStart == sl and (sm.Bought or {})[id]) and (d.Gem or 0) >= (cf.Price(id) or math.huge) and ba.GetCounts(d, id).owned < en.BookStackCap(d) then
				local r = mc.BuyDirect:Fire(id)
				if type(r) ~= "table" then
					j.why = "Auto Buy Skill Market Failed: No Response"
					return
				end
				if r.reason == "ok" then
					j.nt = {Title = "Skill Market", Text = `Bought {nm}`}
				elseif r.reason == "bought" or r.reason == "out_of_stock" or r.reason == "full" then
					sx[`{sl}{id}`] = true
				elseif r.reason ~= "insufficient" and r.reason ~= "busy" then
					j.why = `Auto Buy Skill Market Failed: {r.reason}`
					return
				end
				task.wait(1)
			end
		end
		task.wait(5)
	end
end

local function xu(j)
	local uc, uo, ct = rv.UnitController, md("Shared", "Units", "UnitCore"), md("Data", "Catalog")
	while j.st == "Running" do
		local d, rr, q = pd(), {}, {}
		for _, r in L.Flags.ur or {} do rr[r] = true end
		for id, u in type(d.Units) == "table" and type(d.Units.Owned) == "table" and d.Units.Owned or {} do
			if type(u) == "table" and rr[u.Rarity] and u.locked ~= true and not uo.IsEquipped(d.Units, id) then table.insert(q, id) end
		end
		if #q > 0 then
			j.rq = true
			while j.st == "Running" and fw() do task.wait(0.5) end
			if j.st ~= "Running" then return end
			j.bz, j.rq = true, false
			local t = {}
			for _, id in q do
				if j.st ~= "Running" then break end
				local u = (pd().Units.Owned or {})[id]
				if u and u.locked ~= true and not uo.IsEquipped(pd().Units, id) then
					local ok, e = uc:RemoveUnit(id)
					if ok ~= true then
						if e == "fishing_locked" then break end
						if e ~= "locked" and e ~= "equipped" then
							j.bz = false
							j.why = `Auto Delete Unit Failed: {e or "No Response"}`
							return
						end
					else
						local x = ct.Unit.GetById(u.UnitId)
						table.insert(t, `{x and x.name or u.UnitId} ({u.Rarity})`)
						task.wait(0.5)
					end
				end
			end
			j.bz = false
			if #t > 0 then j.nt = {Title = "Unit", Text = `Deleted {table.concat(t, ", ")}`} end
		end
		task.wait(5)
	end
end

local xk
local function xy()
	local o = ge.__FmU
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false, bz = false, rq = false}
	ge.__FmU = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(xu, j)
	if not ok then j.why = `Auto Delete Unit Failed: {e}` end
	j.dn = true
	if ge.__FmU ~= j or not j.why then return end
	gw:Notify({Title = "Unit", Text = j.why})
	xk:Set(false)
end

local function xo(j)
	local ec, ct = rv.EquipmentsController, md("Data", "Catalog")
	local function al(d, k)
		local a = type(d.Inventory) == "table" and type(d.Inventory.Auras) == "table" and d.Inventory.Auras[k]
		local c = type(a) == "table" and type(a.catalogId) == "string" and ct.Aura.GetById(a.catalogId)
		return c and a.locked ~= true and d.AuraEquip ~= k and c or nil
	end
	while j.st == "Running" do
		local d, rr, q = pd(), {}, {}
		for _, r in L.Flags.xr or {} do rr[r] = true end
		for k in type(d.Inventory) == "table" and type(d.Inventory.Auras) == "table" and d.Inventory.Auras or {} do
			local c = al(d, k)
			if c and rr[c.rarity] then table.insert(q, k) end
		end
		if #q > 0 then
			j.rq = true
			while j.st == "Running" and fw() do task.wait(0.5) end
			if j.st ~= "Running" then return end
			j.bz, j.rq = true, false
			local t = {}
			for _, k in q do
				if j.st ~= "Running" then break end
				local c = al(pd(), k)
				if c and rr[c.rarity] then
					local ok = ec.EquipmentRemove:Fire("aura", k)
					if ok ~= true then
						j.bz = false
						j.why = ok == false and "Auto Delete Aura Failed: Remove Refused" or "Auto Delete Aura Failed: No Response"
						return
					end
					table.insert(t, `{c.name or c.id} ({c.rarity})`)
					task.wait(0.5)
				end
			end
			j.bz = false
			if #t > 0 then j.nt = {Title = "Aura", Text = `Deleted {table.concat(t, ", ")}`} end
		end
		task.wait(5)
	end
end

local xz
local function xw()
	local o = ge.__FmO
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false, bz = false, rq = false}
	ge.__FmO = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(xo, j)
	if not ok then j.why = `Auto Delete Aura Failed: {e}` end
	j.dn = true
	if ge.__FmO ~= j or not j.why then return end
	gw:Notify({Title = "Aura", Text = j.why})
	xz:Set(false)
end

local mk
local function mg()
	local o = ge.__FmM
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false}
	ge.__FmM = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(ml, j)
	if not ok then j.why = `Auto Buy Skill Market Failed: {e}` end
	j.dn = true
	if ge.__FmM ~= j or not j.why then return end
	gw:Notify({Title = "Skill Market", Text = j.why})
	mk:Set(false)
end

local rz, ri = {}, {}
for _, x in {{"Stone Rod", "stone_rod"}, {"Iron Rod", "iron_rod"}, {"Golden Rod", "golden_rod"}, {"Steel Rod", "steel_rod"}, {"Golden Steel Rod", "golden_steel_rod"}, {"Diamond Steel Rod", "diamond_steel_rod"}, {"Taoist Rod", "taoist_rod"}, {"Legacy Rod", "legacy_rod"}} do
	table.insert(rz, x[1])
	ri[x[1]] = x[2]
end

local function rm(id)
	for k = 1, 2 do
		for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
			if x:GetAttribute("InteractiveId") == "npc_rod_shop" and x:GetAttribute("IslandId") == id then
				local q = x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position
				if q then return q end
			end
		end
		local g = k == 1 and rg(id)
		if g then sq(Vector3.new(g.X, 2, g.Z), 10) end
	end
	return nil
end

local function ru(j, id, il)
	local ok, e = ti(j, il, bi[L.Flags.sb] or "truck")
	if not ok then return nil, e or j.st == "Running" and "Move Failed" or nil end
	local np = rm(il)
	if not np then return nil, "No Rod Merchant" end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	local sp = aq(c, np, rt.Position)
	ok, e = go(j, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
	if not ok then return nil, e or j.st == "Running" and "Move Failed" or nil end
	if j.st ~= "Running" then return nil end
	local r = rv.FishingRodShopController.PurchaseRod:Fire(id)
	if r == nil then return nil, "No Response" end
	if r ~= true then return nil, "Purchase Refused" end
	j.by = true
	if rv.EquipmentsController.EquipmentEquip:Fire("rod", id) ~= true then return nil, "Equip Refused" end
	local dl = os.clock() + 5
	repeat task.wait(0.1) until pd().RodEquip == id or os.clock() > dl
	if pd().RodEquip ~= id then return nil, "Equip Timeout" end
	return true
end

local function rj(j)
	local nm = L.Flags.rd
	local id = ri[nm]
	if not id then j.why = "Auto Buy Rod Failed: No Rod Selected"; return end
	local cf = md("Data", "Config", "RodShopConfig")[id]
	if not cf then j.why = "Auto Buy Rod Failed: No Price"; return end
	while j.st == "Running" do
		local d = pd()
		if d.Rods and d.Rods[id] then j.why = "Auto Buy Rod Failed: Already Owned"; return end
		if not ul(cf.islandId) then j.why = "Auto Buy Rod Failed: Island Locked"; return end
		if (d.Coin or 0) < cf.price then
			task.wait(5)
			continue
		end
		j.rq = true
		while j.st == "Running" and (fw() or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz or ge.__FmI and not ge.__FmI.dn or ge.__FmT and not ge.__FmT.dn) do task.wait(0.5) end
		if j.st ~= "Running" then return end
		j.bz, j.rq = true, false
		local _, rt = lc()
		if not rt then j.why = "Auto Buy Rod Failed: No Character"; return end
		local o, oi = rt.CFrame, ic()
		local ok, e = ru(j, id, cf.islandId)
		local hk, he = true, nil
		if j.st == "Running" and oi ~= "" and ic() ~= oi then hk, he = ti(j, oi, bi[L.Flags.sb] or "truck") end
		if hk and j.st == "Running" and ic() == oi then hk, he = go(j, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
		j.bz = false
		if j.st ~= "Running" then return end
		local t = ok and `Bought {nm}` or j.by and `Bought {nm}, {e}` or `Auto Buy Rod Failed: {e}`
		j.why = hk and t or `{t}, Return Failed: {he or "Move Failed"}`
		return
	end
end

local rk
local function rh()
	local o = ge.__FmR
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, bz = false, rq = false, by = false}
	ge.__FmR = j
	local ok, e = cx(rj, j)
	if not ok then j.why = `Auto Buy Rod Failed: {e}` end
	j.dn = true
	if ge.__FmR ~= j or not j.why then return end
	gw:Notify({Title = "Rod Merchant", Text = j.why})
	rk:Set(false)
end

local lgv = {v = false}
gt:Section({Name = "Farm"})
do
	local bl, tk = gt:Label({Text = "Next Boss: --"}), {}
	ge.__FmL = tk
	task.spawn(function()
		local ok, en, iv = cx(function()
			local d, n = md("Data", "Catalog", "Fish"), {}
			for k, v in md("Data", "Catalog", "Boss").Pools do
				if v[1] and d[v[1].id] then n[k] = d[v[1].id].name end
			end
			return n, md("Data", "Catalog", "Event").Constant.OCCURRENCE_INTERVAL
		end)
		if not ok or type(iv) ~= "number" then
			while ge.__FmL == tk do
				bl:Set(lgv.v and "Boss Tiếp Theo: Không Rõ" or "Next Boss: Unknown")
				task.wait(1)
			end
			return
		end
		while ge.__FmL == tk do
			local t, ek, ex = workspace:GetServerTimeNow(), nil, 0
			local ev = rv.EventController and rv.EventController._active_events
			for k, v in type(ev) == "table" and ev or {} do
				if en[k] then ek, ex = k, math.max(v.expire_at or 0, v.admin_override_expire_at or 0) end
			end
			local lf = math.max(0, math.floor((ek and ex or (t // iv + 1) * iv) - t))
			local ms, nh = `{lf // 60}:{string.format("%02d", lf % 60)}`, os.date("%H:%M", math.floor((t // iv + 1) * iv))
			bl:Set(ek and (lgv.v and `Boss Đang Xuất Hiện: {en[ek]} - Còn {ms}` or `Boss Up: {en[ek]} - {ms} Left`) or (lgv.v and `Boss Tiếp Theo: {nh} - Còn {ms}` or `Next Boss: {nh} - In {ms}`))
			task.wait(1)
		end
	end)
end
gt:Dropdown({Name = "Select Farm Island", Options = iz, Flag = "fi"})
ft = gt:Toggle({Name = "Auto Fish", Flag = "af", Callback = function(v)
	local o = ge.__FmF
	if v then
		wg("af", fs)
	elseif o then
		if o.bz and (o.s.fp or o.s.rl) and not (o.s.cr or o.s.rr) then o.fq = true else o.st = "Stopped" end
	end
end})
gt:Toggle({Name = "Auto Boss", Flag = "ab"})

do
	local qq, qb, kz = {}, {qa = "Auto Rod Quest", ka = "Auto Skill Quest", au = "Auto Unlock Island", dq = "Auto Daily Quest", ya = "Auto Soul Quest", tk = "Auto Raid", rw = "Auto Rainbow Boss", fg = "Auto Rod Forge"}, {}
	for _, q in qt do
		if q[12] or q[13] then table.insert(kz, q[4]) end
	end
	local function qo(k)
		return function(v)
			if not v then return end
			wg(k, function()
				for x, t in qq do
					if x ~= k and L.Flags[x] == true then
						t:Set(false)
						gw:Notify({Title = "Auto Fish", Text = `{qb[x]} Turned Off: One Mode At A Time`})
					end
				end
			end)
		end
	end
	gt:Section({Name = "Quest"})
	qq.au = gt:Toggle({Name = "Auto Unlock Island", Flag = "au", Callback = qo("au")})
	qq.dq = gt:Toggle({Name = "Auto Daily Quest", Flag = "dq", Callback = qo("dq")})
	qq.rw = gt:Toggle({Name = "Auto Rainbow Boss", Flag = "rw", Callback = qo("rw")})

	gt:Section({Name = "Raid"})
	gt:Dropdown({Name = "Select Raid", Options = {"Solo", "With Friends", "Anyone"}, Default = "Solo", Flag = "rt"})
	qq.tk = gt:Toggle({Name = "Auto Raid", Flag = "tk", Callback = qo("tk")})

	gt:Section({Name = "Rod"})
	gt:Dropdown({Name = "Select Rod Quest", Options = qz, Flag = "qs"})
	qq.qa = gt:Toggle({Name = "Auto Rod Quest", Flag = "qa", Callback = qo("qa")})

	gt:Section({Name = "Skill"})
	gt:Dropdown({Name = "Select Skill Quest", Options = kz, Flag = "ks"})
	qq.ka = gt:Toggle({Name = "Auto Skill Quest", Flag = "ka", Callback = qo("ka")})

	gt:Section({Name = "Soul"})
	gt:Dropdown({Name = "Select Soul Quest", Options = qgz, Default = {}, Multi = true, Flag = "ys"})
	qq.ya = gt:Toggle({Name = "Auto Soul Quest", Flag = "ya", Callback = qo("ya")})

	gt:Section({Name = "Rod Forge"})
	gt:Dropdown({Name = "Select Forge Mode", Options = {"Forge Chain", "Reforge V1 To Perfect"}, Default = "Forge Chain", Flag = "fm"})
	qq.fg = gt:Toggle({Name = "Auto Rod Forge", Flag = "fg", Callback = qo("fg")})
end

gt:Section({Name = "Sell"})
gt:Dropdown({Name = "Sell Rarity", Options = ra, Default = {}, Multi = true, Flag = "sr"})
gt:Toggle({Name = "Auto Sell", Flag = "as"})

local tz, qtx = gw:Tab({Name = "Status", Icon = "trophy"}), `Iq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Island Quest"})
local iql = tz:Label({Text = qtx})
local rtx = `Rq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Rod Quest"})
local rql = tz:Label({Text = rtx})
local ktx = `Kq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Skill Quest"})
local sql = tz:Label({Text = ktx})
local ytx = `Yq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Soul Quest"})
local yql = tz:Label({Text = ytx})
tz:Section({Name = "Rod Forge"})
local fql = {t = `Fq{game:GetService("HttpService"):GenerateGUID(false)}`}
fql.l = tz:Label({Text = fql.t})
tz:Section({Name = "Skill Market"})
local kql = tz:Label({Text = "Loading..."})

local tm = gw:Tab({Name = "Misc", Icon = "four-squares-grid"})
tm:Section({Name = "Unit"})
tm:Dropdown({Name = "Delete Rarity", Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}, Default = {}, Multi = true, Flag = "ur"})
xk = tm:Toggle({Name = "Auto Delete Unit", Flag = "ua", Callback = function(v)
	if v then wg("ua", xy) elseif ge.__FmU then ge.__FmU.st = "Stopped" end
end})
tm:Section({Name = "Aura"})
tm:Dropdown({Name = "Delete Rarity", Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine"}, Default = {}, Multi = true, Flag = "xr"})
xz = tm:Toggle({Name = "Auto Delete Aura", Flag = "xa", Callback = function(v)
	if v then wg("xa", xw) elseif ge.__FmO then ge.__FmO.st = "Stopped" end
end})

local tq = gw:Tab({Name = "Shop", Icon = "shopping-basket"})
tq:Section({Name = "Gacha"})
tq:Dropdown({Name = "Select Gacha", Options = ga, Default = "Skill Master", Flag = "gk"})
tq:Dropdown({Name = "Select Roll", Options = {"x1", "x10"}, Default = "x1", Flag = "gr"})
gs = tq:Toggle({Name = "Auto Roll", Flag = "gs", Callback = function(v)
	if v then wg("gs", gg) elseif ge.__FmG then ge.__FmG.st = "Stopped" end
end})
tq:Section({Name = "Skill Market"})
tq:Dropdown({Name = "Select Skills", Options = mz, Default = {}, Multi = true, Flag = "mm"})
mk = tq:Toggle({Name = "Auto Buy Skill Market", Flag = "ma", Callback = function(v)
	if v then wg("ma", mg) elseif ge.__FmM then ge.__FmM.st = "Stopped" end
end})
tq:Section({Name = "Rod Market"})
tq:Dropdown({Name = "Select Rod", Options = rz, Flag = "rd"})
rk = tq:Toggle({Name = "Auto Buy Rod", Flag = "rb", Callback = function(v)
	if v then
		wg("rb", function()
			if it then it:Set(false) end
			if nk then nk:Set(false) end
			rh()
		end)
	elseif ge.__FmR then ge.__FmR.st = "Stopped" end
end})

local tl = gw:Tab({Name = "Teleport", Icon = "person-teleport"})
tl:Section({Name = "Island"})
tl:Dropdown({Name = "Select Island", Options = iz, Flag = "si"})
it = tl:Toggle({Name = "Auto Island", Flag = "ai", Callback = function(v)
	if v then
		wg("ai", function()
			if rk then rk:Set(false) end
			if nk then nk:Set(false) end
			is()
		end)
	elseif ge.__FmI then ge.__FmI.st = "Stopped" end
end})
tl:Section({Name = "NPC"})
tl:Dropdown({Name = "Select NPC", Options = nl, Flag = "sv"})
nk = tl:Toggle({Name = "Teleport To NPC", Flag = "tv", Callback = function(v)
	if v then
		wg("tv", function()
			if it then it:Set(false) end
			if rk then rk:Set(false) end
			ny()
		end)
	elseif ge.__FmT then ge.__FmT.st = "Stopped" end
end})
tl:Section({Name = "Server"})
do
	local hb = false
	local function vh(lw)
		if hb then
			gw:Notify({Title = "Server", Text = "Hop Failed: Already Hopping"})
			return
		end
		hb = true
		local ok, r = pcall(function() return hs:JSONDecode((game :: any):HttpGet(`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder={lw and "Asc" or "Desc"}&limit=100`)) end)
		local o, e = {}, nil
		for _, s in ok and type(r) == "table" and type(r.data) == "table" and r.data or {} do
			if type(s) == "table" and type(s.id) == "string" and s.id ~= game.JobId and tonumber(s.playing) and tonumber(s.maxPlayers) and s.playing < s.maxPlayers - 1 then table.insert(o, s) end
		end
		if not (ok and type(r) == "table" and type(r.data) == "table") then e = "Hop Failed: Server List"
		elseif #o == 0 then e = "Hop Failed: No Server"
		else
			if lw then table.sort(o, function(a, b) return a.playing < b.playing end) end
			local s = lw and o[1] or o[math.random(1, #o)]
			local tp = game:GetService("TeleportService")
			zy.hp = os.clock()
			zx(`[Server] Hop{lw and " Low" or ""} From {game.JobId:sub(1, 8)} To {s.id:sub(1, 8)} | {s.playing}/{s.maxPlayers} Players`, true)
			local tk, te = pcall(tp.TeleportToPlaceInstance, tp, game.PlaceId, s.id, lp)
			if tk then task.wait(15) end
			e = tk and "Hop Failed: Teleport Timeout" or `Hop Failed: {te}`
		end
		hb = false
		gw:Notify({Title = "Server", Text = e})
	end
	tl:Button({Name = "Hop Server", Callback = function() task.spawn(vh, false) end})
	tl:Button({Name = "Hop Low Server", Callback = function() task.spawn(vh, true) end})
end

local ez, eo = {cs = {}, o = {}, w = {}}, nil
do
	local ov = ge.__FmV
	if ov then
		ov.w = {}
		if ov.rw then pcall(ov.rw) end
		for _, c in ov.cs do c:Disconnect() end
	end
	ge.__FmV = ez
	for _, n in {"RodSkinId", "AuraCatalogId"} do
		if ov then ez.o[n] = ov.o[n] else ez.o[n] = lp:GetAttribute(n) end
		table.insert(ez.cs, lp:GetAttributeChangedSignal(n):Connect(function()
			local v = lp:GetAttribute(n)
			if v == ez.w[n] then return end
			ez.o[n] = v
			if ez.w[n] then lp:SetAttribute(n, ez.w[n]) end
		end))
	end
	local et, an = 0, "AuraCatalogId"
	table.insert(ez.cs, game:GetService("RunService").Heartbeat:Connect(function()
		if not ez.w[an] or os.clock() < et then return end
		et = os.clock() + 0.25
		local c = lp.Character
		local fx = c and c:FindFirstChild("ClientAuraEffect")
		for _, d in fx and fx:GetDescendants() or {} do
			if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") or d:IsA("Highlight") then
				if not d.Enabled then d.Enabled = true end
			elseif d:IsA("BasePart") and d.LocalTransparencyModifier ~= 0 then
				d.LocalTransparencyModifier = 0
			end
		end
	end))
	local sn, ac, ah, zo = "RodSkinId", {}, nil, {}
	local function rw(t)
		local sk, df, nm = ez.w[sn], eo and eo[3], ah
		local r = sk and df and nm and df[1](t.Name, df[2][sk])
		if not r or r.id == t.Animation.AnimationId then return end
		local n = ac[r.id]
		if not n then
			local an2 = Instance.new("Animation")
			an2.AnimationId = r.id
			local ok, x = pcall(nm.LoadAnimation, nm, an2)
			if not ok or not x then return end
			n, ac[r.id] = x, x
		end
		n.Priority, n.Looped = r.priority, r.looped
		t:AdjustWeight(0.001, 0)
		zo[t] = n
		n:Play(r.fadeTime, 1, r.playbackSpeed)
		local c1
		c1 = t.Stopped:Connect(function()
			c1:Disconnect()
			if zo[t] ~= n then return end
			zo[t] = nil
			for _, n2 in zo do
				if n2 == n then return end
			end
			n:Stop(r.fadeTime)
		end)
	end
	local function hk2(c)
		local h = c and c:WaitForChild("Humanoid", 10)
		local nm = h and h:WaitForChild("Animator", 10)
		if not nm or ge.__FmV ~= ez then return end
		ah, ac, zo = nm, {}, {}
		table.insert(ez.cs, nm.AnimationPlayed:Connect(rw))
	end
	table.insert(ez.cs, lp.CharacterAdded:Connect(hk2))
	task.spawn(hk2, lp.Character)
	ez.rw = function()
		for t, n in zo do
			pcall(function() n:Stop(0.15); t:AdjustWeight(1, 0.15) end)
		end
		zo = {}
		for _, t in ah and ah:GetPlayingAnimationTracks() or {} do
			if t.WeightTarget > 0 then rw(t) end
		end
	end
	local ok, a, b, rz2 = cx(function()
		local ct, rk, sa2 = md("Data", "Catalog"), {}, {}
		for _, v in ct.RodSkin.GetAll() do
			if type(v) == "table" and type(v.id) == "string" then sa2[v.id] = v.animations end
		end
		for i, r in ra do rk[r] = i end
		local function bl(t)
			local l, m, n = {}, {}, {"Default"}
			for _, v in t.GetAll() do
				if type(v) == "table" and type(v.name) == "string" and type(v.id) == "string" then table.insert(l, v); m[v.name] = v.id end
			end
			table.sort(l, function(x, y)
				local p, q = rk[x.rarity] or 0, rk[y.rarity] or 0
				if p ~= q then return p > q end
				return x.name < y.name
			end)
			for _, v in l do table.insert(n, v.name) end
			return {n, m}
		end
		return bl(ct.RodSkin), bl(ct.Aura), {md("Data", "Config", "RodAnimationConfig").Resolve, sa2}
	end)
	if ok then eo = {a, b, rz2} else gw:Notify({Title = "Visual", Text = "Effect List Failed: Catalog Error"}) end
end

local function ep(n, id)
	ez.w[n] = id
	lp:SetAttribute(n, id or ez.o[n])
	if ez.rw then ez.rw() end
end

if eo then
	local tv = gw:Tab({Name = "Visual", Icon = "eye"})
	tv:Section({Name = "Effect"})
	tv:Dropdown({Name = "Rod Skin", Options = eo[1][1], Default = "Default", Flag = "es", Callback = function(v) ep("RodSkinId", eo[1][2][v]) end})
	tv:Dropdown({Name = "Aura", Options = eo[2][1], Default = "Default", Flag = "ea", Callback = function(v) ep("AuraCatalogId", eo[2][2][v]) end})
end

local function zp()
	if ge.__FmP then return nil, "Already On" end
	ge.__FmP = true
	local sc, lt, tr, oc = rv.SettingsController, game:GetService("Lighting"), workspace.Terrain, workspace:FindFirstChild("Ocean")
	local ul = true
	for k, v in {ultra_low_graphic = true, show_others_vfx = false, show_my_vfx = false, show_cutscenes = false, show_damage_indicator = false, camera_shaking = false, auto_fishing_hide_vfx = true} do
		if not (sc and sc._SetLocal and pcall(sc._SetLocal, sc, k, v)) then ul = false end
	end
	local function ko(d)
		d.Enabled = false
		d:GetPropertyChangedSignal("Enabled"):Connect(function() if d.Enabled then d.Enabled = false end end)
	end
	local function lf()
		if lt.GlobalShadows then lt.GlobalShadows = false end
		if lt.FogEnd < 1e9 then lt.FogEnd = 1e9 end
	end
	local function kx(d)
		if d:IsA("PostEffect") then
			ko(d)
		elseif d:IsA("Atmosphere") then
			local function z() if d.Density ~= 0 or d.Haze ~= 0 or d.Glare ~= 0 then d.Density, d.Haze, d.Glare = 0, 0, 0 end end
			z()
			d.Changed:Connect(z)
		end
	end
	local function px(d)
		if d == tr or oc and d:IsDescendantOf(oc) then return end
		if d:IsA("ParticleEmitter") then
			d.Lifetime = NumberRange.new(0)
			ko(d)
		elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("Light") or d:IsA("Highlight") then
			ko(d)
		elseif d:IsA("Decal") then
			d.Transparency = 1
		elseif d:IsA("SurfaceAppearance") then
			task.defer(pcall, d.Destroy, d)
		elseif d:IsA("BasePart") and d.Material ~= Enum.Material.Water then
			d.Material, d.Reflectance, d.CastShadow = Enum.Material.SmoothPlastic, 0, false
		end
	end
	lf()
	lt:GetPropertyChangedSignal("GlobalShadows"):Connect(lf)
	lt:GetPropertyChangedSignal("FogEnd"):Connect(lf)
	for _, d in lt:GetChildren() do pcall(kx, d) end
	lt.ChildAdded:Connect(function(d) pcall(kx, d) end)
	pcall(function() tr.WaterWaveSize, tr.WaterWaveSpeed, tr.WaterReflectance = 0, 0, 0 end)
	workspace.DescendantAdded:Connect(function(d) pcall(px, d) end)
	task.spawn(function()
		for i, d in workspace:GetDescendants() do
			pcall(px, d)
			if i % 2000 == 0 then task.wait() end
		end
	end)
	local rn, ui = game:GetService("RunService"), game:GetService("UserInputService")
	ui.WindowFocusReleased:Connect(function() pcall(rn.Set3dRenderingEnabled, rn, false) end)
	ui.WindowFocused:Connect(function() pcall(rn.Set3dRenderingEnabled, rn, true) end)
	local function sm(d)
		if not d:IsA("Sound") then return end
		d.Volume = 0
		d:GetPropertyChangedSignal("Volume"):Connect(function() if d.Volume ~= 0 then d.Volume = 0 end end)
	end
	game.DescendantAdded:Connect(function(d) pcall(sm, d) end)
	task.spawn(function()
		for i, d in game:GetDescendants() do
			pcall(sm, d)
			if i % 2000 == 0 then task.wait() end
		end
	end)
	local function ax(d)
		if d:IsA("Accoutrement") or d:IsA("Clothing") or d:IsA("ShirtGraphic") or d:IsA("CharacterMesh") then task.defer(pcall, d.Destroy, d) end
	end
	local function cr(c)
		for _, d in c:GetDescendants() do pcall(ax, d) end
		c.DescendantAdded:Connect(function(d) pcall(ax, d) end)
	end
	local function pa(p)
		if p == lp then return end
		if p.Character then cr(p.Character) end
		p.CharacterAdded:Connect(cr)
	end
	for _, p in ps:GetPlayers() do pa(p) end
	ps.PlayerAdded:Connect(pa)
	if not ul then return nil, "Game Settings Failed: Settings Error" end
	return true
end

local lgd = {["Select Farm Island"] = "Chọn Đảo Câu", ["Auto Fish"] = "Tự Động Câu Cá", ["Auto Boss"] = "Tự Động Săn Boss", ["Auto Rainbow Boss"] = "Tự Động Boss Cầu Vồng", ["Auto Raid"] = "Tự Động Raid", ["Select Raid"] = "Chọn Raid", ["Select Forge Mode"] = "Chọn Kiểu Rèn", ["Auto Rod Forge"] = "Tự Động Rèn Cần", ["Select Rod Quest"] = "Chọn Nhiệm Vụ Cần", ["Auto Rod Quest"] = "Tự Động Nhiệm Vụ Cần", ["Select Skill Quest"] = "Chọn Nhiệm Vụ Kỹ Năng", ["Auto Skill Quest"] = "Tự Động Nhiệm Vụ Kỹ Năng", ["Auto Unlock Island"] = "Tự Động Mở Khóa Đảo", ["Auto Daily Quest"] = "Tự Động Nhiệm Vụ Hằng Ngày", ["Select Soul Quest"] = "Chọn Nhiệm Vụ Tộc", ["Auto Soul Quest"] = "Tự Động Nhiệm Vụ Tộc", ["Sell Rarity"] = "Độ Hiếm Cần Bán", ["Auto Sell"] = "Tự Động Bán", ["Delete Rarity"] = "Độ Hiếm Cần Xóa", ["Auto Delete Unit"] = "Tự Động Xóa Unit", ["Auto Delete Aura"] = "Tự Động Xóa Aura", ["Select Gacha"] = "Chọn Gacha", ["Select Roll"] = "Chọn Số Lượt Quay", ["Auto Roll"] = "Tự Động Quay", ["Select Skills"] = "Chọn Kỹ Năng", ["Auto Buy Skill Market"] = "Tự Động Mua Skill Market", ["Select Rod"] = "Chọn Cần Câu", ["Auto Buy Rod"] = "Tự Động Mua Cần", ["Select Island"] = "Chọn Đảo", ["Auto Island"] = "Tự Động Tới Đảo", ["Select NPC"] = "Chọn NPC", ["Teleport To NPC"] = "Dịch Chuyển Tới NPC", ["Hop Server"] = "Đổi Server", ["Hop Low Server"] = "Đổi Server Ít Người", ["Rod Skin"] = "Skin Cần Câu", ["Aura"] = "Aura", ["Select Language"] = "Chọn Ngôn Ngữ", ["Select Boat"] = "Chọn Thuyền", ["Safe"] = "An Toàn", ["Hidden Fishing"] = "Câu Cá Ẩn", ["FPS Booster"] = "Tăng FPS", ["Send Log To Developer"] = "Gửi Log Cho Admin", ["Describe The Problem"] = "Mô Tả Lỗi", ["Auto Gear"] = "Tự Động Trang Bị", ["Instant Teleport"] = "Dịch Chuyển Tức Thì"}
local function lgp()
	for _, T in gw.Tabs do
		if T.Name == "Status" then continue end
		for _, e in T.Rows do
			if not e.Label then continue end
			e.en = e.en or e.Name
			e.Name = lgv.v and lgd[e.en] or e.en
			e.Label.Text = e.Name
		end
	end
end
local ts = gw:Tab({Name = "Setting", Icon = "gear"})
ts:Section({Name = "GUI"})
ts:Dropdown({Name = "Select Language", Options = {"Vietnamese", "English"}, Default = "English", Flag = "lg", Callback = function(v)
	lgv.v = v == "Vietnamese"
	lgp()
end})
ts:Section({Name = "Game"})
ts:Dropdown({Name = "Select Boat", Options = bn, Default = "Truck", Flag = "sb"})
ts:Toggle({Name = "Safe", Flag = "zy", Callback = function(v) zy.on = v == true end})
ts:Toggle({Name = "Instant Teleport", Default = true, Flag = "wb", Callback = function(v) wb = v == true end})
ts:Toggle({Name = "Hidden Fishing", Flag = "hf"})
ts:Toggle({Name = "Auto Gear", Default = true, Flag = "ag"})
local jr = false
pcall(function() ge.__FmJ:Disconnect() end)
local gv = game:GetService("GuiService") :: any
ge.__FmJ = gv.ErrorMessageChanged:Connect(function(m)
	if jr or type(m) ~= "string" or m == "" then return end
	if os.clock() - zy.hp < 30 then
		zx(`[Rejoin] Ignored During Hop: {m}`, true)
		return
	end
	jr = true
	local ok, c = pcall(function() return gv:GetErrorCode() end)
	local cv = ok and typeof(c) == "EnumItem" and c.Value or "?"
	if ok and (c == Enum.ConnectionError.DisconnectEvicted or c == Enum.ConnectionError.DisconnectDuplicatePlayer) then
		zx(`[Rejoin] Skipped, Same Account Elsewhere ({cv}): {m}`, true)
		return
	end
	zx(`[Rejoin] Kicked ({cv}): {m}`, true)
	task.spawn(function()
		local tp = game:GetService("TeleportService")
		while true do
			pcall(tp.Teleport, tp, game.PlaceId, lp)
			task.wait(10)
		end
	end)
end)
local zl = {}
ge.__FmZ = zl
task.spawn(function()
	while ge.__FmZ == zl do
		task.wait(0.5)
		local sk, se = pcall(function()
			local f, ok, w = ge.__FmF, true, false
			if zy.on and os.clock() >= zy.nt then ok, w = cx(zw) end
			if not (ok and w) then
				zy.rq = false
			elseif f and not f.dn and f.st == "Running" then
				zy.rq = true
			else
				gw:Notify({Title = "Safe", Text = "Player On Island, Hopping"})
				local _, e = zh()
				if e then zx(`[Safe] {e}`, true) end
				gw:Notify({Title = "Safe", Text = e})
			end
		end)
		if not sk then zx(`[Safe] Loop Error: {se}`) end
	end
end)
ts:Button({Name = "FPS Booster", Callback = function()
	local ok, e = zp()
	gw:Notify({Title = "FPS Booster", Text = ok and "On Until Rejoin" or e})
end})
ts:Section({Name = "Support"})
do
	local lt, rb = 0, ts:TextBox({Name = "Describe The Problem", Placeholder = "What Went Wrong?"})
	ts:Button({Name = "Send Log To Developer", Callback = function()
		if os.clock() < lt then
			gw:Notify({Title = "Support", Text = `Send Log Failed: Wait {math.ceil(lt - os.clock())} s`})
			return
		end
		local rs = (tostring(rb:Get() or ""):gsub("^%s+", ""):gsub("%s+$", "")):sub(1, 500)
		if rs == "" then
			gw:Notify({Title = "Support", Text = "Send Log Failed: Describe The Problem First"})
			return
		end
		lt = os.clock() + 300
		task.spawn(function()
			local fp = `Avenoric/Configs/FishingMaster/{lp.Name}_Log.txt`
			zx(`[Support] Send Log | {lp.Name} | Place {game.PlaceVersion} | Server {game.JobId:sub(1, 8)} | Problem: {rs}`, true)
			local ok, e = pcall(function()
				local rq = ge.request or ge.http_request or (type(ge.http) == "table" and ge.http.request)
				if type(rq) ~= "function" then error("No Request Function", 0) end
				if not isfile(fp) then error("No Log File", 0) end
				local s = readfile(fp)
				local cu = #s > 8e6
				if cu then s = s:sub(-8e6) end
				local ex = identifyexecutor and select(2, pcall(identifyexecutor)) or "?"
				local b = `FmLog{(hs:GenerateGUID(false):gsub("-", ""))}`
				local pj = hs:JSONEncode({content = `**{lp.Name}** ({lp.UserId}) | Place {game.PlaceVersion} | Server {game.JobId} | {tostring(ex)}{cu and " | Last 8 MB" or ""}\nProblem: {rs}`, allowed_mentions = {parse = {}}})
				local r = rq({Url = "https://discord.com/api/webhooks/1561015132455436318/6NjxnMIKb7-s5KtlU1IIwHvtyTa2YtQlOzwtMg8w-jKxWTzhbRwvrw4CjFV6b3FGBZG6?wait=true", Method = "POST", Headers = {["Content-Type"] = `multipart/form-data; boundary={b}`}, Body = `--{b}\r\nContent-Disposition: form-data; name="payload_json"\r\nContent-Type: application/json\r\n\r\n{pj}\r\n--{b}\r\nContent-Disposition: form-data; name="files[0]"; filename="{lp.Name}_Log.txt"\r\nContent-Type: text/plain\r\n\r\n{s}\r\n--{b}--\r\n`})
				local sc = type(r) == "table" and r.StatusCode
				if sc ~= 200 and sc ~= 204 then error(`Http {sc or "No Response"}`, 0) end
			end)
			zx(ok and "[Support] Log Sent" or `[Support] Send Log Failed: {e}`, true)
			if ok then rb:Set("") else lt = os.clock() + 10 end
			gw:Notify({Title = "Support", Text = ok and "Log Sent To Developer" or `Send Log Failed: {e} ({fp})`})
		end)
	end})
end
lgp()
gr = true
do
	local zc, fn = {}, {{"af", "Auto Fish"}, {"ab", "Auto Boss"}, {"rw", "Auto Rainbow Boss"}, {"tk", "Auto Raid"}, {"rt", "Select Raid"}, {"fi", "Farm Island"}, {"qs", "Rod Quest"}, {"qa", "Auto Rod Quest"}, {"ks", "Skill Quest"}, {"ka", "Auto Skill Quest"}, {"au", "Auto Unlock Island"}, {"dq", "Auto Daily Quest"}, {"ys", "Soul Quest"}, {"ya", "Auto Soul Quest"}, {"sr", "Sell Rarity"}, {"as", "Auto Sell"}, {"ur", "Unit Delete Rarity"}, {"ua", "Auto Delete Unit"}, {"xr", "Aura Delete Rarity"}, {"xa", "Auto Delete Aura"}, {"gk", "Gacha"}, {"gr", "Roll"}, {"gs", "Auto Roll"}, {"mm", "Market Skills"}, {"ma", "Auto Buy Skill Market"}, {"rd", "Rod"}, {"rb", "Auto Buy Rod"}, {"fm", "Forge Mode"}, {"fg", "Auto Rod Forge"}, {"si", "Island"}, {"ai", "Auto Island"}, {"sv", "NPC"}, {"tv", "Teleport To NPC"}, {"es", "Rod Skin"}, {"ea", "Aura"}, {"sb", "Boat"}, {"zy", "Safe"}, {"wb", "Instant Teleport"}, {"hf", "Hidden Fishing"}, {"ag", "Auto Gear"}, {"lg", "Language"}}
	ge.__FmCw = zc
	task.spawn(function()
		local lv, nx = {}, 0
		while ge.__FmCw == zc do
			local ch = {}
			for _, x in fn do
				local v = L.Flags[x[1]]
				local ok, s = pcall(function() return type(v) == "table" and `[{table.concat(v, ", ")}]` or tostring(v) end)
				s = ok and s or "?"
				if lv[x[1]] ~= s then
					lv[x[1]] = s
					table.insert(ch, `{x[2]} = {s}`)
				end
			end
			if #ch > 0 then zx(`[Config] {table.concat(ch, " | ")}`) end
			local f = ge.__FmF
			if os.clock() >= nx and f and not f.dn then
				nx = os.clock() + 60
				local ok, s = cx(function() return `{xt()}{f.s.id and (f.s.fp or f.s.rl) and not (f.s.cr or f.s.rr) and ` | Hooked {ze(f.s.id)} HP {f.s.xh or "?"} / {f.s.xm or "?"}` or ""}` end)
				if ok then zx(s) end
			end
			task.wait(1)
		end
	end)
end

local rx = "Vinh hub"

local function nt()
	for _, c in ge.__FmN or {} do c:Disconnect() end
	local cs, tx, gr = {}, rx, {}
	ge.__FmN = cs
	local function hk(m)
		task.spawn(function()
			local p = m:WaitForChild("PlrName", 10)
			local s = p and p:WaitForChild("Surface", 10)
			local l = s and s:WaitForChild("Label", 10)
			if not l or ge.__FmN ~= cs then return end
			if m.Name == lp.Name then
				local o = `@{lp.Name}`
				if l.Text ~= o then l.Text = o end
				if l:FindFirstChild("Rb") then l.Rb:Destroy() end
				local lo = l
				lo.TextTransparency, lo.TextStrokeTransparency = 1, 1
				for _, n in {"TextTransparency", "TextStrokeTransparency"} do
					table.insert(cs, lo:GetPropertyChangedSignal(n):Connect(function() if lo[n] ~= 1 then lo[n] = 1 end end))
				end
				local fd = l:FindFirstChild("Fade")
				if fd and fd:IsA("GuiObject") then
					fd.Visible = false
					table.insert(cs, fd:GetPropertyChangedSignal("Visible"):Connect(function() if fd.Visible then fd.Visible = false end end))
				end
				if s:FindFirstChild("Rx") then s.Rx:Destroy() end
				local tp = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
				for _, n in {"UIs", "Prefabs", "Nametag", "PlrName", "Surface", "Label"} do tp = tp and tp:FindFirstChild(n) end
				local cl = (tp and tp:IsA("TextLabel") and tp or l):Clone()
				for _, x in cl:GetChildren() do
					if x.Name == "Rb" then x:Destroy() elseif x.Name == "Fade" and x:IsA("GuiObject") then x.Visible = true end
				end
				cl.Name, cl.TextTransparency, cl.TextStrokeTransparency, cl.Parent = "Rx", 0, 0, s
				l = cl
			end
			l.Text = tx
			table.insert(cs, l:GetPropertyChangedSignal("Text"):Connect(function() if l.Text ~= tx then l.Text = tx end end))
			local g = l:FindFirstChild("Rb") or Instance.new("UIGradient")
			g.Name, g.Parent = "Rb", l
			gr[g] = true
		end)
	end
	local nf = workspace:FindFirstChild("Nametags")
	if not nf then return end
	table.insert(cs, game:GetService("RunService").Heartbeat:Connect(function()
		local p, k = os.clock() * 0.25, {}
		for i = 0, 9 do k[i + 1] = ColorSequenceKeypoint.new(i / 9, Color3.fromHSV((i / 9 - p) % 1, 1, 1)) end
		local q = ColorSequence.new(k)
		for g in gr do
			if g.Parent then g.Color = q else gr[g] = nil end
		end
	end))
	table.insert(cs, nf.ChildAdded:Connect(hk))
	for _, m in nf:GetChildren() do hk(m) end
end

nt()

if ge.__FmC then ge.__FmC:Disconnect() end
task.spawn(function()
	local g = lp:WaitForChild("PlayerGui"):WaitForChild("Version", 30)
	local l = g and g:FindFirstChildWhichIsA("TextLabel", true)
	if not l then return end
	l.TextTransparency = 1
	ge.__FmC = l:GetPropertyChangedSignal("TextTransparency"):Connect(function() if l.TextTransparency ~= 1 then l.TextTransparency = 1 end end)
end)

task.spawn(function()
	for _ = 1, 3 do
		if sa() >= 12 then return end
		task.wait(5)
	end
	gw:Notify({Title = "Auto Boss", Text = "Boss Scan Failed: Regions Missing"})
end)

if ge.__FmA then ge.__FmA:Disconnect() end
ge.__FmA = lp.Idled:Connect(function()
	local vu = game:GetService("VirtualUser")
	vu:CaptureController()
	vu:ClickButton2(Vector2.new())
end)

do
	local nc = rv.NotificationController
	if type(nc) == "table" and type(ge.__FmNo) == "function" then nc.Push = ge.__FmNo end
	ge.__FmNo = nil
	if ge.__FmNh then ge.__FmNh:Disconnect() end
	task.spawn(function()
		local ok, h = pcall(function() return lp:WaitForChild("PlayerGui", 30):WaitForChild("NotificationGui", 30):WaitForChild("Holder", 30) end)
		if not (ok and h) then
			zx("[Hub] Hide Notifications Failed: No Holder")
			return
		end
		h.Visible = false
		ge.__FmNh = h:GetPropertyChangedSignal("Visible"):Connect(function()
			if h.Visible then h.Visible = false end
		end)
	end)
end

if ge.__FmTt then ge.__FmTt:Disconnect() end
lp:SetAttribute("PLR_TITLE", "tester")
ge.__FmTt = lp:GetAttributeChangedSignal("PLR_TITLE"):Connect(function()
	if lp:GetAttribute("PLR_TITLE") ~= "tester" then lp:SetAttribute("PLR_TITLE", "tester") end
end)

do
	local wk = {}
	ge.__FmHb = wk
	task.spawn(function()
		local t0
		while ge.__FmHb == wk do
			local h, ht = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"), rv.HeldToolController
			if ht and h and h.Health > 0 and not ht:IsReady() then
				t0 = t0 or os.clock()
				if os.clock() - t0 >= 5 then
					t0 = nil
					pcall(function() ht.BackpackReady.OnClientEvent:Fire() end)
					zx("[Hotbar] Ready Flag Stuck, Repaired")
				end
			else
				t0 = nil
			end
			task.wait(1)
		end
	end)
end

do
	local o = ge.__FmS
	if o then
		o.on = false
		pcall(function() o.t:Stop(0) end)
		pcall(function() o.h:Stop(0) end)
	end
	local sk = {on = true, t = nil :: any, h = nil :: any}
	ge.__FmS = sk
	task.spawn(function()
		local an, ah
		while sk.on do
			local hm = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			local a = hm and hm.Health > 0 and hm:FindFirstChildOfClass("Animator")
			if a and (a ~= an or not (sk.t and sk.t.IsPlaying)) then
				pcall(function()
					local x = Instance.new("Animation")
					x.AnimationId = "rbxassetid://180435571"
					if sk.t and an == a then sk.t:Destroy() end
					sk.t, an = a:LoadAnimation(x), a
					sk.t.Looped, sk.t.Priority = true, Enum.AnimationPriority.Core
					sk.t:Play(0, 0.01, 0.37)
				end)
			end
			local fm = ge.__FmF
			local hw = L.Flags.hf == true and fm and not fm.dn and fm.st == "Running"
			if hw and a and (a ~= ah or not (sk.h and sk.h.IsPlaying)) then
				pcall(function()
					local x = Instance.new("Animation")
					x.AnimationId = "rbxassetid://180435571"
					if sk.h and ah == a then sk.h:Destroy() end
					sk.h, ah = a:LoadAnimation(x), a
					sk.h.Looped, sk.h.Priority = true, Enum.AnimationPriority.Core
					sk.h:Play(0, 0.01, 0.41)
				end)
			elseif not hw and sk.h then
				pcall(function() sk.h:Stop(0) end)
				sk.h, ah = nil, nil
			end
			task.wait(0.5)
		end
	end)
end

do
	local o = ge.__FmHd
	if o then
		o.on = false
		o.rs()
	end
	local hh = {on = true, v = {}}
	function hh.rs()
		for d, v in hh.v do pcall(function() d[v[1]] = v[2] end) end
		hh.v = {}
	end
	ge.__FmHd = hh
	task.spawn(function()
		while hh.on do
			pcall(function()
				local nf, sn = workspace:FindFirstChild("Nametags"), {}
				for _, p in ps:GetPlayers() do
					if p ~= lp and zq(p) then
						for _, m in {p.Character, nf and nf:FindFirstChild(p.Name)} do
							for _, d in m and m:GetDescendants() or {} do
								local k = (d:IsA("BasePart") or d:IsA("Decal")) and "LocalTransparencyModifier" or (d:IsA("Beam") or d:IsA("Trail") or d:IsA("ParticleEmitter") or d:IsA("LayerCollector") or d:IsA("Highlight")) and "Enabled"
								if k then
									if not hh.v[d] then hh.v[d] = {k, d[k]} end
									d[k] = k ~= "Enabled" and 1 or false
									sn[d] = true
								end
							end
						end
					end
				end
				for d, v in hh.v do
					if not sn[d] then
						pcall(function() d[v[1]] = v[2] end)
						hh.v[d] = nil
					end
				end
			end)
			task.wait(0.25)
		end
	end)
end

local function bh()
	for _, x in ge.__FmB or {} do
		pcall(function() x:Disconnect() end)
		pcall(function() x:Destroy() end)
	end
	local cs, fc = {}, rv.FishingController
	ge.__FmB = cs
	local ok, en, bd = cx(function()
		local fs2, n, d = md("Data", "Catalog", "Fish"), {}, {}
		for id, v in fs2 do
			if type(v) == "table" and type(v.name) == "string" then d[id] = {v.name, v.kind == "Boss"} end
		end
		for k, v in md("Data", "Catalog", "Boss").Pools do
			if v[1] and d[v[1].id] then n[k] = d[v[1].id][1] end
		end
		return n, d
	end)
	if not ok then return end
	local sr = lp.PlayerGui:WaitForChild("SessionInfo", 10)
	if not (sr and sr:FindFirstChild("Holder")) then return end
	local sg = sr:Clone()
	for _, x in sg:GetDescendants() do
		if x:IsA("LuaSourceContainer") then x:Destroy() end
	end
	sg.Name, sg.ResetOnSpawn, sg.DisplayOrder, sg.Enabled = game:GetService("HttpService"):GenerateGUID(false), false, 10, true
	local h = sg.Holder
	local hp, fn = h:FindFirstChild("FishHP"), h:FindFirstChild("FishName")
	local fi, ht = hp and hp:FindFirstChild("Fill"), hp and hp:FindFirstChild("HealthText")
	if not (fn and fi and ht) then return end
	for _, n in {"Tension", "FinisherGate", "EscapeSign"} do
		local x = h:FindFirstChild(n)
		if x then x.Visible = false end
	end
	for _, n in {"MaxHealthReduced", "MaxHealthReducedGate"} do
		local x = hp:FindFirstChild(n)
		if x then x.Visible = false end
	end
	local g1, g2, f0, tw = fi:FindFirstChild("Normal"), fi:FindFirstChild("BossPhase2"), fi.BackgroundColor3, game:GetService("TweenService")
	local px, po, pv, sv, fs = h.Position.X.Scale, h.Position.X.Offset, h.Position.Y.Offset, false, -1
	h.Position, h.Visible, fn.Visible = UDim2.new(px, po, -0.2, pv), false, true
	if not pcall(function() sg.Parent = gethui() end) then sg.Parent = lp.PlayerGui end
	table.insert(cs, sg)
	local function sl(v)
		if v == sv then return end
		sv = v
		if v then h.Visible = true end
		local t = tw:Create(h, TweenInfo.new(0.35, Enum.EasingStyle.Quint, v and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = UDim2.new(px, po, v and 0.1 or -0.2, pv)})
		t.Completed:Connect(function() if not sv then h.Visible = false end end)
		t:Play()
	end
	local st, im, nr, iy, kh = nil, nil, 0, {}, false
	for n, v in ix do iy[v] = n end
	local function nf(n)
		return (tostring(math.floor(n + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	table.insert(cs, fc.FishFirstPullStart.OnClientEvent:Connect(function(id, hp, mx) st = {bd[id] and bd[id][1] or tostring(id), hp, mx, 1, bd[id] and bd[id][2]} end))
	table.insert(cs, fc.FishReelStartAck.OnClientEvent:Connect(function(id, hp, mx) if not st then st = {bd[id] and bd[id][1] or tostring(id), hp, mx, 1, bd[id] and bd[id][2]} end end))
	table.insert(cs, fc.FishReelHPUpdate.OnClientEvent:Connect(function(hp) if st then st[2] = hp end end))
	table.insert(cs, fc.FishReelPhaseHP.OnClientEvent:Connect(function(hp, mx) if st then st[2], st[3], st[4] = hp, mx, 2 end end))
	table.insert(cs, fc.FishCatchResult.OnClientEvent:Connect(function() st = nil end))
	table.insert(cs, fc.FishReset.OnClientEvent:Connect(function() st = nil end))
	table.insert(cs, fc.FishWaitingAck.OnClientEvent:Connect(function() st = nil end))
	table.insert(cs, game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			local ev, ek, ex = rv.EventController and rv.EventController._active_events, nil, 0
			for k, v in type(ev) == "table" and ev or {} do
				if en[k] then ek, ex = k, math.max(v.expire_at or 0, v.admin_override_expire_at or 0) end
			end
			local gh = sr.Parent and sr:FindFirstChild("Holder")
			sl((ek ~= nil or st ~= nil) and not (gh and gh.Visible))
			if not sv then return end
			if os.clock() >= nr then
				nr, im = os.clock() + 1, nil
				task.spawn(function()
					local o, v = pcall(function()
						local _, sa = bq()
						return (tonumber(pd().LastBossKillSlot) or 0) >= (sa or workspace:GetServerTimeNow() // 2400 * 2400)
					end)
					kh = o and v == true
				end)
				for _, x in game:GetService("CollectionService"):GetTagged("BossRegion") do
					local fx = x:FindFirstChild("BossSpawnerFX")
					if fx and fx:GetAttribute("BossSpawnerFXActive") == true and x.Parent and x.Parent.Parent then im = iy[x.Parent.Parent.Name] or x.Parent.Parent.Name end
				end
			end
			local lf, bo2 = math.floor(ex - workspace:GetServerTimeNow()), ek ~= nil and (not st or st[5])
			fn.Text = (st and st[1] or en[ek] or "Boss") .. (bo2 and im and ` - {im}` or "")
			if st then
				local f = math.clamp(st[2] / math.max(st[3], 1), 0, 1)
				if f ~= fs then
					fs = f
					tw:Create(fi, TweenInfo.new(0.15), {Size = UDim2.fromScale(f, 1)}):Play()
				end
				fi.BackgroundColor3 = f0
				if g1 then g1.Enabled = st[4] < 2 end
				if g2 then g2.Enabled = st[4] >= 2 end
				ht.Text = `{nf(st[2])} / {nf(st[3])}`
			else
				if fs ~= 1 then
					fs = 1
					tw:Create(fi, TweenInfo.new(0.15), {Size = UDim2.fromScale(1, 1)}):Play()
				end
				local hd = kh and ek ~= nil
				fi.BackgroundColor3 = hd and Color3.fromRGB(96, 165, 110) or Color3.fromRGB(70, 70, 80)
				if g1 then g1.Enabled = false end
				if g2 then g2.Enabled = false end
				ht.Text = hd and "Hunted" or lf > 0 and string.format("Not Hooked - %d:%02d", lf // 60, lf % 60) or "Not Hooked"
			end
		end)
	end))
end

task.spawn(bh)

local function iq()
	local o = ge.__FmQ
	if o then
		o.on = false
		pcall(function() o.sg:Destroy() end)
	end
	local tk, lb, rb, ylb, klb, flb = {on = true}, nil, nil, nil, nil, nil
	ge.__FmQ = tk
	local ok0, hu = pcall(gethui)
	for _, rt in {ok0 and hu or lp.PlayerGui, lp.PlayerGui} do
		for _, x in rt:GetDescendants() do
			if x:IsA("TextLabel") and x.Text == qtx then lb = x end
			if x:IsA("TextLabel") and x.Text == rtx then rb = x end
			if x:IsA("TextLabel") and x.Text == ytx then ylb = x end
			if x:IsA("TextLabel") and x.Text == ktx then klb = x end
			if x:IsA("TextLabel") and x.Text == fql.t then flb = x end
		end
		if lb then break end
	end
	if lb then lb.RichText = true end
	if rb then rb.RichText = true end
	if ylb then ylb.RichText = true end
	if klb then klb.RichText = true end
	if flb then flb.RichText = true end
	fql.l:Set("Loading...")
	iql:Set("Loading...")
	rql:Set("Loading...")
	yql:Set("Loading...")
	sql:Set("Loading...")
	local iy = {}
	for n, v in ix do iy[v] = n end
	local function nf(v)
		return (tostring(math.floor(v + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	local function kg(v)
		return v >= 100 and `{nf(v)} kg` or `{string.format("%.1f", v)} kg`
	end
	local qf = {
		crimson_bead_rod = {RequiredFished = 100, RequiredCoin = 3000000},
		bamboo_rod = {RequiredBamboo = 20, RequiredCoin = 3600000},
		heaven_piercer_turtle_rod = {RequiredFish = 5, RequiredCoin = 5000000},
		zen_staff_rod = {RequiredFish = 5, RequiredCoin = 5000000},
		dread_fish_rod = {RequiredFish = 1, RequiredCoin = 10000000},
		taiji_hooking_art_v2 = {RequiredKills = 100, RequiredCoin = 1000000},
	}
	local function rd(k)
		local q = qm[L.Flags[k or "qs"]]
		if not q then return nil end
		local d, ct = pd(), md("Data", "Catalog")
		local cq = d.Quest and d.Quest.Current
		local ac, id = cq and cq.Id == q[1], q[1]
		if ((d.Quest or {}).Done or {})[id] then return {`{q[4]} (Completed)`, {}} end
		local pr, df, ln = ac and qe(id, cq.Progress) or {}, qf[id] or {}, {}
		local function gv(k) return pr[k] or df[k] or 0 end
		local function ro(n, h, w, s) table.insert(ln, {`{n}: {nf(h)} / {nf(w)}`, h >= w, s}) end
		local na = not ac and "Counts only after accepting" or nil
		if q[10] then
			local ir, ci, x = md("Shared", "Lib", "questRules").IsCompleted, cq and cq.Id or "", nil
			for _, y in q[10] do
				local dn = ir(d, y[1])
				if y[1] == ci and not dn or not x and not dn then x = y end
				table.insert(ln, {`{y[4]}: {dn and "Done" or y[1] == ci and "Accepted" or "Not Done"}`, dn})
			end
			if not x then return {`{q[4]} (Completed)`, ln} end
			local xa = x[1] == ci
			local xp2 = qe(x[1], xa and cq.Progress or {})
			local _, ks = qc(x, d, xp2)
			local fa, n = xp2.RequiredAny, {}
			for v in ks do
				local fx = d.Inventory.Fishes[v]
				if fx then n[fx.fishId] = (n[fx.fishId] or 0) + 1 end
			end
			table.insert(ln, {`{iy[x[2]] or x[2]}: {ul(x[2]) and "Unlocked" or "Locked"}`, ul(x[2])})
			ro("Coins", d.Coin or 0, xp2.RequiredCoin or 0)
			ro("Gems", d.Gem or 0, xp2.RequiredGem or 0)
			if x[1] == "godslayer_rod_v1_inheritance" then
				ro("Lotus Fish With Chu Xin In Team", xa and xp2.CurrentFish or 0, xp2.RequiredFish or 100, not xa and "Counts only after accepting" or "The hub puts Chu Xin in the team")
			end
			for fi, w in xp2.RequiredWeights or {} do
				local fo = ct.Fish.GetById(fi)
				ro(`{fo and fo.name or fi} Over {nf(w)} kg`, n[fi] or 0, (xp2.RequiredFishes or {})[fi] or 1)
			end
			if type(fa) == "table" then
				local c = 0
				for _ in ks do c += 1 end
				ro(`{fa.rarity or fa.kind or "Any"} Fish{fa.minWeightExclusive and ` Over {nf(fa.minWeightExclusive)} kg` or ""}`, c, fa.count or 1, fa.kind == "Boss" and "Caught by Auto Boss" or nil)
			end
			for b, v in x[1] == "godslayer_rod_v2_inheritance" and xp2.RequiredBooks or {} do
				local sk2 = ct.Skill.GetById(b)
				ro(`{sk2 and sk2.name or b} Book`, ((d.Inventory or {}).Books or {})[b] or 0, v)
			end
			return {`{q[4]}: {x[4]}{xa and " (Accepted)" or ""}`, ln}
		end
		if q[12] then
			local p2, n = qe(id, ac and cq.Progress or {}), {}
			table.insert(ln, {`{iy[q[2]] or q[2]}: {ul(q[2]) and "Unlocked" or "Locked"}`, ul(q[2])})
			ro("Coins", d.Coin or 0, p2.RequiredCoin or 0)
			ro("Gems", d.Gem or 0, p2.RequiredGem or 0)
			for _, t in p2.Tr or {} do
				ro((tostring(t.label or t.field):gsub("<[^>]+>", "")), ac and tonumber(p2[t.field]) or 0, t.target, na)
			end
			for v in select(2, qc(q, d, p2)) do
				local fx = d.Inventory.Fishes[v]
				if fx then n[fx.fishId] = (n[fx.fishId] or 0) + 1 end
			end
			for fi, c in p2.RequiredFishes or {} do
				local fo, w = ct.Fish.GetById(fi), (p2.RequiredWeights or {})[fi]
				ro(`{fo and fo.name or fi}{w and ` Over {nf(w)} kg` or ""}`, n[fi] or 0, c)
			end
			for b, v in p2.RequiredBooks or {} do
				local sk2 = ct.Skill.GetById(b)
				ro(`{sk2 and sk2.name or b} Book`, ((d.Inventory or {}).Books or {})[b] or 0, v)
			end
			for k, v in p2.RequiredItems or {} do
				local mt = ct.Material.GetById(k)
				ro(mt and mt.name or k, md("Shared", "getItemCount")(d, k), v)
			end
			return {`{q[4]}{ac and " (Accepted)" or ""}`, ln}
		end
		local u = ul(q[2])
		table.insert(ln, {`{iy[q[2]] or q[2]}: {u and "Unlocked" or "Locked"}`, u})
		if q[7] then
			local r, o = ct.Rod.GetById(q[7]), d.Rods and d.Rods[q[7]] ~= nil
			table.insert(ln, {`Own {r and r.name or q[7]}: {o and "Yes" or "No"}`, o})
		end
		ro("Coins", d.Coin or 0, gv("RequiredCoin"))
		if id == "crimson_bead_rod" then
			ro("Fish With Legacy Rod", ac and pr.CurrentFished or 0, gv("RequiredFished"), na)
		elseif id == "bamboo_rod" then
			ro("Bamboo Fragments", md("Shared", "getItemCount")(d, "bamboo_fragment"), gv("RequiredBamboo"), "10% drop while fishing on Jungle Island")
		elseif id == "zen_staff_rod" then
			ro("Final Blows With Taiji Hooking Art V2", ac and pr.CurrentFish or 0, gv("RequiredFish"), `Legendary fish from Fossil Island{na and `, {na:lower()}` or ""}`)
		elseif id == "taiji_hooking_art_v2" then
			ro("Final Blows With Taiji Hooking Art", ac and pr.CurrentKills or 0, gv("RequiredKills"), `Any fish, any island{na and `, {na:lower()}` or ""}`)
			local bk = ((d.Inventory or {}).Books or {}).taiji_hooking_art or 0
			table.insert(ln, {`Taiji Hooking Art Books: {bk}`, bk >= 1, "One book is turned into V2; the hub unequips it before completing"})
		elseif q[6] then
			local c = 0
			for _ in select(2, qc(q, d, {RequiredFish = gv("RequiredFish")})) do c += 1 end
			ro(`{q[6][1]} Fish`, c, gv("RequiredFish"), `Any {q[6][1]} fish from {iy[q[6][2]] or q[6][2]}`)
		end
		return {`{q[4]}{ac and " (Accepted)" or ""}`, ln}
	end
	local function rs(r, rh2, nm)
		if not r then return `No {nm or "Rod"} Quest Selected` end
		local t = {rh2 and `<b>{r[1]}</b>` or r[1]}
		for _, v in r[2] do
			local hn = v[3] and (rh2 and ` <font color="#96938C">- {v[3]}</font>` or ` - {v[3]}`) or ""
			table.insert(t, (rh2 and `<font color="#{v[2] and "78C882" or "D66A5E"}">{v[1]}</font>` or v[1]) .. hn)
		end
		return table.concat(t, "\n")
	end
	local function dt()
		local d, q = pd(), nil
		for _, x in qd do
			if not ul(x[3]) then q = x; break end
		end
		if not q then return {} end
		local ct, cq = md("Data", "Catalog"), d.Quest and d.Quest.Current
		local pr = cq and cq.Id == q[1] and qe(q[1], cq.Progress) or q[5]
		local _, ks = qc(q, d, pr)
		local ln, n, bw, fl = {{"Coins", d.Coin or 0, pr.RequiredCoin or 0}}, {}, {}, {}
		for u in ks do
			local x = d.Inventory.Fishes[u]
			if x then n[x.fishId] = (n[x.fishId] or 0) + 1 end
		end
		for _, x in d.Inventory.Fishes do bw[x.fishId] = math.max(bw[x.fishId] or 0, x.weight or 0) end
		for _, il in ix do
			for _, x in (ct.Island.GetById(il) or {}).fishes or {} do
				fl[x.fishId] = fl[x.fishId] and `{fl[x.fishId]}, {iy[il]}` or iy[il]
			end
		end
		if q[6] then
			local c = 0
			for _ in ks do c += 1 end
			table.insert(ln, {`{q[6][1]} Fish`, c, pr.RequiredFish or 1, `Any {q[6][1]} fish from {iy[q[6][2]] or q[6][2]}`})
		else
			local wk, fs = q[1] == "unlock_island_6" and md("Data", "Config", "QuestConfig").UnlockIsland6MinWeightKg or {}, {}
			for id, v in pr.RequiredFishes or {} do
				local fi = ct.Fish.GetById(id)
				local nm, rr, il = fi and fi.name or id, fi and fi.rarity or "?", fl[id] or "?"
				table.insert(fs, {nm, n[id] or 0, v, wk[id] and `Need {kg(wk[id])} - Best {bw[id] and kg(bw[id]) or "none"} - {rr} - {il}` or `{rr} - {il}`, wk[id] or 0})
			end
			table.sort(fs, function(x, y)
				if x[5] ~= y[5] then return x[5] < y[5] end
				return x[1] < y[1]
			end)
			for _, x in fs do table.insert(ln, x) end
		end
		return {q[4], ln, cq and cq.Id == q[1]}
	end
	local function yd()
		local d, ct = pd(), md("Data", "Catalog")
		local cq, so, dn, ps = (d.Quest or {}).Current or {}, (d.Inventory or {}).Souls or {}, (d.Quest or {}).Done or {}, L.Flags.ys or {}
		local se = ct.Soul.GetById(d.SoulEquip or "")
		local t = {{`Equipped Soul: {se and se.name or "Human"}`}}
		if #ps == 0 then table.insert(t, {"No Soul Quest Selected"}) end
		for _, q in qg do
			local id = q[1]
			if not table.find(ps, q[4]) then continue end
			if dn[id] or so[id] == true then
				table.insert(t, {`{q[4]} (Owned)`, true, nil, true})
				continue
			end
			local ac = cq.Id == id
			local pr, u = ac and qe(id, cq.Progress) or {}, ul(q[2])
			table.insert(t, {`{q[4]}{ac and " (Accepted)" or ""}`, nil, nil, true})
			table.insert(t, {`{iy[q[2]] or q[2]}: {u and "Unlocked" or "Locked"}`, u})
			if id == "azure_dragon" or id == "supreme_king" then
				local h, w = ac and pr.CurrentUsedSkill or 0, pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5)
				table.insert(t, {`{id == "azure_dragon" and "Final Blows With One Hook Supreme" or "Legendary Final Blows With Rod Gate 20%"}: {nf(h)} / {nf(w)}`, h >= w, `{id == "azure_dragon" and "Any fish" or "Legendary fish from Fossil Island"}{ac and "" or ", counts only after accepting"}`})
			end
			if q[6] then
				local w, c = pr.RequiredFish or 3, 0
				for _ in select(2, qc(q, d, {RequiredFish = w})) do c += 1 end
				table.insert(t, {`{q[6][1]} Fish{q[6][3] and ` {nf(q[6][3])}+ kg` or ""}: {c} / {w}`, c >= w, `From {iy[q[6][2]] or q[6][2]}`})
			end
			for b, v in id == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or id == "supreme_king" and (pr.RequiredBooks or {rod_gate_20_percent = 1}) or {} do
				local a = ((d.Inventory or {}).Books or {})[b] or 0
				table.insert(t, {`{(ct.Skill.GetById(b) or {}).name or b} Book: {math.min(a, v)} / {v}`, a >= v, "Taken off the rod when turning in"})
			end
		end
		return t
	end
	local function yr(r, l)
		local t = {}
		for _, v in r do
			local x = v[4] and (l and `<b>{v[1]}</b>` or v[1]) or v[2] ~= nil and l and `<font color="#{v[2] and "78C882" or "D66A5E"}">{v[1]}</font>` or v[1]
			table.insert(t, x .. (v[3] and (l and ` <font color="#96938C">- {v[3]}</font>` or ` - {v[3]}`) or ""))
		end
		return table.concat(t, "\n")
	end
	local function fd()
		local d, ct, cf = pd(), md("Data", "Catalog"), md("Data", "Config", "RodForgeConfig")
		local rs, gf, rv1, hi, tg = d.Rods or {}, md("Shared", "Lib", "RodModifiers").GetForgedStats, L.Flags.fm == "Reforge V1 To Perfect", 0, nil
		local function rn(id) return (ct.Rod.GetById(id) or {}).name or id end
		for i, id in cf.Order do
			if rs[id] ~= nil then hi = i end
		end
		local hs = hi > 0 and gf(cf.Order[hi], rs[cf.Order[hi]])
		local t = {{`Owned: {hi > 0 and `{rn(cf.Order[hi])} ({hs and hs.quality or "?"})` or "None"}`}}
		if rv1 then
			local q1 = gf(cf.Order[1], rs[cf.Order[1]])
			if not (q1 and q1.quality == cf.QualityNames[#cf.QualityNames]) then tg = cf.Order[1] end
		else
			tg = cf.Order[hi + 1]
		end
		if not tg then
			table.insert(t, 1, {rv1 and `{rn(cf.Order[1])} Is Perfect` or "Rod Forge Chain Done", nil, nil, true})
			return t
		end
		local rc, st = cf.Recipes[tg], md("Shared", "Lib", "RodForgeRules").GetStatus(d, tg) or {}
		table.insert(t, 1, {`{rv1 and "Reforge" or "Next"}: {rn(tg)}{st.ready and " (Ready)" or ""}`, nil, nil, true})
		table.insert(t, {`Lotus Island: {st.hasIsland7 and "Unlocked" or "Locked"}`, st.hasIsland7 == true, "Forge is on Lotus"})
		if rc.previousRodId then table.insert(t, {`{rn(rc.previousRodId)}: {st.hasPreviousRod and "Owned" or "Missing"}`, st.hasPreviousRod == true, "Used up by the forge"}) end
		local fi, jg, nr, nj = ((d.Inventory or {}).Fishes or {}), {}, {}, 0
		for _, x in (ct.Island.GetById("island_jungle") or {}).fishes or {} do jg[x.fishId] = true end
		for _, u in st.fishUids or {} do
			local x = fi[u]
			local fo = x and ct.Fish.GetById(x.fishId)
			if fo then nr[fo.rarity] = (nr[fo.rarity] or 0) + 1 end
			if x and jg[x.fishId] then nj += 1 end
		end
		local n = #(st.fishUids or {})
		if rc.fishKind == "Rarities" then
			for _, r in {"Common", "Uncommon", "Rare", "Epic", "Legendary"} do table.insert(t, {`{r} Fish: {nr[r] or 0} / 1`, (nr[r] or 0) >= 1, "Any island, unlocked"}) end
		elseif rc.fishKind == "Island7Legendary" then
			table.insert(t, {`Lotus Legendary Fish: {n} / {rc.fishCount}`, n >= rc.fishCount, "From Lotus Island, unlocked"})
		elseif rc.fishKind == "Islands23Legendary" then
			table.insert(t, {`Jungle Legendary Fish: {nj} / {rc.fishCount / 2}`, nj >= rc.fishCount / 2, "From Jungle Island, unlocked"})
			table.insert(t, {`Desert Legendary Fish: {n - nj} / {rc.fishCount / 2}`, n - nj >= rc.fishCount / 2, "From Desert Island, unlocked"})
		else
			table.insert(t, {`Boss Fish: {n} / {rc.fishCount}`, n >= rc.fishCount, "Needs Auto Boss, unlocked"})
		end
		if rc.mythicalBookCount > 0 then table.insert(t, {`Mythical Book: {st.bookId and 1 or 0} / {rc.mythicalBookCount}`, st.bookId ~= nil, st.bookId and `{(ct.Skill.GetById(st.bookId) or {}).name or st.bookId} will be used up` or "Unequipped Mythical book"}) end
		if rc.coinCost > 0 then table.insert(t, {`Coins: {nf(d.Coin or 0)} / {nf(rc.coinCost)}`, (d.Coin or 0) >= rc.coinCost}) end
		if rc.gemCost > 0 then table.insert(t, {`Gems: {nf(d.Gem or 0)} / {nf(rc.gemCost)}`, (d.Gem or 0) >= rc.gemCost}) end
		return t
	end
	local function kd()
		local st, ct, t = game:GetService("ReplicatedStorage"):GetAttribute("SkillMarketStock"), md("Data", "Catalog"), {}
		for id in (type(st) == "string" and st or ""):gmatch("[^,]+") do
			local x = ct.Skill.GetById(id)
			table.insert(t, x and x.name or id)
		end
		return #t > 0 and table.concat(t, "\n") or "No Stock"
	end
	while ge.__FmQ == tk do
		local ok, r = cx(dt)
		if ok and r then
			local t = {r[1] and `Next Island: {r[1]}{r[3] and " (Accepted)" or ""}` or "All Islands Unlocked"}
			if lb then t[1] = `<b>{t[1]}</b>` end
			for _, v in r[2] or {} do
				local x = `{v[1]}: {nf(v[2])} / {nf(v[3])}`
				local hn = v[4] and (lb and ` <font color="#96938C">- {v[4]}</font>` or ` - {v[4]}`) or ""
				table.insert(t, (lb and `<font color="#{v[2] >= v[3] and "78C882" or "D66A5E"}">{x}</font>` or x) .. hn)
			end
			iql:Set(table.concat(t, "\n"))
		end
		local ok2, r2 = cx(rd, "qs")
		if ok2 then rql:Set(rs(r2, rb)) end
		local ok5, r5 = cx(rd, "ks")
		if ok5 then sql:Set(rs(r5, klb, "Skill")) end
		local ok4, r4 = cx(yd)
		if ok4 and r4 then yql:Set(yr(r4, ylb)) end
		local ok6, r6 = cx(fd)
		if ok6 and r6 then fql.l:Set(yr(r6, flb)) end
		local ok3, r3 = cx(kd)
		if ok3 then kql:Set(r3) end
		task.wait(1)
	end
end

task.spawn(iq)
