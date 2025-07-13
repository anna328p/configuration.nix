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

function nr {
	env NIXPKGS_ALLOW_UNFREE=1 nix run --impure "$@"
}

function nrn {
	local name="$1"; shift
	nr "nixpkgs#""$name" "$@"
}

function gman {
	local filename=$(basename $(man -w "$@"))
	local tmp=$(mktemp -t gman-"${filename%*.}"-XXXXXX.pdf)

	man -Tps "$@" | ps2pdf - "$tmp"
	papers "$tmp"
}