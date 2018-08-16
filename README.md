# Alexa invocation name tester 

The primary purpose of this container is to use the aws / ask / bespoken toolchains to test our alexa invocation names for SpokenLayer's interactive branded alexa skills.

It is also a prototype for a general Alexa Skill Management Server (asms)


## INSTRUCTIONS

### Step 1: Setup Local CLI / Credentials
1. Locally install & setup the AWS CLI, the ASK CLI, the bespoken.io CLI, and jq.
2. Initialize all three CLIs with proper credentials

### Step 2: Setup Lambda function & Alexa Skill
1. Create a new lambda using AWS CLI (example command below) and the files in `/lambda` and note down the lamda arn
  ```
  aws lambda create-function \
  --region region \
  --function-name alexa-invocation-tester \
  --zip-file fileb://lambda/Archive.zip \
  --role role-arn \
  --handler index.handler \
  --runtime nodejs8.10 \
  --profile adminuser 
  ```

2. Update `skill/skill.json` with your new lambda arn
3. Create a new Alexa Skill using the ASK CLI & the json manifests in `/skill`
  ```
  ask api create-skill --file "skill/skill.json" --profile PROFILE --debug
  ask api update-model --skill-id "amzn1.foo.bar" --file "skill/en-US.json" --locale "en-US" --profile PROFILE --debug
  ```

4.  Enable your Alexa Skill for testing using the ASK CLI or web console
  ```
  ask api enable-skill --skill-id "amzn1.foo.bar" --profile PROFILE --debug
  ```

5. [Link your Lambda & Alexa Skill](https://developer.amazon.com/docs/custom-skills/host-a-custom-skill-as-an-aws-lambda-function.html#add-ask-trigger) within the AWS Lambda console so can talk to each other


### Step 3: Build & Run Docker image
1. Copy contents of `~/.aws` to `/aws-config`
2. Copy contents of `~/.ask` to `/ask-config`
3. Copy contents of `~/.bst` to `/bst-config`
4. Rename the `.env.example` file to `.env` and update the `SKILLID`, `LAMBDAID`, and `PROFILE` variables with your skill id, lambda arn, and ask profile name
5. Build the docker container: `docker build -t asms .`
6. Launch the docker container: 
  ```
  docker run --name asms -it --rm \
  -p 80:5000 \
  -v $(pwd)/ask-config:/home/node/.ask \
  -v $(pwd)/aws-config:/home/node/.aws \
  -v $(pwd)/bst-config:/home/node/.bst \
  --env-file ./.env \
  asms"
  ```

### Step 4. Test it out!

Go to [http://localhost:80](http://localhost:80) in your browser and test an invocation name. Wash. Repeat.

## Links:

- [ASK CLI Quickstart](https://developer.amazon.com/docs/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
- [ASK CLI Full Doc](https://developer.amazon.com/docs/smapi/ask-cli-intro.html#alexa-skills-kit-command-line-interface-ask-cli)

