const express = require("express");
const client = require("prom-client");

const app = express();
const port = process.env.PORT || 8080;
const backendUrl = process.env.BACKEND_URL || "http://stratomesh-backend:3000";

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequests = new client.Counter({
  name: "frontend_http_requests_total",
  help: "Total number of HTTP requests received by the frontend",
  labelNames: ["method", "route", "status_code"],
});

register.registerMetric(httpRequests);

// Count HTTP responses
app.use((req, res, next) => {
  res.on("finish", () => {
    httpRequests.inc({
      method: req.method,
      route: req.path,
      status_code: res.statusCode,
    });
  });

  next();
});

// Prometheus metrics endpoint
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

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
        <h1>StratoMesh Platform</h1>

        <p>GitOps & Self-Healing Cloud Platform</p>

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