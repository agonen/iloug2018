output "lambda_sg_id" {
  value = "${aws_security_group.lambda_sg.id}"
}

output "lambda_name" {
  value = "${aws_lambda_function.lambda.function_name}"
}

output "lambda_arn" {
  value = "${aws_lambda_function.lambda.qualified_arn}"
}

output "lambda_base_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}