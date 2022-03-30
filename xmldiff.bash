#!/bin/bash

\set -e
\set -u
\set -o pipefail

function main {
    test_deps
    parse_args "$@"
    echo $(diff_files 2>/dev/null | json_to_xml 2>/dev/null) | pretty_print
}

function pretty_print {
    if [ "{has_xmllint}" == 1 ] & [ "${has_batcat}" ] ; then
        echo $(cat -) | xmllint --format - | batcat --language xml --decorations never
    else
        if [ "{has_xmllint}" ==1 ] ; then
            echo $(cat -) | xmllint --format -
        fi
        if [ "${has_batcat}" == 1 ] ; then
            echo $(cat -) | batcat --language xml --decorations never
        fi
    fi
}

function json_to_xml {
    echo $(cat -) | python3 <(cat <<EOF
import sys, xmltodict
try:
    import ujson as json
except:
    import json
j = "".join(sys.stdin.readlines())
try:
    print(xmltodict.unparse(json.loads(j)))
except ValueError:
    print(xmltodict.unparse({"root":json.loads(j)}))
EOF
    )
}

function diff_files {
    diff <(gronify "${file_a}") <(gronify "${file_b}") \
        | grep -E '^> ' \
        | sed 's/^> //' \
        | gron --ungron
}

function parse_args {
    \set +u
    file_a="${1}"
    file_b="${2}"
    \set -u
    if [ "${file_a}" == "" ] & [ "${file_b}" == "" ]; then
        log_err "Please specify two files."
        exit 1
    fi
}

function log_err {
    \set +u
    \echo 'ERROR: '"$1" >&2
    \set +u
}

function log_reg {
    \set +u
    \echo "$1"
    \set -u
}

function test_deps {
    errors=0
    for c in diff grep gron jq python3 sed ; do
        if ! \command -v "${c}" 1>/dev/null 2>/dev/null ; then
            log_err "Cannot find command '${c}'. Please ensure it is installed and in your \$PATH."
            errors=$((errors+1))
        fi
    done

    if \command -v xmllint 1>/dev/null 2>/dev/null ; then
        has_xmllint=1
    else
        has_xmllint=0
    fi

    if \command -v batcat 1>/dev/null 2>/dev/null ; then
        has_batcat=1
    else
        has_batcat=0
    fi

    for python_dep in xmltodict ; do
        if ! python3 -c "import ${python_dep}" 2>/dev/null ; then
            log_err "Python cannot import ${python_dep}. Try: pip install ${python_dep}"
            errors=$((errors+1))
        fi
    done
    if [ "${errors}" != "0" ] ; then
        exit 1
    fi
}

function gronify {
    python3 - <<EOF  | jq --sort-keys . | gron
import xmltodict, os
try:
    import ujson as json
except:
    import json
with open(os.path.abspath("${1}"),'r') as f:
    print(json.dumps(xmltodict.parse(''.join(f.readlines()))))
EOF
}

main "$@"
