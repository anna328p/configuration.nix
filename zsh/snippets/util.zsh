function mkcd {
  mkdir -p $* && cd $*
}

function rain {
  curl -s https://isitraining.in/Sammamish | grep result | grep -oP '(?<=\>).+(?=\<)' --color=never
}

function scratch {
  mkdir -p "$HOME/Documents/scratch"
  if [ -z "$1" ]; then
    nvim "$HOME/Documents/scratch"
  else
    nvim "$HOME/Documents/scratch/$1.md"
  fi
}

function psgrep {
  ps aux | grep -v grep | grep $*
}

function try {
  until bash -c "$*"; do
    sleep 2
  done
}
