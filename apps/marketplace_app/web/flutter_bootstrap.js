{{flutter_js}}
{{flutter_build_config}}

// CanvasKit is served from our own origin (build/web/canvaskit/), never from
// the gstatic CDN: a third-party script on the same origin as the session
// token in localStorage is what the CSP in index.html exists to prevent
// (ADR-0011). Setting it here makes it the default for every build, instead
// of depending on someone remembering a build flag.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
