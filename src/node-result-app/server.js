const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'postgres-service',
  port: Number(process.env.POSTGRES_PORT || 5432),
  database: process.env.POSTGRES_DB || 'votes',
  user: process.env.POSTGRES_USER || 'vote',
  password: process.env.POSTGRES_PASSWORD || 'vote'
});

app.use(express.static('public'));

app.get('/health', (req, res) => {
  res.status(200).send('ok');
});

app.get('/results', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT vote, COUNT(*)::int AS count FROM votes GROUP BY vote ORDER BY vote'
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'db_error' });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Result app listening on port ${port}`);
});

