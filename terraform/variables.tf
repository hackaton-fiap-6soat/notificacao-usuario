variable "cognito_user_pool_id" {
  description = "O ID do User Pool no Cognito que será usado para buscar informações do usuário."
  type        = string
  default     = "placeholder-pool-id"
}

variable "sqs_status_queue_url" {
  description = "A URL da fila SQS onde serão enviados os status de erro e sucesso."
  type        = string
  default     = "sqs-status-queue-url"
}

variable "aws_region" {
  description = "Região AWS onde os serviços serão criados."
  type        = string
  default     = "us-east-1"
}