#!/bin/bash

# Create or overwrite the .custom-gcl.yml file with the specified content
cat <<EOF > .custom-gcl.yml
version: v1.59.0
plugins:
  - module: 'github.com/wallester/custom-golang-image'
    import: 'github.com/wallester/custom-golang-image/analyzer'
    version: v1.0.1
EOF

# Run golangci-lint in custom mode with verbose output
golangci-lint custom -v

# Check if golangci-lint was successful
if [ $? -eq 0 ]; then
  # Move custom-gcl file to the specified directory
  mv custom-gcl $GOPATH/bin

  # Remove the .custom-gcl.yml file
  rm .custom-gcl.yml
else
  echo "golangci-lint encountered an error."
fi