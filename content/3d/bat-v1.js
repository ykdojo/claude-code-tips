// Flying bat model with flapping wings
function createModel() {
  const bat = new THREE.Group();

  // Body - dark elongated ellipsoid
  const bodyGeo = new THREE.SphereGeometry(0.3, 16, 12);
  bodyGeo.scale(1, 0.7, 1.5);
  const bodyMat = new THREE.MeshPhysicalMaterial({
    color: 0x2a1a2e,
    roughness: 0.8,
    metalness: 0.1
  });
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  bat.add(body);

  // Head
  const headGeo = new THREE.SphereGeometry(0.2, 16, 12);
  const head = new THREE.Mesh(headGeo, bodyMat);
  head.position.set(0, 0.1, 0.4);
  bat.add(head);

  // Ears
  const earGeo = new THREE.ConeGeometry(0.06, 0.2, 4);
  const leftEar = new THREE.Mesh(earGeo, bodyMat);
  leftEar.position.set(-0.1, 0.28, 0.4);
  leftEar.rotation.z = 0.2;
  bat.add(leftEar);

  const rightEar = new THREE.Mesh(earGeo, bodyMat);
  rightEar.position.set(0.1, 0.28, 0.4);
  rightEar.rotation.z = -0.2;
  bat.add(rightEar);

  // Eyes - small glowing orbs
  const eyeGeo = new THREE.SphereGeometry(0.035, 8, 8);
  const eyeMat = new THREE.MeshPhysicalMaterial({
    color: 0xff4444,
    emissive: 0xff2222,
    emissiveIntensity: 0.8
  });
  const leftEye = new THREE.Mesh(eyeGeo, eyeMat);
  leftEye.position.set(-0.09, 0.15, 0.55);
  bat.add(leftEye);

  const rightEye = new THREE.Mesh(eyeGeo, eyeMat);
  rightEye.position.set(0.09, 0.15, 0.55);
  bat.add(rightEye);

  // Wings - using custom shapes
  const wingMat = new THREE.MeshPhysicalMaterial({
    color: 0x3a2a3e,
    emissive: 0x1a0a1e,
    emissiveIntensity: 0.1,
    transparent: true,
    opacity: 0.7,
    roughness: 0.6,
    metalness: 0.05,
    side: THREE.DoubleSide
  });

  function makeWing() {
    const shape = new THREE.Shape();
    // Wing shape: starts at body, extends out and curves
    shape.moveTo(0, 0);
    shape.lineTo(0.15, 0.15);
    shape.lineTo(0.6, 0.3);
    shape.lineTo(1.0, 0.15);
    shape.lineTo(1.2, -0.1);
    shape.lineTo(0.9, -0.15);
    shape.lineTo(0.5, -0.05);
    shape.lineTo(0.2, -0.1);
    shape.lineTo(0, 0);

    const wingGeo = new THREE.ShapeGeometry(shape);
    return new THREE.Mesh(wingGeo, wingMat);
  }

  // Left wing pivot
  const leftWingPivot = new THREE.Group();
  leftWingPivot.position.set(-0.15, 0.05, 0);
  const leftWing = makeWing();
  leftWing.scale.set(-1, 1, 1); // mirror
  leftWingPivot.add(leftWing);
  bat.add(leftWingPivot);
  bat.userData.leftWing = leftWingPivot;

  // Right wing pivot
  const rightWingPivot = new THREE.Group();
  rightWingPivot.position.set(0.15, 0.05, 0);
  const rightWing = makeWing();
  rightWingPivot.add(rightWing);
  bat.add(rightWingPivot);
  bat.userData.rightWing = rightWingPivot;

  // Wing bone lines for detail
  const boneMat = new THREE.LineBasicMaterial({ color: 0x4a3a4e, transparent: true, opacity: 0.5 });

  function addBones(wing, mirror) {
    const s = mirror ? -1 : 1;
    const bones = [
      [0, 0, s * 1.0, 0.15],
      [0, 0, s * 0.8, -0.1],
      [0, 0, s * 0.5, 0.25]
    ];
    for (const b of bones) {
      const pts = [new THREE.Vector3(b[0], b[1], 0), new THREE.Vector3(b[2], b[3], 0)];
      const geo = new THREE.BufferGeometry().setFromPoints(pts);
      wing.add(new THREE.Line(geo, boneMat));
    }
  }

  addBones(leftWing, true);
  addBones(rightWing, false);

  bat.scale.set(1.2, 1.2, 1.2);
  return bat;
}

// Wing flapping animation
function animateModel(model, time) {
  const flap = Math.sin(time * 4) * 0.6;
  if (model.userData.leftWing) {
    model.userData.leftWing.rotation.z = -flap - 0.2;
  }
  if (model.userData.rightWing) {
    model.userData.rightWing.rotation.z = flap + 0.2;
  }
  // Gentle bobbing
  model.position.y = Math.sin(time * 2) * 0.15;
}
