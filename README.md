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
1. Rename the `.env.example` file to `.env` and update the `SKILLID`, `LAMBDAID`, and `PROFILE` variables with your skill id, lambda arn, and ask profile name
2. Build the docker image: `docker build -t asms .`
3. Run the container by passing in your env variables + ask/aws/bst credentials and forwarding the server to your local machine at port 80: 
  ```
  docker run --name asms -it --rm \
  -p 80:5000 \
  -v ~.aws:/home/node/.ask \
  -v ~.ask:/home/node/.aws \
  -v ~.bst:/home/node/.bst \
  --env-file ./.env \
  asms"
  ```

### Step 4. Test it out!

1. Go to [http://localhost:80](http://localhost:80) in your browser and test an invocation name. Tests can take 3-4 minutes, so please be patient. 
2. Test the invocation name on a physical device linked to your amazon dev / ASK account. Sometimes the 1st test fails due to timing, but passes IRL.
3. Press the 'test another invocation' button. Wash. Repeat.
4. Since you are modifying a real lambda/alexa skill, you can only run 1 test at a time. If you need to cancel an inprogress test or get stuck in a "another test is running" situation, go to [http://localhost:80/reset](http://localhost:80/reset) to reset the app and try again.

## Links:

- [ASK CLI Quickstart](https://developer.amazon.com/docs/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
- [ASK CLI Full Doc](https://developer.amazon.com/docs/smapi/ask-cli-intro.html#alexa-skills-kit-command-line-interface-ask-cli)

