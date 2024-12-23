{
  inputs,
  pkgs,
  system,
  ...
}: {
  config,
  osConfig,
  ...
}: let
  explorer = "yazicd";
in {
  imports = [inputs.nvim.homeManagerModules.${system}.default];
  home = {
    inherit (osConfig.system) stateVersion;
    keyboard = {
      layout = osConfig.airgap.keymap;
    };
    file = {
      ".local/src/README.md" = {
        text = ''
          # Source Code / Packages

          - This is the home for all external source code and projects
          - run `rr` to cd into this directory
        '';
      };
      ".config/yazi/plugins/smart-enter.yazi/init.lua" = {
        text =
          /*
          lua
          */
          ''
            --- @sync entry
            return {
            	entry = function()
              local h = cx.active.current.hovered
            		ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
            	end,
            }
          '';
      };
      ".config/yazi/keymap.toml" = {
        text =
          /*
          toml
          */
          ''
            [[manager.prepend_keymap]]
            on   = [ "l" ]
            run  = "plugin smart-enter"
            desc = "Enter the child directory, or open the file"
          '';
      };
    };
    packages = with pkgs; [
      file
      ffmpegthumbnailer
      unar
      poppler
      jq
      fd
      ripgrep
      fzf
      zoxide
    ];
    sessionVariables = {
      EXPLORER = "${explorer}";
      EDITOR = "nvim";
    };
  };
  programs = {
    home-manager = {
      enable = true;
    };
    bat = {
      enable = true;
    };
    fzf = {
      enable = true;
    };
    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
        "--colors=line:style:bold"
      ];
    };
    yazi = {
      enable = true;
      settings = {
        manager = {
          show_hidden = true;
          show_symlink = false;
        };
        keymap = {
          "[manager.prepend_keymap]" = {
            on = ["l"];
            run = "plugin smart-enter";
            desc = "Enter the child directory, or open the file";
          };
        };
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 500;
        hostname = {
          style = "bold #ff5555";
        };
        username = {
          format = "[$user]($style) on ";
          show_always = true;
          style_user = "bold #bd93f9";
          style_root = "bright-red bold";
        };
        directory = {
          style = "bold #50fa7b";
          truncation_length = 6;
          truncate_to_repo = true;
          truncation_symbol = ".../";
        };
        line_break = {
          disabled = true;
        };
        cmd_duration = {
          style = "bold #f1fa8c";
        };
        git_branch = {
          format = "[$symbol](green)[$branch]($style)";
          style = "bold #ff79c6";
        };
        git_status = {
          format = "[$all_status$ahead_behind]($style) ";
          style = "bold #ff5555";
          conflicted = " ⚔️  ";
          ahead = " 🏎️ 💨 <== \${count}";
          behind = " 🐢 => \${count}";
          diverged = " 🔱 <== \${ahead_count} 🐢 => \${behind_count}";
          untracked = " 🛤️ -> \${count}";
          stashed = " 📦 ";
          modified = " 📝 => \${count}";
          staged = " 🗃️ -> \${count}";
          renamed = " 📛 <!= \${count}";
          deleted = " 🗑️ <!= \${count}";
        };
        nix_shell = {
          disabled = true;
          format = "via [$symbol]($style)";
          symbol = "❄️ ";
        };
        battery = {
          full_symbol = "🔋";
          charging_symbol = "🔌";
          discharging_symbol = "⚡";
        };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      autosuggestion = {
        enable = true;
      };
      autocd = true;
      completionInit = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "colored-man-pages"
          "colorize"
        ];
      };
      dotDir = ".config/zsh";
      shellAliases = with pkgs; {
        sudo = "sudo ";
        ls = "${eza}/bin/eza";
        nix-repl-flake = ''nix repl --expr "builtins.getFlake \"$PWD\""'';
        rr = "${explorer} $HOME/.local/src";
      };
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };
      historySubstringSearch = {
        enable = true;
      };
      initExtraBeforeCompInit = ''
        autoload -U colors && colors
      '';
      initExtra =
        /*
        bash
        */
        ''
          zstyle ':completion*' menu select
          bindkey -v
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
          bindkey -M menuselect 'j' vi-down-line-or-history
          bindkey -v '^?' backward-delete-char
          function zle-keymap-select () {
              case $KEYMAP in
                  vicmd) echo -ne '\e[1 q';;
                  viins|main) echo -ne '\e[5 q';;
              esac
          }
          zle -N zle-keymap-select
          zle-line-init() {
              zle -K viins
              echo -ne "\e[5 q"
          }
          zle -N zle-line-init
          echo -ne '\e[5 q'
          preexec() { echo -ne '\e[5 q' ;}
          lfcd () {
              tmp="$(mktemp -uq)"
              trap 'rm -f $tmp >/dev/null 2>&1' HUP INT QUIT TERM PWR EXIT
              lf -last-dir-path="$tmp" "$@"
              if [ -f "$tmp" ]; then
                  dir="$(cat "$tmp")"
                  [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
              fi
          }
          yazicd () {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
            yazi "$@" --cwd-file="$tmp"
            if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            	cd -- "$cwd"
            fi
            rm -f -- "$tmp"
          }
          bindkey -s '^o' '${explorer}\n'
          autoload edit-command-line; zle -N edit-command-line
          bindkey '^e' edit-command-line
          bindkey -M vicmd '^[[P' vi-delete-char
          bindkey -M vicmd '^e' edit-command-line
          bindkey -M visual '^[[P' vi-delete
          export ZSH_CACHE_DIR
        '';
      profileExtra =
        /*
        bash
        */
        ''
          export LESS=-R
          export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
          export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
          export LESS_TERMCAP_me="$(printf '%b' '[0m')"
          export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
          export LESS_TERMCAP_se="$(printf '%b' '[0m')"
          export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
          export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
        '';
    };
  };
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
    };
  };
  modules = {
    editor = {
      nixvim = {
        enable = true;
      };
    };
  };
}
