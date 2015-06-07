module.exports = LinterSwiftc =
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  scopes: ['source.swift']

  activate: ->
    console.log 'activate linter-swiftc'# if atom.inDevMode()
    unless atom.packages.getLoadedPackages 'linter-plus'
      @showError '[Linter+ swiftc] `linter-plus` package not found,
       please install it'

  showError: (message = '') ->
    atom.notifications.addError message

  provideLinter: ->
    {
      scopes: @scopes
      lint: @lint
      lintOnFly: false
    }

  lint: (TextEditor) ->
    CP = require 'child_process'
    Path = require 'path'
    XRegExp = require('xregexp').XRegExp

    regex = XRegExp('(?<file>\\S+):(?<line>\\d+):(?<column>\\d+): (?<type>\\w+): (?<message>.*)')

    return new Promise (Resolve) ->
      FilePath = TextEditor.getPath()
      return unless FilePath # Files that have not be saved
      Data = []
      Process = CP.exec("swiftc -parse #{TextEditor.getTitle()}",
        {cwd: Path.dirname(FilePath)})
      Process.stderr.on 'data', (data) -> Data.push(data.toString())
      Process.on 'close', ->
        Content = []
        for line in Data
          Content.push XRegExp.exec(line, regex)
        ToReturn = []
        Content.forEach (regex) ->
          if regex
            ToReturn.push(
              type: regex.type,
              message: regex.message,
              file: FilePath
              position: [[regex.line, regex.column], [regex.line, regex.column]]
            )
        Resolve(ToReturn)
