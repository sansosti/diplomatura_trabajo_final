class Particle {

  PVector velocity;
  PVector pos;
  float lifespan = 255;
   
  PVector gravity = new PVector(((SENTIDO == IZQUIERDA)?-1:1)*0.1,0); 
  PVector vientoLateral = new PVector(0,0.1);
  
  boolean muertaContada = false;
  
  color colorActual;  

  Particle() {
    pos = new PVector(0,0);

    renacer();
    lifespan = random(255);
  }
  
  void renacer() {
    renacerEn(origenDeParticulas.x,origenDeParticulas.y);
  }
  
  void renacerEn(float x, float y) {
//    println("renacer");
    float a = random(TWO_PI);
    float speed = random(0.5,4);
    velocity = new PVector(cos(a), sin(a));
    velocity.mult(speed);
    lifespan = 255;   
    pos.x = x;
    pos.y = y;
    
    muertaContada = false;
    
    colorActual = color(0,0,0); 
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
    
    if (!yaGane) {
      if (!muertaContada) {
        int i = (int) map(pos.x,0,width,0,fondo.width-1);
        int j = (int) map(pos.y,0,height,0,fondo.height-1);
        //part.setFill(fondo.get(i,j));
        int pixel_index = j*fondo.width+i;
        if ((pixel_index >=0) && (pixel_index < fondo.pixels.length)) {
          colorActual = fondo.pixels[pixel_index];
        }
      } else {
        colorActual = color(255,0,0);
        //part.setTint(color(255,0,0,lifespan));
      }
    } else {
      float max = 1;
      /*
      int verde = (int)(255*map(pos.dist(origenDeParticulas),0,width,max,0));
      int azul  = (int)(255*map(pos.dist(origenDeParticulas),0,width,0,max));
      */
      int azul = (int)map(255-lifespan,0,255,100,255);
      int verde  = (int)map(lifespan,0,255,100,255);
      colorActual = color(0,verde,azul);
    }
    
 }

  public void draw() {
    //ellipse(pos.x,pos.y,10,10);
    int index = (int)(((int)pos.y*width)+(int)pos.x);
//println((int)pos.x + ":" + (int)pos.y + " - " + index + " - w/h: " + width + "/" + height + " - length: " + pixels.length);
//delay(1000);
  //set((int)pos.x,(int)pos.y,color(255,0,0));
    if ((index >= 0) && (index < pixels.length)) {
      pixels[index] = colorActual;
    }
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
