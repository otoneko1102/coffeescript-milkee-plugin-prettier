#!/usr/bin/env node

{ formatCoffeeFiles } = require './main'

# Main function
main = ->
  # Parse CLI arguments
  args = process.argv.slice(2)
  targetDir = args[0] or process.cwd()

  # Run the formatter
  await formatCoffeeFiles(targetDir)

# Execute
main().catch (error) ->
  console.error error
  process.exit 1
