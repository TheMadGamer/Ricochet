/*
 *  GamePlayManager.cpp
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#include "GamePlayManager.h"

#import <btBulletDynamicsCommon.h>
#import <vector>
#import <algorithm>
#import <set>

#import "TriggerComponent.h"
#import "ExplodableComponent.h"
#import "GateController.h"
#import "GamePlayManager.h"
#import "Entity.h"
#import "GraphicsComponent.h"
#import "GraphicsManager.h"

#import "PhysicsManager.h"
#import "PhysicsComponentFactory.h"
#import "TargetComponent.h"
#import "SceneManager.h"

using namespace std;

const float kTapForce = 30.0;

namespace Dog3D
{
	 
	typedef list<GopherController*>::iterator NavIterator;
	typedef list<Entity *>::iterator EntityListIterator;
	
#pragma mark INIT AND CTOR	
	
	GamePlayManager * GamePlayManager::sGamePlayManager;
	
	void GamePlayManager::Initialize()
	{
		sGamePlayManager = new GamePlayManager();
		srand(2);	
	}
	
	void GamePlayManager::Unload()
	{
		mActiveGophers.clear();
		
		while(!mDeadGopherPool.empty())
		{
			mDeadGopherPool.pop();
		}
		
		mTargets.clear();
		
		mBalls.clear();
		
		mSpawnComponents.clear();
		
		mExplodables.clear();
		
		mKinematicControllers.clear();
		
		mSpawnIntervals.clear();
		
		mGopherHUD = NULL;
		mCarrotHUD = NULL;
		
		mLevelTime = 0;
		
		mCannonController = NULL;
		mCannonUI = NULL;
		
#if DEBUG
		if(mDebugVertices)
		{
			delete [] mDebugVertices;
		}
#endif
		
	}
	
#if DEBUG
	void GamePlayManager::DrawDebugLines()
	{
		return;
		
		UpdateDebugVertices();
		
		glEnableClientState(GL_VERTEX_ARRAY);
		
		// MATERIAL
		glDisableClientState(GL_COLOR_ARRAY);
		glColor4f(1,1,1,1);
		
		for(int i = 0; i < mNumDebugVertices; i+=2)
		{			// To-Do: add support for creating and holding a display list
			glVertexPointer(3, GL_FLOAT, 0, mDebugVertices+i);
			glDrawArrays(GL_LINE_STRIP, 0, 2);
			
		}
	}
#endif
	
			
#pragma mark UPDATE
	void GamePlayManager::Update(float deltaTime)
	{
		if(mActiveGophers.size() == 0 && mDeadGopherPool.empty())
		{
			return;
		}

		if(mGameState == GOPHER_WIN || mGameState == GOPHER_LOST)
		{

			for(EntityListIterator it = mBalls.begin(); it!= mBalls.end(); it++)
			{
				(*it)->mActive = false;
			}
			
			// compute positions
			// eat veggies - todo move this up to update carrot eating
			if(mGameState == GOPHER_LOST)
			{
				for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
				{
					// throw in an explode here
					if((*it)->GetControllerState() != GopherController::EXPLODE)
					{
						btVector3 position = (*it)->GetParent()->GetPosition();
						position.normalize();
					
						(*it)->Explode( position );
					}
				}

				// update exploding gophers
				CleanUpGopherBodies();
			}
			else 
			{
				for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
				{
					if((*it)->GetControllerState() != GopherController::WIN_DANCE)
					{
						(*it)->WinDance( );
					}
				}
				
				// compute positions
				// eat veggies - todo move this up to update carrot eating
				UpdateControllers(deltaTime);
				
								
				// update exploding gophers
				CleanUpGopherBodies();

				// spawn in new gophers
				SpawnNewGophers(deltaTime, mLevelTime);
			}
		}
		else
		{
			
			// compute positions
			// eat veggies - todo move this up to update carrot eating
			UpdateControllers(deltaTime);
			
			// update exploding gophers
			CleanUpGopherBodies();
			
			// spawn in new gophers
			SpawnNewGophers(deltaTime, mLevelTime);
			
			// spawn or spawn new balls
			ReclaimBalls(deltaTime);
			
			if(mBalls.size() > 0)
			{
				btVector3 point = mBalls.front()->GetPosition();
				
                //DLog(@"Ball %f %f %f", point.x(), point.y(), point.z());
                
				mFocalPoint *= 0.9;
				mFocalPoint += point * 0.1f;
			}
			
		}
			
		if(mCarrotLives <= 0 || 
		   mScratched || NoBallsLeft() )
		{
			mGameState = GOPHER_WIN;
		}
		else if(mGopherLives <= 0 )
		{
			mGameState = GOPHER_LOST;
		}
		else 
		{
			mGameState = PLAY;
		}
		
		mLevelTime+= deltaTime;
	}	

	
	// spawns in ball at a new location
	void GamePlayManager::ReclaimBalls(float dt)
	{
		for(list<Entity *>::iterator it = mBalls.begin(); it != mBalls.end(); it++ )
		{
			Entity *entity = (*it);
			if( entity->mActive)
			{
				btVector3 position = entity->GetPosition();	
				ExplodableComponent *explodable =  entity->GetExplodable();	
				
				
				// if ball is in a RECLAIM state
				// or its out of bounds, reclaim
				if ( (explodable && explodable->CanReclaim()) ||
					(fabs(position.getX()) > (mWorldBounds.x() + 5) || 
					 position.getY() < -5 || 
					 fabs(position.getZ()) > (mWorldBounds.z() + 5) ||
					 position.getY() > 20))
				{
					PhysicsManager::Instance()->RemoveComponent(entity->GetPhysicsComponent());
					
					ReclaimBall(entity);
					//toRemove.push_back(entity);
					if(mCannonController)
					{
#if DEBUG
						DLog(@"Removing Ball %s", (*it)->mDebugName.c_str());
#endif
						it = mBalls.erase(it);
					}
				}
			}
		}
	}
	
	// either respawns ball or adds to cannon
	void GamePlayManager::ReclaimBall(Entity *ball)
	{
		
		ExplodableComponent *explodable = ball->GetExplodable();
		
		// reset the explodable into idle state
		explodable->Reset();
		
        // get the physics component
        PhysicsComponent *physicsComponent =  ball->GetPhysicsComponent();
        physicsComponent->SetKinematic(true);
        ball->mActive = false;
        if(mUnlimitedBalls)
        {
            // adds to physics world
            mCannonController->AddBall(ball);
        }
	}
	
	// updates ball (explode) and gopher controllers
	void GamePlayManager::UpdateControllers(float dt)
	{
		for(EntityListIterator it = mBalls.begin(); it != mBalls.end(); it++)
		{
			ExplodableComponent *explodable = (*it)->GetExplodable();
			explodable->Update(dt);
		}
		
		for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
		{
			if((*it)->GetParent()->mActive)
			{
				(*it)->Update(dt);
			}
		}
	
		for( list<ExplodableComponent *>::iterator it = mExplodables.begin(); it != mExplodables.end(); it++)
		{
			ExplodableComponent *explodable = (*it);
			if(explodable->CanReclaim())
			{
#if DEBUG
				DLog(@"Removing Explodable %s",explodable->GetParent()->mDebugName.c_str());
#endif
				it = mExplodables.erase(it);
				
			}
			else {
				explodable->Update(dt);
			}
		}
		
		// and update gates
		for( list<Component *>::iterator it = mKinematicControllers.begin(); it != mKinematicControllers.end(); it++)
		{
			(*it)->Update(dt);
		}
	}
	
	// gopher out of bounds or timed out
	void GamePlayManager::CleanUpGopherBodies()
	{
		
		for(NavIterator it = mActiveGophers.begin(); it!= mActiveGophers.end(); it++)
		{
			
			Entity *gopher = (*it)->GetParent();
			btVector3 position = gopher->GetPosition();	
			
			if(fabs(position.getX()) > (mWorldBounds.x() + 2) || 
			   fabs(position.getZ()) > (mWorldBounds.z()+2))
			{
				DLog(@"Bounds");
			}
			

			if(fabs(position.getX()) > (mWorldBounds.x() + 2) || 
			   fabs(position.getZ()) > (mWorldBounds.z() + 2) ||
			   ( (*it)->GetControllerState() == GopherController::EXPLODE && (*it)->GetExplodeTime() > 3)  ||
			   (*it)->GetControllerState() == GopherController::DEAD)				
			{
				// this puts the gopher into a spawn state
				// away from everythign
				(*it)->Spawn(btVector3(0,-100.1,0), 2.0f);
				
				static_cast<AnimatedGraphicsComponent*>(gopher->GetGraphicsComponent())->PlayAnimation(AnimatedGraphicsComponent::IDLE);
				gopher->mActive = false;
				
				mDeadGopherPool.push(*it);
				
				it = mActiveGophers.erase(it);
				
				PhysicsManager::Instance()->RemoveComponent(gopher->GetPhysicsComponent());
				DLog(@"Removing gopher from world");
			}
		}
	}
	
	///Spaws gopehrs at random holes
	void GamePlayManager::SpawnNewGophers(float dt, float gameTime)
	{
		
		if(mSpawnDelay > 0)
		{
			mSpawnDelay -= dt;
			return;
		}
		
		// look at first item in queue
		pair<float, int> front = mSpawnIntervals.front();
		
		if(mSpawnIntervals.size() > 0 && (gameTime > front.first))
		{
			
			//front = mSpawnIntervals.front();
			mNumGophersToSpawn = front.second;
			//DLog(@"Next Spawn Interval: %d time: %f", front.first, front.second);
		
			mSpawnIntervals.pop_front();
		}
		
        mNumGophersToSpawn = min(mNumGophersToSpawn, mGopherLives);
		

		int numToSpawn =  mNumGophersToSpawn - mActiveGophers.size() ;
		
		if(numToSpawn > 0)
		{
			DLog(@"Active %lu Gophs to Spawn %d", mActiveGophers.size(), mNumGophersToSpawn);
			DLog(@"Spawining in %d gophers", numToSpawn);
		}
		
		for(int i = 0; i < numToSpawn; i++)
		{
			if(mDeadGopherPool.empty())
			{
				// nothing to spawn
				break;
			}
			
			GopherController *controller = mDeadGopherPool.front();
			Entity *gopher = (controller)->GetParent();
			mDeadGopherPool.pop();
			
			btVector3 spawnPosition;
			
			for(int i = 0; i < 20; i++)
			{
				// try to find a random, unoccupied spawn point
				int randomSpawn = rand() % (mSpawnComponents.size());
				
				if(! (mSpawnComponents[randomSpawn]->GetOccupied()))
				{
					DLog(@"Adding gopher to world at spawn %i", randomSpawn);
					
					Entity *spawn =  mSpawnComponents[ randomSpawn ]->GetParent();
					
					btVector3 spawnPosition = spawn->GetPosition();
					spawnPosition.setY(0.1);
					
					controller->Spawn(spawnPosition, 2.0f);
					mSpawnComponents[randomSpawn]->SetOccupied();
					
					gopher->mActive = true;
										
					// set back under kinematic control
					PhysicsComponent* physicsComponent = gopher->GetPhysicsComponent();
					
					btVector3 zero(0,0,0);
					physicsComponent->SetKinematic(true);
					physicsComponent->GetRigidBody()->setLinearVelocity(zero);		
					physicsComponent->GetRigidBody()->setAngularVelocity(zero);
					
					physicsComponent->AddGhostCollider();
					PhysicsManager::Instance()->AddComponent(physicsComponent);
					PhysicsManager::Instance()->AddGhostCollider(physicsComponent->GetGhostCollider());
					
					mActiveGophers.push_back(controller);
										
					mSpawnDelay = ((float) (rand() % 5)) * 0.2f;
					
					break;
				}
			}
			
			// can't find any spawn points, wait till next iteration
			if(!gopher->mActive)
			{
				mDeadGopherPool.push( static_cast<GopherController*> (gopher->GetController()));
				break;
			}
			
		}
		
		for(int i = 0; i < mSpawnComponents.size(); i++)
		{
			mSpawnComponents[i]->Update(dt);
		}
		
		if( mSpawnIntervals.size() == 0)
		{
			SceneManager::Instance()->RefreshSpawnIntervals(gameTime);
			//DLog(@"Refreshing spawn intervals");
		}
	}
	
	Entity *GamePlayManager::GetRandomCarrot(btVector3 position)
	{
		// try for a proximal target

		float closestDist = HUGE_VAL;
		Entity *closestTarget = NULL;
		
		for(list<Entity*>::iterator it = mTargets.begin(); it!= mTargets.end(); it++)
		{
			if((*it)->mActive)
			{
				btVector3 dist = position - (*it)->GetPosition();
				float distance = dist.length();
				if(distance < mCarrotSearchDistance && distance < closestDist)
				{
					closestTarget = (*it);
					closestDist = distance;
				}
			}
		}
		
		return closestTarget;
		

		/*
		// if no proximal target then
		// pick a random carrot as target
		while(true)
		{
			int randomTarget = rand() % mTargets.size();
			if( mTargets[randomTarget]->mActive)
			{
				return mTargets[randomTarget];
			}
		}*/
	}
	
	
	void GamePlayManager::AddGopherController( GopherController *gopher)
	{
		//mActiveGophers.push_back(gopher);
		mDeadGopherPool.push(gopher);
	}
}