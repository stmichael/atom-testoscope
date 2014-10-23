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

  waitForTestToBeFinished = ->
    waitsFor ->
      !atom.workspaceView.find('.quick-test-result span').hasClass('icon-clock')

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
      waitsForPromise ->
        atom.workspace.open('success_spec.js')
      runs ->
        trigger 'test-runner:run-all'

        expectStatusBarToShowRunningIcon()
        expectStatusBarToShow('running')
      waitForTestToBeFinished()

    it 'shows a success message', ->
      waitsForPromise ->
        atom.workspace.open('success_spec.js')
      runs ->
        trigger 'test-runner:run-all'
      waitForTestToBeFinished()
      runs ->
        expectStatusBarToShowSuccessIcon()
        expectStatusBarToShow('All tests in success_spec.js have been successful')

    it 'shows a failure message', ->
      waitsForPromise ->
        atom.workspace.open('fail_spec.js')
      runs ->
        trigger 'test-runner:run-all'
      waitForTestToBeFinished()

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow('fail_spec.js:4 # jasmine test suite a failing test')

    it 'shows a message when no appropriate handler has been found', ->
      waitsForPromise ->
        atom.workspace.open('example.b')
      runs ->
        trigger 'test-runner:run-all'

      runs ->
        expectStatusBarToShowFailureIcon()
        expectStatusBarToShow('Don\'t know how to run example.b')
