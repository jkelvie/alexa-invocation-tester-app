#!/bin/bash

# COLORS
RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
CYAN='\033[00;36m'

# GET INPUT
#printf "You entered: $@"
#printf "${CYAN}Enter invocation name:\n>> $RESTORE" 
invocation=$@
lc=$(tr '[:upper:]' '[:lower:]'<<<${invocation})
echo "-------------" >> results.txt
echo "INVOCATION NAME: $lc" >> results.txt

# CHECK AGAINST INVOCATION NAME GUIDELINES
printf "\n${YELLOW}CHECKING YOUR INVOCATION NAME AGAINST ALEXA GUIDELINES$RESTORE\n"
# Longer than 1 word?
numWords=$(IFS=' '; set -f; set -- $lc; echo $#)

if [ $numWords == 1 ]; then
  printf "${RED}ERROR: Invocation name must be more than 1 word\n$RESTORE"
  echo "ERROR: Invocation name must be more than 1 word" >> results.txt 
  exit 1
fi

# Contains reserved keywords?
declare -a keywords=("open"
  "launch" 
  "ask"
  "tell"
  "load"
  "begin"
  "enable"
  "to"
  "from"
  "by"
  "if"
  "whether"
  "news"
  "amazon"
  "alexa"
  "echo"
  "skill"
  "app"
  "update"
  "briefing"
)
declare -a twoWords=("the" 
  "a"
  "an"
  "for"
  "to"
  "of"
)
for word in $lc
do

  for i in "${keywords[@]}"
  do
    #echo "checking for $i"
    if [[ $word = "$i" ]]; then
      printf "${RED}ERROR: Invocation name contains reserved keyword: $i\n$RESTORE"
      echo "ERROR: Invocation name contains reserved keyword: $i" >> results.txt 
      exit 1
    fi
  done

done

# Check 2 word conditions
if [ $numWords == 2 ]; then 
  read first _ <<< "$lc"
  for i in "${twoWords[@]}"
  do
    #echo "checking for $i"
    if [[ $first = "$i" ]]; then
      printf "${RED}ERROR: Invocation name starts with article or preposition: $i\n$RESTORE"
      echo "ERROR: Invocation name starts with article or preposition: $i" >> results.txt 
      exit 1
    fi
  done
fi

printf "${GREEN}OK, your invocation name is: $lc\n$RESTORE"

# UPDATE INVOCATION NAME (interaction model & lambda)
printf "\n${YELLOW}UPDATING INTERACTION MODEL\n$RESTORE"
jq ".interactionModel.languageModel.invocationName = \"$lc\"" /home/node/app/models/en-US.json > en-US.json

#printf updating interaction model
ask api update-model --skill-id "amzn1.ask.skill.83f2fa62-6266-43ab-a438-56b6ccd422f0" \
--file "en-US.json" \
--locale "en-US" \
--profile SL > /dev/null 2>&1 #direct output to null, to cut down on terminal output #\
#--debug

printf "\n${YELLOW}UPDATING LAMBDA\n$RESTORE"
aws lambda update-function-configuration \
--function-name "arn:aws:lambda:us-east-1:321192638146:function:alexa-invocation-tester" \
--environment Variables={invocation="\"$lc\""} > /dev/null 2>&1 #direct output to null, to cut down on terminal output

# SLEEP 60s, so our model actually updates
printf "\n${YELLOW}WAITING 60s FOR MODEL TO UPDATE\n$RESTORE"
sleep 60

printf "\n${YELLOW}OK, MODEL SHOULD BE UP TO DATE\n$RESTORE"

# RUN SIMULATIONS ON VIRTUAL ALEXA
printf "\n${YELLOW}RUNNING SIMULATIONS\n$RESTORE"

declare -a tests=("open $lc"
  "what's the latest from $lc" 
  "what's the latest from the $lc"
)
for test in "${tests[@]}"
do
  echo "" >> results.txt
  printf "\nTest ${CYAN}[$test] $RESTORE\n"
  result=$(bst speak "alexa, $test" | sed -n 4p)

  echo "Test [$test]" >> results.txt 
  echo "RESULT ($result)" >> results.txt 
  if [[ "$result" == "welcome to "* ]]; then
    printf "${GREEN}PASSED!\n$RESTORE"
    echo "RESULT ($result) PASSED!" >> results.txt 
  else 
    printf "${RED}FAILED\n$RESTORE"
    echo "RESULT ($result) FAILED" >> results.txt 
  fi
  
done

# MANUAL DEBUG
#printf "${CYAN}[open $lc]\n$RESTORE"
#bst speak "alexa, open $lc"

#printf "${CYAN}[what's the latest from $lc]\n$RESTORE"
#bst speak "alexa, what's the latest from $lc"

#printf "${CYAN}[what's the latest from the $lc]\n$RESTORE"
#bst speak "alexa, what's the latest from the $lc"

exit 0