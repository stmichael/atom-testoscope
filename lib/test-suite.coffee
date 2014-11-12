{Emitter} = require 'event-kit'
path = require 'path'
TestHandlerFactory = require './test-handler-factory'

module.exports =
class TestSuite

  constructor: (@handlerFactory) ->
    @emitter = new Emitter
    @lastFailures = []

  run: (file) ->
    @emitter.emit 'did-start'
    @handlerFactory.readConfigurations(@_getConfigPaths())
    @_runFile(file)

  _getConfigPaths: ->
    [
      path.join(atom.packages.getActivePackage('testoscope').path, 'lib', 'testoscope.cson'),
      path.join(atom.project.getPaths()[0], '.testoscope.cson')
    ]

  _runFile: (file) ->
    @lastFailures = []
    filename = atom.project.relativize(file)
    handler = @handlerFactory.findByPath(file)
    if handler
      @lastFile = file
      handler.run(file)
        .then(@_testSuccessCallback)
        .catch(@_testErrorCallback)
        .progress(@_outputCallback)
    else if @lastFile
      @_runFile(@lastFile)
    else
      @emitter.emit 'was-erroneous', message: "Don't know how to run #{filename}"

  _testSuccessCallback: (result) =>
    @lastResult = result
    if result.wasSuccessful()
      @emitter.emit 'was-successful', file: @lastFile
    else
      @emitter.emit 'was-faulty'

  _testErrorCallback: (output) =>
    @emitter.emit 'was-erroneous', output: output

  _outputCallback: (output) =>
    @emitter.emit 'output', output

  wasSuccessful: ->
    !@lastResult || @lastResult.wasSuccessful()

  getLastResult: ->
    @lastResult

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback

  onWasErroneous: (callback) ->
    @emitter.on 'was-erroneous', callback

  onOutput: (callback) ->
    @emitter.on 'output', callback
