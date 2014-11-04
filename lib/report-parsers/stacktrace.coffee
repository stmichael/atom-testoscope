module.exports =
class Stacktrace

  constructor: (@stacktrace) ->
    @projectPath = atom.project.getPaths()[0]

  getFullTrace: ->
    @stacktrace

  getRelevantTrace: ->
    blacklistRegex = new RegExp('node_modules')
    whitelistRegex = new RegExp(@projectPath.replace(/\//g, '\\/'))
    @stacktrace.filter (line) ->
      line.file.match(whitelistRegex) && !line.file.match(blacklistRegex)

  getTestCaller: ->
    lineRegex = new RegExp(@projectPath)
    for line in @getRelevantTrace().reverse()
      if line.file.match(lineRegex)
        return line
