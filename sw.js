// 우리일정 Service Worker v1.7
const CACHE_NAME = 'urischedule-v7';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './apple-touch-icon.png',
  './icon-512.png'
];

// 설치: 핵심 파일 캐시 + 즉시 활성화
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())  // ← 대기 없이 즉시 활성화
  );
});

// 활성화: 이전 버전 캐시 삭제 + 즉시 제어권 획득
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())  // ← 열린 탭 즉시 제어
  );
});

// 요청 가로채기
self.addEventListener('fetch', event => {
  if (!event.request.url.startsWith('http')) return;

  // ★ HTML 파일은 항상 네트워크 우선 → 최신 버전 즉시 반영
  if (event.request.destination === 'document') {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response && response.status === 200) {
            const toCache = response.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, toCache));
          }
          return response;
        })
        .catch(() => caches.match(event.request))  // 오프라인 시 캐시 반환
    );
    return;
  }

  // 다른 리소스: 캐시 우선 (빠른 로드), 없으면 네트워크
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        if (response && response.status === 200 && response.type === 'basic') {
          const toCache = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, toCache));
        }
        return response;
      }).catch(() => caches.match('./index.html'));
    })
  );
});
