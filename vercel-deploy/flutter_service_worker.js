'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "fb04d33014014d46b9257a5f03feaaba",
".vercel/project.json": "a535d2bf0fd314a5fbfc7a245a9e74aa",
".vercel/output/config.json": "90cd698df4d203164df1f430e1d8778c",
".vercel/output/static/flutter_bootstrap.js": "fb04d33014014d46b9257a5f03feaaba",
".vercel/output/static/version.json": "ae5ff0cc59c3d8829f825c8b508cbd64",
".vercel/output/static/index.html": "678993ac9bd0b6cd93f99db4f6767871",
".vercel/output/static/main.dart.js": "14ebdded402ea0ab2bb2e325ff84d568",
".vercel/output/static/flutter.js": "4b2350e14c6650ba82871f60906437ea",
".vercel/output/static/favicon.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
".vercel/output/static/icons/Icon-192.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
".vercel/output/static/icons/Icon-maskable-192.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
".vercel/output/static/icons/Icon-maskable-512.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
".vercel/output/static/icons/Icon-512.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
".vercel/output/static/manifest.json": "7a6da4780737a6dba8dd0ff745ce8e68",
".vercel/output/static/lib/firebase_auth.dart": "dbe7bb24e002f85d0a3766c2b8921dac",
".vercel/output/static/lib/src/recaptcha_verifier.dart": "9cf2b40187e67bc10cedbabcd614bf4d",
".vercel/output/static/lib/src/confirmation_result.dart": "c55f5c6415555f5d48d6b7ec2d053afd",
".vercel/output/static/lib/src/user.dart": "943d49f9a913e6685faf6d643b0c1faf",
".vercel/output/static/lib/src/multi_factor.dart": "e4cfed6b85ff25095add8bb371b719bb",
".vercel/output/static/lib/src/firebase_auth.dart": "244b35918aecb85e8a2dbc5d84a198c3",
".vercel/output/static/lib/src/user_credential.dart": "3ca6b5381ed29a242e7dc288dfd6a85e",
".vercel/output/static/assets/AssetManifest.json": "6cbde945e5dee3056ccec01676a30f68",
".vercel/output/static/assets/NOTICES": "8858fcb327572b4262c17b243f33c701",
".vercel/output/static/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
".vercel/output/static/assets/AssetManifest.bin.json": "c44cdb55b89c95c3fb76eb67db4000a1",
".vercel/output/static/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
".vercel/output/static/assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound_recorder.js": "f7ac74c4e0fd5cd472d86c3fe93883fc",
".vercel/output/static/assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound_player.js": "ab009562c726b262f996cb55447ef32a",
".vercel/output/static/assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound.js": "aecd83c80bf4faace0bcea4cd47ab307",
".vercel/output/static/assets/packages/flutter_sound_web/js/howler/howler.js": "2bba823e6b4d71ea019d81d384672823",
".vercel/output/static/assets/packages/flutter_sound_web/js/howler/howler.spatial.min.js": "28305f7b4898c9b49d523b2e80293ec8",
".vercel/output/static/assets/packages/flutter_sound_web/js/howler/howler.min.js": "0245b64fba989b9e3fd5b253f683d0e4",
".vercel/output/static/assets/packages/flutter_sound_web/js/howler/howler.core.min.js": "55e0af0319483be8a7371a2cceacf921",
".vercel/output/static/assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
".vercel/output/static/assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
".vercel/output/static/assets/packages/model_viewer_plus/assets/model-viewer.min.js": "a9dc98f8bf360be897a0898a7395f905",
".vercel/output/static/assets/packages/model_viewer_plus/assets/template.html": "8de94ff19fee64be3edffddb412ab63c",
".vercel/output/static/assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
".vercel/output/static/assets/AssetManifest.bin": "8f2502eb73ac204e8989f9e14087bb2d",
".vercel/output/static/assets/fonts/MaterialIcons-Regular.otf": "2cb0982e4acfc49650656ac86acbb656",
".vercel/output/static/canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
".vercel/output/static/canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
".vercel/output/static/canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
".vercel/output/static/canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
".vercel/output/static/canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
".vercel/output/static/canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
".vercel/output/static/canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
".vercel/output/static/canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
".vercel/output/static/canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
".vercel/output/static/canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
".vercel/output/diagnostics/cli_traces.json": "a40a47c14a8e64ecc5d2f2775f1b557c",
".vercel/output/builds.json": "9c64f23aa1ea267dfa2d4902dede43f8",
".vercel/README.txt": "2b13c79d37d6ed82a3255b83b6815034",
"version.json": "ae5ff0cc59c3d8829f825c8b508cbd64",
"index.html": "678993ac9bd0b6cd93f99db4f6767871",
"/": "678993ac9bd0b6cd93f99db4f6767871",
"vercel.json": "653c094c1ea8228fd369c5229b43af86",
"main.dart.js": "14ebdded402ea0ab2bb2e325ff84d568",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
"icons/Icon-192.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
"icons/Icon-maskable-192.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
"icons/Icon-maskable-512.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
"icons/Icon-512.png": "f7b1e2d35e7a5f4a4e8ea63c2afecbb3",
"manifest.json": "7a6da4780737a6dba8dd0ff745ce8e68",
"lib/firebase_auth.dart": "dbe7bb24e002f85d0a3766c2b8921dac",
"lib/src/recaptcha_verifier.dart": "9cf2b40187e67bc10cedbabcd614bf4d",
"lib/src/confirmation_result.dart": "c55f5c6415555f5d48d6b7ec2d053afd",
"lib/src/user.dart": "943d49f9a913e6685faf6d643b0c1faf",
"lib/src/multi_factor.dart": "e4cfed6b85ff25095add8bb371b719bb",
"lib/src/firebase_auth.dart": "244b35918aecb85e8a2dbc5d84a198c3",
"lib/src/user_credential.dart": "3ca6b5381ed29a242e7dc288dfd6a85e",
"assets/AssetManifest.json": "6cbde945e5dee3056ccec01676a30f68",
"assets/NOTICES": "8858fcb327572b4262c17b243f33c701",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "c44cdb55b89c95c3fb76eb67db4000a1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound_recorder.js": "f7ac74c4e0fd5cd472d86c3fe93883fc",
"assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound_player.js": "ab009562c726b262f996cb55447ef32a",
"assets/packages/flutter_sound_web/js/flutter_sound/flutter_sound.js": "aecd83c80bf4faace0bcea4cd47ab307",
"assets/packages/flutter_sound_web/js/howler/howler.js": "2bba823e6b4d71ea019d81d384672823",
"assets/packages/flutter_sound_web/js/howler/howler.spatial.min.js": "28305f7b4898c9b49d523b2e80293ec8",
"assets/packages/flutter_sound_web/js/howler/howler.min.js": "0245b64fba989b9e3fd5b253f683d0e4",
"assets/packages/flutter_sound_web/js/howler/howler.core.min.js": "55e0af0319483be8a7371a2cceacf921",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/model_viewer_plus/assets/model-viewer.min.js": "a9dc98f8bf360be897a0898a7395f905",
"assets/packages/model_viewer_plus/assets/template.html": "8de94ff19fee64be3edffddb412ab63c",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "8f2502eb73ac204e8989f9e14087bb2d",
"assets/fonts/MaterialIcons-Regular.otf": "2cb0982e4acfc49650656ac86acbb656",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c"};
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
