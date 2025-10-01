const { GoogleAuth } = require("google-auth-library");
const path = require("path");
const https = require("https");

class FCMSender {
  constructor(serviceAccountPath) {
    this.serviceAccountPath = serviceAccountPath;
    this.projectId = require(serviceAccountPath).project_id;
  }

  async getAccessToken() {
    try {
      const auth = new GoogleAuth({
        keyFile: this.serviceAccountPath,
        scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
      });

      const client = await auth.getClient();
      const accessTokenResponse = await client.getAccessToken();

      console.log("✅ Access token generated successfully!");
      console.log(`🔑 Token: ${accessTokenResponse.token.substring(0, 50)}...`);

      return accessTokenResponse.token;
    } catch (error) {
      console.error("❌ Error generating access token:", error.message);
      throw error;
    }
  }

  async sendToDevice(deviceToken, title, body, data = {}) {
    const accessToken = await this.getAccessToken();

    const message = {
      message: {
        token: deviceToken,
        notification: {
          title: title,
          body: body,
        },
        data: data,
      },
    };

    return this.sendMessage(accessToken, message);
  }

  async sendToTopic(topic, title, body, data = {}) {
    const accessToken = await this.getAccessToken();

    const message = {
      message: {
        topic: topic,
        notification: {
          title: title,
          body: body,
        },
        data: data,
      },
    };

    return this.sendMessage(accessToken, message);
  }

  async sendMessage(accessToken, message) {
    const url = `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`;

    const options = {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
    };

    return new Promise((resolve, reject) => {
      const req = https.request(url, options, (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => {
          const result = JSON.parse(data);

          if (res.statusCode === 200) {
            console.log("✅ Message sent successfully!");
            console.log(`📱 Message ID: ${result.name}`);
            resolve(result);
          } else {
            console.error("❌ Error sending message:", result);
            reject(result);
          }
        });
      });

      req.on("error", reject);
      req.write(JSON.stringify(message));
      req.end();
    });
  }
}

async function main() {
  const fcm = new FCMSender('./service-account-key.json');
  
  try {
    console.log('🔑 Testing access token generation...');
    await fcm.getAccessToken();
    
    const deviceToken =
      "fINZpX-zfXiDakZewrjxxP:APA91bGQQ1FGncVbfJooJ6Bdd7JSdgsrOcw5SPhTCNWiCnaVcKZGtuAXTMOoy84O4_q9PgtMcTE5Bo16d2LlVPF4BlGWZA25Z0U5rAZ0l_E5qGL9Glumvns";
    
    await fcm.sendToDevice(
      deviceToken,
      '🔥 Hello from Node.js!',
      'Notification berhasil dikirim dari server FCM!',
      { 
        source: 'nodejs', 
        timestamp: Date.now().toString(),
        test: 'true'
      }
    );

  } catch (error) {
    console.error('Error:', error);
  }
}

main();

module.exports = FCMSender;
