//
//  FXGraphicsComponent.h
//  Grenades
//
//  Created by Anthony Lobay on 12/23/11.
//  Copyright (c) 2011 3dDogStudios.com. All rights reserved.
//

#import <btBulletDynamicsCommon.h>

#import <map>
#import <list>

#import "AnimatedGraphicsComponent.h"
#import "Component.h"
#import "GraphicsComponent.h"
#import "Texture2D.h"
#import "VectorMath.h"

namespace Dog3D
{
        
    class FXGraphicsComponent : public AnimatedGraphicsComponent
    {
    public: 
        //TODO - FX Element in scene
        // spawn an effect, cleans up after itself
        
        
        FXGraphicsComponent(float drawWidth, float drawHeight) :
        AnimatedGraphicsComponent(drawWidth, drawHeight),
        mTriggeredComponent(NULL)
        { mTypeId = FX;}
        
        // this only works with 16 frame textures
        inline void SetFXTexture(Texture2D* texture)
        {
            mAnimations[IDLE]->mSpriteSheet =texture; 
        }
        
        // this only works with 16 frame textures
        inline void PlayBigVertices(bool playBigVertices, float scale)
        {
            mAnimations[IDLE]->mPlayBigVertices = playBigVertices; 
            if(mBigVertices == NULL)
            {
                mBigVertices = new Vec3[4];
            }
            
            mBigVertices[0].setValue( -scale*0.5, 0, scale*0.5);
            mBigVertices[1].setValue(scale*0.5, 0, scale*0.5);
            mBigVertices[2].setValue(-scale*0.5, 0, -scale*0.5);
            mBigVertices[3].setValue(scale*0.5, 0, -scale*0.5);
        }
        
        void FollowParentRotation() { mIgnoreParentRotation = false;}
        
        GraphicsComponent* mTriggeredComponent;
    };

    
    // transforms with parent object (ie ball)
    class BillBoard : public FXGraphicsComponent
    {
    public:
        BillBoard(float drawWidth, float drawHeight)
        : FXGraphicsComponent(drawWidth, drawHeight)
        {}
        
        void Update(float deltaTime);	
        
    };
    
    //holds an animation on the last frame
    class HoldLastAnim : public FXGraphicsComponent
    {
        //int mNumFrames;
        
    public:
        HoldLastAnim(float drawWidth, float drawHeight)
        :FXGraphicsComponent(drawWidth, drawHeight)
        {
            mTypeId=GRAPHICS;
        }
        
    };

}