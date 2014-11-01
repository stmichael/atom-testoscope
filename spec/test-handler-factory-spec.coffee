TestHandlerFactory = require '../lib/test-handler-factory'
TestHandlerRegistry = require '../lib/test-handler-registry'

describe 'TestHandlerFactory', ->

  jasmineHandler = ->
  rspecHandler = (@options) ->
  rspecHandler.prototype.receivedOptions = ->
    @options
  registry = undefined
  factory = undefined

  beforeEach ->
    registry = new TestHandlerRegistry
    factory = new TestHandlerFactory(registry)
    waitsForPromise ->
      atom.packages.activatePackage('test-runner')

  it 'finds a handler for a test file', ->
    registry.add 'jasmine', jasmineHandler
    factory.readConfigurations()

    expect(factory.findByPath('example_spec.js') instanceof jasmineHandler)
      .toBeTruthy()

  it 'the handler receives the options from the config', ->
    registry.add 'rspec', rspecHandler
    factory.readConfigurations()

    handler = factory.findByPath('example_spec.rb')
    expect(handler.receivedOptions()).toEqual(useBundler: false)

  it 'returns nothing if a handler is configured but not registered', ->
    factory.readConfigurations()

    expect(factory.findByPath('example_spec.js')).toBeUndefined()
