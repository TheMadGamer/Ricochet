/*
 *  ExplodabelComponent.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/13/10.
 *  Copyright 2010 3dDog. All rights reserved.
 *
 */

#import "Entity.h"
#import "ExplodableComponent.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"
#import "PhysicsManager.h"
#import "PhysicsComponent.h"
#import "SceneManager.h"
#import "AudioDispatch.h"
#import "CountExplodable.h"

#import <vector>

using namespace std;

namespace Dog3D
{

  void CountExplodable::Detonate() { 
      
      Explode();
      
      // get fx component				
      vector<Component *> fxComponents;
      mParent->FindComponentsOfType(FX, fxComponents);
      
      // disable
      for(int i = 0; i < fxComponents.size(); i++)
      {
        FXGraphicsComponent *fxComponent = static_cast<FXGraphicsComponent*>( fxComponents[i] );
        fxComponent->mActive = false;
        
      }
      
      AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
      
      btVector3 position = mParent->GetPosition();
      
      if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
      {
        GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
      }
      
      // remove the physics component
      PhysicsComponent *physicsComponent =  mParent->GetPhysicsComponent();
      if(physicsComponent)
      {
        // remove ball from world
        physicsComponent->GetRigidBody()->setLinearVelocity(btVector3(0,0,0));
        physicsComponent->GetRigidBody()->setAngularVelocity(btVector3(0,0,0));
        PhysicsManager::Instance()->MarkForRemoval(physicsComponent);
      }
      
      mParent->GetGraphicsComponent()->mActive = false;
      
  }
  
  // fire ricochet ball
  // explodes after n bumps
  void CountExplodable::OnCollision( Entity *collidesWith )
  { 
    GopherController *controller = collidesWith != NULL ?  dynamic_cast<GopherController*>(collidesWith->GetController()) : NULL;
    
    // NULL = forced explode
    if(collidesWith == NULL)
    {
        Detonate();
    } 
    else
    { 
        if (collidesWith != mLastCollider && ( mTimeWindow > 0.1f || collidesWith != mSecondToLastCollider) ) {
            mSecondToLastCollider = mLastCollider;
            mLastCollider = collidesWith;
            mNBumps++;
            DLog(@"NBumps (%d)++ %s", mNBumps, collidesWith->mDebugName.c_str());
            mTimeWindow = 0;
        }
      
        if (controller != NULL) 
        {
            if (mNBumps == mMaxBumps) {
                Detonate();      
            }
            btVector3 position = mParent->GetPosition();
            
            if(mExplosionType != ELECTRO && mExplosionType != FREEZE && mExplosionType != FIRE)
            {
              GraphicsManager::Instance()->ShowFXElement(position, mExplosionType);
            }
            
            AudioDispatch::Instance()->PlaySound(AudioDispatch::Boom2);
      } else if(mNBumps == mMaxBumps) {
          Detonate();
      }
    }
  }
  
}