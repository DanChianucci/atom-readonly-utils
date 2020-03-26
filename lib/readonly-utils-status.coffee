{View} = require 'atom-space-pen-views'
module.exports =

# Status bar indicator showing current tab settings.
class ReadOnlyToggleStatus extends View
  displayInStatusBar: true
  displayInTab: true
  colorizeTabs: true
  subs: null
  tile: null

  # Private: Setup space-pen view template.
  @content: ->
    @a class: "readonly-utils-status inline-block"

  # Public: Creates new indicator view.
  initialize: ->
    {CompositeDisposable} = require 'atom'
    @subs = new CompositeDisposable
    this

  # Public: destroy view, remove from status bar.
  destroy: ->
    @tile?.destroy()
    @tile = null
    @sub?.dispose()
    @sub = null

  # Public: updates view with current settings.
  update: ->
    ReadOnlyUtilHelper = require './readonly-utils-helper'
    editor = atom.workspace.getActiveTextEditor()
    filepath = editor?.buffer?.file?.path
    # console.log("Update "+filepath)

    if @displayInStatusBar and filepath
      ro = ReadOnlyUtilHelper.isReadOnly(filepath)
      @updateStatus(ro)
      @updateTabs(ro)
      @show()
    else
      @hide()

  updateStatus: (ro) ->
    if ro
      @text "[RO]"
      @element.classList.add "ro"
      @element.classList.remove "rw"
    else
      @text "[RW]"
      @element.classList.add "rw"
      @element.classList.remove "ro"

  updateTabs: (ro) ->
    pane = atom.workspace.getActivePane()
    view = atom.views.getView(pane)?.querySelectorAll(".tab.active")[0]?.querySelectorAll(".title")[0]
    container = view?.querySelector "span.readonly-utils"

    if ro
      if @colorizeTabs
        view?.classList.add "ro"
      else
        view?.classList.remove "ro"

      if @displayInTab and not container?
        container = document.createElement("span")
        container.classList.add "readonly-utils"
        container.innerHTML = " [RO]"
        view?.appendChild container

      if container? and not @displayInTab
        view?.removeChild container

    else
      view?.classList.remove "ro"
      if container?
        view?.removeChild container

  toggle: ->
    ReadOnlyUtilHelper = require './readonly-utils-helper'
    editor = atom.workspace.getActiveTextEditor()
    filepath = editor?.buffer?.file?.path
    if filepath
      ReadOnlyUtilHelper.toggleWriteable(filepath)
    @update()

  # Public: Attaches indicator view to given status bar.
  attach: (statusBar) ->
    @tile = statusBar.addRightTile
      item: this
      priority: 10000
    @handleEvents()
    @update()

  # Private: Sets up event handlers for indicator.
  handleEvents: ->
    @click => @toggle()
    @subs.add atom.workspace.onDidStopChangingActivePaneItem          => @update()
    @subs.add atom.config.observe 'readonly-utils.displayInStatusBar', => @updateConfig()
    @subs.add atom.config.observe 'readonly-utils.colorizeTabs',       => @updateConfig()
    @subs.add atom.config.observe 'readonly-utils.displayInTab',       => @updateConfig()

  # Private: Updates cache of atom config settings for this package.
  updateConfig: ->
    @displayInStatusBar = atom.config.get 'readonly-utils.displayInStatusBar'
    @displayInTab = atom.config.get 'readonly-utils.displayInTab'
    @colorizeTabs = atom.config.get 'readonly-utils.colorizeTabs'
    @update()
