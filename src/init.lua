--[[
	A custom implementation of a binder using CollectionService
	Written by Pr0pelled
	12/06/2022
]]

--[[ Types ]]
type func = (any?) -> (any?)

type module = {
    [string]: (func | any)?
}

type BinderObject = {

}

--[[ Services ]]
local CollectionService: CollectionService = game:GetService("CollectionService")

--[[ Dependencies ]]
local Cleanser = require(script:WaitForChild("Cleanser"))
local Signal = require(script:WaitForChild("Signal"))


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
	Start the BinderObject
	:::tip NOTE
	If `autostart` is `true` when creating the binder, this happens automatically.
	:::

	@within Binder
	@tag Object Methods
	@return boolean --Whether or not the process was successful
]=]
function Binder:Start(): boolean

end

--[=[
	Returns the name of the tag used by the binder

	@within Binder
	@tag Object Methods
	@return string --The name of the tag
]=]
function Binder:GetTag(): string
	return (self) and (self._tagName) or ""
end

--[=[
	Returns the constructor used to create classes for the binder

	@within Binder
	@tag Object Methods
	@return function --The constructor
]=]
function Binder:GetConstructor(): func
	return (self) and (self._constructor) or (function() end)
end

--[=[
	Returns a signal which is fired every time a class is bound

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function Binder:GetClassAddedSignal(): module
	if self and self._classAddedSignal and type(self._classAddedSignal)=="function" then
		return self._classAddedSignal
	end

	--Create it
	self._classAddedSignal = Signal.new()
	self._cleanser:Grant(self._classAddedSignal)
	return self._classAddedSignal
end

--[=[
	Returns a signal which is fired every time a class is being unbound
	:::caution
	If any functions connected to this signal yield, it will yield the removal of the class
	:::

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function Binder:GetClassRemovingSignal(): module
	if self and self._classRemovingSignal and type(self._classRemovingSignal)=="function" then
		return self._classRemovingSignal
	end

	--Create it
	self._classRemovingSignal = Signal.new()
	self._cleanser:Grant(self._classRemovingSignal)
	return self._classRemovingSignal
end

--[=[
	Returns a signal which is fired every time a class has been unbound

	@within Binder
	@tag Object Methods
	@return Signal
]=]
function Binder:GetClassRemovedSignal(): module
	if self and self._classRemovedSignal and type(self._classRemovedSignal)=="function" then
		return self._classRemovedSignal
	end

	--Create it
	self._classRemovedSignal = Signal.new()
	self._cleanser:Grant(self._classRemovedSignal)
	return self._classRemovedSignal
end

--[=[
	Returns a table containing all bound classes

	:::note
	The returned table is not the same as the internally used one, so it can be edited without worry of breaking the binder
	:::

	@within Binder
	@tag Object Methods
	@return table --A new table containing all bound classes
]=]
function Binder:GetAll(): {}
	local all = {}
	for _: Instance, class: module in self._classes do
		table.insert(all, class)
	end
	return all
end

--[=[
	Returns a table containing all bound instances

	:::note
	The returned table is not the same as the internally used one, so it can be edited without worry of breaking the binder
	:::

	@within Binder
	@tag Object Methods
	@return table --A new table containing all bound instances
]=]
function Binder:GetAllInstances(): {}
	local all = {}
	for _:number, inst: Instance in self._instances do
		table.insert(all, inst)
	end
	return all
end

--[=[
	Binds the given instance

	:::danger
	If an error is encountered, nothing is returned
	:::

	@within Binder
	@param inst Instance --The instance to be bound
	@tag Object Methods
	@return table --The bound class
]=]
function Binder:Bind(inst: Instance): module?

	--Assert type
	assert(typeof(inst)=="Instance", "Argument passed to :Bind() must be an Instance")

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
	table.insert(self._instances, inst)
	self._classes[inst] = class

	--Firing events
	if self._classAddedSignal and self._classAddedSignal.Fire then
		self._classAddedSignal:Fire(class) --Fires signal, passing class
	end
	
	--Returning class
	return class
end

--[=[
	Unbind the given instance and destroy the associated class

	:::caution
	If there is no `:Destroy()` method of the class, there may be memory leaks.
	:::

	:::caution
	If the instance is not bound, this will fail
	:::
	
	@within Binder
	@param inst Instance --The instance to be unbound
	@tag Object Methods
	@return boolean --Whether the class was successfully unbound
]=]
function Binder:Unbind(inst: Instance): boolean

	--Assert type
	assert(typeof(inst)=="Instance", "Argument passed to :Bind() must be an Instance")

	--Assuring existence
	if not self._classes[inst] then
		warn(("%q is not bound to %q!"):format(inst:GetFullName(), self._tagName))
		return false
	end
	
end

--[ Class ]

--[=[
	Constructs a new `Binder`
	
	:::tip NOTE
	If you wish to pass constructor arguments, you must also pass a value for `autostart`
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
	local self = setmetatable({}, {
		__index = BinderObject
	})

	assert(typeof(tagName)=="string", "tagName must be a string")
	assert(typeof(constructor)=="function", "Binder constructor must be a function")

	self._cleanser = Cleanser.new() --A cleanser
	self._tagName = tagName --The tagName for CollectionService

	self._constructor = constructor --The constructor function
	self._constructorArgs = {...} --The arguments passed to the constructor function

	self._instances = {} --The instances which have been successfully bound to the tag (arr; [number]: inst)
	self._classes = {} --The classes which have successfully been bound to instances (dict; [inst]: class)

	self._pending = {} --Instances which have been added, but not yet successfully bound (arr; [number]: inst)

	self._loaded = false --Whether or not the binderObject has been loaded

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
	return self
end

--[=[
	Returns whether or not the given object is a `Binder`

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