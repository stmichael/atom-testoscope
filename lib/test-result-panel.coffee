{View, $$} = require 'atom'

module.exports =
class TestResultPanel extends View
  @content: ->
    @div class: 'output-panel split-panel tool-panel panel-bottom padded', =>
      @div class: 'last-failure panel-segment'
      @div class: 'shell-output panel-segment'

  attach: ->
    atom.workspace.addBottomPanel(item: this);

  showFailure: (failure) ->
    @find('.last-failure').empty()
    @find('.last-failure').append $$ ->
      @div class: 'block status-failure message', =>
        for message in failure.messages
          @span message
          @tag 'br'
    for item in failure.stacktrace
      relativeFile = atom.project.relativize(item.file)
      @find('.last-failure').append $$ ->
        @div "#{relativeFile}:#{item.line} at #{item.caller}", class: 'block failure stacktrace-line'

    @attach()

  addOutput: (text) ->
    lines = text.split(/\n/)
    firstLine = lines.shift()
    lastElement = @find('.shell-output .line:last-child')
    if lastElement.length == 0
      @find('.shell-output').append $$ ->
        @div class: 'line'
      lastElement = @find('.shell-output .line:last-child')
    lastElement.text(lastElement.text() + firstLine)

    @find('.shell-output').append $$ ->
      for line in lines
        @div class: 'line', line

  clear: ->
    @find('.last-failure').empty()
    @find('.shell-output').empty()
