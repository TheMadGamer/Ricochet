/*
 *  ball.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 1/19/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>

#import "GameEntityFactory.h"

#import "GraphicsComponent.h"
#import "GraphicsComponentFactory.h"
#import "GraphicsManager.h"
#import "ParticleEmitter.h"
#import "BurstEmitter.h"

#import "PhysicsComponent.h"
#import "PhysicsComponentFactory.h"
#import "PhysicsManager.h"

#import "CountExplodable.h"
#import "GamePlayManager.h"
#import "GopherController.h"
#import "SpawnComponent.h"
#import "TargetComponent.h"
#import "ExplodableComponent.h"
#import "SceneManager.h"
#import "CannonController.h"
#import <vector>

using namespace std;
using namespace Dog3D;

const float kFixedHeight = 10;

/// not added to phys mgr or game play mgr
Entity *GameEntityFactory::BuildBall( float radius, 
									 btVector3 &initialPosition, 
									 float restitution, 
									 float mass,
									 ExplodableComponent::ExplosionType explosionType, 
									 float friction)
{
	
	Entity *newBall = new Entity();
#if DEBUG
	newBall->mDebugName = "Ball";
#endif
	
	newBall->SetPosition(initialPosition);
	
	NSString *textureName = nil;
	FXGraphicsComponent *fxComponent = NULL;
	ParticleEmitter *emitter = NULL; 
    bool timeBomb = true;
    int maxBumps = 10;
    
	switch (explosionType)
	{
		case ExplodableComponent::MUSHROOM:
		case ExplodableComponent::EXPLODE_SMALL:
			textureName = @"Black";
			fxComponent =  GraphicsComponentFactory::BuildBillBoardElement(radius*2.0f, radius* 2.0f, @"BombFuse", 2, 2, 4, radius + 0.1f);
            emitter = new ParticleEmitter(100.0f, 4, @"sparkle", false);
			break;
			
		case ExplodableComponent::FIRE:
            timeBomb = false;
            maxBumps = 10;
			textureName = @"Ball_Fire";
			fxComponent =  GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.fire.sheet",4,4,16, true);
            emitter = new ParticleEmitter(100.0f, 1.0, @"Smoke", true);
			break;
			
		case ExplodableComponent::ELECTRO:
            timeBomb = false;
            maxBumps = 8;
			textureName = @"Ball_Electric";
			fxComponent = GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.electric.sheet", 4,4,16, true);
            emitter = new ParticleEmitter(100.0f, 1.0, @"sparkle", true);
			
			break;
			
		case ExplodableComponent::FREEZE:
			//textureName = @"Ball_Ice";
			//fxComponent =  GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.ice.sheet", 4,4,16, true);
			break;
			
		case ExplodableComponent::CUE_BALL:
			textureName = nil;
			break;
			
		case ExplodableComponent::BALL_8:
			//textureName = @"Ball_Bomb";
			
			textureName = @"Black";
			fxComponent =  GraphicsComponentFactory::BuildBillBoardElement(radius*2.0f, radius* 2.0f, @"BombFuse", 2, 2, 4, radius + 0.1f);

			break;
        default:
            break;
			
	}

    // Added by scene manager
    if(emitter)
    {
        newBall->AddComponent(emitter);
    }
    
    BurstEmitter *burst = new BurstEmitter(1.0f);
    newBall->AddComponent(burst);
    
    GraphicsComponent *sphere = GraphicsComponentFactory::BuildSphere(radius , textureName );
    newBall->SetGraphicsComponent(sphere);
    
    
    /*ParticleEmitter *emitter = new ParticleEmitter(50.0f);
    newBall->SetGraphicsComponent(emitter);*/
    

	//GraphicsManager::Instance()->AddComponent(graphicsComponent);
	// added in order by scene manager

	
	PhysicsComponentInfo info;
	
	info.mIsStatic = false;
	info.mCanRotate = true;
	info.mRestitution = restitution;
	info.mMass = mass;
	info.mCollisionGroup = GRP_BALL;
	info.mCollidesWith = info.mCollidesWith | GRP_FIXED | GRP_WALL;
	info.mDoesNotSleep = true;
	
	info.mFriction = friction;
	
	
	PhysicsComponent *physicsComponent = 
	 PhysicsComponentFactory::BuildBall(radius, initialPosition, info);
	
	newBall->SetPhysicsComponent(physicsComponent);
	physicsComponent->SetKinematic(true);
	

	if(fxComponent != NULL)
	{
		newBall->AddComponent(fxComponent);
		GraphicsManager::Instance()->AddComponent(fxComponent);
	}
	
        
		ExplodableComponent *explodeComponent;
        
        if (timeBomb) { 
            explodeComponent = new TimeBombExplodable(explosionType);
        } else {
            explodeComponent = new CountExplodable(explosionType, maxBumps);		
        }
		newBall->SetExplodable(explodeComponent);
	// balls added to game mgr and phys mgr by cannon or scene mgr, depending on setup
	
	return newBall;
	
}

