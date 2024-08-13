# ---------------------------------------------------------------------------- #
#                         Part 1: Download the Repositories                    #
# ---------------------------------------------------------------------------- #
FROM alpine/git:2.45.2 as download

# Notify that the clone process is starting
RUN echo "Cloning L0RAS directory from Hugging Face..."

# Clone the L0RAS folder to the loras directory in Fooocus
RUN git clone --filter=blob:none --no-checkout https://huggingface.co/ProjectGasm/mod3l-hub /workspace/temp && \
    cd /workspace/temp && \
    git sparse-checkout init --cone && \
    git sparse-checkout set L0RAS && \
    echo "Moving L0RAS files to the loras directory..." && \
    mv L0RAS/* /workspace/repositories/Fooocus/models/loras/ && \
    cd / && rm -rf /workspace/temp && \
    echo "L0RAS cloning and moving complete."

# Notify that the M0D3LS clone process is starting
RUN echo "Cloning M0D3LS directory from Hugging Face..."

# Clone the M0D3LS folder to the models directory in Fooocus
RUN git clone --filter=blob:none --no-checkout https://huggingface.co/ProjectGasm/mod3l-hub /workspace/temp && \
    cd /workspace/temp && \
    git sparse-checkout init --cone && \
    git sparse-checkout set M0D3LS && \
    echo "Moving M0D3LS files to the models directory..." && \
    mv M0D3LS/* /workspace/repositories/Fooocus/models/model/ && \
    cd / && rm -rf /workspace/temp && \
    echo "M0D3LS cloning and moving complete."

# Notify that the CONTROL-NET clone process is starting
RUN echo "Cloning CONTROL-NET directory from Hugging Face..."

# Clone the CONTROL-NET folder to the controlnet directory in Fooocus
RUN git clone --filter=blob:none --no-checkout https://huggingface.co/ProjectGasm/mod3l-hub /workspace/temp && \
    cd /workspace/temp && \
    git sparse-checkout init --cone && \
    git sparse-checkout set CONTROL-NET && \
    echo "Moving CONTROL-NET files to the controlnet directory..." && \
    mv CONTROL-NET/* /workspace/repositories/Fooocus/models/controlnet/ && \
    cd / && rm -rf /workspace/temp && \
    echo "CONTROL-NET cloning and moving complete."

# ---------------------------------------------------------------------------- #
#                        Part 2: Build the Final Image                         #
# ---------------------------------------------------------------------------- #
FROM python:3.10.14-slim as build_final_image

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1

# Use bash as the shell and ensure failures are captured in the pipeline
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Notify that system update and package installation is starting
RUN echo "Updating system packages and installing dependencies..."

# Update and upgrade system packages, and install necessary dependencies
RUN apt-get update && \
    apt install -y \
    fonts-dejavu-core rsync git jq moreutils aria2 wget libgoogle-perftools-dev procps libgl1 libglib2.0-0 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    echo "System update and package installation complete."

# Notify that PyTorch installation is starting
RUN echo "Installing PyTorch and related packages..."

# Install PyTorch with CUDA 12.1 support, using cache for pip to speed up the process
RUN --mount=type=cache,target=/cache --mount=type=cache,target=/root/.cache/pip \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    echo "PyTorch installation complete."

# Notify that copying data from previous stage is starting
RUN echo "Copying data from the download stage..."

# Copy downloaded data from the previous stage to the final image
COPY --from=download /workspace/ /workspace/

# Notify that Fooocus config changes are being applied
RUN echo "Applying Fooocus configuration changes..."

# Overwrite Fooocus configs with custom settings
COPY src/default.json /workspace/repositories/Fooocus/presets/default.json

# Notify that Python dependencies installation is starting
RUN echo "Installing Python dependencies..."

# Install Python dependencies listed in requirements.txt, using cache for pip
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt && \
    echo "Python dependencies installation complete."

# Add the source files to the image
ADD src/ /workspace/

# Notify that cleanup is starting
RUN echo "Cleaning up unnecessary packages and files..."

# Clean up unnecessary packages and files
RUN apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Cleanup complete."

# Grant execute permissions to the start script and notify about execution
RUN chmod +x /start.sh && \
    echo "Setup complete. Ready to start."

CMD /start.sh
