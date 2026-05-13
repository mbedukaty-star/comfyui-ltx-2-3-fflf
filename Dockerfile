# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-gguf@1.1.10 --mode remote || (echo "WARN: comfyui-gguf@1.1.10 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-gguf --mode remote)
RUN comfy node install --exit-on-fail comfyui-videohelpersuite@1.7.9 || (echo "WARN: comfyui-videohelpersuite@1.7.9 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-videohelpersuite)

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensors' --relative-path models/vae --filename 'LTX23_video_vae_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/ggml-org/gemma-3-12b-it-GGUF/resolve/main/gemma-3-12b-it-Q4_K_M.gguf' --relative-path models/diffusion_models --filename 'gemma-3-12b-it-Q4_K_M.gguf' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/onewayomni/ltx-2.3_text_projection_bf16.safetensors/resolve/main/ltx-2.3_text_projection_bf16.safetensors' --relative-path models/diffusion_models --filename 'ltx-2.3_text_projection_bf16.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
# RUN # Could not find URL for LTX-2.3-distilled-Q3_K_M.gguf (diffusion_models)
# Try searching: https://civitai.com/models?query=LTX%202.3%20distilled

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/9k= (1).png' "https://cool-anteater-319.convex.cloud/api/storage/39fe8eed-b91f-44d0-93d8-40218ee34ac3"
RUN wget --progress=dot:giga -O '/comfyui/input/Gemini_Generated_Image_qg19b7qg19b7qg19.png' "https://cool-anteater-319.convex.cloud/api/storage/5c3a0ca9-b838-4114-963e-c16b69600981"