void GameEntityFactory::BuildCannon( float scale, btVector3 &initialPosition , 
									vector<Entity *> &newEntities, float rotationOffset,
									float rotationScale, float powerScale)
{
	
	Entity *cannon = new Entity();
#if DEBUG
	cannon->mDebugName = "Cannon";
#endif
	newEntities.push_back(cannon);
	cannon->SetPosition(initialPosition);
	cannon->SetYRotation(rotationOffset);
	
	// build a compound gfx component (farmer + reticule)
	CompoundGraphicsComponent *gfxCompound = new CompoundGraphicsComponent();
	GraphicsManager::Instance()->AddComponent(gfxCompound);
	
	// this is the graphics component
	HoldLastAnim *farmer = 
	GraphicsComponentFactory::BuildHoldLastAnim(scale*2.0f, scale*2.0f, @"farmer.sheet", 11);
	cannon->SetGraphicsComponent(gfxCompound);
	
	farmer->SetParent(cannon);
	farmer->FollowParentRotation();
	gfxCompound->AddChild(farmer);
	
	GraphicsComponent *reticule = GraphicsComponentFactory::BuildReticule(scale * 10.0f);
	reticule->SetParent(cannon);
	gfxCompound->AddChild(reticule);
 	
	
	// no offset
	//fxComponent->SetOffset( btVector3(0,0,4.0f) );
		
	CannonController *cannonController = new CannonController(powerScale);
	cannon->SetController(cannonController);
	// TODO  this is where a pool of balls would be built
	
	btVector3 pos(0, 1,14);
	
	/*Entity *line = BuildSprite(pos, 20, 1, @"Line", GraphicsManager::POST);
	newEntities.push_back(line);
	
	Entity *wheel = BuildSprite(pos, 8, 4, @"Arrows", GraphicsManager::POST);
	newEntities.push_back(wheel);
	{
#if DEBUG
		std::string textureName([@"Arrows" UTF8String]);
		wheel->mDebugName = textureName;
#endif
	}*/
	
	pos.setX(8);
	pos.setZ(-13);
	Entity *button = BuildSprite(pos, 4, 4, @"button", GraphicsManager::POST);
	newEntities.push_back(button);
	{
#if DEBUG
		std::string textureName([@"button" UTF8String]);
		button->mDebugName = textureName;
#endif
	}
	
	Entity *cannonUI = new Entity();
#if DEBUG
	cannonUI->mDebugName = "CannonUI";
#endif
	cannonUI->SetPosition(btVector3(0,0,0));
	newEntities.push_back(cannonUI);
	
	CannonUI *cannonUIControl = new CannonUI(cannon, /*wheel*/ NULL, button, rotationScale);
	cannonUIControl->SetRotationOffset(rotationOffset);
	
	cannonUI->SetController(cannonUIControl);
	
	
	GamePlayManager::Instance()->SetCannon( cannonController, cannonUIControl );
	
}

