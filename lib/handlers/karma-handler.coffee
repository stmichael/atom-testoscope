path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
JunitReportParser = require '../report-parsers/junit-report-parser'

module.exports =
class KarmaHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @configFile = options.config

  _getCommand: (testFilePath) ->
    "node_modules/karma/bin/karma start #{@configFile} --single-run --reporters junit && cp test-results.xml #{@getReportPath()}"

  parseErrors: (callback) ->
    file = path.join(@getReportPath(), 'test-results.xml')
    fs.readFile file, encoding: 'UTF-8', (err, data) =>
      errors = new JunitReportParser().parse(data)
      fs.unlinkSync(file)
      callback(errors)
