local cleanser = script.Parent.Parent.Parent:FindFirstChild("Cleanser")
assert(cleanser:IsA("ModuleScript"), "Could not find Cleanser. Binder requires that Cleanser be installed.")
return require(cleanser)