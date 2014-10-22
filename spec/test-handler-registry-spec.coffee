TestHandlerRegistry = require '../lib/test-handler-registry'

describe 'TestHandlerRegistry', ->

  registry = undefined
  handler = {}

  beforeEach ->
    registry = new TestHandlerRegistry

  it 'register a handler for a file type', ->
    registry.add handler, /\.rb$/

    expect(registry.findForFile('test.rb')).toEqual(handler)

  it 'returns null if no matching handler can be found', ->
    expect(registry.findForFile('test.js')).toEqual(null)

  it 'handler can be registered with multiple matchers', ->
    registry.add handler, [/_spec\.rb$/, /_test\.rb/]

    expect(registry.findForFile('example_spec.rb')).toEqual(handler)
    expect(registry.findForFile('example_test.rb')).toEqual(handler)

  it 'register a handler with top priority', ->
    handler2 = {}
    registry.add handler, /\.rb$/

    registry.addBefore handler2, /\.rb$/

    expect(registry.findForFile('example.rb')).toEqual(handler2)
