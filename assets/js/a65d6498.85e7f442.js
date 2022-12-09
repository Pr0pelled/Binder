"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[755],{28580:e=>{e.exports=JSON.parse('{"functions":[{"name":"Start","desc":"---\\nsidebar_position: 3\\n---\\n\\nStart the BinderObject\\n:::tip NOTE\\nIf `autostart` is `true` when creating the binder, this happens automatically.\\n:::","params":[],"returns":[{"desc":"Whether or not the process was successful","lua_type":"boolean"}],"function_type":"method","source":{"line":51,"path":"src/init.lua"}},{"name":"GetTag","desc":"---\\nsidebar_position: 4\\n---\\n\\nReturns the name of the tag used by the binder","params":[],"returns":[{"desc":"The name of the tag","lua_type":"string"}],"function_type":"method","source":{"line":65,"path":"src/init.lua"}},{"name":"new","desc":"---\\nsidebar_position: 1\\n---\\n\\nConstructs a new `Binder`\\n:::tip NOTE\\nIf you wish to pass constructor arguments, you must also pass a value for `autostart`\\n:::\\n\\n```LUA\\nlocal function binderConstructor(arg)\\n\\tprint(\\"MyObject has added a new Instance!\\", arg)\\n\\t\\n\\treturn {\\n\\t\\t--your class\\n\\t}\\nend\\n\\nBinder.new(\\"MyObject\\", binderConstructor, true, \\"Yay!\\")\\n```","params":[{"name":"tagName","desc":"The name of the `CollectionService` tag to be used","lua_type":"string"},{"name":"constructor","desc":"The function to run when a new instance containing the tag is created","lua_type":"function"},{"name":"autostart","desc":"Dictates whether or not to automatically start the binder. DEFAULT: true","lua_type":"boolean"},{"name":"...","desc":"Arguments to be passed to the constructor","lua_type":"any?"}],"returns":[{"desc":"","lua_type":"BinderObject"}],"function_type":"static","source":{"line":100,"path":"src/init.lua"}},{"name":"is","desc":"---\\nsidebar_position: 2\\n---\\n\\nReturns whether or not the given object is a `Binder`","params":[{"name":"object","desc":"The object being checked","lua_type":"any"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":148,"path":"src/init.lua"}}],"properties":[],"types":[],"name":"Binder","desc":"Bind classes to Roblox Instances using CollectionService","source":{"line":32,"path":"src/init.lua"}}')}}]);