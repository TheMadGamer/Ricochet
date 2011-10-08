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

bool TooFar(Particle *p)
{
    return p->position.length() > 30;
}

void ParticleEmitter::UpdateSimulation(float dt)
{

    while(mParticlesToEmit >= 1)
    {
        // create a particle
        Particle *p = new Particle();
        p->position = GetParent()->GetPosition();
          
        float theta = (float) random()/RAND_MAX * PI * 2.0f;
        float mag = (float)  random()/RAND_MAX * 10.0f + 1.0f; 
        
        p->velocity = btVector3(sin(theta) * mag ,0,cos(theta) * mag);

        mParticles.push_back(p);
        mParticlesToEmit -= 1.0f;
    }
    
    // remove if outside bounds
    mParticles.remove_if(TooFar);
    
    
    mParticlesToEmit += mEmitterRate * dt;

    // move particles along
    for( list<Particle*>::iterator it = mParticles.begin();
      it != mParticles.end(); ++it)
    {
        Particle *p = *it;
        p->position = p->position + p->velocity * dt;
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
    Texture2D *leaf = GraphicsManager::Instance()->GetTexture(@"Leaf");
    
    [leaf enable];
    
    glColor4f(1,0,0,1);

    btVector3 pos =  GetParent()->GetPosition();

    int nQuads = mParticles.size();
    
    assert(nQuads * 6 < nDrawVerts);
    
    Vec3 *vp = mDrawVerts;

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
    glVertexPointer(3, GL_FLOAT, 0, mDrawVerts);
    
    Vec2 *tp = mTexVerts;
    for(int i = 0; i < nQuads ; i++)
    {
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
    for(int i = 0; i < nQuads * 6;i++)
    {
        *cp++ = Color(1,1,1,1);
    }
    
    glColorPointer(4, GL_FLOAT, 0, mColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, nQuads * 6 );
    
    glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	
	glDisable(GL_TEXTURE_2D);
    
}