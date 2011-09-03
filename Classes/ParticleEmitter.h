//
//  ParticleEmitter.h
//  Grenades
//
//  Created by Anthony Lobay on 9/1/11.
//  Copyright (c) 2011 3dDogStudios. All rights reserved.
//

#import <btBulletDynamicsCommon.h>

#import <map>
#import <list>

#import "GraphicsComponent.h"

namespace Dog3D
{
  
  struct Particle
  {
    btVector3 position;
    btVector3 velocity;
    float attenuation;
    
  };
  
	class ParticleEmitter : public GraphicsComponent
  {
  public:
     
    ParticleEmitter(float emitterRate) : 
    mEmitterRate(emitterRate),
    mDX(0.2), 
    mDZ(0.2), 
    mParticlesToEmit(0){}
    
    virtual ~ParticleEmitter(){}
    
		virtual void Update(float deltaTime);
    
    
  private:
    
    void Draw();
    
    void UpdateSimulation(float dt);
    
    // list of point locations
    std::list<Particle*> mParticles;
    
    // TODO add list of color attenuations
    float mEmitterRate;
    
    float mDX;
    float mDZ;
    
    float mParticlesToEmit;
    
  };
  
}

