CREATE TABLE IF NOT EXISTS app_status (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO app_status (message)
VALUES ('StratoMesh database is working');
