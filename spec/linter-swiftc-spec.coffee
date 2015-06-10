describe "A Linter Provider for the Swift Language", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("linter-swiftc")
  describe "when the base Linter package is installed", ->
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage("linter-plus")
  describe "when the base Linter package is not installed", ->
    it "shows the user an error, instructing the user to install the core Linter package", ->
      expect(atom.notifications.getNotifications()).toContain({
          message: "[linter-swiftc] `linter-plus` package not found, please install it"
        })
