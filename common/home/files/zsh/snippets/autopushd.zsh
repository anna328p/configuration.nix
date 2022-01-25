DIRSTACKFILE="$HOME/.cache/zsh/dirs"

[ ! -d $(dirname $DIRSTACKFILE) ] || mkdir -p $(dirname $DIRSTACKFILE)

if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1]
fi
setopt clobber
function chpwd {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}

DIRSTACKSIZE=20

setopt AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME

# Remove duplicate entries
#setopt PUSHD_IGNORE_DUPS

# This reverts the +/- operators.
#setopt PUSHD_MINUS
