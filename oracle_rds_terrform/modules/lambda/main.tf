resource "aws_lambda_function" "lambda" {
  function_name    = "${var.name}"
  s3_key           = "${var.s3_key}"
  s3_bucket       = "${var.s3_bucket}"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "${var.handler}"
  runtime          = "${var.runtime}"
  timeout          = "${var.timeout}"
  memory_size      = "${var.memory_size}"

  publish          = "true"

  environment {
    variables = "${var.env}"
  }

  vpc_config {
       subnet_ids = ["${var.subnet_ids}"]
       security_group_ids = ["${aws_security_group.lambda_sg.id}"]
   }
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "current"
  description      = "Current version"
  function_name    = "${aws_lambda_function.lambda.arn}"
  function_version = "$LATEST"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${format("%.64s", "iam_for_lambda-${var.name}")}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_policy_document" {
    statement {
        actions = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DeleteNetworkInterface",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "s3:*",
          "iam:PassRole",
          "lambda:*",
          "elasticmapreduce:*"
        ]
        resources = [
            "*",
        ]
    }
}

resource "aws_iam_policy" "lambda_policy" {
    name = "lambda-policy-${var.name}"
    path = "/"
    policy = "${data.aws_iam_policy_document.lambda_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "s3-access-ro" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = "${var.vpc_id}"
  description = "Allows all outbound traffic"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "lambda-sg-${var.name}"
    VpcId       = "${var.vpc_id}"
  }
}

resource "aws_security_group_rule" "lambda-sg-egress" {
  security_group_id = "${aws_security_group.lambda_sg.id}"
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "/aws/lambda/${var.name}"
  retention_in_days = "${var.log_retention}"
}
