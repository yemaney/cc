#!/bin/bash

function usage {
    cat << EOF
cc is bash script, designed to help with creating conventional commit messages.

<type>(<scope>): <short summary>

Usage: cc

Available options:
-h, --help      Print this help and exit
EOF
    
    exit
}

function type_menu {

mapfile -d '' EXAMPLE << 'EOF'
Select a <type>

0.  \e[36;1mbuild\e[0m:      Changes that affect the build system or external dependencies
1.  \e[36;1mchore\e[0m:      Ad-hoc task that doesn't match other types
2.  \e[36;1mci\e[0m:         Changes to our CI configuration files and scripts
3.  \e[36;1mdocs\e[0m:       Documentation only changes
4.  \e[36;1mfeat\e[0m:       A new feature
5.  \e[36;1mfix\e[0m:        A bug fix
6.  \e[36;1mperf\e[0m:       A code change that improves performance
7.  \e[36;1mrefactor\e[0m:   A code change that neither fixes a bug nor adds a feature
8.  \e[36;1mrevert\e[0m:     If changes are reverted
9.  \e[36;1mstyle\e[0m:      Styling changes that don't affect the code performance or behavior
10. \e[36;1mtest\e[0m:       Adding missing tests or correcting existing tests
EOF

    echo -e  "$EXAMPLE"

    return 0
}

function get_type_number {
    while :; do
    read -p "Enter a number between 0 and 10: " TYPE_NUMBER
    [[ $TYPE_NUMBER =~ ^[0-9]+$ ]] || { echo "Enter a valid number $TYPE_NUMBER"; continue; }
    if ((TYPE_NUMBER >= 0 && TYPE_NUMBER <= 10)); then
        break
    else
        echo "number out of range, try again"
    fi
    done

}

function get_type {


    case "$TYPE_NUMBER" in
        0) TYPE=build ;;
        1) TYPE=chore ;;
        2) TYPE=ci ;;
        3) TYPE=docs ;;
        4) TYPE=feat ;;
        5) TYPE=fix ;;
        6) TYPE=perf ;;
        7) TYPE=refactor ;;
        8) TYPE=revert ;;
        9) TYPE=style ;;
        10) TYPE=test ;;
        esac
    return 0
}

function get_scope {
    read -p "Enter an optional <scope> " SCOPE
}

function get_summary {

while :; do
  read -p "Enter a summary: " SUMMARY
  [[ -n $SUMMARY ]] || { echo "Enter a summary $SUMMARY"; continue; }
  break
done
}

function make_commit {
    git diff --name-status --staged 
    
    echo -e "
Potential commit message:

\e[36;1m$message\e[0m
    "
    read -p "Commit these changes with the message [y/N]: "
    
    case $REPLY in
        Y | y)
            git commit -m "$emoji : $message"
        ;;
        *)
            exit 1
        ;;
    esac

}

function create_cc_message {
    
    type_menu
    get_type_number
    get_type
    get_scope
    get_summary


    if [[ -n $SCOPE ]]; then
        message="$TYPE($SCOPE): $SUMMARY"
    else
        message="$TYPE: $SUMMARY"
    fi

    clear

    make_commit
    return 0
}

function die { # exit the program and print a message when an erorr has occurred
    msg=$1
    echo -e "$msg"
    exit 1
}


function parse_params {
    while :; do
        case "${1-}" in
            -h | --help) usage ;;
            -?*)
                 die "\e[31;1mError\e[0m: $1 is an invalid option:. Try \e[32;1mcc -h\e[0m for more information.";;
            *) create_cc_message
                break ;;
        esac
        shift
    done
    

    # args=("$@")
    
    # make_commit
}

parse_params "$@"