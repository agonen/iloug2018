Serverless Oracle Demo 
========================

This repo is for [ILOUG TECH DAYS 2018](https://www.iloug.org)

It contains the following 
* [Terraform scripts](https://www.terraform.io)
* [AWS lambda code](lochttps://aws.amazon.com/lambda/)
* [scale testing framework - Locust](https://locust.io/)


Prerequisites  
--------------

* install terraform 
* setup requirement parameters in `oracle_rds_terrform/secret.tfvars` and `oracle_rds_terrform/terraform.tfvars`
* deploy lambda code 


Deploy 
---------------
Deploy lambda code 
```
  $ cd lambda_oracle
  $ zip -9 -r /tmp/lambda.zip ./*
  $ aws s3 cp /tmp/lambda.zip  s3://<YOUR BUCKET>/<YOUR KEY>
```

Deploy terraform code 

```
  $ cd oracle_rds_terrform
  $ terraform init
  $ terraform plan -var-file="secret.tfvars" -var-file="terraform.tfvars" -var region=us-west-2
  $ terraform apply
```


