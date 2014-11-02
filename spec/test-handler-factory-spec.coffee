path = require 'path'

TestHandlerFactory = require '../lib/test-handler-factory'
TestHandlerRegistry = require '../lib/test-handler-registry'

describe 'TestHandlerFactory', ->

  jasmineHandler = ->
  rspecHandler = (@options) ->
  rspecHandler.prototype.receivedOptions = ->
    @options
  registry = undefined
  factory = undefined
  defaultConfig = undefined

  beforeEach ->
    registry = new TestHandlerRegistry
    factory = new TestHandlerFactory(registry)
    defaultConfig = path.join(atom.project.getPaths()[0], 'configs', 'default.cson')

  it 'finds a handler for a test file', ->
    registry.add 'jasmine', jasmineHandler
    factory.readConfigurations(defaultConfig)

    expect(factory.findByPath('example_spec.js') instanceof jasmineHandler)
      .toBeTruthy()

  it 'the handler receives the options from the config', ->
    registry.add 'rspec', rspecHandler
    factory.readConfigurations(defaultConfig)

    handler = factory.findByPath('example_spec.rb')
    expect(handler.receivedOptions()).toEqual(useBundler: false)

  it 'returns nothing if a handler is configured but not registered', ->
    factory.readConfigurations(defaultConfig)

    expect(factory.findByPath('example_spec.js')).toBeUndefined()
