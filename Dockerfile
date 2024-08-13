# ---------------------------------------------------------------------------- #
#                         Part 1: Download the files                           #
# ---------------------------------------------------------------------------- #
FROM alpine/git:2.45.2 as download
COPY builder/clone.sh /clone.sh

# Clone the repos
# Fooocus-API
RUN . /clone.sh /workspace https://github.com/mrhan1993/Fooocus-API.git 966853794c527f5a08dcc190777022fe6e2e782a

# ---------------------------------------------------------------------------- #
#                        Part 2: Build the final image                         #
# ---------------------------------------------------------------------------- #
FROM python:3.10.14-slim as build_final_image
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update and upgrade the system packages
RUN apt-get update && \
    apt install -y \
    fonts-dejavu-core rsync git jq moreutils aria2 wget libgoogle-perftools-dev procps libgl1 libglib2.0-0 && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/* && apt-get clean -y

RUN --mount=type=cache,target=/cache --mount=type=cache,target=/root/.cache/pip \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Copy downloaded data to the final image
COPY --from=download /workspace/ /workspace/
# Change Fooocus configs
COPY src/default.json /workspace/repositories/Fooocus/presets/default.json

# Install Python dependencies
COPY builder/requirements.txt /requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

ADD src .

# Cleanup
RUN apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------- #
#                  Download specific models using wget                         #
# ---------------------------------------------------------------------------- #

RUN wget -O /workspace/repositories/Fooocus/models/cyberrealisticXL_v22.safetensors https://huggingface.co/ProjectGasm/mod3l-hub/resolve/main/M0D3LS/cyberrealisticXL_v22.safetensors?download=true
RUN wget -O /workspace/repositories/Fooocus/models/dreamshaperXL_v21TurboDPMSDE.safetensors https://huggingface.co/ProjectGasm/mod3l-hub/resolve/main/M0D3LS/dreamshaperXL_v21TurboDPMSDE.safetensors?download=true
RUN wget -O /workspace/repositories/Fooocus/models/lustifySDXLNSFWSFW_v20.safetensors https://huggingface.co/ProjectGasm/mod3l-hub/resolve/main/M0D3LS/lustifySDXLNSFWSFW_v20.safetensors?download=true
RUN wget -O /workspace/repositories/Fooocus/models/ponyDiffusionV6XL.safetensors https://huggingface.co/ProjectGasm/mod3l-hub/resolve/main/M0D3LS/ponyDiffusionV6XL.safetensors?download=true
RUN wget -O /workspace/repositories/Fooocus/models/realvisxlV40_v40LightningBakedvae.safetensors https://huggingface.co/ProjectGasm/mod3l-hub/resolve/main/M0D3LS/realvisxlV40_v40LightningBakedvae.safetensors?download=true

# ---------------------------------------------------------------------------- #
#                    Download entire folder from Hugging Face                  #
# ---------------------------------------------------------------------------- #

COPY builder/download_loras.sh /download_loras.sh

# Make the script executable and run it
RUN chmod +x /download_loras.sh && /download_loras.sh

# ---------------------------------------------------------------------------- #
#                          Set up the final CMD                               #
# ---------------------------------------------------------------------------- #
RUN chmod +x /start.sh
CMD /start.sh
