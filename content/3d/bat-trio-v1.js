// Three bats circling around each other
function createModel() {
  const scene = new THREE.Group();

  const batMat = new THREE.MeshPhysicalMaterial({
    color: 0x6a0dad,
    emissive: 0x6a0dad,
    emissiveIntensity: 0.15,
    roughness: 0.4,
    metalness: 0.1,
    side: THREE.DoubleSide
  });

  const membraneMat = new THREE.MeshPhysicalMaterial({
    color: 0x5a0aad,
    emissive: 0x5a0aad,
    emissiveIntensity: 0.1,
    transparent: true,
    opacity: 0.6,
    roughness: 0.5,
    metalness: 0.0,
    side: THREE.DoubleSide
  });

  function makeBat() {
    const group = new THREE.Group();

    // Body
    const bodyGeo = new THREE.SphereGeometry(0.3, 16, 16);
    const body = new THREE.Mesh(bodyGeo, batMat);
    body.scale.set(0.8, 1.3, 0.7);
    group.add(body);

    // Head
    const headGeo = new THREE.SphereGeometry(0.22, 16, 16);
    const head = new THREE.Mesh(headGeo, batMat);
    head.position.set(0, 0.45, 0.1);
    group.add(head);

    // Snout
    const snoutGeo = new THREE.SphereGeometry(0.1, 12, 12);
    const snout = new THREE.Mesh(snoutGeo, batMat);
    snout.scale.set(0.8, 0.6, 1.0);
    snout.position.set(0, 0.4, 0.3);
    group.add(snout);

    // Ears
    const earGeo = new THREE.ConeGeometry(0.08, 0.25, 8);
    [-1, 1].forEach(s => {
      const ear = new THREE.Mesh(earGeo, batMat);
      ear.position.set(0.12 * s, 0.68, 0.05);
      ear.rotation.z = -0.15 * s;
      group.add(ear);
    });

    // Eyes
    const eyeMat = new THREE.MeshBasicMaterial({ color: 0xff4444 });
    const eyeGeo = new THREE.SphereGeometry(0.04, 8, 8);
    [-1, 1].forEach(s => {
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(0.1 * s, 0.5, 0.28);
      group.add(eye);
    });

    // Wings
    function makeWing(xSign) {
      const wingGroup = new THREE.Group();
      const boneGeo = new THREE.CylinderGeometry(0.015, 0.01, 0.7, 6);
      const upperArm = new THREE.Mesh(boneGeo, batMat);
      upperArm.rotation.z = (Math.PI / 2) * xSign;
      upperArm.position.set(0.35 * xSign, 0.1, 0);
      wingGroup.add(upperArm);

      const fingerGeo = new THREE.CylinderGeometry(0.01, 0.005, 0.5, 6);
      [-0.3, 0.0, 0.3, 0.55].forEach(angle => {
        const finger = new THREE.Mesh(fingerGeo, batMat);
        finger.position.set(0.7 * xSign, 0.1, 0);
        finger.rotation.z = ((Math.PI / 2) + angle) * xSign;
        finger.position.y += Math.cos(angle) * 0.15;
        finger.position.x += Math.sin(angle) * 0.15 * xSign;
        wingGroup.add(finger);
      });

      const memShape = new THREE.Shape();
      memShape.moveTo(0, 0.15);
      memShape.lineTo(0.7 * xSign, 0.3);
      memShape.quadraticCurveTo(0.85 * xSign, 0.15, 0.9 * xSign, 0.0);
      memShape.quadraticCurveTo(0.8 * xSign, -0.05, 0.7 * xSign, -0.1);
      memShape.quadraticCurveTo(0.55 * xSign, -0.15, 0.45 * xSign, -0.2);
      memShape.quadraticCurveTo(0.3 * xSign, -0.1, 0.2 * xSign, -0.25);
      memShape.lineTo(0, -0.35);
      memShape.closePath();

      const memGeo = new THREE.ShapeGeometry(memShape);
      const membrane = new THREE.Mesh(memGeo, membraneMat);
      membrane.position.z = 0.005;
      wingGroup.add(membrane);
      const memBack = new THREE.Mesh(memGeo, membraneMat);
      memBack.position.z = -0.005;
      wingGroup.add(memBack);

      return wingGroup;
    }

    const leftWing = makeWing(-1);
    const rightWing = makeWing(1);
    group.add(leftWing);
    group.add(rightWing);

    // Feet
    const footGeo = new THREE.SphereGeometry(0.04, 8, 8);
    [-1, 1].forEach(s => {
      const foot = new THREE.Mesh(footGeo, batMat);
      foot.position.set(0.1 * s, -0.45, 0);
      group.add(foot);
    });

    group.userData.leftWing = leftWing;
    group.userData.rightWing = rightWing;
    return group;
  }

  // Create 3 bats in orbit pivots
  const bats = [];
  for (var i = 0; i < 3; i++) {
    var pivot = new THREE.Group();
    var bat = makeBat();
    bat.scale.set(0.7, 0.7, 0.7);
    bat.position.x = 1.5;
    // No rotation - bats face inward (wrong)
    pivot.rotation.y = (Math.PI * 2 / 3) * i;
    // Stagger heights
    bat.position.y = (i - 1) * 0.3;
    pivot.add(bat);
    scene.add(pivot);
    bats.push({ pivot: pivot, bat: bat });
  }

  scene.userData.bats = bats;
  return scene;
}

function animateModel(model, time) {
  var bats = model.userData.bats;
  for (var i = 0; i < bats.length; i++) {
    var b = bats[i];
    // Orbit
    b.pivot.rotation.y = (Math.PI * 2 / 3) * i + time * 0.8;

    // Wing flap
    var flapAngle = Math.sin(time * 5 + i * 2) * 0.5;
    b.bat.userData.leftWing.rotation.y = flapAngle;
    b.bat.userData.rightWing.rotation.y = -flapAngle;

    var tilt = Math.sin(time * 5 + i * 2) * 0.1;
    b.bat.userData.leftWing.rotation.x = tilt;
    b.bat.userData.rightWing.rotation.x = tilt;

    // Bobbing
    b.bat.position.y = (i - 1) * 0.3 + Math.sin(time * 2 + i * 1.5) * 0.15;
  }
}
