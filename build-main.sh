#!/bin/bash
echo "=== Using Dockerfile: $(pwd)/Dockerfile ==="
cat Dockerfile | head -5
echo "=== Building with explicit Dockerfile ==="
docker build -f $(pwd)/Dockerfile -t $1 .
