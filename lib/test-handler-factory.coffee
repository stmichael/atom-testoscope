CSON = require 'season'
minimatch = require 'minimatch'

module.exports =
class TestHandlerFactory

  constructor: (@registry) ->
    @handlers = {}

  findByPath: (testFilePath) ->
    for pathSpecification, handlerName of @handlers when testFilePath.match(pathSpecification)
      handlerClass = @registry.find(handlerName)
      if handlerClass
        return new handlerClass(@configurations[handlerName])

  readConfigurations: (path) ->
    data = CSON.readFileSync(path)
    {@handlers, @configurations} = data
