// PWA Configuration for RISAQ
// This file extends Flutter's default service worker with advanced PWA features

const CACHE_NAME = 'risaq-cache-v2';
const OFFLINE_URL = '/offline.html';
const CACHE_TIMEOUT = 10000; // 10 second timeout for cache operations

// Critical assets to cache for offline use (only essential files)
const STATIC_CACHE_URLS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/offline.html'
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

// Install event - cache static assets with timeout protection
self.addEventListener('install', (event) => {
  event.waitUntil(
    Promise.race([
      caches.open(CACHE_NAME).then(async (cache) => {
        console.log('[PWA] Caching critical assets');
        
        // Cache assets individually with error handling
        const cachePromises = STATIC_CACHE_URLS.map(async (url) => {
          try {
            const response = await fetch(url);
            if (response.ok) {
              await cache.put(url, response);
              console.log(`[PWA] Cached: ${url}`);
            }
          } catch (error) {
            console.warn(`[PWA] Failed to cache ${url}:`, error);
            // Don't fail the entire install for optional assets
          }
        });
        
        await Promise.allSettled(cachePromises);
        console.log('[PWA] Install completed');
      }),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Install timeout')), CACHE_TIMEOUT)
      )
    ]).catch((error) => {
      console.warn('[PWA] Install warning:', error);
      // Don't fail install completely, continue with what we have
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

// Fetch event - implement cache strategies with timeout protection
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests and special protocols
  if (url.origin !== location.origin || url.protocol === 'chrome-extension:') {
    return;
  }

  // Skip if it's a range request (partial content)
  if (request.headers.get('range')) {
    return;
  }

  // Cache first strategy with timeout
  if (CACHE_STRATEGIES.cacheFirst.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      Promise.race([
        caches.match(request).then((response) => {
          if (response) return response;
          
          return fetch(request).then((fetchResponse) => {
            if (fetchResponse.ok) {
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(request, fetchResponse.clone()).catch(() => {
                  // Ignore cache errors
                });
              });
            }
            return fetchResponse;
          });
        }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Fetch timeout')), CACHE_TIMEOUT)
        )
      ]).catch(() => {
        // Fallback to network or cached offline page
        return caches.match(OFFLINE_URL) || new Response('Offline', { status: 503 });
      })
    );
    return;
  }

  // Network first strategy with timeout
  if (CACHE_STRATEGIES.networkFirst.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      Promise.race([
        fetch(request).then((response) => {
          if (response.ok) {
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, response.clone()).catch(() => {
                // Ignore cache errors
              });
            });
          }
          return response;
        }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Network timeout')), CACHE_TIMEOUT)
        )
      ]).catch(() => {
        return caches.match(request) || new Response('Network Error', { status: 503 });
      })
    );
    return;
  }

  // Stale while revalidate strategy (simplified)
  if (CACHE_STRATEGIES.staleWhileRevalidate.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(
      caches.match(request).then((cachedResponse) => {
        // Always try to update cache in background
        fetch(request).then((networkResponse) => {
          if (networkResponse.ok) {
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, networkResponse.clone()).catch(() => {
                // Ignore cache errors
              });
            });
          }
        }).catch(() => {
          // Ignore network errors for background updates
        });
        
        return cachedResponse || fetch(request);
      })
    );
    return;
  }

  // Default: simple network with cache fallback
  event.respondWith(
    fetch(request).catch(() => {
      return caches.match(request) || caches.match(OFFLINE_URL);
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