# Custom Plugin Development for golangci-lint

This instruction outlines how to develop and integrate custom plugins into `golangci-lint`, enhancing its functionality to suit specific linting needs.

## Creating the Plugin

### Develope the Plugin

1. Provide one or more `golang.org/x/tools/go/analysis.Analyzer` structs.
2. Ensure your project utilizes a `go.mod` file for managing dependencies.
3. All overlapping library versions between your plugin and `golangci-lint` must match those used in `golangci-lint`. Check these versions by running `go version -m golangci-lint`.
4. Create a Go file, such as `plugin/example.go`, with the following specifications:

    ```go
   func New(conf any) ([]*analysis.Analyzer, error) { 
            // ...
   }
    ```

### Generate the plugin

1. From the root directory of your plugin project, compile the plugin using the command:

    ```bash
    go build -buildmode=plugin plugin/example.go
    ```

3. **Copy the generated `example.so` file** to a directory within your project or to another location that is easily accessible.

## Setting Up a Custom `golangci-lint`

**Note:** Custom plugins require a version of `golangci-lint` that supports plugin integration.

### Plugin and golangci-lint Dependencies

Ensure that all dependencies used in the plugin match the versions used by `golangci-lint` to avoid conflicts. This includes direct and transitive dependencies.

### Configuring Your Project for Linting

To configure `golangci-lint` to use your custom plugin, perform the following steps:

1. **Add or update the `.golangci.yml` file** in the root directory of the project you want to lint:

    ```yaml
    linters-settings:
      custom:
        example:
          path: /path/to/mocklint.so
          description: "The description of the linter"
          original-url: "github.com/golangci/example-linter"
          settings: # Optional settings for the linter.
            one: "Foo"
            two:
              - name: "Bar"
            three:
              name: "Bar"
    ```

Custom linters are enabled by default but follow the same rules as standard linters. To disable all linters, including custom ones, use the `disable-all: true` option in `.golangci.yml` or the `-D` flag on the command line. They can be re-enabled in the `.golangci.yml` file or by using the `-E` flag (e.g., `golangci-lint run -Eexample`)
