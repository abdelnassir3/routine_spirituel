// PWA Configuration for RISAQ
// This file extends Flutter's default service worker with advanced PWA features

const CACHE_NAME = 'risaq-cache-v1';
const OFFLINE_URL = '/offline.html';

// Assets to cache for offline use
const STATIC_CACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  // Add fonts
  '/assets/fonts/Inter-Regular.ttf',
  '/assets/fonts/Inter-Bold.ttf',
  '/assets/fonts/NotoNaskhArabic-Regular.ttf',
  '/assets/fonts/NotoNaskhArabic-Bold.ttf',
  // Add critical assets
  '/assets/images/app_logo.png',
  '/assets/corpus/quran_combined.json',
];

// Dynamic cache configuration
const CACHE_STRATEGIES = {
  // Cache first for static assets
  cacheFirst: [
    /\.(?:png|jpg|jpeg|svg|gif|webp|ico)$/,
    /\.(?:woff|woff2|ttf|otf|eot)$/,
    /\.(?:css|js)$/,
  ],
  // Network first for API calls
  networkFirst: [
    /\/api\//,
    /\/supabase\//,
  ],
  // Stale while revalidate for content
  staleWhileRevalidate: [
    /\.json$/,
    /\/assets\/corpus\//,
  ],
};

// Install event - cache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[PWA] Caching static assets');
      return cache.addAll(STATIC_CACHE_URLS);
    })
  );
  self.skipWaiting();
});

// Activate event - clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((cacheName) => cacheName !== CACHE_NAME)
          .map((cacheName) => {
            console.log('[PWA] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - implement cache strategies
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Cache first strategy
  if (CACHE_STRATEGIES.cacheFirst.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      caches.match(request).then((response) => {
        return response || fetch(request).then((fetchResponse) => {
          return caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, fetchResponse.clone());
            return fetchResponse;
          });
        });
      })
    );
    return;
  }

  // Network first strategy
  if (CACHE_STRATEGIES.networkFirst.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          return caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, response.clone());
            return response;
          });
        })
        .catch(() => {
          return caches.match(request);
        })
    );
    return;
  }

  // Stale while revalidate strategy
  if (CACHE_STRATEGIES.staleWhileRevalidate.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      caches.match(request).then((cachedResponse) => {
        const fetchPromise = fetch(request).then((networkResponse) => {
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(request, networkResponse.clone());
          });
          return networkResponse;
        });
        return cachedResponse || fetchPromise;
      })
    );
    return;
  }

  // Default: network with cache fallback
  event.respondWith(
    fetch(request).catch(() => {
      return caches.match(request);
    })
  );
});

// Background sync for offline actions
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-routines') {
    event.waitUntil(syncRoutines());
  }
});

// Push notifications
self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'Nouvelle notification de RISAQ',
    icon: '/icons/Icon-192.png',
    badge: '/icons/badge-72.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Ouvrir',
        icon: '/icons/checkmark.png'
      },
      {
        action: 'close',
        title: 'Fermer',
        icon: '/icons/xmark.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('RISAQ', options)
  );
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'explore') {
    clients.openWindow('/');
  }
});

// Helper function to sync routines
async function syncRoutines() {
  try {
    const cache = await caches.open(CACHE_NAME);
    const requests = await cache.keys();
    
    // Filter for routine-related requests
    const routineRequests = requests.filter(req => 
      req.url.includes('/api/routines') || 
      req.url.includes('/supabase/routines')
    );

    // Attempt to sync each routine
    for (const request of routineRequests) {
      try {
        await fetch(request);
      } catch (error) {
        console.error('[PWA] Failed to sync:', request.url, error);
      }
    }
  } catch (error) {
    console.error('[PWA] Sync failed:', error);
  }
}

// Periodic background sync
self.addEventListener('periodicsync', (event) => {
  if (event.tag === 'update-routines') {
    event.waitUntil(updateRoutines());
  }
});

async function updateRoutines() {
  // Fetch latest routines data
  try {
    const response = await fetch('/api/routines/sync');
    const data = await response.json();
    
    // Update cache with new data
    const cache = await caches.open(CACHE_NAME);
    await cache.put('/api/routines/sync', new Response(JSON.stringify(data)));
    
    console.log('[PWA] Routines updated successfully');
  } catch (error) {
    console.error('[PWA] Failed to update routines:', error);
  }
}

// Share target handler
self.addEventListener('fetch', (event) => {
  if (event.request.url.endsWith('/share') && event.request.method === 'POST') {
    event.respondWith(handleShare(event.request));
  }
});

async function handleShare(request) {
  const formData = await request.formData();
  const title = formData.get('title');
  const text = formData.get('text');
  const url = formData.get('url');
  
  // Store shared data for the app to process
  const cache = await caches.open(CACHE_NAME);
  await cache.put('/shared-data', new Response(JSON.stringify({
    title,
    text,
    url,
    timestamp: Date.now()
  })));
  
  // Redirect to the app
  return Response.redirect('/routines/new?shared=true', 303);
}