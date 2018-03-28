Skeleton project for AWS Lambda functions in Python, deployed using Serverless
==============================================================================

Use this project as a starting point when you want to write an AWS Lambda
function (or collection of functions) in Python. It assumes that you are using
Python 3.6.

## Prerequisites (on your computer or build server):

 * Python 3.6
   * virtualenv
   * pip
 * Node.js
   * npm
 * GNU make

Any other dependencies (including Serverless) will be installed by the makefile.

## Getting started

Clone this project onto your hard drive:

    git clone https://github.com/ukparliament/lambda-template.git

Create a new empty repository on GitHub (you probably don't want to clone this
project directly, as you want it to be a separate entity). Then change the
origin to point to the URL of your new repository:

    git remote set-url origin git@github.com:ukparliament/your-new-project.git

Edit the following file to configure a name for your Serverless project and
your Lambda functions, and to reconfigure any triggers, IAM permissions, VPC
settings etc:

 * src/serverless.yml

Make whatever other changes are necessary, then push:

    git push origin master

## Project layout

Source code for your lambda function is in the `src` directory. Your unit tests
go in `src/tests`.

## Testing

Run `make test` to run your unit tests.
Run `make deploy` to deploy your project to AWS Lambda.

## Caveats

Note that you should use absolute rather than relative imports when importing
modules and packages in your own code into your tests.

DO NOT add an `__init__.py` file to the `src` directory or your unit tests may
break.