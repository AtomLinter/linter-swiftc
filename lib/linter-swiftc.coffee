linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
path = require 'path'

module.exports = class LinterSwiftc extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: ['source.swift']
  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  cmd: 'swiftc -parse'
  linterName: 'swiftc'
  errorStream: 'stderr'
  # A regex pattern used to extract information from the executable's output.
  # Beacuse swiftc is essentially a specialized clang, I am using the regex from
  #   from linter-clang.
  regex: '.+:(?<line>\\d+):.+: .*((?<error>error)|(?<warning>warning)): ' +
         '(?<message>.*)'

  constructor: (@editor) ->
    super(@editor)
    @listen =
      atom.config.observe 'linter-crystal.liveLinting', (value) =>
        @lintLive = value

  lintFile: (filePath, callback) ->
    if @lintLive
      super(filePath, callback)
    else
      super((path.basename do @editor.getPath), callback)

  destroy: ->
    @listen.dispose()
