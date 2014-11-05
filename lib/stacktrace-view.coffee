{View, $$} = require 'atom'

module.exports =
class StacktraceView extends View
  @content: ->
    @div class: 'stacktrace tool-panel panel-bottom padded'

  show: (failure) ->
    @empty()
    @append $$ ->
      @div class: 'block failure message', =>
        for message in failure.messages
          @span message
          @tag 'br'
    for item in failure.stacktrace
      relativeFile = atom.project.relativize(item.file)
      @append $$ ->
        @div "#{relativeFile}:#{item.line} at #{item.caller}", class: 'block failure stacktrace'

    atom.workspace.addBottomPanel(item: this);
