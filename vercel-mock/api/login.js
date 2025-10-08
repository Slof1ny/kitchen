export default async function handler(req, res) {
  // Allow CORS for testing (restrict in production)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const body = req.body || {};
  const phone = body.email_or_phone || body.phone || body.username;
  const password = body.password;

  console.log('[vercel-mock] /api/login body:', body);

  if (phone === '+8801122334455' && password === '12345678') {
    return res.status(200).json({ message: 'Logged in', token: 'TEST_TOKEN_abc123' });
  } else {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
}
