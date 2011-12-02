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

static float gAttenuation = 0.99f;

void ParticleEmitter::Update(float deltaTime)
{
    if(GetParent()->mActive)
    {
        UpdateSimulation(deltaTime);
        Draw();
    }
}

bool TooFar(Particle *p)
{   
    float len = p->position.length();
    return len > 30.0;
}

bool ZeroAttenuation(Particle *p)
{
    return p->attenuation <= 0.001f;
}

void Attenuate(Particle *p)
{
    p->attenuation *= gAttenuation;
}

void ParticleEmitter::UpdateSimulation(float dt)
{

    while(mParticlesToEmit >= 1)
    {
        // create a particle
        Particle *p = new Particle();
        p->position = GetParent()->GetPosition();
        float theta = (float) random()/RAND_MAX * PI * 2.0f;
        float mag = (float) random()/RAND_MAX * mVelocityMagnitude + mVelocityMagnitude; 
        
        

        //NSLog(@"Particle %f %f %f ", p->position.x(), p->position.y(), p->position.z());
        if (mSpread ) 
        {
            p->velocity = btVector3(sin(theta) * mag ,0,cos(theta) * mag);
            p->position = p->position + p->velocity * (float) random()/RAND_MAX * mVelocityMagnitude;
        }
        else
        { 
            p->velocity = btVector3(0,0,0);
        }
        
        mParticles.push_back(p);
        mParticlesToEmit -= 1.0f;
    }
    //size_t prevSize =  mParticles.size();
    // remove if outside bounds
    mParticles.remove_if(TooFar);
    mParticles.remove_if(ZeroAttenuation);
    //DLog(@"%lu particles before, now %lu", prevSize, mParticles.size());
    
    // 
    gAttenuation = 1.0f - (mParticleAttenuation * dt);
    for_each(mParticles.begin(), mParticles.end(), Attenuate);
    
    mParticlesToEmit += (float) random()/RAND_MAX * mEmitterRate * dt;

    // move particles along
    for( list<Particle*>::iterator it = mParticles.begin();
      it != mParticles.end(); ++it)
    {
        Particle *p = *it;
        // trick - slow velocity based on attenuation
        p->position = p->position + p->velocity * dt * p->attenuation;
    }
}

void ParticleEmitter::Draw()
{
  
    // setup textured drawing
    //setup blending
    glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
	glDisable(GL_DEPTH_TEST);

    glEnable(GL_TEXTURE_2D);
    Texture2D *leaf = GraphicsManager::Instance()->GetTexture(mTexture);
    
    [leaf enable];
    
    glColor4f(1,1,1,1);

    //btVector3 pos =  GetParent()->GetPosition();

    int nParticles = mParticles.size();
    
    //assert(nParticles * 6 < nDrawVerts);
    
    Vec3 *vp = mDrawVerts;

    int cnt = 0;
    for( list<Particle*>::iterator it = mParticles.begin();
      it != mParticles.end(); ++it)
    {
        if (cnt >= nDrawVerts) 
        {
          break;
        } 
        else 
        {
          cnt += 6;
        }

        btVector3 pos = (*it)->position;
                
        *vp++ = Vec3( pos.x() - mDX, 1, pos.z() - mDZ );
        *vp++ = Vec3( pos.x() + mDX, 1, pos.z() - mDZ );
        *vp++ = Vec3( pos.x() - mDX, 1, pos.z() + mDZ );

        *vp++ = Vec3( pos.x() + mDX, 1, pos.z() - mDZ );
        *vp++ = Vec3( pos.x() - mDX, 1, pos.z() + mDZ );
        *vp++ = Vec3( pos.x() + mDX, 1, pos.z() + mDZ );
    }

    // To-Do: add support for creating and holding a display list
    glVertexPointer(3, GL_FLOAT, 0, mDrawVerts);
    
    Vec2 *tp = mTexVerts;
    cnt = 0;
    for(int i = 0; i < nParticles ; i++)
    {
    
        if (cnt >= nDrawVerts) 
        {
          break;
        } 
        else 
        {
          cnt += 6;
        }

        *tp++ = Vec2(0,0);
        *tp++ = Vec2(1,0);
        *tp++ = Vec2(0,1);
        
        *tp++ = Vec2(1,0);
        *tp++ = Vec2(0,1);
        *tp++ = Vec2(1,1);
    }
    
    glTexCoordPointer(2, GL_FLOAT, 0, mTexVerts);	
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // TODO - try colors
    Color *cp = mColors;
    cnt = 0;
    for( list<Particle*>::iterator it = mParticles.begin();
        it != mParticles.end(); ++it)
    {
        if (cnt >= nDrawVerts) 
        {
          break;
        } 
        else 
        {
          cnt += 6;
        }

        *cp++ = Color(1,1,1,(*it)->attenuation);
        *cp++ = Color(1,1,1,(*it)->attenuation);
        *cp++ = Color(1,1,1,(*it)->attenuation);
        *cp++ = Color(1,1,1,(*it)->attenuation);
        *cp++ = Color(1,1,1,(*it)->attenuation);
        *cp++ = Color(1,1,1,(*it)->attenuation);
    }
    
    glColorPointer(4, GL_FLOAT, 0, mColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    int nToDraw = (nParticles * 6 > nDrawVerts) ? nDrawVerts : nParticles * 6;
    glDrawArrays(GL_TRIANGLES, 0, nToDraw );
    
    glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	
	glDisable(GL_TEXTURE_2D);
    
}