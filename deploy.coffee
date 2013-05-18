fs = require "fs"
s = require "string"
esprima = require "esprima"
esmangle = require "esmangle"
escodegen = require "escodegen"
async = require "async"

ignore = {"deploy.js"};
version = "cjucovschi-0.0.1";

prefix_core = "define(function(require) { ";
suffix_core = "});";

prefix = "define(function(require) { return function(ace) { var core = require(\"scripts/core-#{version}\"); core.setAce(ace); ";
suffix = "}});";

compressAndStore = (file, fileContent) ->
	ast = esprima.parse(fileContent)
	optimized = esmangle.optimize(ast, null);
	mangled = esmangle.mangle(optimized);  
	result = escodegen.generate(mangled, {format: {compact: true }});
	fs.writeFile("build/"+s(file).chompRight(".js")+"-"+version+".js", fileContent);

async.waterfall [
	(callback) -> fs.readdir "./", callback,
	(files, callback) -> async.filter(files, 
		(file, callback) -> callback(s(file).endsWith(".js") and not ignore[file]);
	,(result) -> callback(null, result));
	(files, callback) -> async.map files, (file, callback) ->
		async.waterfall [
			(callback) -> fs.readFile file, callback,
			(data, callback) ->
				console.log("deploying #{file}");
				if file == "core.js"
					fileContent = prefix_core + data.toString() + suffix_core;
				else
					fileContent = prefix + data.toString() + suffix
				compressAndStore(file, fileContent);
			], callback
], (err) ->
	console.log("err=", err);
