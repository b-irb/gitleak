#!/bin/bash

usage () {
    printf -- "USAGE: $0 [OPTIONS] [TEXT]\n\nOPTIONS\n\n"
    printf -- "\t-r  Clone and scan specified remote git repository.\n"
    printf -- "\t-d  Scan specified local directory.\n"
    exit;
}

if [ $# -lt 2 ]; then
    usage
fi;

case "$1" in
    "-r")
        repo_dir=$(mktemp -d);
        if ! git clone $2 $repo_dir; then
            exit;
        fi;;
    "-d") repo_dir=$2;;
    *) usage;;
esac

declare -A patterns=(
    ["RSA private key"]="-----BEGIN RSA PRIVATE KEY-----"
    ["SSH (DSA) private key"]="-----BEGIN DSA PRIVATE KEY-----"
    ["SSH (EC) private key"]="-----BEGIN EC PRIVATE KEY-----"
    ["OpenSSH private key"]="-----BEGIN OPENSSH PRIVATE KEY-----"
    ["PGP private key"]="-----BEGIN PGP PRIVATE KEY BLOCK-----"
    ["Access token"]="[aA][cC][cC][eE][sS][sS]_?[tT][oO][kK][eE][nN].*[\'\\\"]"
    ["Password"]="(.*_)?[pP][aA][sS]{2}([wW]([oO][rE])?[dD])?.*[\'\\\"]"
    ["Unknown secret"]="[sS][eE][cC][rR][eE][tT].*[\'\\\"]"
    ["Unknown API key"]="[aA][pP][iI][_]?[kK][eE][yY].*[\'\\\"]"
    ["HTTP auth creds"]="[a-zA-Z]{3,10}:\\\/\\\/[^\\\\\\\\\/ @]{3,10}:[^\\\\\\\\\/ @]{3,10}@[^\\\\\\\\\/ @]{3,10}\\\/?"
    ["AWS API key"]="AKIA[0-9A-Z]{16}"
    ["Heroku API key"]="[hH][eE][rR][oO][kK][uU].*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"
);

echo "scanning $repo_dir"

for f in $(find $repo_dir -type f); do
    for classification in "${!patterns[@]}"; do
        if grep -q -e "${patterns[$classification]}" $f; then
            echo -e "\e[33m$f\t\e[31m$classification\e[0m";
            grep -n -e "${patterns[$classification]}" $f;
        fi;
    done;
done;

echo "done!"
