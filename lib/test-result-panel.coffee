{View, $, $$} = require 'atom'
Convert = require 'ansi-to-html'

class StacktraceView extends View
  @content: ->
    @div class: 'last-failure panel-segment'

  constructor: ->
    super
    @on 'core:move-down', =>
      @selectNext()
    @on 'core:move-up', =>
      @selectPrevious()
    @on 'core:confirm', =>
      @openSelection()

  clear: ->
    @empty()

  showFailure: (failure) ->
    @empty()
    @append $$ ->
      @div class: 'block status-failure message', =>
        for message in failure.messages
          @span message
          @tag 'br'
    @stacktrace = failure.stacktrace
    @append $$ ->
      @div class: 'stacktrace', =>
        for item in failure.stacktrace
          relativeFile = atom.project.relativize(item.file)
          @div "#{relativeFile}:#{item.line} at #{item.caller}", class: 'block status-failure stacktrace-line', tabindex: '1'

  enableSelection: ->
    @selectedIndex = 0
    $(@find('.stacktrace-line')[0]).focus()
    @_updateSelection()

  selectNext: ->
    if @selectedIndex + 1 < @stacktrace.length
      @selectedIndex += 1
      @_updateSelection()

  selectPrevious: ->
    if @selectedIndex > 0
      @selectedIndex -= 1
      @_updateSelection()

  _updateSelection: ->
    @find('.stacktrace-line.selected').removeClass('selected')
    $(@find('.stacktrace-line')[@selectedIndex]).addClass('selected')

  openSelection: ->
    item = @stacktrace[@selectedIndex]
    atom.workspace.open(item.file).then ->
      atom.workspace.getActiveTextEditor().setCursorBufferPosition([parseInt(item.line) - 1, 0])

class ShellOutputView extends View
  @content: ->
    @div class: 'shell-output panel-segment'

  clear: ->
    @empty()

  addOutput: (text) ->
    convert = new Convert
    lines = text.split(/\n/)
    firstLine = lines.shift()
    @_addTextToCurrentLine(firstLine)
    @_addTextsToNewLines(lines)

  _addTextToCurrentLine: (text) ->
    lastElement = @find('.line:last-child')
    if lastElement.length == 0
      @append $$ ->
        @div class: 'line'
      lastElement = @find('.line:last-child')
    escaped_text = $('<div/>').text(text).html()
    lastElement.append new Convert().toHtml(escaped_text)

  _addTextsToNewLines: (texts) ->
    @append $$ ->
      for line in texts
        @div class: 'line', =>
          escaped_line = $('<div/>').text(line).html()
          @raw new Convert().toHtml(escaped_line)


module.exports =
class TestResultPanel extends View
  @content: ->
    @div class: 'output-panel split-panel tool-panel panel-bottom padded', =>
      @subview 'stacktraceView', new StacktraceView()
      @subview 'shellOutputView', new ShellOutputView()

  attach: ->
    atom.workspace.addBottomPanel(item: this);

  showFailure: (failure) ->
    @stacktraceView.showFailure(failure)
    @attach()

  enableSelection: ->
    @stacktraceView.enableSelection()

  addOutput: (text) ->
    @shellOutputView.addOutput(text)

  clear: ->
    @stacktraceView.clear()
    @shellOutputView.clear()
