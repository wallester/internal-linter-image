package main

import (
	"fmt"
	"os/exec"
)

func main() {
	// Command to execute
	cmd := exec.Command("golangci-lint", "custom")
	fmt.Println("Executing")

	// Capture command output
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error executing command:", err)
		return
	}

	// Print command output
	fmt.Println(string(output))
}
