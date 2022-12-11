--[[
	A custom implementation of a binder using CollectionService
	Written by Pr0pelled
	12/06/2022
]]

--[[ Types ]]
type func = (any) -> (any)

type module = {
    [string]: (func | any)?
}

type BinderObject = {
	--Hidden
	["_add"]: func,
	["_classes"]: {[Instance]: module},
	["_cleanser"]: module,
	["_constructor"]: func,
	["_constructorArgs"]: {any},
	["_instances"]: {[Instance]: boolean},
	["_loaded"]: boolean,
	["_pending"]: {[Instance]: boolean},
	["_remove"]: func,
	["_tagName"]: string,

	--Public
	["Bind"]: func,
	["GetAll"]: func,
	["GetAllInstances"]: func,
	["GetClassAddedSignal"]: func,
	["GetClassRemovedSignal"]: func,
	["GetClassRemovingSignal"]: func,
	["GetConstructor"]: func,
	["GetTag"]: func,
	["Unbind"]: func
}

--[[ Services ]]
local CollectionService: CollectionService = game:GetService("CollectionService")

--[[ Dependencies ]]
local Cleanser = require(script.Parent:WaitForChild("Cleanser"))
local Signal = require(script.Parent:WaitForChild("Signal"))


--[[ Variables ]]
local BinderObject: module = {}
--[=[
	@class Binder
	Bind classes to Roblox Instances using CollectionService
]=]
local Binder: module = {}

--[[ Functions ]]

--[ Object ]

--[=[
	Start the BinderObject.

	:::tip NOTE
	If `autostart` is `true` when creating the binder, this happens automatically.
	:::

	@within Binder
	@tag Object Methods
	@return boolean --Whether or not the process was successful
]=]
function BinderObject:Start(): boolean
	if self._loaded then
		warn("BinderObject already loaded, but :Start() was called again")
		return false
	end
	self._loaded = true

	--Binding instances which already have the tag
	for _: number, inst: Instance in CollectionService:GetTagged(self._tagName) do
		task.defer(self._add, self, inst)
	end

	--Connecting to CollectonService events
	self._cleanser:Grant(CollectionService:GetInstanceAddedSignal(self._tagName):Connect(function(inst: Instance)
		self:_add(inst)
	end))

	self._cleanser:Grant(CollectionService:GetInstanceRemovedSignal(self._tagName):Connect(function(inst: Instance)
		self:_remove(inst)
	end))

	return true
end

--[=[
	Returns the name of the tag used by the binder.

	@within Binder
	@tag Object Methods
	@return string --The name of the tag
]=]
function BinderObject:GetTag(): string
	return (self) and (self._tagName) or ""
end

--[=[
	Returns the constructor used to create classes for the binder.

	@within Binder
	@tag Object Methods
	@return function --The constructor
]=]
function BinderObject:GetConstructor(): func
	return (self) and (self._constructor) or (function() end)
end

