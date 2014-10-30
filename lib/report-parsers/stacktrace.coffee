module.exports =
class Stacktrace

  constructor: (stacktrace) ->
    @stacktrace = (for item in stacktrace
      item
    )

  getFullTrace: ->
    @stacktrace

  getRelevantTrace: ->
    blacklistRegex = new RegExp('node_modules')
    whitelistRegex = new RegExp(atom.project.getPaths()[0].replace(/\//g, '\\/'))
    @stacktrace.filter (line) ->
      line.file.match(whitelistRegex) && !line.file.match(blacklistRegex)

  getTestCaller: ->
    lineRegex = new RegExp(atom.project.getPaths()[0])
    for line in @getRelevantTrace().reverse()
      if line.file.match(lineRegex)
        return line
