{WorkspaceView, $} = require 'atom'
StacktraceView = require '../lib/stacktrace-view'

describe 'stacktrace view', ->

  view = undefined
  failure = undefined

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    view = new StacktraceView
    failure =
      messages: ['You made', 'a mistake.']
      stacktrace: [
        {file: "#{atom.project.getPaths()[0]}/lib/file.js", line: '3', caller: 'test_method'}
        {file: "#{atom.project.getPaths()[0]}/source.js", line: '54', caller: 'start'}
      ]

  it 'shows the failure message with the stacktrace', ->
    view.show failure

    expect(view.find('.failure.message span').map(-> $(this).text()).toArray())
      .toEqual ['You made', 'a mistake.']

    expect(view.find('.failure.stacktrace-line').map(-> $(this).text()).toArray())
      .toEqual [
        'lib/file.js:3 at test_method',
        'source.js:54 at start'
      ]
