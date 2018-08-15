# Alexa invocation name tester 

The primary purpose of this container is to use the aws / ask / bespoken toolchains to test our alexa invocation names for SpokenLayer's interactive branded alexa skills.

It is also a prototype for a general Alexa Skill Management Server (asms)


## SETUP

0. Install & setup the AWS CLI, the ASK CLI, the bespoken.io CLI, and jq.
1. Initialize all three CLIs with proper credentials
2. Clone this repo
3. Copy the contents of ~/.aws to /aws-config
4. Copy the contents of ~/.ask to /ask-config
5. Copy the contents of ~/.bst to /bst-config
6. Create a new lambda using AWS CLI & the files in `/lambda` or by creating a new node lambda in the AWS console and uploading `Archive.zip`
7. Create a new Alexa Skill using the ASK CLI & the json manifests in `/skill`.
8. Enable your Alexa Skill for testing using the ASK CLI
9. Link your Lambda & Alexa Skill within the AWS console so one can trigger the other.
10. Build the docker container: `docker build -t asms .`
11. Launch the docker container: 
  ```
  docker run --name asms -it --rm \
  -p 80:5000 \
  -v $(pwd)/ask-config:/home/node/.ask \
  -v $(pwd)/aws-config:/home/node/.aws \
  -v $(pwd)/bst-config:/home/node/.bst \
  -v $(pwd)/app:/home/node/app \
  --env-file ./.env \
  asms"
  ```
12. Go to localhost in your browser and test an invocation name

## Links:

- [ASK CLI Quickstart](https://developer.amazon.com/docs/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
- [ASK CLI Full Doc](https://developer.amazon.com/docs/smapi/ask-cli-intro.html#alexa-skills-kit-command-line-interface-ask-cli)

