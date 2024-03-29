/*
 *  GenericsFactory.mm
 *  Gopher
 *
 *  Created by Anthony Lobay on 4/9/11.
 *  Copyright 2011 3dDogStudios.com. All rights reserved.
 *
 */


#import <btBulletDynamicsCommon.h>

#import "GateFactory.h"

#import "GraphicsComponent.h"
#import "GraphicsComponentFactory.h"
#import "GraphicsManager.h"

#import "PhysicsComponent.h"
#import "PhysicsComponentFactory.h"
#import "PhysicsManager.h"

#import "GamePlayManager.h"
#import "GopherController.h"
#import "SpawnComponent.h"
#import "TargetComponent.h"
#import "ExplodableComponent.h"
#import "SceneManager.h"
#import "CannonController.h"
#import "GateController.h"
#import "SpinnerController.h"

#import <vector>

const float kFixedHeight = 10;
const float kFrogScale = 2.0f;
using namespace Dog3D;
using namespace std;

// TODO return a pair
pair<Entity *, Entity *> GateFactory::BuildSpinnerGate( btVector3 &initialPosition, btVector3 &halfExtents, 
                                                      float yRotation, float restitution,
                                                      NSString *gateTextureName, NSString *targetTextureName,
                                                      float graphicsScale, float triggerX, float triggerZ)
{
	
	Entity *gate = new Entity();
	{
        gate->SetPosition(initialPosition);
        
        btMatrix3x3 rotation;
        rotation.setEulerZYX(0, 0, yRotation);
        gate->SetRotation(rotation);
        
#if DEBUG
        gate->mDebugName = [targetTextureName UTF8String];
#endif
        
        GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
                                                                                     halfExtents.z()*2.0f * graphicsScale, 
                                                                                     gateTextureName);
        
        GraphicsManager::Instance()->AddComponent(graphicsComponent);
        gate->SetGraphicsComponent(graphicsComponent);	
        
        PhysicsComponentInfo info;
        info.mIsStatic = false;
        info.mRestitution = restitution;
        info.mDoesNotSleep = false;
        info.mCanRotate = true;
        info.mCollisionGroup = GRP_FIXED;
        info.mCollidesWith = GRP_BALL | GRP_GOPHER;
        
        PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info );
        
        PhysicsManager::Instance()->AddComponent( physicsBox );
        
        gate->SetPhysicsComponent( physicsBox );
        physicsBox->AddHingeMotor();
        
    }
    
	GateController *gateCtl = new GateController(PI/2.0f, 10.0f, 0.0f, -PI/2.0f );
	gate->AddComponent(gateCtl);
	
    
    btVector3 triggerPosition(triggerX, initialPosition.y(), triggerZ);
    Entity *trigger = new Entity();
    trigger->SetPosition(triggerPosition);
    {
        GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildHoldLastAnim(graphicsScale*kFrogScale, 
                                                                                           graphicsScale*kFrogScale, 
                                                                                           targetTextureName, 
                                                                                           4,
                                                                                           2);
        
        GraphicsManager::Instance()->AddComponent(graphicsComponent);
        trigger->SetGraphicsComponent(graphicsComponent);	
        
        PhysicsComponentInfo info;
        info.mIsStatic = true;
        info.mRestitution = restitution;
        info.mDoesNotSleep = false;
        info.mCanRotate = false;
        info.mCollisionGroup = GRP_EXPLODABLE;
        info.mCollidesWith = GRP_BALL | GRP_GOPHER;
        
        PhysicsComponent *physicsCyl = PhysicsComponentFactory::BuildCylinder(halfExtents.x(), 
                                                                              halfExtents.y(), 
                                                                              triggerPosition, 
                                                                              info);
        
        PhysicsManager::Instance()->AddComponent( physicsCyl );
        trigger->SetPhysicsComponent( physicsCyl );
        
        TriggerComponent *triggerCtl = new TriggerComponent(gateCtl);
        trigger->SetExplodable(triggerCtl);
        GamePlayManager::Instance()->AddExplodable(triggerCtl);
        
    }
    
	return pair<Entity *, Entity*>(gate, trigger);
	
}


