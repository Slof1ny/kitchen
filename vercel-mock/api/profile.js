export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const auth = req.headers.authorization || '';
  if (!auth.startsWith('Bearer ') || auth.indexOf('TEST_TOKEN_abc123') === -1) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  return res.status(200).json({
    profile: {
      id: 1,
      name: 'Test Kitchen',
      phone: '+8801122334455',
      branch_id: 1
    },
    branch: {
      id: 1,
      name: 'Main Branch'
    }
  });
}
