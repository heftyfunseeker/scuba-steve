fs = require 'fs-plus'
path = require 'path'

module.exports = (projectPaths) ->
	# Indicates that this task will be async.
	# Call the `callback` to finish the task
	callback = @async()

	pathCache = new Object()
	for projectPath in projectPaths
		for filepath in fs.listTreeSync(projectPath)
			if fs.isDirectorySync(filepath) then continue

			base = path.basename(filepath, path.extname(filepath))

			if !(pathCache[base]) then pathCache[base] = new Array()

			pathCache[base].push(filepath)

	emit('path-cache-loaded', {pathCache: pathCache})

	callback()