Entity *GameEntityFactory::BuildCharacter( float radius, btVector3 &initialPosition, CharacterType charType )
{
	
	Entity *gopher = new Entity();
	
	gopher->SetPosition(initialPosition);	
	
#if DEBUG
	gopher->mDebugName = "Gopher";
#endif
	
    
    AnimatedGraphicsComponent *graphicsComponent;
    if( charType  == GameEntityFactory::Gopher)
    {
        graphicsComponent = GraphicsComponentFactory::BuildGopher(radius*2.0f, radius*2.0f);
    }
    else if( charType == GameEntityFactory::Bunny)
    {
        graphicsComponent = GraphicsComponentFactory::BuildBunny(radius*2.0f, radius*2.0f);
    }
    else {
		graphicsComponent = GraphicsComponentFactory::BuildSqu(radius*2.0f, radius*2.0f);
	}

	// added in Scene Manager so that graphics objects draw in order
	//GraphicsManager::Instance()->AddComponent(graphicsComponent);
	gopher->SetGraphicsComponent(graphicsComponent);	

	
	GopherController *navigationComponent = new GopherController;
	gopher->SetController(navigationComponent);
	
	// start in a spawn state, away from everything
	navigationComponent->Spawn(btVector3(0,-100.1,0), 3.0f);
	GamePlayManager::Instance()->AddGopherController(navigationComponent);
	

	PhysicsComponentInfo info;
	
	info.mRestitution = 1.1f;
	info.mMass = 0.05f;
	// does not collide with walls
	
	info.mCollisionGroup = GRP_GOPHER;
	// does not collide with walls
	info.mCollidesWith =  GRP_BALL | GRP_FLOOR_CEIL | GRP_FIXED;
	info.mIsStatic = false;
	info.mCanRotate = false;
	
	PhysicsComponent *physicsComponent =
			PhysicsComponentFactory::BuildBall(radius*0.33f, initialPosition, info);

	gopher->SetPhysicsComponent(physicsComponent);
	
	// gophers get a ghost collider
	// i must have been high when i thought this was a good idea.  
	// gophers already have a physics component that collides.  
	// ghost collider setup currenlty relies on the physics component to do the 
	// synch up.  gah.
	physicsComponent->AddGhostCollider();
	PhysicsManager::Instance()->AddGhostCollider(physicsComponent->GetGhostCollider());
	
	PhysicsManager::Instance()->AddComponent(physicsComponent);
	physicsComponent->SetKinematic(true);
		
	
	
	// gophers get spawned in
	gopher->mActive = false;
	
	return gopher;
}

Entity *GameEntityFactory::BuildHole(  btVector3 &initialPosition, float radius)
{
	Entity *hole = new Entity();
	hole->SetPosition(initialPosition);	
#if DEBUG
	hole->mDebugName = "Hole";
#endif	
	
	//gfx
	GraphicsComponent *graphicsComponent =  GraphicsComponentFactory::BuildSprite(2.0, 2.0, @"Hole2");
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	hole->SetGraphicsComponent(graphicsComponent);	
	
	SpawnComponent *spawnComponent = new SpawnComponent();
	hole->SetSpawnComponent(spawnComponent);
	GamePlayManager::Instance()->AddSpawnComponent(spawnComponent);
	
	
	// target (for caching node id's)
	TargetComponent *targetComponent = new TargetComponent( TargetComponent::HOLE );
	hole->AddComponent(targetComponent);
	
	hole->mActive = true;
	
	return hole;	
}


Entity *GameEntityFactory::BuildCarrot(  btVector3 &initialPosition, float radius)
{
	Entity *carrot = new Entity();
	//set position
	carrot->SetPosition(initialPosition);	
#if DEBUG
	carrot->mDebugName = "Carrot";
#endif
	
	//gfx
	GraphicsComponent *graphicsComponent =  GraphicsComponentFactory::BuildSprite(2,2, @"Carrot");
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	carrot->SetGraphicsComponent(graphicsComponent);	
	
	
	// target (for caching node id's)
	TargetComponent *targetComponent = new TargetComponent( TargetComponent::CARROT );
	carrot->AddComponent(targetComponent);
	
	GamePlayManager::Instance()->AddTarget(carrot);
	
	carrot->mActive = true;
	
	return carrot;
	
}

Entity *GameEntityFactory::BuildHedgeCircle( btVector3 &initialPosition, float radius )
{
	
	Entity *newHedge = new Entity();
#if DEBUG
	newHedge->mDebugName = "Hedge";
#endif
	
	/*GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSphere(radius , kNumSlices, kNumRings );
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newHedge->SetGraphicsComponent(graphicsComponent);	
	*/
	
	// no graphics component
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = 0.9f;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith =  GRP_GOPHER | GRP_BALL;
	
	
	// make this static (collider)
	// uses a ht of 10
	PhysicsComponent *phys = PhysicsComponentFactory::BuildCylinder(radius, kFixedHeight, initialPosition, info); 
	
	PhysicsManager::Instance()->AddComponent(  phys );
	
	newHedge->SetPhysicsComponent( phys );
	
	
	return newHedge;
	
}


