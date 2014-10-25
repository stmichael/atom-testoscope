{View, SelectListView} = require 'atom'

module.exports =
class StacktraceView extends SelectListView
  initialize: ->
    super
    @addClass 'stacktrace-view overlay from-top'

  viewForItem: (item) ->
    "<li>#{item}</li>"

  show: (stacktrace) ->
    @setItems @_extractFilePaths(stacktrace)
    @attach()

  _extractFilePaths: (stacktrace) ->
    for line in stacktrace
      lineMatch = line.match(/((\/[\w\d\.\-_]+)+)/)
      if lineMatch
        atom.project.relativize(lineMatch[1])

  confirmed: (item) ->
    atom.workspace.open(item)

  attach: ->
    atom.workspaceView.append(this)
    @focusFilterEditor()
