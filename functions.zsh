mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside
trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf $1;;
            *.tar.gz) tar xvzf $1;;
            *.tar.xz) tar xvJf $1;;
            *.tar.lzma) tar --lzma xvf $1;;
            *.bz2) bunzip $1;;
            *.rar) unrar $1;;
            *.gz) gunzip $1;;
            *.tar) tar xvf $1;;
            *.tbz2) tar xvjf $1;;
            *.tgz) tar xvzf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *.7z) 7z x $1;;
            *.dmg) hdiutul mount $1;; # mount OS X disk images
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

#   cdf:  'Cd's to frontmost window of MacOS Finder
#   ------------------------------------------------------
cdf () {
    currFolderPath=$( /usr/bin/osascript <<EOF
        tell application "Finder"
            try
        set currFolder to (folder of the front window as alias)
            on error
        set currFolder to (path to desktop folder as alias)
    end try
            POSIX path of currFolder
        end tell
EOF
)
echo "cd to \"$currFolderPath\""
cd "$currFolderPath"
}

httpHeaders () { /usr/bin/curl -I -L $@ ; }             # httpHeaders:      Grabs headers from web page

# -------------------------------------------------------------------
# any function from http://onethingwell.org/post/14669173541/any
# search for running processes
# -------------------------------------------------------------------
any() {
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if [[ -z "$1" ]] ; then
        echo "any - grep for process(es) by keyword" >&2
        echo "Usage: any " >&2 ; return 1
    else
        ps xauwww | grep -i --color=auto "[${1[1]}]${1[2,-1]}"
    fi
}

command_not_found_handler() {
    # Do not run within a pipe
    if test ! -t 1; then
        >&2 echo "command not found: $1"
        return 127
    fi
    if [ `echo $1 | cut -b1-3` = "git" ]
    then
        first=$1
        shift
        echo Autocorrecting to: git `echo $first | sed 's/git//'`$*
        git `echo $first | sed 's/git//'`$*
        return 0
    fi

    >&2 echo "command not found: $1"
    return 1
}

gocover () {
    t="/tmp/go-cover.$$.tmp"
    go test -coverprofile=$t && go tool cover -html=$t && unlink $t
}

gouncover () {
    if [ "$1" = "" ]
    then
        echo "Usage: gouncover [FuncName]"
    fi
    t="/tmp/go-cover.$$.tmp"
    go test -coverprofile=$t && uncover $t $1 && unlink $t
}

rmake () {
    origdir=`pwd`
    while [[ ! -f ./Makefile && ! `pwd` == "/" ]]; do cd ../ ; done
    if [[ -f ./Makefile ]]; then
        make $@
    else
        echo "Couldn't find a makefile"
    fi
    cd $origdir
}
alias m=rmake
