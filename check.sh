#!/bin/bash
#
# Run all apio tests for the Manchester Baby TTL Verilog project
#

set -e  # Exit on any error

echo "Running apio tests..."

cd Source
apio test

echo "All tests completed successfully!"
