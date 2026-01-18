fs = require 'fs'
path = require 'path'
consola = require 'consola'
prettier = require 'prettier'
ignore = require 'ignore'

pkg = require '../package.json'
PREFIX = "[#{pkg.name}]"

# Create a custom logger with prefix
c = {}
for method in ['log', 'info', 'success', 'warn', 'error', 'debug', 'start', 'box']
  do (method) ->
    c[method] = (args...) ->
      if typeof args[0] is 'string'
        args[0] = "#{PREFIX} #{args[0]}"
      consola[method] args...

# Helper: recursively collect .coffee files
collectCoffeeFiles = (dir, list = []) ->
  try
    entries = fs.readdirSync(dir, { withFileTypes: true })
  catch error
    return list

  for ent in entries
    full = path.join(dir, ent.name)
    if ent.isDirectory()
      collectCoffeeFiles full, list
    else if path.extname(ent.name) is '.coffee'
      list.push full
  list

# Export a plugin factory
main = (opts = {}) ->
  (compilationResult) ->
    { config, compiledFiles } = compilationResult

    # Determine output directory
    output = config?.output or 'dist'
    outDir = if config?.options?.join then path.dirname(output) else output

    projectRoot = process.cwd()

    # Handle prettierignore: can be a path (string) or an array of patterns
    ignorePath = null
    ignorePatterns = null
    ig = null

    if Array.isArray(opts?.prettierignore)
      ignorePatterns = opts.prettierignore.filter((p) -> typeof p is 'string')
      if ignorePatterns.length > 0
        ig = ignore().add(ignorePatterns)
    else if typeof opts?.prettierignore is 'string'
      ignorePath = if path.isAbsolute(opts.prettierignore) then opts.prettierignore else path.join(projectRoot, opts.prettierignore)
      unless fs.existsSync(ignorePath)
        c.warn "prettierignore not found at #{ignorePath}"
        ignorePath = null
    else
      defaultIgnore = path.join(projectRoot, '.prettierignore')
      if fs.existsSync(defaultIgnore)
        ignorePath = defaultIgnore

    # Load prettierrc: opts.prettierrc can be an object or a path to a file. If not provided, try resolveConfig, then package.json
    prettierrc = null

    if opts?.prettierrc?
      if typeof opts.prettierrc is 'object'
        prettierrc = opts.prettierrc
      else if typeof opts.prettierrc is 'string'
        rcPath = if path.isAbsolute(opts.prettierrc) then opts.prettierrc else path.join(projectRoot, opts.prettierrc)
        try
          prettierrc = JSON.parse fs.readFileSync(rcPath, 'utf8')
        catch error
          c.warn "Failed to read prettierrc at #{rcPath}: #{error.message}"

    unless prettierrc?
      try
        prettierrc = await prettier.resolveConfig(projectRoot)
      catch error
        prettierrc = null

    unless prettierrc?
      try
        pkgPath = path.join(projectRoot, 'package.json')
        if fs.existsSync(pkgPath)
          pkg = JSON.parse fs.readFileSync(pkgPath, 'utf8')
          if pkg?.prettier?
            prettierrc = pkg.prettier
      catch error
        # ignore

    c.info "Searching .coffee files in #{outDir}"

    unless fs.existsSync(outDir)
      c.warn "Output directory not found: #{outDir}"
      return

    files = collectCoffeeFiles outDir

    if files.length is 0
      c.info "No .coffee files found in #{outDir}"
      return

    c.info "Found #{files.length} .coffee file(s)"

    formattedCount = 0

    for file in files
      try
        # Ensure we only format CoffeeScript files
        if path.extname(file) isnt '.coffee'
          c.debug "Skip non-coffee file: #{file}"
          continue

        # Check ignore via patterns or ignore file
        if ig?
          rel = path.relative(projectRoot, file).split(path.sep).join('/')
          if ig.ignores(rel)
            c.info "Ignored by prettierignore patterns: #{file}"
            continue
        else if ignorePath?
          try
            info = await prettier.getFileInfo(file, { ignorePath })
            if info?.ignored
              c.info "Ignored by .prettierignore: #{file}"
              continue
          catch err
            c.debug "Failed to check ignore for #{file}: #{err.message}"

        text = fs.readFileSync(file, 'utf8')

        prettierOptions = Object.assign {}, prettierrc or {},
          filepath: file,
          plugins: [ require.resolve('prettier-plugin-coffeescript') ]

        formatted = prettier.format text, prettierOptions

        if formatted isnt text
          fs.writeFileSync file, formatted, 'utf8'
          formattedCount += 1
          c.success "Formatted: #{file}"
        else
          c.debug "Already formatted: #{file}"
      catch error
        c.error "Failed to format #{file}: #{error.message}"

    c.success "Prettier formatted #{formattedCount} file(s)"

module.exports = main
