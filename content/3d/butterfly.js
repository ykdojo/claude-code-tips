// Butterfly model with flapping wings
function createModel() {
  const group = new THREE.Group();

  // Body - thin dark cylinder
  const bodyGeo = new THREE.CylinderGeometry(0.04, 0.03, 0.8, 8);
  const bodyMat = new THREE.MeshPhysicalMaterial({
    color: 0x2a1a2e,
    roughness: 0.3,
    metalness: 0.1
  });
  const body = new THREE.Mesh(bodyGeo, bodyMat);
  group.add(body);

  // Wing shape (one side, two lobes)
  const wingShape = new THREE.Shape();
  wingShape.moveTo(0, 0);
  // Upper lobe
  wingShape.bezierCurveTo(0.15, 0.3, 0.5, 0.55, 0.65, 0.35);
  wingShape.bezierCurveTo(0.75, 0.2, 0.7, 0.05, 0.55, 0);
  // Lower lobe
  wingShape.bezierCurveTo(0.65, -0.1, 0.55, -0.35, 0.35, -0.3);
  wingShape.bezierCurveTo(0.15, -0.25, 0.05, -0.1, 0, 0);

  const wingMat = new THREE.MeshPhysicalMaterial({
    color: 0xff69b4,
    emissive: 0xff69b4,
    emissiveIntensity: 0.15,
    transparent: true,
    opacity: 0.7,
    roughness: 0.2,
    metalness: 0.1,
    side: THREE.DoubleSide
  });

  // Right wing
  const rightWing = new THREE.Mesh(new THREE.ShapeGeometry(wingShape), wingMat);
  group.add(rightWing);

  // Left wing (mirrored)
  const leftWingGeo = new THREE.ShapeGeometry(wingShape);
  leftWingGeo.scale(-1, 1, 1);
  const leftWing = new THREE.Mesh(leftWingGeo, wingMat);
  group.add(leftWing);

  // Store references for animation
  group.userData.rightWing = rightWing;
  group.userData.leftWing = leftWing;

  return group;
}

function animateModel(model, time) {
  const angle = Math.sin(time * 3) * 0.6;
  model.userData.rightWing.rotation.y = angle;
  model.userData.leftWing.rotation.y = -angle;
}
