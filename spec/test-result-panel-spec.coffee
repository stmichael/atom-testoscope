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
