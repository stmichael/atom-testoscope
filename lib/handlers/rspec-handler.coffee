path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
RspecReportParser = require '../report-parsers/rspec-report-parser'

module.exports =
class RspecHandler extends BaseHandler

  getCommand: (testFilePath, reportPath) ->
    "rspec --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"

  parseErrors: (callback) ->
    file = path.join(@getReportPath(), 'rspec.json')
    fs.readFile file, encoding: 'UTF-8', (err, data) =>
      errors = new RspecReportParser(atom.project.getPaths()[0]).parse(data)
      callback(errors)