Entity *GameEntityFactory::BuildFenceBox( btVector3 &initialPosition, btVector3 &halfExtents )
{
	
	Entity *newBox = new Entity();
#if DEBUG
	newBox->mDebugName = "Fence";
#endif
	
	// no graphics component
	btVector3 zero(0,0,0);
	
	/* uncomment this to debug fence collider
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildBox( initialPosition, halfExtents );
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	*/
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution =0.9f;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith =  GRP_GOPHER | GRP_BALL;
	
	// make this static (collider)
	PhysicsComponent *phys = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents ,0, info); 
	
	PhysicsManager::Instance()->AddComponent(  phys  );
	
	newBox->SetPhysicsComponent( phys );
	
	
	return newBox;
	
}



Entity *GameEntityFactory::BuildGround( btVector3 &initialPosition, float height, float width, const std::string *backgroundTexture )
{
	
	Entity *newGround = new Entity();
	
#if DEBUG
	newGround->mDebugName = "Ground";
#endif 
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildGroundPlane( height, width, backgroundTexture );
	GraphicsManager::Instance()->AddComponent(graphicsComponent, GraphicsManager::PRE);
	newGround->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution =  0.9f;
	
	info.mCollisionGroup = GRP_FLOOR_CEIL;
	info.mFriction =  0.1;
	
	// TODO - if you want this to support explodables, add GRP_EXPLODABLES
	info.mCollidesWith =  GRP_GOPHER | GRP_BALL;
	
	/*PhysicsComponent *physicsGround = PhysicsComponentFactory::BuildPlane(initialPosition, 1, info);*/
    
    btVector3 halfExtents(100, 0.1, 100);
    
	PhysicsComponent *physicsGround = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents,0, info );
    
	PhysicsManager::Instance()->AddComponent( physicsGround );
	newGround->SetPhysicsComponent(physicsGround);
    PhysicsManager::Instance()->SetGround( physicsGround );
    
    
	return newGround;
	
}


Entity *GameEntityFactory::BuildTopPlate( btVector3 &initialPosition )
{
	
	Entity *newGround = new Entity();
#if DEBUG
	newGround->mDebugName = "TopPlate";
#endif 
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = 0.9f;
	info.mCollisionGroup = GRP_FLOOR_CEIL;
	info.mCollidesWith = GRP_GOPHER | GRP_BALL;
	
	PhysicsComponent *physicsGround = PhysicsComponentFactory::BuildPlane(initialPosition, -1, info);
	PhysicsManager::Instance()->AddComponent( physicsGround );
	newGround->SetPhysicsComponent(physicsGround);
	
	return newGround;
}

Dog3D::Entity *GameEntityFactory::BuildSprite( btVector3 &initialPosition, float w, float h, NSString *spriteName, GraphicsManager::RenderQueueOrder order)
{
	Entity *sprite = new Entity();
	sprite->SetPosition(initialPosition);
#if DEBUG
	sprite->mDebugName = std::string([spriteName UTF8String]);
#endif
	
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite( w, h, spriteName );
	GraphicsManager::Instance()->AddComponent(graphicsComponent, order);
	sprite->SetGraphicsComponent(graphicsComponent);	
	
	return sprite;
}

Dog3D::Entity *GameEntityFactory::BuildScreenSpaceSprite( btVector3 &initialPosition, float w, float h, NSString *spriteName, float duration)
{
	Entity *sprite = new Entity();
	sprite->SetPosition(initialPosition);
#if DEBUG
	sprite->mDebugName = std::string([spriteName UTF8String]);
#endif
	
	
	ScreenSpaceComponent *graphicsComponent = 
	dynamic_cast<ScreenSpaceComponent*> (GraphicsComponentFactory::BuildScreenSpaceSprite( w, h, spriteName, initialPosition, duration ));
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	sprite->SetGraphicsComponent(graphicsComponent);	
	
	return sprite;
}


// all boxes can rotate if not static
Entity *GameEntityFactory::BuildWall( btVector3 &initialPosition, btVector3 &halfExtents, float restitution )
{
	
	Entity *newBox = new Entity();
	
#if DEBUG
	newBox->mDebugName = "Wall";
#endif 
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildBox( halfExtents );
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = 0.8f;
	info.mCollisionGroup = GRP_WALL;
	info.mCollidesWith = GRP_BALL;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents,0, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	newBox->SetPosition(initialPosition);
	return newBox;
	
}


