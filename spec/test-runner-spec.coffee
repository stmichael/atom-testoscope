{WorkspaceView} = require 'atom'
ChildProcess = require 'child_process'
path = require 'path'

testRunner = require '../lib/test-runner'
JasmineHandler = require '../lib/handlers/jasmine-handler'

class TestJasmineHandler extends JasmineHandler

  getCommand: (testFilePath, reportPath) ->
    "../../node_modules/jasmine-node/bin/jasmine-node --junitreport --output #{reportPath} #{testFilePath}"

describe "TestRunner", ->

  trigger = (action) ->
    atom.workspaceView.getActiveView().trigger action

  runTrigger = (action) ->
    runs ->
      trigger action

  waitForTestToBeFinished = ->
    waitsFor ->
      !atom.workspaceView.find('.quick-test-result span').hasClass('icon-clock')

  waitToOpen = (file) ->
    waitsForPromise ->
      atom.workspace.open(file)

  expectStatusBarToShowRunningIcon = ->
    expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-clock')

  expectStatusBarToShowSuccessIcon = ->
    expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-check')

  expectStatusBarToShowFailureIcon = ->
    expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')

  expectStatusBarToShow = (text) ->
    expect(atom.workspaceView.find('.quick-test-result').text()).toEqual(text)

  beforeEach ->
    testRunner.handlerRegistry.addBefore new TestJasmineHandler, /_spec\.js/

    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')
    waitsForPromise ->
      promise = atom.packages.activatePackage('test-runner')
      promise

  it 'exposes a handler registry', ->
    thisPackage = require '../lib/test-runner'
    TestHandlerRegistry = require '../lib/test-handler-registry'

    expect(thisPackage.handlerRegistry instanceof TestHandlerRegistry).toBeTruthy()

  describe 'running complete test files', ->
    it 'shows that the tests are running', ->
      waitToOpen('success_spec.js')
      runs ->
        trigger 'test-runner:run-all'

        expectStatusBarToShowRunningIcon()
        expectStatusBarToShow('running')
      waitForTestToBeFinished()

    it 'shows a success message', ->
      waitToOpen('success_spec.js')
      runTrigger 'test-runner:run-all'
      waitForTestToBeFinished()
      runs ->
        expectStatusBarToShowSuccessIcon()
        expectStatusBarToShow('success_spec.js')

    it 'shows a failure message', ->
      waitToOpen('fail_spec.js')
      runTrigger 'test-runner:run-all'
      waitForTestToBeFinished()

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow('fail_spec.js:4 / Expected true to equal false.')

    it 'shows a message when no appropriate handler has been found', ->
      waitToOpen('example.b')
      runTrigger 'test-runner:run-all'

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow('Don\'t know how to run example.b')

    it 'run the specs again when another file is open', ->
      waitToOpen('success_spec.js')
      runTrigger 'test-runner:run-all'
      waitForTestToBeFinished()
      waitToOpen('example.b')
      runTrigger 'test-runner:run-all'
      waitForTestToBeFinished()

      runs ->
        expectStatusBarToShowSuccessIcon()
        expectStatusBarToShow('success_spec.js')

  describe 'stacktrace view', ->
    expectStacktraceToShow = (stacktrace) ->
      stacktraceItems = atom.workspaceView.find('.stacktrace-view li').text()
      expect(stacktraceItems).toEqual(stacktrace)

    waitForStacktraceToShow = ->
      waitsFor ->
        atom.workspaceView.find('.stacktrace-view li').length > 0

    describe 'with a failed test', ->
      beforeEach ->
        waitToOpen('fail_spec.js')
        runTrigger 'test-runner:run-all'
        waitForTestToBeFinished()

      it 'shows the stack trace of the last failed test', ->
        trigger 'test-runner:toggle-last-stack-trace'

        runs ->
          expectStacktraceToShow('fail_spec.js')

      it 'opens the file selected from the stack trace', ->
        waitToOpen('example.b')
        runTrigger 'test-runner:toggle-last-stack-trace'
        waitForStacktraceToShow()
        runs ->
          atom.workspaceView.find('.stacktrace-view').view().trigger 'core:confirm'

        waitsFor ->
          atom.workspace.getActiveTextEditor().getPath().match(/fail_spec\.js$/)

    describe 'no test has been run', ->
      it 'doesnt show the stacktrace', ->
        waitToOpen('example.b')
        runTrigger 'test-runner:toggle-last-stack-trace'

        runs ->
          expect(atom.workspaceView.find('.stacktrace-view li').length).toEqual 0

    describe 'with a passing test', ->
      beforeEach ->
        waitToOpen('success_spec.js')
        runTrigger 'test-runner:run-all'
        waitForTestToBeFinished()

      it 'doesnt show test stacktrace', ->
        trigger 'test-runner:toggle-last-stack-trace'

        runs ->
          expect(atom.workspaceView.find('.stacktrace-view li').length).toEqual 0