--[=[
	Returns a signal which is fired every time a class is bound.

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function BinderObject:GetClassAddedSignal(): module
	if self._classAddedSignal and type(self._classAddedSignal)=="table" then
		return self._classAddedSignal
	end

	--Create it
	self._classAddedSignal = Signal.new(("Binder_%s_AddedSignal"):format(self._tagName))
	self._cleanser:Grant(self._classAddedSignal)
	return self._classAddedSignal
end

--[=[
	Returns a signal which is fired every time a class is being unbound.

	:::caution
	If any functions connected to this signal yields, it will yield the removal of the class.
	:::

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function BinderObject:GetClassRemovingSignal(): module
	if self._classRemovingSignal and type(self._classRemovingSignal)=="table" then
		return self._classRemovingSignal
	end

	--Create it
	self._classRemovingSignal = Signal.new(("Binder_%s_RemovingSignal"):format(self._tagName))
	self._cleanser:Grant(self._classRemovingSignal)
	return self._classRemovingSignal
end

--[=[
	Returns a signal which is fired every time a class has been unbound.

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function BinderObject:GetClassRemovedSignal(): module
	if self._classRemovedSignal and type(self._classRemovedSignal)=="table" then
		return self._classRemovedSignal
	end

	--Create it
	self._classRemovedSignal = Signal.new(("Binder_%s_RemovedSignal"):format(self._tagName))
	self._cleanser:Grant(self._classRemovedSignal)
	return self._classRemovedSignal
end

--[=[
	Returns the class bound to the given instance if it exists.

	@within Binder
	@param inst Instance --The instance to be used
	@tag Object Methods
	@return table? --The bound class
]=]
function BinderObject:Get(inst: Instance): module?
	return self._classes[inst]
end

--[=[
	Returns a table containing all bound classes.

	:::tip NOTE
	The returned table is not the same as the internally used one, so it can be edited without worry of breaking the binder.
	:::

	@within Binder
	@tag Object Methods
	@return table --A new table containing all bound classes
]=]
function BinderObject:GetAll(): {}
	local all = {}
	for _: Instance, class: module in self._classes do
		table.insert(all, class)
	end
	return all
end

--[=[
	Returns a table containing all bound instances.

	:::tip NOTE
	The returned table is not the same as the internally used one, so it can be edited without worry of breaking the binder.
	:::

	@within Binder
	@tag Object Methods
	@return table --A new table containing all bound instances
]=]
function BinderObject:GetAllInstances(): {}
	local all = {}
	for _:number, inst: Instance in self._instances do
		table.insert(all, inst)
	end
	return all
end

--[=[
	Binds the given instance.

	:::danger
	If an error is encountered, nothing is returned.
	:::

	@within Binder
	@param inst Instance --The instance to be bound
	@tag Object Methods
	@return table --The bound class
]=]
function BinderObject:Bind(inst: Instance): module?
	--Assert type
	assert(typeof(inst)=="Instance", "Argument passed to :Bind() must be an Instance")

	--Adding the tag
	CollectionService:AddTag(inst, self._tagName)
	
	--Fecthing class
	local class: module? = self._classes[inst] --Can be nil if binding failed

	--Returning class
	return class
end

--[=[
	Unbind the given instance and destroy the associated class.

	:::caution
	If there is no `:Destroy()` method of the class, there may be memory leaks.

	If the instance is not bound, this will fail.
	:::
	
	@within Binder
	@param inst Instance --The instance to be unbound
	@tag Object Methods
	@return boolean --Whether the class was successfully unbound
]=]
function BinderObject:Unbind(inst: Instance): boolean
	--Assert type
	assert(typeof(inst)=="Instance", "Argument passed to :Bind() must be an Instance")

	--Fetching preliminary inst value
	local wasBound: boolean = self._instances[inst]

	--Removing the type
	CollectionService:RemoveTag(inst, self._tagName)

	--Depending on whether it was previously bound
	if wasBound then
		return not self._instances[inst] --Return the opposite of the status (If it was bound, it worked if it is now unbound)
	end
	
	--Return false
	return false --It wasn't bound before, so nothing happened (failure)
end

--[=[
	Cleans up the binder and destroys it

	:::caution
	If the bound classes do not have a `:Destroy()` method, there may be memory leaks
	:::

	@within Binder
	@tag Object Methods
	@return nil
]=]
function BinderObject:Destroy(): nil
	
end

function BinderObject:_add(inst: Instance): nil
	--Assuring it's not already being added
	if self._pending[inst] then
		warn(("%q is already being bound to %q!"):format(inst:GetFullName(), self._tagName))
	end

	--Adding to pending
	self._pending[inst] = true

	--Assuring non-existence
	if self._classes[inst] then
		warn(("%q is already bound to %q!"):format(inst:GetFullName(), self._tagName))
		return nil
	end

	--Call constructor
	local class = self._constructor(inst, self._constructorArgs)

	--Adding to the cleanser
	self._cleanser:Grant(class)

	--Storing
	self._instances[inst] = false
	self._classes[inst] = class

	--Removing from pending list
	self._pending[inst] = nil

	--Firing events
	if self._classAddedSignal and self._classAddedSignal.Fire then
		task.spawn(function()
			self._classAddedSignal:Fire(class) --Fires signal, passing class
		end)
	end

	--Returning nil
	return nil
end

function BinderObject:_remove(inst: Instance): nil
	--Fecthing class
	local class = self._classes[inst]

	--Assuring existence
	if not class then
		warn(("%q is not bound to %q!"):format(inst:GetFullName(), self._tagName))
		return nil
	end

	--Fire removing event
	if self._classRemovingSignal then
		self._classRemovingSignal:Fire(class) --Fires signal, passing class; Is not in a new thread (Yields)
	end

	--Cleaning up class
	if class.Destroy then
		class:Destroy()
	end

	--Removing the class referrence
	self._classes[inst] = nil

	--Removing the instance referrence
	self._instances[inst] = nil

	--Firing removed event
	if self._classRemovedSignal then
		task.spawn(function()
			self._classRemovedSignal:Fire(class) --Fires signal, passing class
		end)
	end

	--Returning nil
	return nil
end

--[ Class ]

--[=[
	Constructs a new `Binder`.
	
	:::tip NOTE
	If you wish to pass constructor arguments, you must also pass a value for `autostart`.
	:::

	```LUA
	local function binderConstructor(arg)
		print("MyObject has added a new Instance!", arg)
		
		return {
			--your class
		}
	end

	Binder.new("MyObject", binderConstructor, true, "Yay!")
	```

	@within Binder
	@param tagName string --The name of the `CollectionService` tag to be used
	@param constructor function --The function to run when a new instance containing the tag is created
	@param autostart boolean --Dictates whether or not to automatically start the binder. DEFAULT: true
	@param ... any? --Arguments to be passed to the constructor
	@tag Constructors
	@return BinderObject
]=]
function Binder.new(tagName: string, constructor: func, autostart: boolean?, ...: any?): BinderObject
	--Asserting types
	assert(typeof(tagName)=="string", ("tagName must be of type string. Is currently of type %s"):format(typeof(tagName)))
	assert(typeof(constructor)=="function", ("Binder constructor must be of type function. Is currently of type %s"):format(typeof(constructor)))

	local self = setmetatable({
		--Hidden
		_cleanser = Cleanser.new(); --A cleanser
		_tagName = tagName; --The tagName for CollectionService

		_constructor = constructor; --The constructor function
		_constructorArgs = {...}; --The arguments passed to the constructor function

		_instances = {}; --The instances which have been successfully bound to the tag (dict; [inst]: boolean)
		_classes = {}; --The classes which have successfully been bound to instances (dict; [inst]: class)

		_pending = {}; --Instances which have been added, but not yet successfully bound (dict; [inst]: boolean)

		_loaded = false; --Whether or not the binderObject has been loaded

		_add = nil; --Internal function for binding
		_remove = nil; --Internal function for unbinding
	}, 
	{
		__index = BinderObject
	})

	--Checking autostart
	if autostart==true then
		task.spawn(self.Start, self) --Starting the binderObject
	end

	--Assuring loaded status
	task.delay(5, function()
		if not self._loaded then
			warn(("Binder for %q has not loaded! Call :Start() on it to resolve this!"):format(self._tagName))
		end
	end)

	--Returning the binderObject
	return self :: BinderObject
end

--[=[
	Returns whether or not the given object is a `Binder`.

	@within Binder
	@param object any --The object being checked
	@tag Class Methods
	@return boolean
]=]
function Binder.is(object: any): boolean
	--Check through and assure existence of all functions
	return type(object)=="table"
		and type(object.Start)=="function"
		and type(object.GetTag)=="function"
		and type(object.GetConstructor)=="function"
		and type(object.GetClassAddedSignal)=="function"
		and type(object.GetClassRemovingSignal)=="function"
		and type(object.GetClassRemovedSignal)=="function"
		and type(object.GetAll)=="function"
		and type(object.GetAllInstances)=="function"
		and type(object.Bind)=="function"
		and type(object.Unbind)=="function"
end

--Returning Binder
return Binder