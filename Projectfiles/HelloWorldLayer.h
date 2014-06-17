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
    
    float rotation;
    float lasttouchangle;
    
    CCSprite* block;
    CCSprite* block2;
    
    CCSprite* player;
}

@end
