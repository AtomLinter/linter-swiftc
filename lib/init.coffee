module.exports =
  configDefaults:
    swiftcCommandName: 'swiftc'

  activate: ->
    if atom.inDevMode()
      console.log 'activate linter-swiftc'
