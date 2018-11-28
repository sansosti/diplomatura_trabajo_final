class ParticleSystem {
  ArrayList<Particle> particles;

  ParticleSystem(int n) {
    particles = new ArrayList<Particle>();

    for (int i = 0; i < n; i++) {
      Particle p = new Particle();
      particles.add(p);
    }
  }

  void update() {
    for (Particle p : particles) {
      p.update();
    }
  }

  void display() {
    loadPixels();
    for (Particle p : particles) {
      p.draw();
    }    
    updatePixels();
    
  }
}
