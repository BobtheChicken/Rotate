/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"

@interface HelloWorldLayer : CCLayer
{
    int screenheight;
    int screenwidth;
    CGPoint screencenter;
    
    bool isdead;
    bool karthus;
    float deadrotation;
    
    float diffcount;
    
    float rotation;
    float lasttouchangle;
    
    NSMutableArray* circle2;
    NSMutableArray* circle2dir;
    NSMutableArray* circle2color;
    
    CCSprite* block;
    CCSprite* block2;
    
    int score;
    CCLabelTTF* scorelabel;
    
    CCSpriteBatchNode* SpriteSheet1;
    
    CCMotionStreak* blockstreak;
    CCMotionStreak* blockstreak2;
    
    float blockside1;
    float blockside2;
    float blockside3;
    float blockside4;
    
    int enemyspeed;
    
    int playerWidth;
    
    int colorseeking;
    
    CCSprite* player;
    
    CCRenderTexture* rt;
    

}

+(id) scene;

@end