// all boxes can rotate if not static
Entity *GameEntityFactory::BuildBox( btVector3 &initialPosition, btVector3 &halfExtents, bool isStatic, float restitution, float mass, 
									bool isExplodable )
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = "Box";
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildBox( halfExtents );
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	

	PhysicsComponentInfo info;
	info.mIsStatic = isStatic;
	info.mRestitution = 0.1f;
	info.mMass = mass;
	info.mDoesNotSleep = true;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, 0, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	if(isExplodable)
	{
		ExplodableComponent *explodable = new ExplodableComponent(ExplodableComponent::MUSHROOM);
		newBox->SetExplodable(explodable);
	}
	
	
	return newBox;
	
}


// basic textured crate that explode
Entity *GameEntityFactory::BuildCrate( btVector3 &initialPosition, btVector3 &halfExtents, float restitution, float mass, 
									bool isExplodable )
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = "Crate";
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildBox( 
					halfExtents, GraphicsManager::Instance()->GetTexture(@"CrateTexture") );
	
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = false;
	info.mCanRotate = true;
	info.mRestitution = restitution;
	info.mMass = mass;
	info.mDoesNotSleep = true;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents,0, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	if(isExplodable)
	{
		ExplodableComponent *explodable = new FireballExplodable(ExplodableComponent::MUSHROOM);
		newBox->SetExplodable(explodable);
	}
	
	return newBox;
	
}

// basic textured crate that explode
Entity *GameEntityFactory::BuildTexturedExploder( btVector3 &initialPosition, btVector3 &halfExtents, NSString *textureName )
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = [textureName UTF8String] ;
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f, halfExtents.z()*2.0f, textureName );
	
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mCanRotate = false;
	info.mDoesNotSleep = false;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, 0, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	ExplodableComponent *explodable = new FireballExplodable(ExplodableComponent::MUSHROOM);
	newBox->SetExplodable(explodable);

	
	return newBox;
	
}


// basic rock like object
Entity *GameEntityFactory::BuildTexturedCollider( btVector3 &initialPosition, btVector3 &halfExtents, 
												 float yRotation, float restitution, NSString *textureName,
												 float graphicsScale)
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
	
	btMatrix3x3 rotation;
	rotation.setEulerZYX(0, 0, yRotation);
	newBox->SetRotation(rotation);
	
#if DEBUG
	newBox->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f * graphicsScale, 
																				 halfExtents.z()*2.0f * graphicsScale, 
																				 textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = restitution;
	info.mDoesNotSleep = false;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL | GRP_GOPHER;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, yRotation, info );
	//PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBall( halfExtents.x(), initialPosition, info );
	//PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildCylinder(halfExtents.x(), 10,initialPosition,info);
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	
	return newBox;
	
}

// basic rock like object
Entity *GameEntityFactory::BuildCircularCollider( btVector3 &initialPosition, btVector3 &halfExtents, float restitution, NSString *textureName, float graphicsScale)
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f*graphicsScale, halfExtents.z()*2.0f*graphicsScale, textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = restitution;
	info.mDoesNotSleep = false;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL | GRP_GOPHER;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildCylinder(halfExtents.x(), kFixedHeight,initialPosition,info);
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	
	return newBox;
	
}

