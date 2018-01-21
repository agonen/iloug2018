# AWS Lambda with cx_Oracle

This repository provides the basis for using the [cx_Oracle](http://cx-oracle.sourceforge.net/) Python module in
an AWS Lambda. 

## 0. Pre-requisites 

1. You need access to a Docker server. This code was prepared using v1.12.3 of the Docker OS X application.
1. It's reasonable to assume that you have an Oracle 11/12 RDS database running in your VPC. Make sure you have an Oracle
user with connection privileges and that you have defined your Security Group(s) for the Oracle instance such that 
it can be accessed from another security group (one you'll run your lambda in).

NOTE: This code was tested and run on an OS X system.

## 1. Build the deployment

1. Download the following [Instant Client Downloads for Linux x86-64](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html)
    and place them into the `cx_Oracle-packager/rpms` directory:
    1. Instant Client Package - Basic (rpm)
    1. Instant Client Package - SDK (rpm)
1. Run `./build.sh` to create the lambda deployment package. This will appear in the `dist` directory.

I use a Docker-based approach to building the required libraries. Alternatively, you could perform this task in an 
EC2 instance - just follow the appropriate parts from `cx_Oracle-packager/Dockerfile`. AWS provide an AMI for the 
Lambda host so that's a useful one to use - just search the marketplace/AMI list for "lambda".

### References

Packaging cx_Oracle for Lambda isn't much fun and I acknowledge the following resources in lighting the way:

- http://stackoverflow.com/questions/37734748/aws-python-lambda-with-oracle
- http://stackoverflow.com/questions/39201869/aws-python-lambda-with-oracle-oid-generation-failed

## 2. Create the lambda 

First of all, you need to put the `dist/lambda.zip` file into an S3 bucket. Create a new bucket or use an existing one -
you just need to upload the `lambda.zip` file to the bucket.

Next, we'll create an IAM Role for the lambda:

1. Head to the IAM section of the AWS web console and open the Roles screen
1. Click "Create New Role"
1. Configure your role as follows:
    1. Give the role a useful name
    1. For "Select Role Type", select "AWS Lambda"
    1. For "Attach Policy", select "AWSLambdaVPCAccessExecutionRole"

Finally, let's put the lambda together:

1. Head to the Lambda section of the AWS web console and click on the "Create a Lambda function" button
1. Select the "Blank Function" option in the next screen
1. Don't worry about configuring a trigger in the "Configure triggers" screen, just click "Next"
1. On the "Configure function" screen, use the following items:
    1. Name: _cx_Oracle_Test_
    1. Runtime: _Python 2.7_
    1. Lambda function code
        1. Code entry type: _Upload a file from Amazon S3_
            - Enter the URL for your `lambda.zip` file in S3
        1. Environment variables:
            - LD_LIBRARY_PATH: `./lib`
            - ORACLE_HOME: `/var/task/lib`
            - HOSTALIASES: `/tmp/HOSTALIASES`
            - DB_USER: _\<value>_
            - DB_PASSWORD: _\<value>_
            - DB_HOSTNAME: _\<value>_
            - DB_PORT: _\<value>_
            - DB_DATABASE: _\<value>_
    1. Lambda function handler and role
        1. Handler: _lambda.handler_
        1. Role: Use the IAM Role you just created
    1. Advanced settings
        1. Memory: _128_
        1. Timeout: _30sec_
        1. VPC Configuration
            1. VPC: select appropriate
            1. Subnets: pick two subnets that can reach your Oracle instance
            1. Security groups: select one that gives you access to your Oracle instance
        1. KMS key: Use the default (_aws/lambda_)

### Security note
Whilst AWS encrypts the Lambda's environment settings _at rest_, you will have a running
lambda with an unencrypted password (`DB_PASSWORD`). You can encrypt the environment 
variables for better security and I'd suggest you look into this. Helpfully, the 
[lambda documentation](http://docs.aws.amazon.com/lambda/latest/dg/env_variables.html)
describes how to do this and the lambda console can also provide you with code to decrypt 
the environment variable inside your script. Don't forget that the role you use with your lambda
will need to be able to access the KMS `decrypt` function.

## 3. Test the lambda
Once you've created the lambda, you'll see a "Test" button in the lambda screen. 
Click on "Test" and just select the "Hello World" sample template. As the lambda described
here doesn't use any input beyond the environment variables, it's easy to test.

Click "Save and test" and let's see how you went.

If it all worked out, you should see the following entry in the "Execution result" section
of the screen:

````json
{
  "result": "success",
  "cx_Oracle.version": "5.2.1"
}
````

If the lambda failed, start by checking the "Log output" section of the screen. A successful
run will look as follows:

````
START RequestId: 3267420f-c193-11e6-864d-e70645597578 Version: $LATEST
[INFO]	2016-12-14T00:21:06.242Z	3267420f-c193-11e6-864d-e70645597578	LD_LIBRARY_PATH: ./lib
[INFO]	2016-12-14T00:21:06.242Z	3267420f-c193-11e6-864d-e70645597578	ORACLE_HOME: /var/task/lib
[INFO]	2016-12-14T00:21:06.242Z	3267420f-c193-11e6-864d-e70645597578	Connecting to the database
[INFO]	2016-12-14T00:21:06.323Z	3267420f-c193-11e6-864d-e70645597578	Connecting to the database - success
END RequestId: 3267420f-c193-11e6-864d-e70645597578
REPORT RequestId: 3267420f-c193-11e6-864d-e70645597578	Duration: 85.60 ms	Billed Duration: 100 ms 	Memory Size: 128 MB	Max Memory Used: 19 MB	
````

If you had no joy, the key items to check are:

1. Are your `DB_*` environment variables correct - i.e. is it the correct username/password
    for the Oracle user?
1. Does the IAM role have the correct privileges
1. Does your security role have access to the Oracle instance?
1. Are NACLs set that are stopping access to the Oracle port?
1. Are your chosen subnets able to communicate with the subnet(s) in which the 
    Oracle instance is running?

## Next steps
Obviously this just gets you to a point where you have a framework for working with lambda and Oracle databases. From
here you can start to prepare useful lambdas for a range of purposes but take a quick read of the 
[Best Practices](http://docs.aws.amazon.com/lambda/latest/dg/best-practices.html) guide - you'll notice that moving the
database connection out of the lambda function is a good first step.

Enjoy!
