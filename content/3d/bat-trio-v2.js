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

    // Body (slim, matching flat model)
    const bodyGeo = new THREE.SphereGeometry(0.18, 16, 16);
    const body = new THREE.Mesh(bodyGeo, batMat);
    body.scale.set(1.0, 2.2, 0.8);
    group.add(body);

    // Head
    const headGeo = new THREE.SphereGeometry(0.18, 16, 16);
    const head = new THREE.Mesh(headGeo, batMat);
    head.position.set(0, 0.45, 0.05);
    group.add(head);

    // Snout
    const snoutGeo = new THREE.SphereGeometry(0.07, 12, 12);
    const snout = new THREE.Mesh(snoutGeo, batMat);
    snout.scale.set(0.8, 0.6, 1.0);
    snout.position.set(0, 0.4, 0.2);
    group.add(snout);

    // Ears
    const earGeo = new THREE.ConeGeometry(0.06, 0.2, 8);
    [-1, 1].forEach(s => {
      const ear = new THREE.Mesh(earGeo, batMat);
      ear.position.set(0.1 * s, 0.62, 0.02);
      ear.rotation.z = -0.15 * s;
      group.add(ear);
    });

    // Eyes
    const eyeMat = new THREE.MeshBasicMaterial({ color: 0xff4444 });
    const eyeGeo = new THREE.SphereGeometry(0.035, 8, 8);
    [-1, 1].forEach(s => {
      const eye = new THREE.Mesh(eyeGeo, eyeMat);
      eye.position.set(0.08 * s, 0.48, 0.18);
      group.add(eye);
    });

    // Wings
    function makeWing(xSign) {
      const wingGroup = new THREE.Group();
      // Wing membrane (same shape as flat model)
      const memShape = new THREE.Shape();
      memShape.moveTo(0, 0);
      memShape.quadraticCurveTo(0.4 * xSign, 0.3, 0.8 * xSign, 0.15);
      memShape.quadraticCurveTo(0.7 * xSign, 0.0, 0.9 * xSign, -0.1);
      memShape.quadraticCurveTo(0.75 * xSign, -0.15, 0.6 * xSign, -0.2);
      memShape.quadraticCurveTo(0.45 * xSign, -0.1, 0.35 * xSign, -0.25);
      memShape.quadraticCurveTo(0.15 * xSign, -0.15, 0, -0.3);
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
    leftWing.position.set(-0.12, 0.05, 0);
    const rightWing = makeWing(1);
    rightWing.position.set(0.12, 0.05, 0);
    group.add(leftWing);
    group.add(rightWing);

    // Hind feet with claws
    [-1, 1].forEach(s => {
      const legGeo = new THREE.CylinderGeometry(0.015, 0.01, 0.12, 6);
      const leg = new THREE.Mesh(legGeo, batMat);
      leg.position.set(0.06 * s, -0.42, 0);
      group.add(leg);
      const clawGeo = new THREE.CylinderGeometry(0.006, 0.002, 0.06, 4);
      [-1, 0, 1].forEach(t => {
        const claw = new THREE.Mesh(clawGeo, batMat);
        claw.position.set(0.06 * s + 0.015 * t, -0.49, 0);
        claw.rotation.z = 0.15 * t;
        group.add(claw);
      });
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
    // Correct facing, but standing upright
    bat.rotation.y = Math.PI;
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
