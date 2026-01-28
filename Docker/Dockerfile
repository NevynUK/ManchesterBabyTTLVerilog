FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages including wget
RUN apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Download and install apio from GitHub releases
RUN wget https://github.com/FPGAwars/apio/releases/download/2026-01-28/apio-cli-linux-x86-64-20260128-debian.deb && \
    dpkg -i ./apio-cli-linux-x86-64-20260128-debian.deb && \
    rm ./apio-cli-linux-x86-64-20260128-debian.deb

# Install oss-cad-suite
RUN apio install oss-cad-suite

# Set working directory
WORKDIR /workspace

# Copy the project files
COPY . /workspace

# Make the check script executable
RUN chmod +x /workspace/check.sh

# Default command
CMD ["/workspace/check.sh"]
