
--[[Services]]
local RepStore = game:GetService("ReplicatedStorage")
local Collector = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Content = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
--[[Other stuff]]
local Relay = script.Relay
local Relay2 = script.Relay2

local yeah = {}

function yeah:CoCreate(func,...)
	coroutine.wrap(func,...)()
end

function yeah:TweenNew(Part,Info,Changes,Client)
	Relay:FireAllClients(Part,Info,Changes,Client)
end

function yeah:yield(n)
	n = n or 0
	local Delta = 0
	repeat
		Delta = Delta + RunService.Heartbeat:Wait()
	until Delta >= n
	return Delta
end


--[[Constructors]]

function yeah:CreateVel(VelocityTable,DebrisTime)
	local NewVel = Instance.new(VelocityTable.VelType) 
	VelocityTable["VelType"] = nil
	for i,k in pairs(VelocityTable) do
		NewVel[i] = k
	end Debris:AddItem(NewVel,DebrisTime or .2)
	return NewVel
end

function yeah:CreateSFX(AudioTable,DebrisTime)
	local NewAudio = Instance.new("Sound",AudioTable.Parent) AudioTable["Parent"] = nil
	for i,k in pairs(AudioTable) do
		NewAudio[i] = k
	end NewAudio:Play() Debris:AddItem(NewAudio, DebrisTime or NewAudio.Ended:Wait())
	return NewAudio
end

function yeah:LocalInstance(InstanceProps)
	Relay2:FireAllClients(InstanceProps)
end


return yeah
