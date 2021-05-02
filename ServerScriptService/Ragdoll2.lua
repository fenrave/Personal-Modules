--!strict
--[[Services]]
local Players: any = game:GetService("Players")
local Debris: Debris = game:GetService("Debris")
--[[Stuff]]
local Rags: any = game.ReplicatedStorage:WaitForChild("Rags",15)

local GirlHair: any = require(game.ReplicatedStorage:WaitForChild("GIRLHAIRS"))

local FirstWeight: Part = Instance.new("Part") do
	FirstWeight.Transparency = 1
	FirstWeight.Name = "Weight"
end

local Sockets: BallSocketConstraint = Instance.new("BallSocketConstraint") do
	Sockets.Radius = .15
	Sockets.LimitsEnabled = true
	Sockets.MaxFrictionTorque = .5
	Sockets.Restitution = 0
	Sockets.TwistLimitsEnabled = true
	Sockets.UpperAngle = 180
	Sockets.TwistLowerAngle = -45
	Sockets.UpperAngle = 45
end

local mult: any = {
	["Head"] = Vector3.new(0,-1,0),
	["Right Arm"] = Vector3.new(-1,.5,0),
	["Left Arm"] = Vector3.new(1,.5,0),
	["Left Leg"] = Vector3.new(-1,1,0),
	["Right Leg"] = Vector3.new(1,1,0)
}

local function Merge(Main: string, ...: any)
	return string.format(Main, ...)
end

local function NoiseMaker(Char)
	local GamerGirl: boolean = false
	local HRP: Part = Char:FindFirstChild("Torso")
	local Descendants: {} = Char:GetDescendants()

	local st: string = Merge("Death%s",math.random(1,4))

	for _,k in pairs(Descendants) do
		if k:IsA("MeshPart") then
			if GirlHair[k.MeshId] then
				GamerGirl = true
				st = Merge("femaleded%s",math.random(1,4))
				break
			end
		end
	end

	local Audio: any = script:FindFirstChild(st):Clone()
	Audio.Parent = HRP
	Audio:Play()
	Debris:AddItem(Audio,2)
end

local function Anchors(Character: any): {}

	local Attachments: {} = {}

	for _,k in pairs(Character:GetChildren()) do
		if k:IsA("Part") then
			if k.Name == "Torso" or k.Name == "HumanoidRootPart" then
				continue
			end
			local Weight: any = FirstWeight:Clone()
			Weight.Position = k.Position
			Weight.Orientation = k.Orientation
			Weight.Size = Vector3.new(k.Size.X*.8,1,k.Size.Z*.8)

			local Constraint: WeldConstraint = Instance.new("WeldConstraint") do
				Constraint.Parent = Weight
				Constraint.Part1 = Weight
				Constraint.Part0 = k
			end

			local Attachment: Attachment = Instance.new("Attachment") do
				Attachment.Parent = k
				Attachment.Position = Vector3.new(k.Size.X,k.Size.Y,0)*.5 * mult[k.Name]
			end table.insert(Attachments, Attachment)

			Weight.Parent = k

		end
	end

	return Attachments
end


local function RagSetUp(Character: any)
	local Attachments: any = Anchors(Character)

	local CharTorso: Part = Character:WaitForChild("Torso",10)
	Character.Humanoid.BreakJointsOnDeath = false
	Character.Humanoid.RequiresNeck = false

	for _,Joint in pairs(Attachments) do

		local TorsoAttachment: Attachment = Instance.new("Attachment", CharTorso)
		TorsoAttachment.WorldPosition = Joint.WorldPosition

		local NewSocket: any = Sockets:Clone()
		NewSocket.Parent = CharTorso
		NewSocket.Attachment0 = TorsoAttachment
		NewSocket.Attachment1 = Joint
	end
end

local function UnRagdoll(Humanoid: any)
	for _,k in pairs(Humanoid.Parent:GetDescendants()) do
		if k:IsA("Motor6D") and k.Parent.Name ~= "HumanoidRootPart" then
			k.Enabled = true
		end
	end

	Debris:AddItem(Humanoid:FindFirstChild("Ragdolled"),0)

	Humanoid.AutoRotate = true
	Humanoid.PlatformStand = false

	local HRP: Part = Humanoid.Parent:FindFirstChild("HumanoidRootPart")

	local CrossProduct = Vector3.new(0,1,0):Cross(HRP.CFrame.RightVector)
	HRP.CFrame = CFrame.new(HRP.CFrame.p,HRP.CFrame.p+CrossProduct)
end

local function Ragdoll(Humanoid: any, State: boolean, Time: number)
	if not State then
		UnRagdoll(Humanoid)
		return
	end

	if Humanoid == nil then
		return
	end

	if not Humanoid:FindFirstChild('Ragdolled') and not Humanoid:FindFirstChild('BrokenApart') and Humanoid.Parent:FindFirstChild('Torso') then

		if Humanoid:FindFirstChild("ExcuseRagdoll") then
			return
		end

		Instance.new("BoolValue", Humanoid).Name = "Ragdolled"

		Humanoid.PlatformStand = true
		Humanoid.AutoRotate = false

		local Char: any = Humanoid.Parent
		local Descendants: {any} = Char:GetDescendants()

		for _,k in pairs(Descendants) do
			if k:IsA("Motor6D") and k.Parent.Name ~= "HumanoidRootPart" then
				k.Enabled = false
			end
		end

		Char.Head.AssemblyLinearVelocity = Vector3.new(0,-50,0)

		if Time >= 2000 then
			return
		end

		wait(Time) do
			UnRagdoll(Humanoid)
		end
	end
end

local function SelfRagdoll(Player: any, state: boolean, Time: number)
	Ragdoll(Player.Character:FindFirstChild("Humanoid"), state, Time)
end

Rags.Ragdoll.Event:Connect(Ragdoll)
Rags.RagdollSelf.OnServerEvent:Connect(SelfRagdoll)

local ThingsToDestroy: {any} = {
	"Health", "Animator", "Sound", "Animate"
}

local function DeathTracker(Char: any)
	local Humanoid: Humanoid = Char:FindFirstChild("Humanoid")

	Humanoid.Died:Connect(function()
		Humanoid.DisplayName = Char.Name.."'s Corpse"

		local plr: any = Players:GetPlayerFromCharacter(Char)

		local Clone: any

		if plr ~= nil then
			Clone = Char:Clone()
			Char:Destroy()

			Humanoid = Clone:WaitForChild("Humanoid",10)

			for _,i in pairs(Clone:GetDescendants()) do
				if i:IsA("Motor6D") then
					i:Destroy()
				end
			end

			for _,k in pairs(ThingsToDestroy) do
				if Clone:FindFirstChild(k) then
					Clone[k]:Destroy()
				else
					continue
				end
			end
			
			Clone.Parent = workspace.Ragdolls
			Clone.Humanoid.PlatformStand = true
			Clone.Name = Char.Name.."'s Corpse"

			coroutine.wrap(function()
				wait(4)
				plr:LoadCharacter()
			end)

		else
			Char.Parent = workspace.Ragdolls
			Char.Humanoid.PlatformStand = true
			Char.Name = Char.Name.."'s Corpse"
		end

		Debris:AddItem(Clone or Char, 30)

		coroutine.wrap(NoiseMaker)(Char or Clone)

		coroutine.wrap(Ragdoll)(Humanoid or nil, true, math.huge)
	end)
end

local function onPlayerAdded(Player: any)
	Player.CharacterAdded:Connect(function(char)
		char.Archivable = true
		RagSetUp(char)
		DeathTracker(char)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)