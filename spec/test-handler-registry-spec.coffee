TestHandlerRegistry = require '../lib/test-handler-registry'
JasmineHandler = require '../lib/handlers/jasmine-handler'

describe 'TestHandlerRegistry', ->

  registry = undefined
  handler = {}

  beforeEach ->
    registry = new TestHandlerRegistry

  it 'register a handler', ->
    handler = {}
    registry.add 'jasmine', handler

    expect(registry.find('jasmine')).toEqual(handler)

  it 'check if a handler is registered', ->
    expect(registry.has('jasmine')).toBeFalsy()

    registry.add 'jasmine', {}
    expect(registry.has('jasmine')).toBeTruthy()
