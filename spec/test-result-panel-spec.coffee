{WorkspaceView, $} = require 'atom'
TestResultPanel = require '../lib/test-result-panel'

describe 'test result panel', ->

  view = undefined
  failure = undefined

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    view = new TestResultPanel
    failure =
      messages: ['You made', 'a mistake.']
      stacktrace: [
        {file: "#{atom.project.getPaths()[0]}/lib/file.js", line: '3', caller: 'test_method'}
        {file: "#{atom.project.getPaths()[0]}/source.js", line: '54', caller: 'start'}
      ]

  it 'add output messages', ->
    view.addOutput 'Starting Jasmine'

    expect(view.find('.shell-output').text()).toEqual 'Starting Jasmine'

  it 'splits line breaks into multiple elements', ->
    view.addOutput 'multiple\nlines'

    expect(view.find('.shell-output .line').map(-> $(this).text()).toArray())
      .toEqual ['multiple', 'lines']

  it 'add consequent output to the same line', ->
    view.addOutput 'same '
    view.addOutput 'line'

    expect(view.find('.shell-output .line:first-child').text()).toEqual 'same line'

  it 'converts ansi colors to html', ->
    view.addOutput '\x1b[30mblack'
    view.addOutput 'longer line\n\x1b[37mwhite'

    expect(view.find('.shell-output .line').map(-> $(this).html()).toArray())
      .toEqual ['<span style="color:#000">black</span>longer line',
        '<span style="color:#AAA">white</span>']

  it "escape the output before displaying", ->
    view.addOutput '#<ActiveRecord::Association []>'

    expect(view.find('.shell-output .line:last-child').text()).toEqual '#<ActiveRecord::Association []>'

  it 'shows the failure message with the stacktrace', ->
    view.showFailure failure

    expect(view.find('.last-failure .message span').map(-> $(this).text()).toArray())
      .toEqual ['You made', 'a mistake.']

    expect(view.find('.last-failure .stacktrace-line').map(-> $(this).text()).toArray())
      .toEqual [
        'lib/file.js:3 at test_method',
        'source.js:54 at start'
      ]

  it 'clears the content of the whole panel', ->
    view.addOutput 'hello'
    view.showFailure failure

    view.clear()

    expect(view.find('.last-failure *').length).toEqual 0
    expect(view.find('.shell-output *').length).toEqual 0

  describe 'enabling selection', ->
    it 'selects the first line of the stacktrace', ->
      view.showFailure failure

      view.enableSelection()

      expect(view.find('.last-failure .stacktrace-line')[0]).toHaveClass('selected')

  describe 'selection enabled', ->
    beforeEach ->
      view.showFailure failure
      view.enableSelection()

    it 'change selection downwards', ->
      view.find('.last-failure').view().trigger 'core:move-down'

      expect(view.find('.last-failure .stacktrace-line.selected').text()).toEqual 'source.js:54 at start'

    it "don't go further down than the last line", ->
      view.find('.last-failure').view().trigger 'core:move-down'
      view.find('.last-failure').view().trigger 'core:move-down'

      expect(view.find('.last-failure .stacktrace-line.selected').text()).toEqual 'source.js:54 at start'

    it 'change selection upwards', ->
      view.find('.last-failure').view().trigger 'core:move-down'
      view.find('.last-failure').view().trigger 'core:move-up'

      expect(view.find('.last-failure .stacktrace-line.selected').text()).toEqual 'lib/file.js:3 at test_method'

    it "don't go further up than the first line", ->
      view.find('.last-failure').view().trigger 'core:move-up'

      expect(view.find('.last-failure .stacktrace-line.selected').text()).toEqual 'lib/file.js:3 at test_method'

    it 'open the selected file', ->
      view.find('.last-failure').view().trigger 'core:confirm'

      waitsFor ->
        atom.workspace.getActiveTextEditor() != undefined &&
          atom.workspace.getActiveTextEditor().getPath().match /file\.js$/
      runs ->
        expect(atom.workspace.getActiveTextEditor().getCursorBufferPosition()).toEqual
          row: 2
          column: 0
