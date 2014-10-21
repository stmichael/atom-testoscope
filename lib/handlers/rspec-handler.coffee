BaseHandler = require './base-handler'

module.exports =
class RspecHandler extends BaseHandler

  getCommand: (testFilePath) ->
    "rspec #{testFilePath}"
