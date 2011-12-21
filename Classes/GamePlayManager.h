/*
 *  GamePlayManager.h
 *  Gopher
 *
 *  Created by Anthony Lobay on 2/1/10.
 *  Copyright 2010 3dDogStudios. All rights reserved.
 *
 */

#import <btBulletDynamicsCommon.h>
#import <vector>
#import <list>
#import "PhysicsComponent.h"
#import "TriggerComponent.h"
#import "GateController.h"

#import "GopherController.h"
#import "SpawnComponent.h"
#import "Entity.h"
#import "VectorMath.h"
#import "GraphicsComponent.h"
#import "CannonController.h"
#import "CannonUI.h"
#import "ExplodableComponent.h"

namespace Dog3D
{
	typedef std::list< std::pair<float, int> >  IntervalQueue;
	typedef std::list< std::pair<float, int> >::iterator  IntervalQueueIterator;
	
	class GamePlayManager
	{
	public:
		enum GameState { PLAY, PAUSE, GOPHER_WIN, GOPHER_LOST };

	private:
		GameState mGameState;
		
	public:
		GamePlayManager(): mGopherLives( 10 ) , mCarrotLives ( 5 ), mGopherBaseLine(mGopherLives), mCarrotBaseLine(mCarrotLives), 
		mDestroyedObjects(0),
		mGameState(PLAY),
		mGopherHUD(NULL), mCarrotHUD(NULL), mTouched(false), mFlicked(false),
    mCannonController(NULL), mCannonUI(NULL), 
		mUnlimitedBalls(true), mFocalPoint(0,0,0), mCarrotSearchDistance(20.0f),
		mSpawnDelay(0.0f)
#if DEBUG
        , mDebugVertices(NULL)
#endif
		{}
	
		
		// singleton
		static GamePlayManager *Instance()
		{
			return sGamePlayManager;
		}
		
		static void ShutDown()
		{
			delete sGamePlayManager;
			sGamePlayManager = NULL;
		}
			
		
		void Unload();
		
		// initializes singleton manager
		static void Initialize();	
		
		// steps physics
		void Update(float deltaTime);

		
#pragma mark TOUCH
		//todo multi touch
		inline void Touch(btVector3 &position)
		{

			if(mCannonController == NULL)
			{
			
				if(mBalls.size() == 0)
				{
					DLog(@"No balls");
				}
				else {
									
					Dog3D::GraphicsComponent *gfx = mBalls.front()->GetGraphicsComponent();
					if(gfx->mActive)
					{
						mTouchPosition = position;
						mTouched = true;
					}
				}
			}
			else if(mCannonUI)
			{
				// update the cannon controller
				mCannonUI->SetTouch(position);
			}
		}
		
		// write out old swipe, start a new one
		inline void StartSwipe(btVector3 &startPosition)
		{
			mCannonUI->StartSwipe(startPosition);
		}
		
		inline void MoveSwipe(btVector3 &endPosition)
		{
			
			// update the cannon controller
			mCannonUI->MoveSwipe(endPosition);	
		}
		
		inline void EndSwipe(btVector3 &endPosition)
		{
			// update the cannon controller
			mCannonUI->EndSwipe(endPosition);	
		}
		
		inline void CancelSwipe()
		{
			mCannonUI->CancelSwipe();
		}
		

        inline void ApplyRotation(float delta)
        {
            mCannonUI->ApplyRotation(delta);
        }
        
		
		// returns position of ball 0
		inline btVector3 GetActiveBallPosition()
		{
			
			if(mBalls.size() > 0)
			{
				return mBalls.front()->GetPosition();
			}
			else {
				return btVector3(0,0,0);
			}
			
		}
		
#pragma mark SCENE SETUP
		// play, win
		inline GameState GetGameState() { return mGameState; }
		
		inline void SetGameState(GameState gameState){ mGameState = gameState;}
				
		inline void AddSpawnComponent(SpawnComponent *spawn)
		{
			mSpawnComponents.push_back(spawn);
		}
		
		inline void AddTarget(Entity *target)
		{
			mTargets.push_back(target);
		}
		
		inline void AddBall( Entity *ball, int ballType = 0)
		{
			if(ballType == ExplodableComponent::CUE_BALL)
			{
				mBalls.push_front(ball);
			}
			else 
			{
				mBalls.push_back(ball);
			}
		}
		
		
		inline void SetCannon( CannonController *controller, CannonUI *ui)
		{
			mCannonController = controller;
			mCannonUI = ui;
		}
        inline CannonController *GetCannon(){ return mCannonController;}
        		
		void AddGopherController( GopherController *component);
		
		// initializes debug node network
		// to be replaced later
		void InitializeDebugNetwork();
		
		void SetSpawnIntervals( IntervalQueue intervals) 
		{ 
			mSpawnIntervals = intervals;
			
			// process first spawn interval
			if(mSpawnIntervals.size() > 0)
			{
				mNumGophersToSpawn = mSpawnIntervals.front().second;
				mSpawnIntervals.pop_front();
			}
		}
		
		inline void SetWorldBounds(btVector3 &bounds)
		{
			mWorldBounds = bounds;
		}
		
		inline void GetFocalPoint(btVector3 &point)
		{
			
      point.setZero();

		}
			
		
#pragma mark TARGET SYSTEM
		// for target acquisition
		Entity *PickTarget(btVector3 position);
		
		// target acq
		Entity *GetRandomCarrot(btVector3 position);
		
