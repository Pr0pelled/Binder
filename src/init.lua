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
	@return boolean --Whether or not the process was successful
]=]
function Binder:Start(): boolean

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

	self._instances = {} --The instances which have been successfully bound to the tag (dict; [inst]: boolean)
	self._classes = {} --The classes which have successfully been bound to instances (dict; [inst]: class)

	self._pending = {} --Instances which have been added, but not yet successfully bound (dict; [inst]: boolean)

	self._loaded = false

	if autostart==true then
		task.spawn(self.Start, self)
	end
end

--[=[
	Returns whether or not the given object is a `Binder`

	@within Binder
	@param object any --The object being checked
	@return boolean
]=]
function Binder.is(object: any): boolean

end

--Returning Binder
return Binder