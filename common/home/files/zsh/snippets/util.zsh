function mkcd {
  mkdir -p $* && cd $*
}

function try {
  until bash -c "$*"; do
    sleep 2
  done
}

function psgrep {
  ps aux | grep -v grep | grep "$@"
}

function nrn {
	nix run --impure "nixpkgs#""$*"
}
