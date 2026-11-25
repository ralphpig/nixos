{
  flake.modules.homeManager.base = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # zsh picks the vi keymap on its own when $EDITOR contains "vi" (we set
      # nvim). oh-my-zsh used to force emacs; keep that (Ctrl-R, Ctrl-A/E, ...).
      defaultKeymap = "emacs";

      autocd = true; # type a dir name (e.g. `..`) to cd into it
      setOptions = [ "INTERACTIVE_COMMENTS" ]; # allow `# comments` at the prompt

      history.size = 10000;
      historySubstringSearch.enable = true; # Up/Down search by typed prefix

      shellAliases = {
        cpwd = "pwd | tee >(wl-copy)";
        # NixOS's /etc/zshrc also defines these (and ls --color=tty); pinned here
        l = "ls -lha";
        ll = "ls -lh";
      };

      initContent = ''
        # Bits oh-my-zsh used to provide
        bindkey '^[[1;5C' forward-word    # Ctrl-Right
        bindkey '^[[1;5D' backward-word   # Ctrl-Left
        bindkey '^[[3~'   delete-char     # Delete
        bindkey '^[[H'    beginning-of-line # Home
        bindkey '^[[F'    end-of-line     # End
        bindkey '^[[Z'    reverse-menu-complete # Shift-Tab

        # Ctrl-Shift-<key> = Ctrl-<key>. Ghostty sends these as CSI u; other
        # terminals send the plain control char, which is already bound.
        bindkey '^[[114;6u' fzf-history-widget # Ctrl-Shift-R
        bindkey '^[[108;6u' clear-screen       # Ctrl-Shift-L

        zstyle ':completion:*' menu select # arrow-key completion menu
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case-insensitive
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

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

    # Prompt; zsh integration is on by default
    # Colors come from Stylix (its palette is merged into these settings)
    programs.starship = {
      enable = true;
      settings = {
        # user@host, normally only shown over SSH / as root
        username = {
          show_always = true;
          format = "[$user]($style)@";
        };
        hostname = {
          ssh_only = false;
          format = "[$ssh_symbol$hostname]($style) in ";
        };
        # Full path (still ~ for home), also inside git repos
        directory = {
          truncation_length = 0;
          truncate_to_repo = false;
        };
        # Clock on the right of the input line (12h, like the GNOME clock)
        right_format = "$time";
        time = {
          disabled = false;
          time_format = "%-I:%M:%S %p";
        };
      };
    };

    # Fuzzy finder: Ctrl-R history, Ctrl-T files, Alt-C cd. Themed by Stylix.
    programs.fzf.enable = true;
  };
}
