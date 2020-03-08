#!/bin/bash

declare -A patterns=(
    ["RSA private key"]="-----BEGIN RSA PRIVATE KEY-----"
    ["SSH (DSA) private key"]="-----BEGIN DSA PRIVATE KEY-----"
    ["SSH (EC) private key"]="-----BEGIN EC PRIVATE KEY-----"
    ["PGP private key"]="-----BEGIN PGP PRIVATE KEY BLOCK-----"
    ["Access token"]="[aA][cC][cC][eE][sS][sS]_?[tT][oO][kK][eE][nN].*"
    ["Unknown secret"]="[sS][eE][cC][rR][eE][tT].*[\'\\\"]"
    ["Unknown API key"]="[aA][pP][iI][_]?[kK][eE][yY].*[\'\\\"]"
    ["HTTP auth creds"]="[a-zA-Z]{3,10}:\\\/\\\/[^\\\\\\\\\/ @]{3,10}:[^\\\\\\\\\/ @]{3,10}@[^\\\\\\\\\/ @]{3,10}\\\/?"
    ["AWS API key"]="AKIA[0-9A-Z]{16}"
    ["Heroku API key"]="[hH][eE][rR][oO][kK][uU].*[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}"
);

clone_dir=$(mktemp -d)

if ! git clone $1 $clone_dir; then
    exit;
fi;

for f in $(find $clone_dir -type f); do
    for classification in "${!patterns[@]}"; do
        if grep -q -e "${patterns[$classification]}" $f; then
            echo -e "\e[33m$f\t\e[31m$classification\e[0m";
            grep -n -e "${patterns[$classification]}" $f;
        fi;
    done;
done;

echo "done!"
