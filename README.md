# Serviço de Notificação com AWS Lambda, SQS, Cognito e SES

## Descrição
Este projeto implementa um serviço de notificação que utiliza os seguintes recursos da AWS:
- **SQS**: Fila para receber mensagens com informações do usuário e link de arquivos.
O formato da mensagem JSON { "id_usuario": "U12346", "link_arquivo": "http://amazon-us-xxxxxxxxx" }

- **Lambda**: Processa eventos do SQS, consulta o Cognito para buscar o e-mail do usuário e envia notificações por e-mail utilizando o SES.
- **Cognito**: Utilizado para buscar o e-mail do usuário com base no `id_usuario`.
- **SES**: Serviço de envio de e-mails.

## Alterações Necessárias
1. **Cognito**:
   - Substitua `<COGNITO_USER_POOL_ID>` na variável de ambiente `COGNITO_USER_POOL_ID` pelo ID do User Pool que será fornecido.

3. **Variáveis de Ambiente**:
   - Configure as variáveis no Terraform para ajustar as configurações de SES e Cognito.

## Comandos para Subir o Serviço
1. **Configurar Dependências do Lambda**:
   ```bash
   cd lambda
   npm install
   npm run package
   ```
   Isso criará o arquivo `lambda_function_payload.zip` necessário para o Terraform.

2. **Inicializar e Aplicar o Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

3. **Testar o Serviço**:
   - Publique mensagens no SQS com o seguinte formato:
     ```json
     {
       "id_usuario": "U12346",
       "link_arquivo": "http://amazon-us-xxxxxxxxx"
     }
     ```

## Informações para Uso

### Publicar Mensagens no SQS
Para que outros serviços possam publicar mensagens no SQS, você precisa fornecer o **SQS Queue URL**. Esse URL será exibido como saída no Terraform. Além disso, pode-se usar o AWS CLI ou SDK para publicar mensagens.

Exemplo de publicação via AWS CLI:
```bash
aws sqs send-message \
  --queue-url <SQS_QUEUE_URL> \
  --message-body '{"id_usuario": "U12346", "link_arquivo": "http://amazon-us-xxxxxxxxx"}'
```

### Fluxo do Serviço
1. Mensagens são publicadas no SQS com o `id_usuario` e `link_arquivo`.
2. A Lambda é acionada automaticamente.
3. A Lambda consulta o Cognito para buscar o e-mail do usuário com base no `id_usuario`.
4. A Lambda envia o e-mail para o usuário utilizando o SES.

### Informações Adicionais
- **Chave de Acesso ao SQS**: Garanta que o IAM Role do serviço Lambda tenha permissão para consumir mensagens do SQS. Para permitir que outros serviços publiquem mensagens, forneça o URL da fila.
- **Logs**: Os logs do Lambda podem ser visualizados no CloudWatch para depuração e monitoramento.
- **Variáveis Sensíveis**: Use variáveis de ambiente no Terraform para configurar `COGNITO_USER_POOL_ID` e outros detalhes sensíveis.


### Teste:
```bash
aws sqs send-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/918602927576/notification-queue \
  --message-body '{"id_usuario": "U12349", "link_arquivo": "http://amazon-us-yyyyyyyy"}'
```

<!-- usuario_id = 12314234 | link: 'https://teste -->
<!-- usuario_id 12314234 | email = axel@tesdte.com  -->

### Init com variaveis:
```bash
terraform apply -var="cognito_user_pool_id=placeholder-pool-id" -var="ses_email_source=axel.tank.kjellin@gmail.com"
```