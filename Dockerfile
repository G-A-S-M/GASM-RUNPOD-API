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

# Download only necessary models using wget
RUN wget -O /workspace/repositories/Fooocus/models/checkpoints/lustifySDXLNSFWSFW_v10.safetensors https://huggingface.co/ProjectGasm/M0D3L-HUB/resolve/main/lustifySDXLNSFWSFW_v10.safetensors?download=true && \
    wget -O /workspace/repositories/Fooocus/models/loras/sd_xl_offset_example-lora_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors?download=true && \
    wget -O /workspace/repositories/Fooocus/models/loras/sdxl_lcm_lora.safetensors https://huggingface.co/3WaD/RunPod-Fooocus-API/resolve/main/v0.3.30/sdxl_lcm_lora.safetensors?download=true

# Other models can be added or removed as needed
# For example, remove the models that are not needed

RUN chmod +x /start.sh
CMD /start.sh
