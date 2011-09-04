//
//  ParticleEmitter.mm
//  Grenades
//
//  Created by Anthony Lobay on 9/1/11.
//  Copyright (c) 2011 3dDogStudios. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <iostream>
#import "ParticleEmitter.h"
#import "GraphicsManager.h"

using namespace Dog3D;
using namespace std;

void ParticleEmitter::Update(float deltaTime)
{
  UpdateSimulation(deltaTime);
  Draw();
}

void ParticleEmitter::UpdateSimulation(float dt)
{

  while(mParticlesToEmit >= 1)
  {
    // create a particle
    Particle *p = new Particle();
    p->position = GetParent()->GetPosition();
    p->velocity = btVector3(1,0,1);
    
    mParticles.push_back(p);
    mParticlesToEmit -= 1.0f;
  }
  
  mParticlesToEmit += mEmitterRate * dt;
  
  // move particles along
  for( list<Particle*>::iterator it = mParticles.begin();
      it != mParticles.end(); ++it)
  {
    Particle *p = *it;
    p->position = p->position + p->velocity * dt;
  }
  
  
  // remove a particle
  
}

void ParticleEmitter::Draw()
{
  
  // setup
  GraphicsManager::Instance()->SetupLineDrawing();
  
  glColor4f(1,0,0,1);
  
  btVector3 pos =  GetParent()->GetPosition();
  glPushMatrix();

  glTranslatef(pos.x(), pos.y(), pos.z());
  
  int nQuads = mParticles.size();
  
  Vec3 *verts = (Vec3*) alloca(sizeof(Vec3)*nQuads * 6);
    
  Vec3 *vp = verts;
  
  for( list<Particle*>::iterator it = mParticles.begin();
      it != mParticles.end(); ++it)
  {
    btVector3 pos = (*it)->position;
    *vp++ = Vec3( pos.x() - mDX, pos.y(), pos.z() - mDZ );
    *vp++ = Vec3( pos.x() + mDX, pos.y(), pos.z() - mDZ );
    *vp++ = Vec3( pos.x() - mDX, pos.y(), pos.z() + mDZ );

    *vp++ = Vec3( pos.x() + mDX, pos.y(), pos.z() - mDZ );
    *vp++ = Vec3( pos.x() - mDX, pos.y(), pos.z() + mDZ );
    *vp++ = Vec3( pos.x() + mDX, pos.y(), pos.z() + mDZ );
  }
  
  // To-Do: add support for creating and holding a display list
  glVertexPointer(3, GL_FLOAT, 0, verts);
  
  glDrawArrays(GL_TRIANGLES, 0, nQuads * 6);
  
  
  glPopMatrix();
  
  // cleanup
  GraphicsManager::Instance()->DisableLineDrawing();
  
}