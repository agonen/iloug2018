provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
  name   = "default"
}


##################
# query lambda
##################
module "query_lambda" {
  source = "./modules/lambda"
  name = "oracle_query_demo"
  subnet_ids = ["${data.aws_subnet_ids.all.ids}"]
  vpc_id = "${data.aws_vpc.default.id}"
  s3_key = "${var.s3_lambda_key}"
  s3_bucket = "${var.s3_lambda_bucket}"
  handler = "${var.lambda_handler}"
  env =   {
    LD_LIBRARY_PATH = "./lib"
    ORACLE_HOME = "/var/task/lib"
    HOSTALIASES = "/tmp/HOSTALIASES"
    DB_USER = "${module.db_instance.this_db_instance_username}"
    DB_PASSWORD = "${module.db_instance.this_db_instance_password}"
    DB_PORT = "${module.db_instance.this_db_instance_port}"
    DB_DATABASE = "${module.db_instance.this_db_instance_name}"
    DB_HOSTNAME = "${module.db_instance.this_db_instance_address}"
  }
}

##################
# API gateway 
#################


# Create a resource

resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}


resource "aws_api_gateway_resource" "query" {
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.MyDemoAPI.root_resource_id}"
  path_part = "query"
}


# This is too wide permission th open for demo only prpouse 
resource "aws_lambda_permission" "allow_api_gateway" {
    function_name = "${module.query_lambda.lambda_name}"
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:*"
}

# Call the module to attach a method along with its request/response/integration templates
# This one creates a user.
data "aws_caller_identity" "current" {}

module "UsersQueries" {

  source  = "./modules/api_gateway_method"
  rest_api_id = "${aws_api_gateway_rest_api.MyDemoAPI.id}"
  resource_id = "${aws_api_gateway_resource.query.id}"
  http_method = "POST"
  lambda_name = "${module.query_lambda.lambda_name}"
  account_id = "${data.aws_caller_identity.current.account_id}"
  region = "${var.region}"   
  authorization = "NONE"
  integration_response_template = "#set($inputRoot = $input.path('$')){}"
  response_model = "Empty"
}


##################
# DB subnet group
##################
module "db_subnet_group" {
  source = "./modules/db_subnet_group"

  identifier  = "${var.identifier}"
  name_prefix = "${var.identifier}-"
  subnet_ids  = ["${data.aws_subnet_ids.all.ids}"]

  tags = "${var.tags}"
}

####################
# add rule to allow traffic between the lambda and th db
###################
resource "aws_security_group_rule" "allow_lambda" {
  type = "ingress"
  to_port = "${module.db_instance.this_db_instance_port}"
  from_port = 0
  protocol = "tcp"
  security_group_id = "${data.aws_security_group.default.id}"
  source_security_group_id = "${module.query_lambda.lambda_sg_id}"  
}

#####################
# DB parameter group
#####################
module "db_parameter_group" {
  source = "./modules/db_parameter_group"

  identifier  = "${var.identifier}"
  name_prefix = "${var.identifier}-"
  family      = "${var.family}"

  parameters = ["${var.parameters}"]

  tags = "${var.tags}"
}

##############
# DB instance
##############
module "db_instance" {
  source = "./modules/db_instance"

  identifier = "${var.identifier}"

  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  storage_type      = "${var.storage_type}"
  storage_encrypted = "${var.storage_encrypted}"
  kms_key_id        = "${var.kms_key_id}"
  license_model     = "${var.license_model}"

  name                                = "${var.name}"
  username                            = "${var.username}"
  password                            = "${var.password}"
  port                                = "${var.port}"
  iam_database_authentication_enabled = "${var.iam_database_authentication_enabled}"

  replicate_source_db = "${var.replicate_source_db}"

  snapshot_identifier = "${var.snapshot_identifier}"

  vpc_security_group_ids = ["${data.aws_security_group.default.id}"]
  db_subnet_group_name   = "${module.db_subnet_group.this_db_subnet_group_id}"
  parameter_group_name   = "${module.db_parameter_group.this_db_parameter_group_id}"

  multi_az            = "${var.multi_az}"
  iops                = "${var.iops}"
  publicly_accessible = "${var.publicly_accessible}"

  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  apply_immediately           = "${var.apply_immediately}"
  maintenance_window          = "${var.maintenance_window}"
  skip_final_snapshot         = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"
  final_snapshot_identifier   = "${var.final_snapshot_identifier}"

  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"

  monitoring_interval    = "${var.monitoring_interval}"
  monitoring_role_arn    = "${var.monitoring_role_arn}"
  monitoring_role_name   = "${var.monitoring_role_name}"
  create_monitoring_role = "${var.create_monitoring_role}"

  tags = "${var.tags}"
}
