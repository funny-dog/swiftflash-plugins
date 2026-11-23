# SwiftFlash Plugins Registry

Official plugin registry for [SwiftFlash](https://github.com/funny-dog/SwiftFlash) IDE.

## Structure

```text
swiftflash-plugins/
├── index.json                              # Registry index consumed by SwiftFlash
├── plugins/
│   └── com.swiftflash.lang.zh-cn/
│       ├── manifest.json                   # Plugin metadata & contribution points
│       └── strings.json                    # Localization dictionary
├── releases/
│   └── com.swiftflash.lang.zh-cn-1.0.0.zip # Packaged plugin archive
└── scripts/
    └── package_plugins.sh                  # Rebuilds .zip archives & updates index.json
```

## Packaging Plugins

Run:

```bash
./scripts/package_plugins.sh
```

This packages every plugin directory under `plugins/` into `releases/<id>-<version>.zip` and updates `sha256`, `archiveURL`, and `updatedAt` in `index.json`.
