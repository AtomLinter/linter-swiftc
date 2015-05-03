module.exports =
  config:
    liveLinting:
      type: 'boolean'
      default: false

  activate: ->
    if atom.inDevMode()
      console.log 'activate linter-swiftc'
