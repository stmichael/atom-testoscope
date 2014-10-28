QuickResultView = require './quick-result-view'
StacktraceView = require './stacktrace-view'

TestSuite = require './test-suite'
TestHandlerRegistry = require './test-handler-registry'
KarmaHandler = require './handlers/karma-handler'
JasmineHandler = require './handlers/jasmine-handler'
RspecHandler = require './handlers/rspec-handler'

handlerRegistry = new TestHandlerRegistry
handlerRegistry.add(new KarmaHandler, /_spec\.js$/)
handlerRegistry.add(new JasmineHandler, /_spec\.js$/)
handlerRegistry.add(new RspecHandler, /_spec\.rb$/)

module.exports =
  activate: (state) ->
    createStatusEntry = ->
      @testSuite = new TestSuite(handlerRegistry)
      @quickResultView = new QuickResultView
      @stacktraceView = new StacktraceView

      @testSuite.onDidStart =>
        @quickResultView.setRunning()
      @testSuite.onWasSuccessful (event) =>
        @quickResultView.setSuccessful(event.message)
      @testSuite.onWasFaulty (event) =>
        @quickResultView.setFaulty(event.message)

      atom.workspaceView.statusBar.appendLeft(@quickResultView)

      atom.workspaceView.command 'test-runner:run-all', =>
        @testSuite.run(atom.workspace.getActiveTextEditor().getPath())
      atom.workspaceView.command 'test-runner:toggle-last-stack-trace', =>
        if @testSuite.wasLastTestErroneous()
          @stacktraceView.show(@testSuite.lastErrors[0].stacktrace)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', =>
        createStatusEntry()

  deactivate: ->
    @quickResultView.destroy() if @quickResultView

  handlerRegistry: handlerRegistry
