{View, $$} = require 'atom'

module.exports =
class StacktraceView extends View
  @content: ->
    @div class: 'stacktrace tool-panel panel-bottom padded status-erroneous'

  show: (error) ->
    @empty()
    @append $$ ->
      @div error.message, class: 'block failure'
    for item in error.stacktrace
      relativeFile = atom.project.relativize(item.file)
      @append $$ ->
        @div "#{relativeFile}:#{item.line} at #{item.caller}", class: 'block failure'

    atom.workspaceView.prependToBottom(this);
