#!/bin/bash

# GET INPUT
invocation=$@
lc=$(tr '[:upper:]' '[:lower:]'<<<${invocation})

# CHECK AGAINST INVOCATION NAME GUIDELINES
#printf "<p>CHECKING YOUR INVOCATION NAME AGAINST ALEXA GUIDELINES</p>"
# Longer than 1 word?
numWords=$(IFS=' '; set -f; set -- $lc; echo $#)

if [ $numWords == 1 ]; then
  printf "<p class=\"red\">ERROR: Invocation name must be more than 1 word</p>"
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
    if [[ $word = "$i" ]]; then
      printf "<p class=\"red\">ERROR: Invocation name contains reserved keyword: $i</p>"
      exit 1
    fi
  done

done

# Check 2 word conditions
if [ $numWords == 2 ]; then 
  read first _ <<< "$lc"
  for i in "${twoWords[@]}"
  do
    if [[ $first = "$i" ]]; then
      printf "<p class=\"red\">ERROR: Invocation name starts with article or preposition: $i</p>"
      exit 1
    fi
  done
fi

printf "<p>Your invocation name: <span class=\"purple\">$lc</span></p>"

# UPDATE INVOCATION NAME & LAMBDA (interaction model & lambda)
jq ".interactionModel.languageModel.invocationName = \"$lc\"" /home/node/app/models/en-US.json > en-US.json

ask api update-model --skill-id "amzn1.ask.skill.83f2fa62-6266-43ab-a438-56b6ccd422f0" \
--file "en-US.json" \
--locale "en-US" \
--profile SL > /dev/null 2>&1 #direct output to null, to cut down on terminal output #\
#--debug

aws lambda update-function-configuration \
--function-name "arn:aws:lambda:us-east-1:321192638146:function:alexa-invocation-tester" \
--environment Variables={invocation="\"$lc\""} > /dev/null 2>&1 #direct output to null, to cut down on terminal output

# SLEEP 60s, so our model actually updates
sleep 60

# RUN SIMULATIONS ON VIRTUAL ALEXA
#printf "<p>RUNNING SIMULATIONS</p>"

declare -a tests=(
  "open $lc"
  "what's the latest from $lc" 
  "what's the latest from the $lc"
)
for test in "${tests[@]}"
do
  sleep 5
  printf "<p>Test: <span class=\"cyan\"><em>$test</em></span></p>"
  result=$(bst speak "alexa, $test" | sed -n 4p)

  if [[ "$result" == "welcome to "* ]]; then
    printf "<p class=\"green\">PASSED!</p>"
  else 
    printf "<p class=\"red\">FAILED</p>"
  fi
  
done
exit 0