--!strict

--[[Services]]--------------------------
local Debris: Debris = game:GetService("Debris")
local RS: RunService = game:GetService("RunService")
local CS: CollectionService = game:GetService("CollectionService")

--[[Variables]]-------------------------
local Debug: boolean = false
----------------------------------------

local function Debugger(Scale: Vector3, Position: Vector3, Type: string): Part
	local DebugPart: Part = Instance.new("Part") do
		DebugPart.Shape = Enum.PartType[Type]
		DebugPart.Size = Scale
		DebugPart.Color = Color3.fromRGB(50,200,50)
		DebugPart.Transparency = .6
		DebugPart.Anchored = true
		DebugPart.Material = Enum.Material.Neon
		DebugPart.CanCollide = false
		DebugPart.Position = Position
		DebugPart.Parent = workspace
	end Debris:AddItem(DebugPart,.3)
	return DebugPart
end

local function RayDebugger(Scale: number, Position1: Vector3, Position2: Vector3): Part
	local DebugPart: Part = Instance.new("Part") do
		DebugPart.Size = Vector3.new(.4,.4,Scale)
		DebugPart.Color = Color3.fromRGB(50,200,50)
		DebugPart.Transparency = .6
		DebugPart.Anchored = true
		DebugPart.Material = Enum.Material.Neon
		DebugPart.CanCollide = false
		DebugPart.Parent = workspace
	end Debris:AddItem(DebugPart,.3)

	local Diff: Vector3 = (Position1 - Position2)

	DebugPart.CFrame = CFrame.new(Position2 + .5*Diff, Position1)

	return DebugPart
end

local function yield(n: number)
	n = n or 0
	local Delta: number = 0
	repeat
		Delta += RS.Heartbeat:Wait()
	until Delta > n
end


local HitMethods = {}

function HitMethods:StartDebugger()
	Debug = true
end

function HitMethods:StopDebugger()
	Debug = false
end

function HitMethods.Fuzzy(Part1: Part, Part2: Part, Epsilon: number): boolean
	local InRange: boolean = Vector3.new(0, 0, 0):FuzzyEq(Part2.Position - Part1.Position, Epsilon)

	if Debug then
		local Scale: number = (Epsilon+Epsilon)
		Debugger(Vector3.new(1,1,1)*Scale,Part1.Position,"Block")
	end

	return InRange
end

function HitMethods.MagCast(Position: Vector3, Position2: Vector3, DesiredRadius: number): (number | boolean)

	local MagDistance: number = (Position - Position2).Magnitude

	if Debug then
		Debugger(Vector3.new(1,1,1)*(DesiredRadius*2),Position,'Ball')
	end

	if MagDistance < DesiredRadius then
		return MagDistance
	else
		return false
	end 
end

function HitMethods.RayCast(Origin: Vector3, Exit: Vector3, RayInfo: RaycastParams): (RaycastResult | Vector3)
	local Raycheck: any = workspace:Raycast(Origin,Exit,RayInfo)

	if Debug then
		if Raycheck ~= nil then
			local Scale: number = (Origin - Raycheck.Position).Magnitude

			RayDebugger(Scale,Origin,Raycheck.Position)
		else
			local Scale: number = (Origin - Exit).Magnitude

			RayDebugger(Scale,Origin,Exit)
		end

	end


	if Raycheck ~= nil then
		return Raycheck
	else
		return Exit
	end
end

function HitMethods.TouchingParts(Main: Part): {}
	local Touched = Main.Touched:Connect(function()end)
	local TouchingParts = Main:GetTouchingParts()
	
	local Humanoids: {} = {}
	
	if Debug then
		Debugger(Main.Size,Main.Position,"Block")
	end
	
	for Index,Part in pairs(TouchingParts) do
		if CS:HasTag(Part.Parent, "Character") then
			table.insert(Humanoids,Index,Part.Parent)
		end
	end Touched:Disconnect()
	
	return Humanoids
end


return HitMethods