const express = require("express");

const app = express();
const port = process.env.PORT || 8080;
const backendUrl = process.env.BACKEND_URL || "http://stratomesh-backend:3000";

app.get("/", async (req, res) => {
  let backendStatus = "unavailable";
  let databaseStatus = "unavailable";

  try {
    const healthResponse = await fetch(`${backendUrl}/health`);
    if (healthResponse.ok) {
      backendStatus = "healthy";
    }

    const readyResponse = await fetch(`${backendUrl}/ready`);
    if (readyResponse.ok) {
      const data = await readyResponse.json();
      databaseStatus = data.database || "connected";
    }
  } catch (error) {
    console.error("Backend connection failed:", error.message);
  }

  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>StratoMesh Dashboard</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 40px;
          background: #f4f6f8;
        }

        .container {
          max-width: 800px;
          margin: auto;
          background: white;
          padding: 30px;
          border-radius: 12px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        h1 {
          margin-top: 0;
        }

        .status {
          padding: 15px;
          margin: 12px 0;
          border-radius: 8px;
          background: #eef2f7;
        }

        .value {
          font-weight: bold;
        }
      </style>
    </head>

    <body>
      <div class="container">
        <h1>StratoMesh Platform</h1><p><strong>CANARY v1.1</strong></p>

        <p>Multi-Region GitOps & Self-Healing Cloud Platform</p>

        <div class="status">
          Frontend:
          <span class="value">Running</span>
        </div>

        <div class="status">
          Backend:
          <span class="value">${backendStatus}</span>
        </div>

        <div class="status">
          Database:
          <span class="value">${databaseStatus}</span>
        </div>
      </div>
    </body>
    </html>
  `);
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy"
  });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`StratoMesh frontend listening on port ${port}`);
});

