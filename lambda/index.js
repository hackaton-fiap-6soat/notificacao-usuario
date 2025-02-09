const AWS = require('aws-sdk');

const sqs = new AWS.SQS();
const cognito = new AWS.CognitoIdentityServiceProvider();

exports.handler = async (event) => {
    for (const record of event.Records) {
        try {
            const message = JSON.parse(record.body);
            const { id_usuario, link_arquivo } = message;

            if (!id_usuario) {
                throw new Error("Invalid message format: Missing id_usuario");
            }

            const userResponse = await cognito.adminGetUser({
                UserPoolId: process.env.COGNITO_USER_POOL_ID,
                Username: id_usuario,
            }).promise();

            const emailAttribute = userResponse.UserAttributes.find(attr => attr.Name === 'email');
            const userEmailAttribute = emailAttribute ? emailAttribute.Value : null;

            if (!userEmailAttribute) {
                throw new Error(`Email not found for user: ${id_usuario}`);
            }

            if (!link_arquivo) {
                console.log(`Simulated error email to ${userEmailAttribute}:`);
                console.log(`Subject: Erro no processamento`);
                console.log(`Body: Não foi possível processar seu vídeo. Por favor, tente novamente mais tarde.`);

                throw new Error(`Missing link_arquivo for user: ${id_usuario}`);
            }

            console.log(`Simulated email to ${userEmailAttribute}:`);
            console.log(`Subject: Seu arquivo está pronto!`);
            console.log(`Body: Olá, aqui estão os detalhes do seu arquivo:\n\nID do Usuário: ${id_usuario} \nLink: ${link_arquivo}`);

            await sendSqsMessage(id_usuario, "notificacao", link_arquivo, "ok");

        } catch (error) {
            console.error(`Failed to process message: ${error.message}`);

            await sendSqsMessage(record.body.id_usuario || "unknown", "notificacao", link_arquivo, "error");
        }
    }
};

async function sendSqsMessage(id_usuario, processo, nome_arquivo, status) {
    const params = {
        QueueUrl: process.env.SQS_STATUS_QUEUE_URL,
        MessageBody: JSON.stringify({
            id_usuario,
            processo,
            nome_arquivo,
            status,
        }),
    };

    try {
        await sqs.sendMessage(params).promise();
        console.log(`SQS Message sent: ${JSON.stringify(params.MessageBody)}`);
    } catch (err) {
        console.error(`Failed to send message to SQS for user ${id_usuario}:`, err);
    }
}
