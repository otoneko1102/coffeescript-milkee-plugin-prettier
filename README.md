[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)

# milkee-plugin-prettier

A Milkee plugin for working with Prettier for CoffeeScript without version conflicts.

> [!TIP]
> Uses [Optimized-Prettier](https://github.com/helixbass/prettier/releases/tag/prettier-v2.1.0-dev.100-gitpkg) (by [helixbass](https://github.com/helixbass)) and [prettier-plugin-coffeescript](https://www.npmjs.com/package/prettier-plugin-coffeescript) (by [helixbass](https://github.com/helixbass)) to format CoffeeScript files.

## Features

- Recursively finds `.coffee` files in the build entry directory and formats them with Prettier.
- Supports a `prettierrc` (object or a path to a config file) and `.prettierignore` to exclude files.
- Automatically resolves config via `prettier.resolveConfig()` or `package.json#prettier` when `prettierrc` is not provided.

## Usage

### As a Milkee Plugin (coffee.config.cjs)

```js
const prettierPlugin = require('milkee-plugin-prettier');

module.exports = {
  entry: 'src',
  output: 'dist',
  milkee: {
    plugins: [
      // Pass options (optional)
      prettierPlugin({
        prettierrc: { tabWidth: 2 },        // or a path to a config file
        prettierignore: '.prettierignore'   // optional, resolved from cwd
      })
    ]
  }
};
```

### As a CLI Tool

You can also use this package as a standalone CLI tool to format CoffeeScript files:

```bash
# Format files in the current directory
npx cprettier

# Format files in a specific directory
npx cprettier src
```

The CLI will:
- Recursively find all `.coffee` files in the target directory
- Respect `.prettierignore` and prettier config files (`.prettierrc`, `prettier.config.js`, or `package.json#prettier`)
- Format files in place

### Notes

- `.prettierignore` is resolved relative to `process.cwd()` by default. You can pass an absolute or relative path via the `prettierignore` option.
- When `config.options.join` is used and a single entry file is emitted, the plugin will use the directory of the entry file as the search root for `.coffee` files.
