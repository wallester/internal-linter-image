#!/bin/bash

parse_args() {
  BINDIR=${BINDIR:-./bin}
  while getopts "b:dh?x" arg; do
    case "$arg" in
      b) BINDIR="$OPTARG" ;;
      d) log_set_priority 10 ;;
      h | \?) usage "$0" ;;
      x) set -x ;;
    esac
  done
  shift $((OPTIND - 1))
  TAG=$1
}

parse_args "$@"

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.59.0

if [ $? -ne 0 ]; then
  echo "Failed to install golangci-lint."
  exit 1
fi

cat <<EOF > .custom-gcl.yml
version: v1.59.0
plugins:
  - module: 'github.com/wallester/internal-linter-image'
    import: 'github.com/wallester/internal-linter-image/analyzer'
    version: v1.0.3
EOF

golangci-lint custom -v

if [ $? -eq 0 ]; then
  mv custom-gcl $BINDIR

  rm .custom-gcl.yml

  echo "Operation completed successfully."
else
  echo "golangci-lint encountered an error."

fi
