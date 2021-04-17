local ServiceLib = {}

--[[Services]]
local RepStore = game:GetService("ReplicatedStorage")
local Collector = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Content = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
--[[Other stuff]]
local Rand = Random.new()
local Relay = RepStore.Events.Relay
local Relay2 = RepStore.Events.Relay2
local Relay3 = RepStore.Events.Relay3

--[[Logic functions]]

function ServiceLib:CoCreate(func,...)
	coroutine.wrap(func,...)()
end 


function ServiceLib:TweenNew(Part,Info,Changes,Client)
	Relay:FireAllClients(Part,Info,Changes,Client)
end

function ServiceLib:yield(n)
	n = n or 0
	local Delta = 0
	repeat
		Delta = Delta + RunService.Heartbeat:Wait()
	until Delta > n
end

--[[Custom Math Lib]]

function ServiceLib:CalcRNG(min,max)
	local RandIntg = Rand:NextInteger(min or -5,max or 5)
	return RandIntg
end

function ServiceLib:vecrandomizer(vec,noise1,noise2)
	local x,y,z = vec.X*ServiceLib:CalcRNG(noise1,noise2),vec.Y*ServiceLib:CalcRNG(noise1,noise2),vec.Z*ServiceLib:CalcRNG(noise1,noise2)
	return Vector3.new(x,y,z)
end

function ServiceLib:LerpVal(orig,pos,alpha)
	return orig + (pos-orig) * alpha
end

--[[HitDetection]]

function ServiceLib:RayCastNew(Origin,Direction,Distance,InstanceArray)
	local raycastparams = RaycastParams.new()
	raycastparams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastparams.FilterDescendantsInstances = InstanceArray or {}

	local NewRay = workspace:Raycast(Origin, Direction*Distance, raycastparams) or nil
	local HitInstance,ReturnedPos
	if NewRay ~= nil then
		HitInstance = NewRay.Instance
		ReturnedPos = NewRay.Position
	end
	return HitInstance,ReturnedPos
end

function ServiceLib:MagNew(Pos,Size,damage,char)
	local NewTable = {}
	local FirstHit 
	for _,m in pairs(Collector:GetTagged("Character")) do
		if m.Humanoid then
			local root = m.Torso or nil
			if root ~= nil then
				local magni = (Pos - root.Position).Magnitude
				if Size == nil or Size > magni then
					if damage and m ~= char then
						m.Humanoid:TakeDamage(damage)
					end
					table.insert(NewTable,m)
					FirstHit = m
				end
			end
		end
	end print(unpack(NewTable))
	return NewTable, FirstHit
end

--[[Constructors]]

function ServiceLib:CreateVel(VelocityTable,DebrisTime)
	local NewVel = Instance.new(VelocityTable.VelType) VelocityTable["VelType"] = nil
	for i,k in pairs(VelocityTable) do
		NewVel[i] = k
	end Debris:AddItem(NewVel,DebrisTime or .2)
	return NewVel
end

function ServiceLib:CreateSFX(AudioTable,DebrisTime,destroy)
	local NewAudio = Instance.new("Sound",AudioTable.Parent) AudioTable["Parent"] = nil
	for i,k in pairs(AudioTable) do
		NewAudio[i] = k
	end NewAudio:Play()
	if destroy then
		Debris:AddItem(NewAudio, DebrisTime or NewAudio.Ended:Wait())
	end
	return NewAudio
end

function ServiceLib:LocalInstance(InstanceProps)
	Relay2:FireAllClients(InstanceProps)
end

function ServiceLib:PositionClient(part,secndpart)
	Relay3:FireAllClients(part,secndpart)
end

--[[For Reference V
local TweenDict = {
	Objects = {Object1,Object2},
	Info = TweenInfo,
	Changes = {}
}]]


function ServiceLib:BulkTween(TweenTable)
	for Objects = 1, #TweenTable.Objects do 
		local v = TweenTable.Objects[Objects]
		ServiceLib:TweenNew(v,TweenTable.Info,TweenTable.Changes)
	end
end

function ServiceLib:PreloadAsync(Array)
	Content:PreloadAsync(Array)
end

--[[Premade functions]]

function ServiceLib:GiveReduction(Humanoid,Reduct,Time)
	local IgnoreHealthChange = false
	local DamageReduct = false
	local ReduceDamage

	ServiceLib:CoCreate(function()
		DamageReduct = true
		ServiceLib:yield(Time)
		DamageReduct = false
	end)


	local CurrentHealth = Humanoid.Health
	ReduceDamage = Humanoid.Changed:connect(function(Property)
		local NewHealth = Humanoid.Health
		if DamageReduct then
			if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
				if NewHealth < CurrentHealth then
					local DamageDealt = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					Humanoid.Health = (Humanoid.Health + Reduct * DamageDealt)
					IgnoreHealthChange = false
				end
			end
			CurrentHealth = NewHealth
		end
	end)
end




return ServiceLib
