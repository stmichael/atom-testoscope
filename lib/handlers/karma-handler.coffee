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

  getCommand: (testFilePath, reportPath) ->
    "node_modules/karma/bin/karma start #{@configFile} --single-run --reporters junit"

  parseErrors: (callback) ->
    file = path.join(atom.project.getPaths()[0], 'test-results.xml')
    fs.readFile file, encoding: 'UTF-8', (err, data) =>
      errors = new JunitReportParser().parse(data)
      callback(errors)
