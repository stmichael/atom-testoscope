QuickResultView = require './quick-result-view'
{Emitter} = require 'event-kit'
{relative} = require 'path'
TestHandlerRegistry = require './test-handler-registry'
JasmineHandler = require('./handlers/jasmine-handler')
RspecHandler = require('./handlers/rspec-handler')

handlerRegistry = new TestHandlerRegistry
handlerRegistry.add(new JasmineHandler, /_spec\.js$/)
handlerRegistry.add(new RspecHandler, /_spec\.rb$/)

class TestSuite

  constructor: (@handlerRegistry) ->
    @emitter = new Emitter

  run: (testPath) ->
    @emitter.emit 'did-start'
    relativeTestPath = relative(atom.project.getPaths()[0], testPath)
    handler = @handlerRegistry.findForFile(testPath)
    if handler
      handler.run(testPath
        , =>
          @emitter.emit 'was-successful', message: "All tests in #{relativeTestPath} have been successful"
        , (errors) =>
          # @emitter.emit 'was-faulty', message: "The tests in #{relativeTestPath} were faulty"
          @emitter.emit 'was-faulty', message: "#{errors[0].file}:#{errors[0].line} # #{errors[0].namespace} #{errors[0].name}"
        )
    else
      @emitter.emit 'was-faulty', message: "Don't know how to run #{relativeTestPath}"

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback

module.exports =
  activate: (state) ->
    createStatusEntry = ->
      @testSuite = new TestSuite(handlerRegistry)
      @quickResultView = new QuickResultView()
      @testSuite.onDidStart =>
        @quickResultView.setRunning()
      @testSuite.onWasSuccessful (event) =>
        @quickResultView.setSuccessful(event.message)
      @testSuite.onWasFaulty (event) =>
        @quickResultView.setFaulty(event.message)

      atom.workspaceView.statusBar.appendLeft(@quickResultView)

      atom.workspaceView.command 'test-runner:run-all', =>
        @testSuite.run(atom.workspace.getActiveTextEditor().getPath())

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', =>
        createStatusEntry()

  deactivate: ->
    @quickResultView.destroy() if @quickResultView

  handlerRegistry: handlerRegistry
