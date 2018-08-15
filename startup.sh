#!/bin/bash

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
#exec "$@"
python app.py