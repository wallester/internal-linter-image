# Command to create symlink for subpackages: ln -s ../Makefile Makefile

generate:
	@go build -buildmode=plugin plugin/mockplugin.go

test:
	@golangci-lint run