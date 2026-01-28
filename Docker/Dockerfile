FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install python3 and pip
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install apio using pip
RUN pip3 install apio
RUN apio install oss-cad-suite

# Set working directory
WORKDIR /workspace

# Copy the project files
COPY . /workspace

# Make the check script executable
RUN chmod +x /workspace/check.sh

# Default command
CMD ["/workspace/check.sh"]
