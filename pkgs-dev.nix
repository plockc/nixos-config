{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    neovim
    git
    go
    yq
    jq
    python3
    zig # systems programming language
    vscode
  ];
}

