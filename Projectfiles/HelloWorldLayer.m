/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
@end

@implementation HelloWorldLayer



-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0,0,0,255);
        
		//SCREEN VALUES
        screencenter = [CCDirector sharedDirector].screenCenter;
        screenheight = [CCDirector sharedDirector].winSize.height;
        screenwidth = [CCDirector sharedDirector].winSize.width;
        
        //top label
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Rotate" fontName:@"Arial" fontSize:20];
		label.position = ccp(screenwidth/2,screenheight - 40);
		label.color = ccWHITE;
		[self addChild:label];
        
        //player sprite
        player = [CCSprite spriteWithFile:@"orange.png"];
        player.position = screencenter;
        [self addChild:player];
        player.scale = 0.15;
        
        //blockades
        block = [CCSprite spriteWithFile:@"block.png"];
        block.position = screencenter;
        [self addChild:block];
        block.scale = 0.15;
        
        block2 = [CCSprite spriteWithFile:@"block.png"];
        block2.position = screencenter;
        [self addChild:block2];
        block2.scale = 0.15;
        block2.rotation = 180;
        
        [self scheduleUpdate];
	}
    
	return self;
}

-(void)update:(ccTime)dt
{
    [self rotations];
    [self movement];
    [self positioning];
    [self camerad];
    
    screenheight = [CCDirector sharedDirector].winSize.height;
    screenwidth = [CCDirector sharedDirector].winSize.width;
    

}

-(void) camerad
{
    [self runAction:[CCFollow actionWithTarget:(player) worldBoundary:CGRectMake(0,0,1050,2000)]];
}

-(void) positioning
{
    block.position = player.position;
    block2.position = player.position;
}

-(void) movement
{
    float angle = block.rotation + 180;
    float speed = 2; // Move 50 pixels in 60 frames (1 second)
    
    float vx = cos(angle * M_PI / 180) * speed;
    float vy = sin(angle * M_PI / 180) * speed;
    
    CGPoint direction = ccp(vx,-vy);
    
    player.position = ccpAdd(player.position, direction);

    player.rotation = angle + 90;
    
    
}

-(void) rotations
{
    KKInput *input = [KKInput sharedInput];
    input.multipleTouchEnabled = true;
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if(pos.x != 0 && pos.y != 0)
    {
//        [self divideAngularSections];
        
        NSLog(@"%f,%f",pos.x,pos.y);
        
        float distX = pos.x - screencenter.x;
        float distY = pos.y - screencenter.y;
        float touchDistance = sqrtf((distX * distX) + (distY * distY));
        
        
        float ratio = distY/touchDistance; // ratio of distance in terms of Y to distance from player
        float shipAngleRadians = asin(ratio); // arcsin of ratio
        float antiShipAngle = CC_RADIANS_TO_DEGREES(shipAngleRadians) * (-1); // convert to degrees from radians
        //        float rotation = antiShipAngle; // shipAngle
        
        CGPoint rot_pos1 = screencenter;//[block position];
        CGPoint rot_pos2 = pos;
        
        CGPoint circle_pos1 = [block position];
        CGPoint circle_pos2 = pos;
        
        //    rot_pos1 = [player position];
        //    rot_pos2 = posOfTouch;
        
        float rotation_theta = atan((rot_pos1.y-rot_pos2.y)/(rot_pos1.x-rot_pos2.x)) * 180 / M_PI;
        
        //        float rotation;
        
        if(rot_pos1.y - rot_pos2.y > 0)
        {
            if(rot_pos1.x - rot_pos2.x < 0)
            {
                rotation = (-90-rotation_theta);
            }
            else if(rot_pos1.x - rot_pos2.x > 0)
            {
                rotation = (90-rotation_theta);
            }
        }
        else if(rot_pos1.y - rot_pos2.y < 0)
        {
            if(rot_pos1.x - rot_pos2.x < 0)
            {
                rotation = (270-rotation_theta);
            }
            else if(rot_pos1.x - rot_pos2.x > 0)
            {
                rotation = (90-rotation_theta);
            }
        }
        
        if (rotation < 0)
        {
            rotation+=360;
        }
        
        
        
        
        float diff = (lasttouchangle-rotation) * (-1);
        
        
        if (!input.anyTouchBeganThisFrame) {
            block.rotation += diff; // was originally player.rotation += diff

            if (block.rotation < 0) {
                block.rotation = block.rotation + 360.f;
            }
            
            if (block.rotation > 360) {
                block.rotation -= 360;
            }
            
            block2.rotation = block.rotation + 180;
            
           

        }
        
        lasttouchangle = rotation;
        

    }
}

@end
