CSON = require 'season'
minimatch = require 'minimatch'
fs = require 'fs'

module.exports =
class TestHandlerFactory

  constructor: (@registry) ->
    @handlers = {}

  findByPath: (testFilePath) ->
    for pathSpecification, handlerName of @handlers when testFilePath.match(pathSpecification)
      handlerClass = @registry.find(handlerName)
      if handlerClass
        return new handlerClass(@configurations[handlerName])

  readConfigurations: (paths) ->
    @handlers = {}
    @configurations = {}
    for path in paths
      if fs.existsSync(path)
        data = CSON.readFileSync(path)
        for key, value of data.handlers
          @handlers[key] = value
        for key, value of data.configurations
          @configurations[key] = value
