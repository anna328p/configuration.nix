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
	name="$1"; shift
	nix run --impure "nixpkgs#""$name" -- "$@"
}
