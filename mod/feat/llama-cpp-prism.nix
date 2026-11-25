{
  flake.modules.homeManager.llama-cpp-prism =
    { pkgs, ... }:
    let
      # PrismML's llama.cpp fork (branch `prism`) - required to load the
      # fork's custom PQ2_0/PTQ1_0 ternary GGUF tensor types (ggml ids 142/143),
      # which mainline llama.cpp/ollama cannot decode.
      # https://github.com/PrismML-Eng/llama.cpp
      llama-cpp-prism =
        (pkgs.llama-cpp.override {
          rocmSupport = true;
          rocmGpuTargets = [ "gfx1201" ]; # RX 9070 XT
        }).overrideAttrs
          (_old: {
            pname = "llama-cpp-prism";
            version = "prism-9a9394a";
            src = pkgs.fetchFromGitHub {
              owner = "PrismML-Eng";
              repo = "llama.cpp";
              rev = "9a9394a895b96003ca842a6041cb28ac49a108f7";
              hash = "sha256-KDecY+v9S/193mLGse5EsJPugZR1wxWzOlOU7GuMd5Y=";
            };
          });
    in
    {
      home.packages = [ llama-cpp-prism ];
    };
}
