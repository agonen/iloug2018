resource "aws_api_gateway_method" "ResourceMethod" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.http_method}"
  authorization = "${var.authorization}"

}

resource "aws_api_gateway_integration" "ResourceMethodIntegration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${var.lambda_name}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_integration_response" "ResourceMethodIntegration200" {
  depends_on = ["aws_api_gateway_integration.ResourceMethodIntegration"]
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.ResourceMethod200.status_code}"
  response_templates = { "application/json" = "${var.integration_response_template}" }
}


resource "aws_api_gateway_method_response" "ResourceMethod200" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${aws_api_gateway_method.ResourceMethod.http_method}"
  status_code = "200"
  response_models = { "application/json" = "${var.response_model}" }
}

resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = ["aws_api_gateway_integration.ResourceMethodIntegration"]

  rest_api_id = "${var.rest_api_id}"
  stage_name  = ""

}

resource "aws_api_gateway_stage" "test" {
  depends_on = ["aws_api_gateway_integration.ResourceMethodIntegration"]
  stage_name = "${var.stage_name}"
  rest_api_id = "${var.rest_api_id}"
  deployment_id = "${aws_api_gateway_deployment.MyDemoDeployment.id}"
}
