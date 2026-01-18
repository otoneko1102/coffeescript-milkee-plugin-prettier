# milkee-plugin-prettier

A Milkee plugin for working with Prettier for CoffeeScript without version conflicts.

- Uses [Optimized-Prettier](https://github.com/helixbass/prettier/releases/tag/prettier-v2.1.0-dev.100-gitpkg) (by [helixbass](https://github.com/helixbass)) and [prettier-plugin-coffeescript](https://www.npmjs.com/package/prettier-plugin-coffeescript) (by [helixbass](https://github.com/helixbass)) to format CoffeeScript files.

## Features

- Recursively finds `.coffee` files in the build output directory and formats them with Prettier.
- Supports a `prettierrc` (object or a path to a config file) and `.prettierignore` to exclude files.
- Automatically resolves config via `prettier.resolveConfig()` or `package.json#prettier` when `prettierrc` is not provided.

## Usage

### coffee.config.cjs

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

### Notes

- `.prettierignore` is resolved relative to `process.cwd()` by default. You can pass an absolute or relative path via the `prettierignore` option.
- When `config.options.join` is used and a single output file is emitted, the plugin will use the directory of the output file as the search root for `.coffee` files.

## Development

- Build: `npm run build`
- Link for local testing: `npm link` → in another project: `npm link milkee-plugin-prettier`

## License

MIT
