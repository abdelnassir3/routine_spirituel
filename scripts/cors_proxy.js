const http = require('http');
const https = require('https');
const { URL } = require('url');

// Configuration du proxy CORS
const PORT = 3000;
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
  'Access-Control-Max-Age': '86400'
};

console.log('🚀 Démarrage du proxy CORS pour APIs Quran...');

// Serveur proxy
const server = http.createServer((req, res) => {
  // Headers CORS pour toutes les réponses
  Object.keys(CORS_HEADERS).forEach(key => {
    res.setHeader(key, CORS_HEADERS[key]);
  });

  // Gérer les requêtes OPTIONS (preflight)
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Extraire l'URL cible depuis les paramètres
  const urlParam = new URL(req.url, `http://localhost:${PORT}`).searchParams.get('url');
  
  if (!urlParam) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Missing URL parameter' }));
    return;
  }

  let targetUrl;
  try {
    targetUrl = new URL(urlParam);
  } catch (error) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Invalid URL parameter' }));
    return;
  }

  // Vérifier que c'est une URL Quran autorisée
  const allowedHosts = [
    'cdn.alquran.cloud',
    'cdn.islamic.network', // Nouvelle URL de redirection AlQuran
    'www.everyayah.com', 
    'api.alquran.cloud',
    'api.quran.com'
  ];
  
  if (!allowedHosts.includes(targetUrl.hostname)) {
    console.log(`❌ Host non autorisé: ${targetUrl.hostname}`);
    res.writeHead(403, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Host not allowed' }));
    return;
  }

  console.log(`📡 Proxy: ${req.method} ${targetUrl.href}`);

  // Choisir http ou https selon l'URL cible
  const client = targetUrl.protocol === 'https:' ? https : http;
  
  const proxyReq = client.request(targetUrl, {
    method: req.method,
    headers: {
      'User-Agent': 'Spiritual-Routines-App/1.0',
      'Accept': '*/*'
    }
  }, (proxyRes) => {
    // Copier les headers de la réponse (sauf CORS)
    const responseHeaders = { ...proxyRes.headers };
    delete responseHeaders['access-control-allow-origin'];
    delete responseHeaders['access-control-allow-methods'];
    delete responseHeaders['access-control-allow-headers'];
    
    res.writeHead(proxyRes.statusCode, responseHeaders);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (error) => {
    console.error(`❌ Erreur proxy: ${error.message}`);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Proxy request failed', details: error.message }));
  });

  // Transmettre le corps de la requête si présent
  req.pipe(proxyReq);
});

server.listen(PORT, () => {
  console.log(`✅ Proxy CORS démarré sur http://localhost:${PORT}`);
  console.log(`📖 Usage: http://localhost:${PORT}/?url=https://cdn.alquran.cloud/media/audio/ayah/ar.sudais/674`);
  console.log(`🔒 Hosts autorisés: cdn.alquran.cloud, cdn.islamic.network, www.everyayah.com, api.alquran.cloud, api.quran.com`);
});

// Gestion propre de l'arrêt
process.on('SIGINT', () => {
  console.log('\n🛑 Arrêt du proxy CORS...');
  server.close(() => {
    console.log('✅ Proxy fermé proprement');
    process.exit(0);
  });
});
