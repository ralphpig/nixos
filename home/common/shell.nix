{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.size = 10000;
    historySubstringSearch.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "ys";
    };

    shellAliases = {
      cpwd = "pwd | tee >(wl-copy)";
    };

    initContent = ''
      json2csv () {
        jq -r '
          def flatten($pfx):
            to_entries |
            map(
              . as $pair |
              if $pair.value | type == "object" then
                ($pair.value | flatten($pfx + $pair.key + "_"))
              else
                {($pfx + $pair.key): $pair.value}
              end
            ) | add;

          def set_null_key($keys):
            reduce $keys[] as $key
              (.; if has($key) | not then .[$key] = null else . end);

          [
            (. | map(flatten("")) | add | keys_unsorted | sort) as $keys | $keys,
            (. | map(flatten("") | set_null_key($keys) | to_entries | sort_by(.key) | from_entries | map(.)) )
          ] as $csv |
          ($csv[0] | @csv),
          ($csv[1] | .[] | @csv)
        ' "$1"
      }
    '';
  };
}
