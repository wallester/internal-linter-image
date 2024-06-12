#!/bin/bash

usage() {
  echo "Usage: $0 [-b <bindir>] [-d] [-h] [-x]"
  echo "  -b <bindir>   Specify the directory where custom-gcl will be moved (default: ./bin)"
  echo "  -d            Enable debug logging"
  echo "  -h            Display this help and exit"
  echo "  -x            Set shell script debugging mode"
  exit 1
}

parse_args() {
  BINDIR="./bin"
  while getopts ":b:dhx" arg; do
    case "$arg" in
      b) BINDIR="$OPTARG" ;;
      d) set -x ;;
      h) usage ;;
      x) set -x ;;
      *) usage ;;
    esac
  done
  shift $((OPTIND - 1))
  TAG=$1
}

parse_args "$@"

if ! command -v golangci-lint >/dev/null 2>&1; then
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.59.0;
fi

cat <<EOF > .custom-gcl.yml
version: v1.59.0
plugins:
  - module: 'github.com/wallester/internal-linter-image'
    import: 'github.com/wallester/internal-linter-image/analyzer'
    version: v1.0.3
EOF

if golangci-lint custom -v; then
  mv custom-gcl "$BINDIR" && echo "Operation completed successfully."
  rm .custom-gcl.yml
else
  echo "golangci-lint encountered an error."
  rm .custom-gcl.yml
fi
