exports.handler = async (event) => {
    for (const record of event.Records) {
        const message = JSON.parse(record.body);
        const { id_usuario, link_arquivo } = message;

        if (!id_usuario || !link_arquivo) {
            console.error('Invalid message format:', message);
            continue;
        }

        try {
            // Trecho para buscar o e-mail no Cognito (comentado)
            /*
            const AWS = require('aws-sdk');
            const cognito = new AWS.CognitoIdentityServiceProvider();
            const userResponse = await cognito.adminGetUser({
                UserPoolId: process.env.COGNITO_USER_POOL_ID,
                Username: id_usuario,
            }).promise();

            const emailAttribute = userResponse.UserAttributes.find(attr => attr.Name === 'email');
            const userEmail = emailAttribute ? emailAttribute.Value : null;

            if (!userEmail) {
                console.error(`Email not found for user: ${id_usuario}`);
                continue;
            }
            */

            // Simulação de um e-mail fixo para testes
            const userEmail = 'axel.kjellin.self@gmail.com';

            // Trecho de envio de e-mail com SES (comentado)
            /*
            const AWS = require('aws-sdk');
            const ses = new AWS.SES({ region: process.env.SES_REGION });

            const emailParams = {
                Source: process.env.SES_EMAIL_SOURCE,
                Destination: {
                    ToAddresses: [userEmail],
                },
                Message: {
                    Subject: {
                        Data: 'Seu arquivo está pronto!',
                    },
                    Body: {
                        Text: {
                            Data: `Olá, aqui estão os detalhes do seu arquivo:\n\nID do Usuário: ${id_usuario}\nLink: ${link_arquivo}`,
                        },
                    },
                },
            };

            await ses.sendEmail(emailParams).promise();
            console.log(`Email sent to ${userEmail}`);
            */

            // Console log simulando envio do e-mail
            console.log(`Simulated email to ${userEmail}:`);
            console.log(`Subject: Seu arquivo está pronto!`);
            console.log(`Body: Olá, aqui estão os detalhes do seu arquivo:\n\nID do Usuário: ${id_usuario}\nLink: ${link_arquivo}`);
        } catch (error) {
            console.error(`Failed to process message for user: ${id_usuario}`, error);
        }
    }
};
