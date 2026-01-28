#!/bin/bash
#
# Run all apio tests for the Manchester Baby TTL Verilog project
#

set -e  # Exit on any error

echo "Running apio tests..."

cd Source

# Run all test benches
for test_file in Tests/*_tb.v; do
    echo "Testing: $test_file"
    apio test "$test_file"
done

echo "All tests completed successfully!"
