BaseHandler = require './base-handler'

module.exports =
class JasmineHandler extends BaseHandler

  getCommand: (testFilePath) ->
    "node_modules/jasmine-node/bin/jasmine-node #{testFilePath}'"
