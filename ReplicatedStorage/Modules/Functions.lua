--!strict
local ServiceLib = {}

--[[Services]]
local RepStore: any = game:GetService("ReplicatedStorage")
local Collector: CollectionService = game:GetService("CollectionService")
local RunService: RunService = game:GetService("RunService")
local Content: ContentProvider = game:GetService("ContentProvider")
local Debris: Debris = game:GetService("Debris")
--[[Other stuff]]
local Rand: Random = Random.new()
local Relay: RemoteEvent = RepStore.Events.Relay
local Relay2: RemoteEvent = RepStore.Events.Relay2
local Relay3: RemoteEvent = RepStore.Events.Relay3

--[[Logic functions]]

function ServiceLib:CoCreate(func: any, ...: any): any
	return coroutine.wrap(func,...)()
end 


function ServiceLib:TweenNew(Part: Part,Info: TweenInfo ,Changes: {}, Client: any)
	Relay:FireAllClients(Part,Info,Changes,Client)
end

function ServiceLib:yield(n: number)
	n = n or 0
	local Delta: number = 0
	repeat
		Delta += RunService.Heartbeat:Wait()
	until Delta > n
end

--[[Custom Math Lib]]

function ServiceLib:CalcRNG(min: number, max: number): number
	local RandIntg: number = Rand:NextInteger(min or -5,max or 5)
	return RandIntg
end

function ServiceLib:vecrandomizer(vec: Vector3, noise1: number, noise2: number): Vector3
	local x: number, y: number, z: number = vec.X*ServiceLib:CalcRNG(noise1,noise2),vec.Y*ServiceLib:CalcRNG(noise1,noise2),vec.Z*ServiceLib:CalcRNG(noise1,noise2)
	return Vector3.new(x,y,z)
end

function ServiceLib:LerpVal(orig: Vector3, pos: Vector3 ,alpha: number): Vector3
	return orig + (pos-orig) * alpha
end

--[[HitDetection]]

function ServiceLib:RayCastNew(Origin: Vector3, Direction: Vector3, Distance: number, InstanceArray: any): (Instance,Vector3)
	local raycastparams: RaycastParams = RaycastParams.new()
	raycastparams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastparams.FilterDescendantsInstances = InstanceArray or {}

	local NewRay: RaycastResult = workspace:Raycast(Origin, Direction*Distance, raycastparams) or nil
	local HitInstance: Instance, ReturnedPos: Vector3
	if NewRay then
		HitInstance = NewRay.Instance
		ReturnedPos = NewRay.Position
	end
	return HitInstance,ReturnedPos
end

function ServiceLib:MagNew(Pos: Vector3, Size: number, damage: number, char: any): ({},Instance)
	local NewTable: {} = table.create(20)
	local FirstHit: any 
	for i,m: any in pairs(Collector:GetTagged("Character")) do
		if m.Humanoid then
			local root: any = m.Torso or nil
			if root ~= nil then
				local magni: number = (Pos - root.Position).Magnitude
				if Size or Size > magni then
					if damage and m ~= char then
						m.Humanoid:TakeDamage(damage)
					end
					table.insert(NewTable,i,m)
					FirstHit = m
				end
			end
		end
	end 
	return NewTable, FirstHit
end

--[[Constructors]]

function ServiceLib:CreateVel(VelocityTable: any, DebrisTime: number): any
	local NewVel = Instance.new(VelocityTable.VelType) VelocityTable["VelType"] = nil
	for i,k in pairs(VelocityTable) do
		NewVel[i] = k
	end Debris:AddItem(NewVel,DebrisTime or .2)
	return NewVel
end

function ServiceLib:CreateSFX(AudioTable: any, DebrisTime: number, destroy: boolean): Sound
	local NewAudio: any = Instance.new("Sound",AudioTable.Parent) AudioTable["Parent"] = nil
	for i,k in pairs(AudioTable) do
		NewAudio[i] = k
	end NewAudio:Play()
	if destroy then
		Debris:AddItem(NewAudio, DebrisTime or NewAudio.Ended:Wait())
	end
	return NewAudio
end

function ServiceLib:LocalInstance(InstanceProps: {})
	Relay2:FireAllClients(InstanceProps)
end

function ServiceLib:PositionClient(part: Part, secndpart: Part)
	Relay3:FireAllClients(part,secndpart)
end

--[[For Reference V
local TweenDict = {
	Objects = {Object1,Object2},
	Info = TweenInfo,
	Changes = {}
}]]


function ServiceLib:BulkTween(TweenTable: any, Client: any)
	for _,v in pairs(TweenTable) do
		ServiceLib:TweenNew(v,TweenTable.Info,TweenTable.Changes, Client)
	end
end

function ServiceLib:PreloadAsync(Array: any)
	Content:PreloadAsync(Array)
end

--[[Premade functions]]

function ServiceLib:GiveReduction(Humanoid: Humanoid, Reduct: number, Time: number)
	local IgnoreHealthChange: boolean = false
	local DamageReduct: boolean = false
	local ReduceDamage: any

	ServiceLib:CoCreate(function()
		DamageReduct = true
		ServiceLib:yield(Time)
		DamageReduct = false
	end)


	local CurrentHealth: number = Humanoid.Health
	ReduceDamage = Humanoid.Changed:Connect(function(Property)
		local NewHealth: number = Humanoid.Health
		if DamageReduct then
			if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
				if NewHealth < CurrentHealth then
					local DamageDealt: number = (CurrentHealth - NewHealth)
					IgnoreHealthChange = true
					Humanoid.Health = (Humanoid.Health + Reduct * DamageDealt)
					IgnoreHealthChange = false
				end
			end
			CurrentHealth = NewHealth
		else
			ReduceDamage:Disconnect()
		end
	end)
end




return ServiceLib