variable "cognito_user_pool_id" {
  description = "O ID do User Pool no Cognito que será usado para buscar informações do usuário."
  type        = string
  default     = "placeholder-pool-id"
}

variable "ses_email_source" {
  description = "O endereço de e-mail verificado no SES que será usado como remetente."
  type        = string
  default     = "axel.kjellin.self@gmail.com"
}

variable "aws_region" {
  description = "Região AWS onde os serviços serão criados."
  type        = string
  default     = "us-east-1"
}