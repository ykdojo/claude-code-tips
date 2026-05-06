// SVG-style flying bat - flat extruded shape with wing flapping
function createModel() {
  const group = new THREE.Group();

  // --- Body ---
  const bodyShape = new THREE.Shape();
  bodyShape.ellipse(0, 0, 0.18, 0.4, 0, Math.PI * 2, false, 0);
  const bodyGeo = new THREE.ExtrudeGeometry(bodyShape, { depth: 0.08, bevelEnabled: false });
  const batMat = new THREE.MeshPhysicalMaterial({
    color: 0x6a0dad,
    emissive: 0x6a0dad,
    emissiveIntensity: 0.15,
    roughness: 0.3,
    metalness: 0.1,
    side: THREE.DoubleSide
  });
  const body = new THREE.Mesh(bodyGeo, batMat);
  body.position.set(0, 0, -0.04);
  group.add(body);

  // --- Head ---
  const headGeo = new THREE.SphereGeometry(0.2, 16, 16);
  const head = new THREE.Mesh(headGeo, batMat);
  head.position.set(0, 0.5, 0);
  group.add(head);

  // --- Ears ---
  function makeEar(xSign) {
    const earShape = new THREE.Shape();
    earShape.moveTo(0, 0);
    earShape.lineTo(0.06 * xSign, 0.2);
    earShape.lineTo(0.12 * xSign, 0);
    earShape.closePath();
    const earGeo = new THREE.ExtrudeGeometry(earShape, { depth: 0.04, bevelEnabled: false });
    const ear = new THREE.Mesh(earGeo, batMat);
    ear.position.set(0.08 * xSign, 0.65, -0.02);
    return ear;
  }
  group.add(makeEar(-1));
  group.add(makeEar(1));

  // --- Eyes ---
  const eyeMat = new THREE.MeshBasicMaterial({ color: 0xff4444 });
  const eyeGeo = new THREE.SphereGeometry(0.04, 8, 8);
  [-1, 1].forEach(s => {
    const eye = new THREE.Mesh(eyeGeo, eyeMat);
    eye.position.set(0.08 * s, 0.55, 0.15);
    group.add(eye);
  });

  // --- Wings (flat shapes, will be animated) ---
  function makeWing(xSign) {
    const shape = new THREE.Shape();
    // Wing origin at body side
    shape.moveTo(0, 0);
    // Top scallop
    shape.quadraticCurveTo(0.4 * xSign, 0.3, 0.8 * xSign, 0.15);
    // First finger dip
    shape.quadraticCurveTo(0.7 * xSign, 0.0, 0.9 * xSign, -0.1);
    // Second scallop
    shape.quadraticCurveTo(0.75 * xSign, -0.15, 0.6 * xSign, -0.2);
    // Third scallop dip
    shape.quadraticCurveTo(0.45 * xSign, -0.1, 0.35 * xSign, -0.25);
    // Back to body
    shape.quadraticCurveTo(0.15 * xSign, -0.15, 0, -0.3);
    shape.closePath();

    const wingGeo = new THREE.ExtrudeGeometry(shape, { depth: 0.02, bevelEnabled: false });
    const wing = new THREE.Mesh(wingGeo, batMat);
    wing.position.set(0.15 * xSign, 0.1, -0.01);
    return wing;
  }

  const leftWing = makeWing(-1);
  const rightWing = makeWing(1);
  group.add(leftWing);
  group.add(rightWing);

  // --- Hind feet ---
  const footGeo = new THREE.CylinderGeometry(0.01, 0.006, 0.12, 6);
  [-1, 1].forEach(s => {
    const leg = new THREE.Mesh(footGeo, batMat);
    leg.position.set(0.05 * s, -0.42, 0);
    group.add(leg);
    // Claws
    const clawGeo = new THREE.CylinderGeometry(0.005, 0.002, 0.06, 4);
    [-1, 0, 1].forEach(t => {
      const claw = new THREE.Mesh(clawGeo, batMat);
      claw.position.set(0.05 * s + 0.015 * t, -0.49, 0);
      claw.rotation.z = 0.15 * t;
      group.add(claw);
    });
  });

  // Store wing refs for animation
  group.userData.leftWing = leftWing;
  group.userData.rightWing = rightWing;

  // Scale up a bit
  group.scale.set(1.8, 1.8, 1.8);
  group.position.y = -0.4;

  return group;
}

function animateModel(model, time) {
  const flapAngle = Math.sin(time * 5) * 0.4;
  model.userData.leftWing.rotation.y = flapAngle;
  model.userData.rightWing.rotation.y = -flapAngle;

  // Gentle bobbing
  model.position.y = -0.4 + Math.sin(time * 2) * 0.15;
}
