{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # build essential
    gcc
    autoconf
    automake
    libtool
    flex
    bison
    libiconv
    gnumake
    # texinfo # maybe has conflicts
    pkg-config
  ];
}


