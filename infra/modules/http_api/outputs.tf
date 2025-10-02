output "invoke_url" {
  value = "${aws_apigatewayv2_api.http.api_endpoint}/${var.stage}"
}


output "stage_arn" {
  value = aws_apigatewayv2_stage.stage.arn
}


output "api_id" {
  value = aws_apigatewayv2_api.http.id
}
