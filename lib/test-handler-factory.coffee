CSON = require 'season'
path = require 'path'
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

  readConfigurations: ->
    configPath = path.join(atom.packages.getActivePackage('test-runner').path, 'lib', 'test-handler.cson')
    data = CSON.readFileSync(configPath)
    {@handlers, @configurations} = data
