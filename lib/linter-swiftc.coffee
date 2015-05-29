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
      lintOnFly: true
    }

  lint: (TextEditor) ->
    CP = require 'child_process'
    Path = require 'path'
    XRegExp = require('xregexp').XRegExp

    regex = XRegExp('(?<file>\\S+):(?<line>\\d+):(?<column>\\d+):
     ((?<error>error)|(?<warning>warning)): (?<message>.*)')

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
            if regex.error
              ToReturn.push(
                Type: 'Error',
                Message: regex.message,
                File: regex.file
              )
            if regex.warning
              ToReturn.push(
                Type: 'Warning',
                Message: regex.message,
                File: regex.file
              )
        Resolve(ToReturn)
