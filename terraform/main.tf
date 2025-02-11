terraform {
  backend "s3" {
    bucket = ""
    key    = ""
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_iam_role" LabRole {
  name = "LabRole"
}

data "aws_vpc" "hackathon-vpc" {
  filter {
    name   = "tag:Name"
    values = ["fiap-hackathon-vpc"]
  }
}
data "aws_subnets" "private_subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.hackathon-vpc.id]
  }

  filter {
    name = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_security_group" "lambda" {
  name        = "notification_lambda_sg"
  description = "Security group for Lambda"
  vpc_id      = data.aws_vpc.hackathon-vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data sources para buscar o "User Pool Client" do Amazon Cognito a ser utilizado na autenticação do endpoint
# O valor fornecido ao user_pool_id também pode ser utilizado como environment variable das Lambda functions caso seja necessário acessar a api do Amazon Cognito (por exemplo para obter o email dos usuários)
data aws_cognito_user_pools user_pools {
  name = "user-pool"
}
data aws_cognito_user_pool user_pool {
  user_pool_id = data.aws_cognito_user_pools.user_pools.ids[0]
}


resource "aws_sqs_queue" "notification_queue" {
  name = "notification-queue"
}

resource "aws_lambda_function" "notification_lambda" {
  function_name     = "notificationLambda"
  runtime           = "nodejs18.x"
  handler           = "index.handler"
  role              = data.aws_iam_role.LabRole.arn
  filename          = "lambda_function_payload.zip"
  source_code_hash  = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      SQS_QUEUE_URL        = aws_sqs_queue.notification_queue.id
      SQS_STATUS_QUEUE_URL = var.sqs_status_queue_url
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    }
  }


  vpc_config {
    subnet_ids = data.aws_subnets.private_subnets.ids
    security_group_ids = [aws_security_group.lambda.id]
  }

}

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.notification_queue.arn
  function_name    = aws_lambda_function.notification_lambda.arn
}