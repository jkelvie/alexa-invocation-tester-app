#!/bin/bash

printf "**SETTING ENV VARIABLES & ALIASES**\n\n"
# set env variables


# useful aliases
alias invoke="/home/node/app/invoke.sh"
alias rel="source /entrypoint.sh"
alias k="clear"
alias ..="cd .."
alias ~="cd ~"
alias py=python

# git aliases
alias gc="git commit -m"
alias gca="git commit -am"
alias gs="git status"
alias gp="git push"
alias gpp="git push -u origin master"
alias gd="git diff"
alias ga="git add"
alias gaa="git add ."
alias gr="git rm"
alias gb="git checkout -b"

# COLORS
RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
LIGHTGRAY='\033[00;37m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'

## FUNCTIONS

# tail logs from aws
function awslog {
  if [[ $1 == "google" ]]; then
    awslogs get /aws/lambda/google-branded-fulfillments --watch  --profile "$2"
  fi

  if [[ $1 == "alexa" ]]; then 
    awslogs get /aws/lambda/alexa-branded-fulfillments --watch  --profile "$2"
  fi
}

printf "**WELCOME TO THE SPOKENLAYER ALEXA SKILL MANAGEMENT SERVER**\n\n"
exec "$@"