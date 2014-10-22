{WorkspaceView} = require 'atom'
ChildProcess = require 'child_process'
path = require 'path'

testRunner = require '../lib/test-runner'
JasmineHandler = require '../lib/handlers/jasmine-handler'

class TestJasmineHandler extends JasmineHandler

  getCommand: (testFilePath, reportPath) ->
    "../../node_modules/jasmine-node/bin/jasmine-node --junitreport --output #{reportPath} #{testFilePath}"

describe "TestRunner", ->

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
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-clock')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('running')
      waitsFor ->
        !atom.workspaceView.find('.quick-test-result span').hasClass('icon-clock')

    it 'shows a success message', ->
      waitsForPromise ->
        atom.workspace.open('success_spec.js')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
      waitsFor ->
        !atom.workspaceView.find('.quick-test-result span').hasClass('icon-clock')

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-check')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('All tests in success_spec.js have been successful')

    it 'shows a failure message', ->
      waitsForPromise ->
        atom.workspace.open('fail_spec.js')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'
      waitsFor ->
        !atom.workspaceView.find('.quick-test-result span').hasClass('icon-clock')

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('fail_spec.js:4 # jasmine test suite a failing test')

    it 'shows a message when no appropriate handler has been found', ->
      waitsForPromise ->
        atom.workspace.open('example.b')
      runs ->
        atom.workspaceView.getActiveView().trigger 'test-runner:run-all'

      runs ->
        expect(atom.workspaceView.find('.quick-test-result span')).toHaveClass('icon-stop')
        expect(atom.workspaceView.find('.quick-test-result').text()).toEqual('Don\'t know how to run example.b')
