--[[
	A custom implementation of a binder using CollectionService
	Written by Pr0pelled
	12/06/2022
]]

--[[ Types ]]
type func = (any?) -> (any?)

type module = {
    [string]: func?
}

--[[ Services ]]


--[[ Dependencies ]]


--[[ Variables ]]

--[=[
	@class Binder
	A custom implementation binder using CollectionService
]=]
local Binder: module = {}

--[[ Functions ]]

--[ Helpers ]

--[ Constructors ]

--[=[
	Constructs a new `binder`

	@within Binder
	@param tagName string -- The name of the `CollectionService` tag to be used
	@param constructor function --The function to run when a new instance containing the tag is created
	@param ... any? --Arguments to be passed to the constructor
	@return binder
]=]
function Binder.new(tagName: string, constructor: func, ...: any?)

end

--[ Methods ]

--Returning Binder
return Binder