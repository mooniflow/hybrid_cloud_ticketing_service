resource "aws_lambda_function" "example_lambda" {
  function_name = "test2"
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler"
  filename      = "./lambda_function/lambda_function.zip"
  role          = "arn:aws:iam::447079561480:role/lambdatoDB"  # lambdadb 역할의 ARN으로 변경하세요

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# SQS 큐와 Lambda 함수 간의 이벤트 소스 매핑 설정
resource "aws_lambda_event_source_mapping" "terraform_queue_mapping" {
  event_source_arn  = aws_sqs_queue.terraform_queue.arn
  function_name     = aws_lambda_function.example_lambda.function_name
  batch_size         = 5  # Lambda 함수에 전달되는 메시지의 최대 수
}