local signal = script.Parent.Parent.Parent:FindFirstChild("Signal")
assert(signal:IsA("ModuleScript"), "Could not find Signal. Binder requires that Signal be installed.")
return require(signal)