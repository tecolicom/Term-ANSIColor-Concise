#!/usr/bin/env bash

mydir="${0%/*}"; . $mydir/getoptlong.sh

set -eu

help() {
    cat <<-END
	repeat count command
	repeat [ options ] command
	    -c#, --count=#    repeat count
	    -i#, --sleep=#    interval time
	    -p , --paragraph  print newline after command
	    -x , --trace      trace execution (set -x)
	    -d , --debug      debug mode
	END
    exit 0
}
trace() {
    [[ $1 ]] && set -x || set +x
}

declare -A OPT=(
    [ count     | c : ]=1
    [ sleep     | i : ]=
    [ paragraph | p   ]=
    [ trace     | x   ]=
    [ debug     | d + ]=
    [ help      | h   ]=
)
tgl_setup OPT DEBUG=
tgl_callback help - trace -
getoptlong "$@" && shift $((OPTIND - 1))

case ${1:-} in
    [0-9]*) OPT[count]=$1 ; shift ;;
esac

while (( OPT[count]-- ))
do
    eval "${@@Q}"
    if (( OPT[count] > 0 ))
    then
	[[ ${OPT[paragraph]} ]] && echo
	[[ ${OPT[sleep]} ]] && sleep ${OPT[sleep]}
    fi
done
