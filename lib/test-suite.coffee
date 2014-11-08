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
      path.join(atom.packages.getActivePackage('testoscope').path, 'lib', 'test-handler.cson'),
      path.join(atom.project.getPaths()[0], '.test-handler.cson')
    ]

  _runFile: (file) ->
    @lastFailures = []
    filename = atom.project.relativize(file)
    handler = @handlerFactory.findByPath(file)
    if handler
      @lastFile = file
      handler.run(file, @_testSuccessCallback, @_testErrorCallback)
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
