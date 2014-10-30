ResultStatusView = require './result-status-view'
StacktraceSelectView = require './stacktrace-select-view'
StacktraceView = require './stacktrace-view'

TestSuite = require './test-suite'
TestHandlerRegistry = require './test-handler-registry'
KarmaHandler = require './handlers/karma-handler'
JasmineHandler = require './handlers/jasmine-handler'
RspecHandler = require './handlers/rspec-handler'

handlerRegistry = new TestHandlerRegistry
# handlerRegistry.add(new KarmaHandler, /_spec\.js$/)
handlerRegistry.add(new JasmineHandler, /_spec\.js$/)
handlerRegistry.add(new RspecHandler, /_spec\.rb$/)

module.exports =
  activate: (state) ->
    createStatusEntry = ->
      @testSuite = new TestSuite(handlerRegistry)
      @resultStatusView = new ResultStatusView
      @stacktraceSelectView = new StacktraceSelectView
      @stacktraceView = new StacktraceView

      @testSuite.onDidStart =>
        @resultStatusView.setRunning()
      @testSuite.onWasSuccessful (event) =>
        @resultStatusView.setSuccessful(event.message)
      @testSuite.onWasFaulty (event) =>
        @resultStatusView.setFaulty(event.message)
        @stacktraceView.show(@testSuite.lastErrors[0])

      atom.workspaceView.statusBar.appendLeft(@resultStatusView)

      atom.workspaceView.command 'test-runner:run-all', =>
        @testSuite.run(atom.workspace.getActiveTextEditor().getPath())
      atom.workspaceView.command 'test-runner:toggle-last-stack-trace', =>
        if @testSuite.wasLastTestErroneous()
          @stacktraceSelectView.show(@testSuite.lastErrors[0].stacktrace)

    if atom.workspaceView.statusBar
      createStatusEntry()
    else
      atom.packages.once 'activated', =>
        createStatusEntry()

  deactivate: ->
    @resultStatusView.destroy() if @resultStatusView

  handlerRegistry: handlerRegistry
