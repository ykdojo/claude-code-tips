// 3D slide base - shared scene setup, lighting, drag, animation
// Expects: createModel() defined before this runs
// Placeholders __CANVAS_ID__ and __SLIDE_ID__ replaced by build.js
(function() {
  const canvas = document.getElementById('__CANVAS_ID__');
  const slideEl = document.getElementById('__SLIDE_ID__');
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 100);
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setClearColor(0x1a1a1a);

  // Add model
  const model = createModel();
  const onAnimate = typeof animateModel === 'function' ? animateModel : null;
  scene.add(model);

  // Warm directional light
  const dirLight = new THREE.DirectionalLight(0xffd4a0, 1.2);
  dirLight.position.set(5, 8, 4);
  scene.add(dirLight);

  // Ambient light
  const ambLight = new THREE.AmbientLight(0x404040, 0.6);
  scene.add(ambLight);

  // Orange point light for warmth
  const pointLight = new THREE.PointLight(0xff8c32, 0.8, 15);
  pointLight.position.set(-2, 3, -2);
  scene.add(pointLight);

  camera.position.set(3, 3, 3);
  camera.lookAt(0, 0, 0);

  // Drag to rotate
  let isDragging = false;
  let prevMouse = { x: 0, y: 0 };

  canvas.addEventListener('mousedown', (e) => {
    isDragging = true;
    prevMouse = { x: e.clientX, y: e.clientY };
  });

  window.addEventListener('mouseup', () => { isDragging = false; });

  window.addEventListener('mousemove', (e) => {
    if (!isDragging) return;
    const dx = e.clientX - prevMouse.x;
    const dy = e.clientY - prevMouse.y;
    model.rotation.y += dx * 0.01;
    model.rotation.x += dy * 0.01;
    prevMouse = { x: e.clientX, y: e.clientY };
  });

  // Touch support for drag
  canvas.addEventListener('touchstart', (e) => {
    isDragging = true;
    prevMouse = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    e.stopPropagation();
  }, { passive: true });

  canvas.addEventListener('touchmove', (e) => {
    if (!isDragging) return;
    const dx = e.touches[0].clientX - prevMouse.x;
    const dy = e.touches[0].clientY - prevMouse.y;
    model.rotation.y += dx * 0.01;
    model.rotation.x += dy * 0.01;
    prevMouse = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    e.stopPropagation();
  }, { passive: true });

  canvas.addEventListener('touchend', () => { isDragging = false; });

  let animId;
  function animate() {
    animId = requestAnimationFrame(animate);
    if (onAnimate) onAnimate(model, performance.now() / 1000);
    renderer.render(scene, camera);
  }

  // Only animate when this slide is active
  const origShowSlide = window.showSlide;
  window.showSlide = function(n, itemCount, showAll) {
    origShowSlide(n, itemCount, showAll);
    if (slides[current] === slideEl) {
      renderer.setSize(window.innerWidth, window.innerHeight);
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      animate();
    } else {
      cancelAnimationFrame(animId);
    }
  };
})();
