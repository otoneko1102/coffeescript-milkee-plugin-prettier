#!/usr/bin/env node

{ formatCoffeeFiles } = require './main.coffee'

# Parse CLI arguments
args = process.argv.slice(2)
targetDir = args[0] or process.cwd()

# Run the formatter
await formatCoffeeFiles(targetDir)