// TODO return a pair
pair<Entity *, Entity *> GateFactory::BuildDrivenGate( btVector3 &initialPosition, btVector3 &halfExtents, 
                                                             float yRotation, float restitution,
                                                             NSString *gateTextureName, NSString *targetTextureName,
                                                             float graphicsScale, float triggerX, float triggerZ)
{
	
	Entity *gate = new Entity();
	{
        gate->SetPosition(initialPosition);
        
        btMatrix3x3 rotation;
        rotation.setEulerZYX(0, 0, yRotation);
        gate->SetRotation(rotation);
        
#if DEBUG
        gate->mDebugName = [targetTextureName UTF8String];
#endif
        
        GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
                                                                                     halfExtents.z()*2.0f * graphicsScale, 
                                                                                     gateTextureName);
        
        GraphicsManager::Instance()->AddComponent(graphicsComponent);
        gate->SetGraphicsComponent(graphicsComponent);	
        
        PhysicsComponentInfo info;
        info.mIsStatic = false;
        info.mRestitution = restitution;
        info.mDoesNotSleep = false;
        info.mCanRotate = true;
        info.mCollisionGroup = GRP_FIXED;
        info.mCollidesWith = GRP_BALL | GRP_GOPHER;
        
        PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info);
        
        PhysicsManager::Instance()->AddComponent( physicsBox );
        
        gate->SetPhysicsComponent( physicsBox );
        physicsBox->AddHingeMotorWithTarget(PI/2.0f);
        
    }
    
	GateController *gateCtl = new GateController(PI/2.0f, 10.0f, 0.0f, -PI/2.0f );
    gateCtl->mFreeSpinner = false;
	gate->AddComponent(gateCtl);
	
    
    btVector3 triggerPosition(triggerX, initialPosition.y(), triggerZ);
    Entity *trigger = new Entity();
    trigger->SetPosition(triggerPosition);
    {
        GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildHoldLastAnim(graphicsScale*kFrogScale, 
                                                                                           graphicsScale*kFrogScale, 
                                                                                           targetTextureName, 
                                                                                           4,
                                                                                           2);
        
        GraphicsManager::Instance()->AddComponent(graphicsComponent);
        trigger->SetGraphicsComponent(graphicsComponent);	
        
        PhysicsComponentInfo info;
        info.mIsStatic = true;
        info.mRestitution = restitution;
        info.mDoesNotSleep = false;
        info.mCanRotate = false;
        info.mCollisionGroup = GRP_EXPLODABLE;
        info.mCollidesWith = GRP_BALL | GRP_GOPHER;
        
        // Scale down cactus collider size
        PhysicsComponent *physicsCyl = PhysicsComponentFactory::BuildCylinder(halfExtents.x()*0.5f, 
                                                                              halfExtents.y()*0.5f, 
                                                                              triggerPosition, 
                                                                              info);
        
        PhysicsManager::Instance()->AddComponent( physicsCyl );
        trigger->SetPhysicsComponent( physicsCyl );
        
        TriggerComponent *triggerCtl = new TriggerComponent(gateCtl);
        trigger->SetExplodable(triggerCtl);
        triggerCtl->mSoundEffect = AudioDispatch::Boing1;
        
        GamePlayManager::Instance()->AddExplodable(triggerCtl);
        
    }
    
	return pair<Entity *, Entity*>(gate, trigger);
	
}




Entity *GateFactory::BuildSpinner( btVector3 &initialPosition, btVector3 &halfExtents, 
                                        float yRotation, float restitution, NSString *textureName,
                                        float graphicsScale)
{
	
	Entity *newEntity = new Entity();
	newEntity->SetPosition(initialPosition);
	
	btMatrix3x3 rotation;
	rotation.setEulerZYX(0, 0, yRotation);
	newEntity->SetRotation(rotation);
	
#if DEBUG
	newEntity->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
																				 halfExtents.z()*2.0f * graphicsScale, 
																				 textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newEntity->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = false;
	info.mRestitution = restitution;
	info.mDoesNotSleep = true;
	info.mCanRotate = true;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL | GRP_GOPHER;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info );
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newEntity->SetPhysicsComponent( physicsBox );
    
    physicsBox->AddHingeMotor();
    
	return newEntity;
	
}

