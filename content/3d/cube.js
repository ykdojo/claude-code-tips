// Pink cube model
function createModel() {
  const geo = new THREE.BoxGeometry(1.5, 1.5, 1.5);
  const mat = new THREE.MeshPhysicalMaterial({
    color: 0xff69b4,
    emissive: 0xff69b4,
    emissiveIntensity: 0.1,
    transparent: true,
    opacity: 0.55,
    roughness: 0.1,
    metalness: 0.2,
    side: THREE.DoubleSide
  });
  const mesh = new THREE.Mesh(geo, mat);

  // Wireframe edges
  const edgesGeo = new THREE.EdgesGeometry(geo);
  const edgesMat = new THREE.LineBasicMaterial({ color: 0xff69b4, transparent: true, opacity: 0.8 });
  const edges = new THREE.LineSegments(edgesGeo, edgesMat);
  mesh.add(edges);

  return mesh;
}
