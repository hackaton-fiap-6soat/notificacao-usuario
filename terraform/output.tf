output "sqs_queue_url" {
  value       = aws_sqs_queue.notification_queue.id
  description = "URL da fila SQS que será usada para publicar mensagens."
}

output "sqs_status_queue_url" {
  value       = aws_sqs_queue.status_queue.id
  description = "URL da fila de status SQS para registrar sucesso ou erro."
}

output "lambda_function_name" {
  value       = aws_lambda_function.notification_lambda.function_name
  description = "Nome da função Lambda criada."
}
