path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
RspecReportParser = require '../report-parsers/rspec-report-parser'

module.exports =
class RspecHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @useBundler = options.useBundler

  _getCommand: (testFilePath, reportPath) ->
    if @useBundler
      "bundle exec rspec --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"
    else
      "rspec --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"

  parseErrors: (callback) ->
    file = path.join(@getReportPath(), 'rspec.json')
    fs.readFile file, encoding: 'UTF-8', (err, data) =>
      errors = new RspecReportParser().parse(data)
      callback(errors)
