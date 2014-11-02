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
      path.join(atom.packages.getActivePackage('test-runner').path, 'lib', 'test-handler.cson'),
      path.join(atom.project.getPaths()[0], '.test-handler.cson')
    ]

  _runFile: (file) ->
    @lastFailures = []
    filename = atom.project.relativize(file)
    handler = @handlerFactory.findByPath(file)
    if handler
      @lastFile = file
      handler.run(file, (=> @_testSuccessCallback(filename)), @_testFailureCallback)
    else if @lastFile
      @_runFile(@lastFile)
    else
      @emitter.emit 'was-erroneous', message: "Don't know how to run #{filename}"

  _testSuccessCallback: (filename) =>
    @emitter.emit 'was-successful', file: filename

  _testFailureCallback: (failures) =>
    @lastFailures = failures
    @emitter.emit 'was-faulty'

  wasLastTestFailure: ->
    @lastFailures.length > 0

  onDidStart: (callback) ->
    @emitter.on 'did-start', callback

  onWasSuccessful: (callback) ->
    @emitter.on 'was-successful', callback

  onWasFaulty: (callback) ->
    @emitter.on 'was-faulty', callback

  onWasErroneous: (callback) ->
    @emitter.on 'was-erroneous', callback
