{ pkgs, ... }:
{
  # Local LLM inference on the AMD GPU (RDNA4 / gfx1201, RX 9070 XT).
  # ROCm 6.4.1+ (nixpkgs has 7.x) officially supports gfx1201, so no
  # HSA_OVERRIDE_GFX_VERSION override should be needed.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;

    # Flash attention is required for quantized K/V cache; without it
    # OLLAMA_KV_CACHE_TYPE is silently ignored (falls back to f16).
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      # Default context window; Ollama's own default (4096) is too small for
      # Open WebUI's system prompt + a real conversation.
      OLLAMA_CONTEXT_LENGTH = "16384";
    };
  };

  # Chat UI against the local ollama API, http://localhost:10000
  services.open-webui = {
    enable = true;
    port = 10000;
  };
}
