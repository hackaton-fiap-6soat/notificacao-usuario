provider "aws" {
  region = "us-east-1"
}

resource "aws_sqs_queue" "notification_queue" {
  name = "notification-queue"
}

resource "aws_lambda_function" "notification_lambda" {
  function_name     = "notificationLambda"
  runtime           = "nodejs18.x"
  handler           = "index.handler"
  role              = var.aws_lambda_role_arn
  filename          = "lambda_function_payload.zip"
  source_code_hash  = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      SQS_QUEUE_URL        = aws_sqs_queue.notification_queue.id
      SQS_STATUS_QUEUE_URL = var.sqs_status_queue_url
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  function_name    = aws_lambda_function.notification_lambda.arn
}