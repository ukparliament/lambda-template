.PHONY: build-tools deploy docker-image

ACCOUNT_ID = $(shell aws sts get-caller-identity | jq -r '.Account')
ACCOUNT_ALIAS = $(shell aws iam list-account-aliases | jq -r '.AccountAliases[0]')
CURRENT_REGION = $(shell aws configure get region)
CREDSTASH_KEY = $(shell \
	aws kms describe-key --key-id arn:aws:kms:$(CURRENT_REGION):$(ACCOUNT_ID):alias/credstash | \
	jq -r '.KeyMetadata.Arn' \
)

.venv:
	virtualenv -p python3 .venv
	.venv/bin/pip install -r ./src/requirements.txt

node_modules/serverless:
	npm install serverless

node_modules/serverless-python-requirements:
	npm install serverless-python-requirements

node_modules/serverless-vpc-discovery:
	npm install serverless-vpc-discovery

docker-image:
	docker pull lambci/lambda:build-python3.6

build-tools: \
	.venv \
	node_modules/serverless \
	node_modules/serverless-python-requirements \
	node_modules/serverless-vpc-discovery

deploy: build-tools
	cd src && ../node_modules/.bin/serverless deploy \
		--account-alias $(ACCOUNT_ALIAS) \
		--credstash-key $(CREDSTASH_KEY)

src/test-requirements.txt: .venv
	.venv/bin/pip install -r src/test-requirements.txt

test: src/test-requirements.txt
	bash -c "source .venv/bin/activate && cd src && pytest tests"