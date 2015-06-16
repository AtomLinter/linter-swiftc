module.exports = LinterSwiftc =
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  scopes: ['source.swift']

  activate: ->
    console.log 'activate linter-swiftc'# if atom.inDevMode()
    unless atom.packages.getLoadedPackages 'linter-plus'
      @showError '[linter-swiftc] `linter-plus` package not found, please install it'

  showError: (message = '') ->
    atom.notifications.addError message

  provideLinter: -> {
    grammarScopes: @scopes
    scope: 'file'
    lint: @lint
    lintOnFly: false
  }

  lint: (TextEditor) ->
    CP = require 'child_process'
    path = require 'path'
    XRegExp = require('xregexp').XRegExp

    regex = XRegExp('(?<file>\\S+):(?<line>\\d+):(?<column>\\d+):\\s+(?<type>\\w+):\\s+(?<message>.*)')

    return new Promise (Resolve) ->
      filePath = TextEditor.getPath()
      file = TextEditor.getTitle()
      cwd = path.dirname(TextEditor.getPath())
      return unless filePath # Files that have not be saved
      Data = []
      Process = CP.exec("swiftc -parse #{file}", {cwd: cwd})
      Process.stderr.on 'data', (data) -> Data.push(data.toString())
      Process.on 'close', ->
        Content = []
        for line in Data
          console.log "linter-swiftc command output: #{line}" if atom.inDevMode()
          Content.push XRegExp.exec(line, regex)
        ToReturn = []
        Content.forEach (regex) ->
          if regex
            ToReturn.push(
              type: regex.type,
              text: regex.message,
              filePath: path.join(cwd, regex.file).normalize()
              range: [[regex.line - 1, regex.column - 1], [regex.line - 1, regex.column - 1]]
            )
        Resolve(ToReturn)
