---
sidebar_position: 1
---
# Getting Started

Bind classes to Roblox Instances using <a href="https://create.roblox.com/docs/reference/engine/classes/CollectionService" target="_blank" title="Documentation">CollectionService</a>

This module is heavily inspired by <a href="https://quenty.github.io/NevermoreEngine/api/Binder/" target="_blank" title="Documentation">Binder</a> by <a href="https://www.roblox.com/users/4397833" target="_blank" title="View Profile">Quenty</a>. There are many similarities in function between this module and his. There are many identical methods, as well as identical functionality. The underlying code, however, is quite different so as to take advantage of <a href="https://www.roblox.com/users/289025524" target="_blank" title="View Profile">R0BL0XIAN_D3M0's</a> library of modules and <a href="https://quenty.github.io/NevermoreEngine/" target="_blank" title="Documentation">Nevermore</a> ports.

With this module, binding a class to an instance is as easy as calling a method!
```lua
--Create a class
local myClass = {}
myClass.__index = myClass

function myClass.new(inst: Instance)
	print(("A new class was created for %q"):format(inst:GetFullName()))

	local self = {}
	self.Name = "Test"
	return self
end

function myClass:Destroy()
	print(("Class %q has been destroyed!"):format(self.Name))
	self.Name = nil
end

--Implement a Binder
local myBinder = Binder.new("myTag", myClass.new)
myBinder:Start()
```

Written by <a href="https://www.roblox.com/users/112576463" target="_blank" title="View Profile">Pr0pelled</a>