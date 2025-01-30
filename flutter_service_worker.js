'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "693635b5258fe5f1cda720cf224f158c",
"assets/AssetManifest.bin.json": "69a99f98c8b1fb8111c5fb961769fcd8",
"assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "52afe9838475864a0b575996cfdc1844",
"assets/NOTICES": "27d5bc3ec8b77b7edaf14b20057188bb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"docs/categories.json": "58e0494c51d30eb3494f7c9198986bb9",
"docs/index.html": "f3be6fc317471c457531b7c609a8fde3",
"docs/index.json": "5bc81a4bf47638e972162a7f223dbf1a",
"docs/main/HomePage/build.html": "3db2ff55922d372b21aa76410db63e45",
"docs/main/HomePage/HomePage.html": "2ec7c7abe3f32c7cf5c16b7641032e39",
"docs/main/HomePage-class-sidebar.html": "e039bbe92350d398b533870fbb135e25",
"docs/main/HomePage-class.html": "0b77baa242a78924441d3d4e255d5411",
"docs/main/MacDock/builder.html": "6d8b170f1b0c18a2a93f2340d8868879",
"docs/main/MacDock/createState.html": "92177c5f93fd1db46edd4253b64e4f9c",
"docs/main/MacDock/items.html": "8835adec9ab1f71242cba683c81893ea",
"docs/main/MacDock/MacDock.html": "3c745942765bee68b7337747108f2e49",
"docs/main/MacDock-class-sidebar.html": "0a87f885bac5972341efd1b192141f13",
"docs/main/MacDock-class.html": "14508e9a2e3e2e07485ff920816fc58d",
"docs/main/MacDockState/build.html": "4c07a3053524a0af9127b03e58aaaecb",
"docs/main/MacDockState/calculatedItemValue.html": "7dadbfafbe07080fff0e012354057bd4",
"docs/main/MacDockState/items.html": "ff4f978f5b27d8fa594a7886ce9a1531",
"docs/main/MacDockState/MacDockState.html": "37c8b00bf514c5d836b59bf590a20ea1",
"docs/main/MacDockState-class-sidebar.html": "3b4869fbaa1de9d27d25b13da4da1cdc",
"docs/main/MacDockState-class.html": "d6c46c5bca700229201ae3ca2f1e6b7d",
"docs/main/main-library-sidebar.html": "05e8513017c88223fd0daa9b87a1f3a3",
"docs/main/main-library.html": "ef79f7753bb58336793cd08e05833317",
"docs/main/main.html": "ad14a53744f8c1aa9267281645beefcc",
"docs/main/MyApp/build.html": "6e65b1f37cf92a3d04774ef2e9113727",
"docs/main/MyApp/MyApp.html": "86be07c2e152a5150082476d8fea548a",
"docs/main/MyApp-class-sidebar.html": "ac84cc4758d046374a50f717df4f9971",
"docs/main/MyApp-class.html": "cc1af02aa527731fcfccc6f77f4ad6b1",
"docs/main/PlaceholderWidget/createState.html": "c962b490ea226539c6168cfeb7269b8d",
"docs/main/PlaceholderWidget/PlaceholderWidget.html": "e40d77f3566bc184340ba581b64dbad9",
"docs/main/PlaceholderWidget-class-sidebar.html": "41bb509ab2d6844da33b7afd61951db1",
"docs/main/PlaceholderWidget-class.html": "8868a5883428a975c02bef65cca55b34",
"docs/search.html": "16a3d0823902167e7242f64e3bff758a",
"docs/static-assets/docs.dart.js": "abc8e9c6079a16a3a71ec1b82ba0d87b",
"docs/static-assets/docs.dart.js.map": "c9b46e42d9b2cab52258b8c95b614cd3",
"docs/static-assets/favicon.png": "35ac27af3a3d8917ff1c7d3bf7e57bdd",
"docs/static-assets/github.css": "bf6c14925e66edb1526b6c9489b3c042",
"docs/static-assets/highlight.pack.js": "711099331393b01b7350d11a3627dbe4",
"docs/static-assets/play_button.svg": "bcb14c36edf9d4c36ecff6f4b16d0f45",
"docs/static-assets/readme.md": "bb41c1a055586fc7adcee3480b07e153",
"docs/static-assets/search.svg": "01c9b214378d2717983e2cd223d2b73d",
"docs/static-assets/styles.css": "477705a941cbbfb75ca3fe6284e85819",
"docs/__404error.html": "107c47bf3302fd48db39f2d74f6d5bc0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "ba6db7be5ef3a3fed8b29a300ba6da4f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "3d2dee6ad43e845135cbd86a1e55e062",
"/": "3d2dee6ad43e845135cbd86a1e55e062",
"main.dart.js": "ff7d3170a97b9918dd512931322bcc76",
"manifest.json": "5df9d95be1cb16a5689eb16ba009d5d8",
"version.json": "53b72f3aa39d46482645c78e1ffd3b43"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
