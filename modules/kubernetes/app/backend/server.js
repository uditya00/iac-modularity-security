const express = require("express");
const { Pool } = require("pg");

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || "stratomesh",
  user: process.env.DB_USER || "stratomesh",
  password: process.env.DB_PASSWORD
});

app.get("/", (req, res) => {
  res.json({
    service: "StratoMesh Backend",
    status: "running"
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy"
  });
});

app.get("/ready", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.status(200).json({
      status: "ready",
      database: "connected"
    });
  } catch (error) {
    res.status(503).json({
      status: "not-ready",
      database: "unavailable"
    });
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(`StratoMesh backend listening on port ${port}`);
});