// basic rock like object
Entity *GameEntityFactory::BuildCircularExploder( btVector3 &initialPosition, btVector3 &halfExtents, 
												 NSString *textureName, float respawnTime, float graphicsScale,
												 ExplodableComponent::ExplosionType explosionType )
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = [textureName UTF8String];
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f*graphicsScale, halfExtents.z()*2.0f*graphicsScale, textureName);
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mDoesNotSleep = false;
	// note that we force the explosion only on explode small
	info.mCollisionGroup =GRP_EXPLODABLE;
	
	info.mCollidesWith = GRP_BALL;
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildCylinder(halfExtents.x(), kFixedHeight,initialPosition,info);
	
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	ExplodableComponent *explodable = NULL;
	
	switch (explosionType) {
		case ExplodableComponent::EXPLODE_SMALL:
			explodable = new RespawnExplodable(ExplodableComponent::EXPLODE_SMALL, respawnTime, [textureName UTF8String]);
			
			break;
		
		case ExplodableComponent::POP:
			explodable = new PopExplodable(ExplodableComponent::EXPLODE_SMALL, respawnTime, [textureName UTF8String]);
			
			//new PopExplodable(ExplodableComponent::EXPLODE_SMALL, respawnTime, [textureName UTF8String]);
			
			break;
			
		case ExplodableComponent::BUMPER:
			explodable = new BumperExplodable(ExplodableComponent::EXPLODE_SMALL, respawnTime, [textureName UTF8String]);
			
			//
			//new BumperExplodable(ExplodableComponent::EXPLODE_SMALL, respawnTime, [textureName UTF8String]);
			
			break;
			
		default:
			break;
	}
	
	newBox->SetExplodable(explodable);
	explodable->Prime();
	
	return newBox;
	
}


// basic rock
Entity *GameEntityFactory::BuildGasCan( btVector3 &initialPosition, btVector3 &halfExtents, float restitution)
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = "GasCan";
#endif
	
	GraphicsComponent *graphicsComponent = GraphicsComponentFactory::BuildSprite(halfExtents.x()*2.0f, halfExtents.z()*2.0f, @"GasCan");
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newBox->SetGraphicsComponent(graphicsComponent);	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mRestitution = restitution;
	info.mDoesNotSleep = false;
	
	btVector3 physExtents = btVector3(halfExtents);
	
	physExtents.setX( physExtents.x() );
	physExtents.setZ( physExtents.z() * 0.5);
	
	PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, physExtents, 0, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	
	ExplodableComponent *explodable = new FireballExplodable(ExplodableComponent::MUSHROOM);
	newBox->SetExplodable(explodable);

	return newBox;
	
}

/// build two vertical and one cross bar
///
Entity *GameEntityFactory::BuildFence( btVector3 &initialPosition, btVector3 &halfExtents, float restitution, float mass, 
									  bool isExplodable )
{
	
	Entity *newBox = new Entity();
	newBox->SetPosition(initialPosition);
#if DEBUG
	newBox->mDebugName = "Fence";
#endif
	
	CompoundGraphicsComponent *parentGFX = new CompoundGraphicsComponent();
	newBox->SetGraphicsComponent(parentGFX);	
	GraphicsManager::Instance()->AddComponent(parentGFX);
	
	btVector3 postExtents(0.125,0.5,0.125);
	btVector3 topSlatExtents(0.125,0.125,0.75);
	
	{
		GraphicsComponent *childGFX = GraphicsComponentFactory::BuildBox( postExtents, GraphicsManager::Instance()->GetTexture(@"CrateTexture") );
	
		// todo full offsets
		childGFX->SetOffset(btVector3(0,0, -halfExtents.x()));
		parentGFX->AddChild(childGFX);
	}
	{
		GraphicsComponent *childGFX = GraphicsComponentFactory::BuildBox( topSlatExtents, GraphicsManager::Instance()->GetTexture(@"CrateTexture") );
		
		// todo full offsets
		childGFX->SetOffset(btVector3(0,0.5,0));
		parentGFX->AddChild(childGFX);
	}
	{
		GraphicsComponent *childGFX = GraphicsComponentFactory::BuildBox( postExtents, GraphicsManager::Instance()->GetTexture(@"CrateTexture") );
		
		// todo full offsets
		childGFX->SetOffset(btVector3(0,0,halfExtents.x()));
		parentGFX->AddChild(childGFX);
	}
	
	PhysicsComponentInfo info;
	info.mIsStatic = false;
	info.mCanRotate = true;
	info.mRestitution = 0.1f;
	info.mMass = mass;
	
	/*PhysicsComponent *physicsBox = PhysicsComponentFactory::BuildBox( initialPosition, halfExtents, info );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );*/
	
	PhysicsComponent *physicsBox = 
		PhysicsComponentFactory::BuildFenceTriple( initialPosition, 
												  halfExtents, 
												  info ,
												  postExtents,
												  topSlatExtents
												  );
	PhysicsManager::Instance()->AddComponent( physicsBox  );
	newBox->SetPhysicsComponent( physicsBox );
	physicsBox->SetKinematic(true);
	
	if(isExplodable)
	{
		CompoundExplodable *explodable = new CompoundExplodable(ExplodableComponent::MUSHROOM);
		newBox->SetExplodable(explodable);
	}

	
	return newBox;
	
}


