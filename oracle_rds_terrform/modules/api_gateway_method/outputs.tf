# DB instance
output "this_api_gateway_endpoint_url" {
  description = "API end point "
  value       = "${aws_api_gateway_deployment.MyDemoDeployment.invoke_url}"
}
