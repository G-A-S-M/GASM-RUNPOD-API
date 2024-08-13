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

# Download LORAs
RUN wget -O /workspace/repositories/Fooocus/models/loras/Canopus-Pencil-Art-LoRA.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/Canopus-Pencil-Art-LoRA.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/EnvyBetterHiresFixLoL01.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/EnvyBetterHiresFixLoL01.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/EnvyZoomSliderXL01.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/EnvyZoomSliderXL01.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/PonyPantiesCameltoesUpSkirt.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/PonyPantiesCameltoesUpSkirt.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/RMSDXL_Enhance.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/RMSDXL_Enhance.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/SDXL-ClaymationX-Lora-000002.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/SDXL-ClaymationX-Lora-000002.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/SDXL_FaeTastic2400.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/SDXL_FaeTastic2400.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/SDXL_Lora_ZumiArtstyle_Animagine_-000032.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/SDXL_Lora_ZumiArtstyle_Animagine_-000032.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/SDXL_Lora_zumi_artstyle_Pony.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/SDXL_Lora_zumi_artstyle_Pony.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/add-detail-xl.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/add-detail-xl.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/aidmaFluxStyleXL-v0.2.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/aidmaFluxStyleXL-v0.2.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/blur_control_xl_v1.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/blur_control_xl_v1.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/booty_shorts.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/booty_shorts.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/boringRealism_primaryV4.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/boringRealism_primaryV4.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/microskirt.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/microskirt.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/model_287054.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/model_287054.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/nsfw_poc_all_in_one.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/nsfw_poc_all_in_one.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/sdxl_lightning_4step_lora.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/sdxl_lightning_4step_lora.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/sdxl_lightning_8step_lora.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/sdxl_lightning_8step_lora.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/underboob.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/underboob.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/ups.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/ups.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/wet_tshirt.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/LORAS/wet_tshirt.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/loras/experiment.safetensors https://huggingface.co/ProjectGasm/GASM-EROS-BETA/resolve/main/ER0S-GASM-LORAS/Experiment/last.safetensors

# Download Models
RUN wget -O /workspace/repositories/Fooocus/models/model/b00bs.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/ER0S-GASM-LORAS/b00bs/b00bs.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/bl0wjob.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/ER0S-GASM-LORAS/bl0wj0b/model/bl0wjob.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/m1nd3xpand3r.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/ER0S-GASM-LORAS/m1nd3xpand3r-chichago/model/m1nd3xpand3r.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/selfie.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/ER0S-GASM-LORAS/selfie/model/selfie.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/cyberrealisticXL_v22-mid_312530-vid_709456.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/M0D3L-HUB/CyberRealistic%20XL/cyberrealisticXL_v22-mid_312530-vid_709456.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/dreamshaperXL_v21TurboDPMSDE-mid_112902-vid_351306.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/M0D3L-HUB/DreamShaper%20XL/dreamshaperXL_v21TurboDPMSDE-mid_112902-vid_351306.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/realvisxlV40_v40LightningBakedvae-mid_139562-vid_361593.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/M0D3L-HUB/RealVisXL%20V4.0/realvisxlV40_v40LightningBakedvae-mid_139562-vid_361593.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/ponyDiffusionV6XL_v6StartWithThisOne.safetensors https://huggingface.co/ProjectGasm/b00bs/blob/main/M0D3L-HUB/ponyDiffusionV6XL_v6StartWithThisOne/ponyDiffusionV6XL_v6StartWithThisOne.safetensors && \
    wget -O /workspace/repositories/Fooocus/models/model/lustifySDXLNSFWSFW_v10.safetensors https://huggingface.co/ProjectGasm/M0D3L-HUB/blob/main/lustifySDXLNSFWSFW_v10.safetensors

# Other models can be added or removed as needed

RUN chmod +x /start.sh
CMD /start.sh
