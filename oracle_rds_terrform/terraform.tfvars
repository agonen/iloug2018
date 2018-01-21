
# AWS setting
identifier                          = "oraclepoc"
name                                = "DEMODB"
vpc_security_group_ids=[""]
iam_database_authentication_enabled = false
vpc_id = ""
region = ""
 # DB subnet group

tags = { owner = "amihay", goal = "oracle poc" }
maintenance_window     = "Mon:00:00-Mon:03:00"
backup_window          = "03:00-06:00"
# disable backups to create DB faster
backup_retention_period = 0

# Oracle settings
username                            = "oracle"
engine            = "oracle-ee"
engine_version    = "12.1.0.2.v8"
instance_class    = "db.t2.medium"
allocated_storage = 10
storage_encrypted = false
license_model     = "bring-your-own-license"
port                                = "1521"
multi_az        = true

# DB parameter group
family = "oracle-ee-12.1"

#Lambda setting
s3_lambda_bucket=""
s3_lambda_key="oracle_demo_lambda.zip_1.12"