// builds a looping FX elt
Entity *GameEntityFactory::BuildFXElement(  btVector3 &initialPosition, btVector3 &extents, 
										  NSString *spriteSheet, int nTilesHigh, int nTilesWide, 
										  int nTiles, bool  renderInPreQueue)
{
	Entity *newElement = new Entity();
	newElement->SetPosition(initialPosition);
#if DEBUG
	newElement->mDebugName = "FXElement";
#endif
	
	FXGraphicsComponent *graphicsComponent = 
	GraphicsComponentFactory::BuildFXElement(extents.x(), extents.z(), spriteSheet, nTilesWide, nTilesHigh, nTiles, true, 1.0f/15.0f);

	
	// kick off default anim (won't do anything until the anim starts updating)
	graphicsComponent->StartAnimation(AnimatedGraphicsComponent::IDLE );
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent, renderInPreQueue);
	newElement->SetGraphicsComponent(graphicsComponent);	
	
	// target (for caching node id's)	
	newElement->mActive = true;
	
	return newElement;
	
}

// builds a looping FX elt
// has a circular collider element
Entity *GameEntityFactory::BuildFXCircularCollider(  btVector3 &initialPosition, btVector3 &extents, 
										  NSString *spriteSheet, int nTilesHigh, int nTilesWide, 
										  int nTiles)
{
	Entity *newElement = new Entity();
	newElement->SetPosition(initialPosition);
#if DEBUG
	newElement->mDebugName = "FXElement";
#endif
	
	FXGraphicsComponent *graphicsComponent = 
	GraphicsComponentFactory::BuildFXElement(extents.x()*2.0f, extents.z()*2.0f, spriteSheet, nTilesWide, nTilesHigh, nTiles, true, 1.0f/15.0f);
	
	
	// kick off default anim (won't do anything until the anim starts updating)
	graphicsComponent->StartAnimation(AnimatedGraphicsComponent::IDLE );
	
	GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newElement->SetGraphicsComponent(graphicsComponent);	
	
	newElement->mActive = true;
	
	
	PhysicsComponentInfo info;
	info.mIsStatic = true;
	info.mDoesNotSleep = false;
	info.mCollisionGroup = GRP_FIXED;
	info.mCollidesWith = GRP_BALL;	
	
	PhysicsComponent *cyl = PhysicsComponentFactory::BuildCylinder(extents.x(), kFixedHeight,initialPosition,info);
	
	PhysicsManager::Instance()->AddComponent( cyl  );
	newElement->SetPhysicsComponent( cyl );
	
	
	return newElement;
	
}

Entity *GameEntityFactory::BuildFXElement(  btVector3 &initialPosition, ExplodableComponent::ExplosionType effect)
{
	Entity *newElement = new Entity();
	newElement->SetPosition(initialPosition);
#if DEBUG
	newElement->mDebugName = "FXElement";
#endif
	
	FXGraphicsComponent *graphicsComponent = NULL;
	
	switch (effect) {
		case ExplodableComponent::EXPLODE_SMALL:
			//gfx
			graphicsComponent = 
				GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.smokeExplode.sheet", 4,4,12, false);
			
			break;
		case ExplodableComponent::MUSHROOM:
			//gfx
			graphicsComponent = 
				GraphicsComponentFactory::BuildFXElement(2, 2, @"mushroom.sheet", 4,4,16, false);
			
			break;
		case ExplodableComponent::ELECTRO:
			//gfx
			graphicsComponent = 
				GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.electric.sheet", 4,4,16, false);
			break;
		case ExplodableComponent::FREEZE:
			//gfx
			//graphicsComponent = 
			//	GraphicsComponentFactory::BuildFXElement(2, 2, @"ball.ice.sheet", 4,4,16, false);
			break;
		default:
			break;
	}
	
	// kick off default anim (won't do anything until the anim starts updating)
	//graphicsComponent->StartAnimation(AnimatedGraphicsComponent::IDLE );
	
	//GraphicsManager::Instance()->AddComponent(graphicsComponent);
	newElement->SetGraphicsComponent(graphicsComponent);	
	
		
	// target (for caching node id's)	
	newElement->mActive = true;
	
	return newElement;
	
}
