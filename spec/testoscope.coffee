{$, WorkspaceView} = require 'atom'
ChildProcess = require 'child_process'
path = require 'path'

testRunner = require '../lib/testoscope'
JasmineHandler = require '../lib/handlers/jasmine-handler'

class TestJasmineHandler extends JasmineHandler

  _getCommand: (testFilePath, reportPath) ->
    "../../node_modules/jasmine-node/bin/jasmine-node --junitreport --output #{reportPath} #{testFilePath}"

describe "TestRunner", ->

  trigger = (action) ->
    atom.workspaceView.getActiveView().trigger action

  runTrigger = (action) ->
    runs ->
      trigger action

  waitForTestToBeFinished = ->
    waitsFor ->
      !atom.workspaceView.find('.test-result-status span').hasClass('icon-clock')

  waitToOpen = (file) ->
    waitsForPromise ->
      atom.workspace.open(file)

  expectStatusBarToShowRunningIcon = ->
    expect(atom.workspaceView.find('.test-result-status span')).toHaveClass('icon-clock')

  expectStatusBarToShowSuccessIcon = ->
    expect(atom.workspaceView.find('.test-result-status span')).toHaveClass('icon-check')

  expectStatusBarToShowFailureIcon = ->
    expect(atom.workspaceView.find('.test-result-status span')).toHaveClass('icon-stop')

  expectStatusBarToShow = (text) ->
    expect(atom.workspaceView.find('.test-result-status').text()).toEqual(text)

  beforeEach ->
    testRunner.handlerRegistry.add 'jasmine', TestJasmineHandler

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      atom.packages.activatePackage('testoscope')

  it 'exposes a handler registry', ->
    thisPackage = require '../lib/testoscope'
    TestHandlerRegistry = require '../lib/test-handler-registry'

    expect(thisPackage.handlerRegistry instanceof TestHandlerRegistry).toBeTruthy()

  describe 'results in the status bar', ->
    it 'shows that the tests are running', ->
      waitToOpen('success_spec.js')
      runs ->
        trigger 'testoscope:run-all'

        expectStatusBarToShowRunningIcon()
        expectStatusBarToShow('running')
      waitForTestToBeFinished()

    it 'shows a success message', ->
      waitToOpen('success_spec.js')
      runTrigger 'testoscope:run-all'
      waitForTestToBeFinished()
      runs ->
        expectStatusBarToShowSuccessIcon()
        expectStatusBarToShow('success_spec.js')

    it 'shows a failure message', ->
      waitToOpen('fail_spec.js')
      runTrigger 'testoscope:run-all'
      waitForTestToBeFinished()

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow('fail_spec.js:4')

    it 'shows a message when a test file cannot be executed', ->
      waitToOpen('example.b')
      runTrigger 'testoscope:run-all'
      waitForTestToBeFinished()

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow("Don't know how to run example.b")

  describe 'stacktrace view', ->
    expectStacktraceSelectionToShow = (stacktrace) ->
      stacktraceItems = atom.workspaceView.find('.stacktrace-selection li div:first-child').text()
      expect(stacktraceItems).toEqual(stacktrace)

    expectStacktraceToShow = (stacktrace) ->
      stacktraceItems = atom.workspaceView.find('.stacktrace .failure').map(->
        $(this).text()
      ).toArray()
      for line, index in stacktrace
        expect(stacktraceItems[index]).toMatch(line)

    waitForStacktraceSelectionToShow = ->
      waitsFor ->
        atom.workspaceView.find('.stacktrace-selection li').length > 0

    describe 'with a failed test', ->
      beforeEach ->
        waitToOpen('fail_spec.js')
        runTrigger 'testoscope:run-all'
        waitForTestToBeFinished()

      it 'shows the stack trace of the last failed test', ->
        trigger 'testoscope:toggle-last-stack-trace'

        runs ->
          expectStacktraceSelectionToShow('fail_spec.js:4 at null.<anonymous>')

      it 'opens the file selected from the stack trace', ->
        waitToOpen('example.b')
        runTrigger 'testoscope:toggle-last-stack-trace'
        waitForStacktraceSelectionToShow()
        runs ->
          atom.workspaceView.find('.stacktrace-selection').view().trigger 'core:confirm'

        waitsFor ->
          atom.workspace.getActiveTextEditor().getPath().match(/fail_spec\.js$/)

      it 'shows the stacktrace in a panel at bottom', ->
        expectStacktraceToShow [
          /Expected true to equal false\./,
          /fail_spec\.js/
        ]

      it 'stacktrace disappears before a new test is run', ->
        runTrigger 'testoscope:run-all'

        runs ->
          expect(atom.workspaceView.find('.stacktrace').length).toEqual 0
        waitForTestToBeFinished()

      it 'stacktrace disappears when esc is pressed', ->
        runTrigger('core:cancel')

        runs ->
          expect(atom.workspaceView.find('.stacktrace').length).toEqual 0

    describe 'no test has been run', ->
      it 'doesnt show the stacktrace', ->
        waitToOpen('example.b')
        runTrigger 'testoscope:toggle-last-stack-trace'

        runs ->
          expect(atom.workspaceView.find('.stacktrace-view li').length).toEqual 0

    describe 'with a passing test', ->
      beforeEach ->
        waitToOpen('success_spec.js')
        runTrigger 'testoscope:run-all'
        waitForTestToBeFinished()

      it 'doesnt show test stacktrace', ->
        trigger 'testoscope:toggle-last-stack-trace'

        runs ->
          expect(atom.workspaceView.find('.stacktrace-view li').length).toEqual 0