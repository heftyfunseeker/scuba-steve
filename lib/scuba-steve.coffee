{CompositeDisposable} = require 'atom'
{Task} = require 'atom'
path = require 'path'
fs = require 'fs-plus'

module.exports = ScubaSteve =
	subscriptions: null
	pathCache : null

	activate: (state) ->
		@active = true
		# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
		@subscriptions = new CompositeDisposable

		# Register command that toggles this view
		@subscriptions.add atom.commands.add 'atom-workspace', 'scuba-steve:toggle': => @toggle()
		@subscriptions.add atom.commands.add 'atom-workspace', 'scuba-steve:start-dive': => @startDive()

	deactivate: ->
		@subscriptions.dispose()
		stopDive()
		@active = false

	consumeSignal: (registry) ->
		@busySignal = registry.create()
		@subscriptions.add(@busySignal)


	startDive: ->
		return if !@active

		@stopDive()

		projectPaths = atom.project.getPaths()
		return if projectPaths.length == 0

		editor = atom.workspace.getActiveTextEditor()
		return unless editor

		taskPath = require.resolve('./load-base-cache')

		@busySignal.add('Scuba Steve') unless !@busySignal

		@startDiveTask = Task.once taskPath, projectPaths, ->
			console.log 'scuba-steve finished dive'

		@startDiveTask.on 'path-cache-loaded', (data) =>
			@pathCache = data.pathCache
			@busySignal.clear() unless !@busySignal

	stopDive: ->
		@pathCache = null
		@startDiveTask?.terminate()
		@startDiveTask = null

	toggle: ->
		return if !@active

		return unless @pathCache

		editor = atom.workspace.getActiveTextEditor()
		return unless editor

		filepath = editor.getPath()
		base = path.basename(filepath, path.extname(filepath))

		cache = @pathCache[base]
		return unless cache

		nextPathIndex = (cache.indexOf(filepath) + 1) % cache.length

		while (cache.length)
			stevesNextFile = cache[nextPathIndex]

			if fs.isFileSync(stevesNextFile)
				atom.workspace.open(stevesNextFile)
				return

			cache.splice(nextPathIndex, 1)

			nextPathIndex = (nextPathIndex + 1) % cache.length