		// target acq
		Entity *GetClosestHole(btVector3 position);
		
		
		inline int GetNumActiveTargets()
		{
			int nActiveTargets = 0;
			for(std::list<Entity *>::iterator it = mTargets.begin(); it != mTargets.end(); it++)
			{
				if((*it)->mActive)
				{
					nActiveTargets++;
				}
			}
			return nActiveTargets;
		}
		

#if DEBUG
		void DrawDebugLines();
#endif
		void RemoveTargetNode(int nodeId);
		
#pragma mark GAME LOGIC
		// reset of game win/loss logic
		// called during load up
		void InitializeLevel( int numGopherLives, int numCarrotLives)
		{
			
			SetNumGopherLives(numGopherLives);
			SetNumCarrotLives(numCarrotLives);
			mDestroyedObjects = 0;
			mScratched = false;
			mLevelTime = 0;
		}
		
		// gophers or carrots = 0
		inline bool IsGameOver() { return mGopherLives == 0 || mCarrotLives == 0 ||mScratched ; }
		
		// carrot lives = 0
		inline bool GophersWon() { return mCarrotLives == 0 || mScratched; }
		
		inline bool PlayerScratched() { return mScratched; }
		
		inline void AddExplodable(ExplodableComponent *explodable)
		{
			mExplodables.push_back(explodable);
		}
		
		inline void AddKinematicController(Component *gate)
		{
			mKinematicControllers.push_back(gate);
		}
		
		inline void SetUnlimitedBalls(bool enabled)
		{
			mUnlimitedBalls = enabled;
		}
		
#pragma mark SCORING
		
		
		//crude score test
		inline int ComputeScore()
		{
			return  (mGopherBaseLine - mGopherLives)*5;
		}
		
		// todo this really should be private
		inline void RemoveCarrotLife()
		{
			if(mCarrotLives > 0)
			{
				mCarrotLives--;
				if(mCarrotHUD)
				{
					mCarrotHUD->RemoveLife();
				}
			}
		}
		
		inline float GetLevelTime() { return mLevelTime;}
		
		inline int GetTotalGophers()
		{
			return mGopherBaseLine;
		}
		
		inline int GetDeadGophers()
		{
			return (mGopherBaseLine - mGopherLives);
		}
				
		inline int GetRemainingCarrots()
		{
			return mCarrotLives; 
		}
		
		inline int GetNumBallsLeft()
		{
			if(mCannonController != NULL)
			{
				return mCannonController->NumBallsLeft();
			}
			else {
				return -1;
			}
		}
        
        inline int GetNumDestroyedObjects()
        {
            return mDestroyedObjects;
        }
        
        inline void IncrementDestroyedObjects()
        {
            mDestroyedObjects++;
        }
		
		inline void SetCarrotSearchDistance(float distance)
		{
			mCarrotSearchDistance = distance;	
		}

        // drop gopher one life
		inline void RemoveGopherLife() 
		{ 
			if(mGopherLives > 0)
			{
				mGopherLives--;
				if(mGopherHUD)
				{
					mGopherHUD->RemoveLife();
				}
			}
		}
        
	private:
		
		inline bool NoBallsLeft()
		{
			if( mCannonController == NULL)
			{
				return false;
			}
			
			if( mCannonController->NumBallsLeft() == 0 
			   && mBalls.size() == 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		  		
		inline void SetNumGopherLives( int nLives ) 
		{ 
			mGopherLives = nLives; 
			mGopherBaseLine = nLives;
		}
		
		inline void SetNumCarrotLives( int nLives ) 
		{ 
			mCarrotLives = nLives; 
			mCarrotBaseLine = nLives;
		}
		
		
		void UpdateDebugVertices();
		
		// update object contact/explosion mojo		
		void UpdateObjectContacts(float dt);
		
		// steps ball and gopher controllers
		void UpdateControllers(float dt);
		
		// updates gopher ai - calls controller
		void UpdateGopherAIs();
		
		// spawn in new gophers
		void SpawnNewGophers(float dt, float gameTime);
		
		// clean up gophers that have flown off screen
		void CleanUpGopherBodies();
		
		// clean up exploded balls
		void UpdateBallExplosions(float dt);
		
		// manages spawn in
		void ReclaimBalls(float dt);
		
		// either continuous spawn or to cannon
		void ReclaimBall(Entity *ball);
		
		
		std::list<GopherController *> mActiveGophers;
		
		std::list<Entity *> mTargets;
		
		
		// managed components
		std::list<Entity *> mBalls;
		
		IntervalQueue mSpawnIntervals;
		
		HUDGraphicsComponent *mGopherHUD;
		HUDGraphicsComponent *mCarrotHUD;

		std::vector<SpawnComponent *> mSpawnComponents;
		
		std::list<ExplodableComponent *> mExplodables;
		std::list<Component *> mKinematicControllers;
		
		std::queue<GopherController *> mDeadGopherPool;
		
		
		// from UI
		btVector3 mTouchPosition;
		btVector3 mFlick;
		
		// for cannon control
		CannonController *mCannonController;
		CannonUI *mCannonUI;
		
		btVector3 mWorldBounds;
		btVector3 mFocalPoint;
				
		// total play time on level
		float mLevelTime;
		
		float mCarrotSearchDistance;

		float mSpawnDelay;
		
		// singleton
		static GamePlayManager *sGamePlayManager;
		
		int mNumDebugVertices;
		
		int mNumGophersToSpawn;
		
#if DEBUG
		// debug
		Dog3D::Vec3 *mDebugVertices;
#endif
	
		// number of gopher lives (when zero, game over)
		int mGopherLives;
		
		// number of carrots lives (when zero, game over)
		int mCarrotLives;
		
		// base line number of gopher  (to begin with)
		int mGopherBaseLine;
		
		// base line number of carrots (to begin with)
		int mCarrotBaseLine;
		
		// gas cans, etc
		int mDestroyedObjects;
		
		bool mUnlimitedBalls;
		
		// ui events passed in
		bool mTouched;
		bool mFlicked;
		
		// pool variant
		bool mScratched;
		
	};
}