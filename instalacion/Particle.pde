class Particle {

 
  PVector velocity;
  PVector pos;
  float lifespan = 255;
  
  PShape part;
  float partSize;
  
  PVector gravity = new PVector(((SENTIDO == IZQUIERDA)?-1:1)*0.1,0);
  
  PVector vientoLateral = new PVector(0,0.1);
  
  boolean muertaContada = false;

  Particle() {
    pos = new PVector(0,0);
    //partSize = random(10,60);
    partSize = 5;
    part = createShape();
    part.beginShape(QUAD);
    part.noStroke();
    part.normal(0, 0, 1);
    part.vertex(-partSize/2, -partSize/2);
    part.vertex(+partSize/2, -partSize/2);
    part.vertex(+partSize/2, +partSize/2);
    part.vertex(-partSize/2, +partSize/2);
    part.endShape();
    
    renacer();
    lifespan = random(255);
  }

  PShape getShape() {
    return part;
  }
  
  void renacer() {
    renacerEn(origenDeParticulas.x,origenDeParticulas.y);
  }
  void renacerEn(float x, float y) {
    float a = random(TWO_PI);
    float speed = random(0.5,4);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    lifespan = 255;   
    part.resetMatrix();
    part.translate(x, y);
    pos.x = x;
    pos.y = y;
    
    muertaContada = false;
  }
  
  boolean isDead() {
    if (lifespan < 0) {
     return true;
    } else {
     return false;
    } 
  }
  

  public void update() {
    if (isDead()) {
      renacer();
    }
    lifespan = lifespan - 1;

    float prev_pos_x = pos.x;
    
    //rebotar(mouseX,mouseY);
    //rebotar(mouseX-100,mouseY);
    float maxPuntoRef_x = ((SENTIDO == IZQUIERDA)?0:10000);
    for (PVector puntoRef : puntosRef) {
      rebotar((int)puntoRef.x,(int)puntoRef.y);
      
      if (
          ((SENTIDO == IZQUIERDA) && (puntoRef.x > maxPuntoRef_x))
          ||
          ((SENTIDO == DERECHA) && (puntoRef.x < maxPuntoRef_x))
          ){
        maxPuntoRef_x = puntoRef.x;
      }
    }
    
    velocity.add(gravity);
    
    //part.texture(fondo);
    //part.setTint(color(255,lifespan));
    pos.x += velocity.x;
    pos.y += velocity.y;
    
    boolean pasoElUmbral = (SENTIDO == IZQUIERDA)?(maxPuntoRef_x > UMBRAL_DE_INICIO):(maxPuntoRef_x < width - UMBRAL_DE_INICIO);
    boolean aMorir = (SENTIDO == IZQUIERDA)?(pos.x < maxPuntoRef_x - MARGEN_MUERTE):(pos.x > maxPuntoRef_x + MARGEN_MUERTE);
    
    if ( !muertaContada && pasoElUmbral && aMorir && (pos.x > 0) && (pos.y >= CENTRO_DEL_CAMINO-anchoBanda/2)  && (pos.y < CENTRO_DEL_CAMINO+anchoBanda/2)) {
    //if ( !muertaContada && (pos.x > width)) {  
      muertas++;
      muertaContada = true;
    }
    
    if (!muertaContada) {
      int i = (int) map(pos.x,0,width,0,fondo.width-1);
      int j = (int) map(pos.y,0,height,0,fondo.height-1);
      //part.setFill(fondo.get(i,j));
      int pixel_index = j*fondo.width+i;
      if ((pixel_index >=0) && (pixel_index < fondo.pixels.length)) {
        part.setFill(fondo.pixels[pixel_index]);
      }
    } else {
      part.setFill(color(255,0,0));
      //part.setTint(color(255,0,0,lifespan));
    }

    part.translate(velocity.x, velocity.y);

  }
  
  private void rebotar(int x, int y)
  {
    // Compute a vector that points from location to mouse
    PVector ref = new PVector(x,y);
    float dist = ref.dist(pos);
    
    if (dist < 100) {
      PVector acceleration = PVector.sub(pos,ref);
      // Set magnitude of acceleration
      acceleration.setMag(1.1);
      velocity.add(acceleration);
    }
    
    //if (pos.x < mouseX) {
     if ((SENTIDO == IZQUIERDA)?pos.x < x:pos.x > x) {
      if (pos.y > height/2) {
        velocity.sub(vientoLateral);
      } else {
        velocity.add(vientoLateral);
      };
    }
  }
}
