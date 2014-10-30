{$$, View, SelectListView} = require 'atom'
path = require 'path'

module.exports =
class StacktraceView extends SelectListView
  initialize: ->
    super
    @addClass 'stacktrace-view overlay from-top'

  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div "#{path.basename(item.file)}:#{item.line} at #{item.caller}", class: 'primary-line'
        @div atom.project.relativize(item.file), class: 'secondary-line'

  show: (stacktrace) ->
    @setItems stacktrace
    @attach()

  confirmed: (item) ->
    atom.workspace.open(item.file)

  attach: ->
    atom.workspaceView.append(this)
    @focusFilterEditor()
