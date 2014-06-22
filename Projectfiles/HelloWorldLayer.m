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

#define PTM_RATIO 32.0

-(id) init
{
	if ((self = [super init]))
	{
		glClearColor(0,0,0,255);
        
        diffcount = 100;
        
        layer = [CCLayer node];
        [self addChild:layer];
        
        //score
        score = 0;
        
        //batchnode
        SpriteSheet1 = [CCSpriteBatchNode batchNodeWithFile:@"orange.png"];
        [layer addChild:SpriteSheet1];
        
        //bg
        CCSprite* bg = [CCSprite spriteWithFile:@"bgc.png"];
        bg.position = screencenter;
        [layer addChild:bg z:-1];
        bg.scale = 1;
        
        CCSprite* wall = [CCSprite spriteWithFile:@"walls.png"];
        wall.position = screencenter;
        [layer addChild:wall z:5];
        wall.scale = 2;
        
		//SCREEN VALUES
        screencenter = [CCDirector sharedDirector].screenCenter;
        screenheight = [CCDirector sharedDirector].winSize.height;
        screenwidth = [CCDirector sharedDirector].winSize.width;
        
        //top label
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Rotate" fontName:@"Arial" fontSize:20];
		label.position = ccp(screenwidth/2,screenheight - 40);
		label.color = ccWHITE;
		//[layer addChild:label];
        
        //player sprite
        player = [CCSprite spriteWithFile:@"orange.png"];
        player.position = ccp(screencenter.x - 50,screencenter.y);
        [layer addChild:player z:6];
        player.scale = 0.15;
        player.anchorPoint = ccp(0.5,0.5);
        player.rotation = [[NSUserDefaults standardUserDefaults] floatForKey:@"rotation"];
        
        //blockades
        block = [CCSprite spriteWithFile:@"block.png"];
        block.position = screencenter;
        [layer addChild:block z:6];
        block.scale = 0.15;
        block.rotation = [[NSUserDefaults standardUserDefaults] floatForKey:@"rotation"];
        
        block2 = [CCSprite spriteWithFile:@"block.png"];
        block2.position = screencenter;
        [layer addChild:block2 z:6];
        block2.scale = 0.15;
        block2.rotation = [[NSUserDefaults standardUserDefaults] floatForKey:@"rotation"] + 180;
        
        
        
        
        //motion streak
        [self blur];
        
        
        //some variables
        playerWidth = [player boundingBox].size.width;
        enemyspeed = 1;
        isdead = false;
        karthus = false;
        
        
        //initialize array
        circle2 = [[NSMutableArray alloc] init];
        circle2dir = [[NSMutableArray alloc] init];
        circle2color = [[NSMutableArray alloc] init];
        
        //label
        scorelabel = [CCLabelTTF labelWithString:@"0" fontName:@"HelveticaNeue-UltraLight" fontSize:30];
        scorelabel.color = ccc3(0, 0, 0);
        scorelabel.position = ccp(15,screenheight - 15);
        [self addChild:scorelabel z:1];
        
        //color
        rt = [[CCRenderTexture alloc] initWithWidth:screenwidth height:screenheight pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        
        //enemies
        for(int i = 0; i < 100; i++)
        {
            CCSprite* enemy = [CCSprite spriteWithFile:@"orange.png"];
            
            int randx = 200;
            int randy = 200;
            
            bool tryagainx = [self getYesOrNo];
            bool tryagainy = [self getYesOrNo];
            
            
            
            
            
            randx = (arc4random() % 300);
            if(tryagainx)
            {
                randx = 250 + randx;
            }
            else
            {
                randx = -50 - randx;
            }
            
            randy = (arc4random() % 300);
            if(tryagainy)
            {
                randy = 150 + randy;
            }
            else
            {
                randy = -150 - randy;
            }
            
            enemy.position = ccp(randx,randy);
            
            int rands = arc4random() % 10;
            
            enemy.scale = 0.05 + (rands * 0.02);
            [SpriteSheet1 addChild:enemy];
            [circle2 addObject:enemy];
            
            int randd = arc4random() % 360;
            NSNumber *dir = [NSNumber numberWithInt:randd];
            [circle2dir addObject:dir];
            
            int randcolor = arc4random() % 7;
            
            [circle2color addObject:[NSNumber numberWithInt:randcolor]];
            
            int r;
            int g;
            int b;
            
            switch(randcolor)
            {
                case 0:
                    r = 22;
                    g = 160;
                    b = 133;
                    break;
                case 1:
                    //rgb(46, 204, 113)
                    r = 46;
                    g = 204;
                    b = 113;
                    break;
                case 2:
                    //rgb(52, 152, 219)
                    r = 52;
                    g = 152;
                    b = 219;
                    break;
                case 3:
                    //rgb(142, 68, 173)
                    r = 142;
                    g = 68;
                    b = 173;
                    break;
                case 4:
                    //rgb(241, 196, 15)
                    r = 241;
                    g = 196;
                    b = 15;
                    break;
                case 5:
                    //rgb(230, 126, 34)
                    r = 230;
                    g = 126;
                    b = 34;
                    break;
                case 6:
                    //rgb(231, 76, 60)
                    r = 231;
                    g = 76;
                    b = 60;
                    break;
            }
            
            id tint = [CCTintTo actionWithDuration:0.0f red:r green:g blue:b];
            [enemy runAction:tint];
            
        }
        
        [self changeColorStart];
        
        
        
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
    [self streaking];
    [self rollover];
    [self enemies];
    [self circleCollisionWith];
    [self calculateblocks];
    [self karthuspassive];
    [self scoreplacement];
    
}

-(void) scoreplacement
{
    //scorelabel.position = ccp(block.position.x - screenwidth/2 + 15,block.position.y + screenheight/2 - 15);
}

-(BOOL) getYesOrNo
{
    return (CCRANDOM_0_1() < 0.5f);
}

-(void) dead
{
    CCSprite* dark = [CCSprite spriteWithFile:@"dark.png"];
    dark.position = player.position;
    dark.opacity = 0;
    dark.scale = 2;
    id fade = [CCFadeTo actionWithDuration:1.0 opacity:200];
    [layer addChild:dark];
    [dark runAction:fade];
    
    id tint = [CCTintTo actionWithDuration:1.0f red:255 green:255 blue:255];
    id tint2 = [CCTintTo actionWithDuration:1.0f red:255 green:255 blue:255];
    id tint3 = [CCTintTo actionWithDuration:1.0f red:255 green:255 blue:255];
    id fadeplayer = [CCFadeTo actionWithDuration:1.0 opacity:155];
    id fadeblock = [CCFadeTo actionWithDuration:1.0 opacity:155];
    id fadeblock2 = [CCFadeTo actionWithDuration:1.0 opacity:155];
    [player runAction:tint];
    [block runAction:tint2];
    [block2 runAction:tint3];
    [player runAction:fadeplayer];
    [block runAction:fadeblock];
    [block2 runAction:fadeblock2];
    
    
    [self removeChild:scorelabel];
    
    CCLabelTTF* gameover = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"HelveticaNeue-UltraLight" fontSize:60];
    [layer addChild:gameover z:14];
    gameover.opacity = 0;
    id fade2 = [CCFadeIn actionWithDuration:2.0];
    [gameover runAction:fade2];
    gameover.position = ccp(player.position.x,player.position.y + 150);
    
    
    if(!([[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"] > score))
    {
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highscore"];
    }
    
    
    CCLabelTTF* highscore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"high score: %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"]] fontName:@"HelveticaNeue-UltraLight" fontSize:20];
    [layer addChild:highscore z:14];
    highscore.opacity = 0;
    id fade3 = [CCFadeIn actionWithDuration:2.0];
    [highscore runAction:fade3];
    highscore.position = ccp(player.position.x - screenwidth/2 + 15,player.position.y + screenheight/2 - 15);
    highscore.anchorPoint = ccp(0,0.5);
    
    
    
    CCLabelTTF* retry = [CCLabelTTF labelWithString:@"rotate to retry" fontName:@"HelveticaNeue-UltraLight" fontSize:30];
    [layer addChild:retry z:14];
    retry.opacity = 0;
    id faderet = [CCFadeIn actionWithDuration:2.0];
    [retry runAction:faderet];
    retry.position = ccp(player.position.x,player.position.y - 100);
    
    
    
    [self performSelector:@selector(karthusult) withObject:nil afterDelay:1.5f];
}

-(void) karthuspassive
{
    if(karthus)
    {
        
        int opacity;
        if(deadrotation > block.rotation)
        {
            opacity = deadrotation - block.rotation;
        }
        else if(deadrotation < block.rotation)
        {
            opacity = block.rotation - deadrotation;
        }
        else
        {
            opacity = 255*2;
        }
        
        //NSLog(@"%f--%f",deadrotation,block.rotation);
        
        float op = fabsf(diffcount + 155);
        
       
        
        if(op > 255)
        {
            op = 225 - op;
        }
        
        op = op - 100;
        
        if(op < 0)
        {
        //    op = 0;
        }
        
        
        if(op < 0.0 && op > -70.0)
        {
           op = 0;
        }
        
        else if( op < -255)
        {
            op = 0;
        }
        
        if(op == 0)
        {
            [[NSUserDefaults standardUserDefaults] setFloat:0 forKey:@"rotation"];
            [[NSUserDefaults standardUserDefaults] setInteger:(arc4random() % 7) forKey:@"color"];
            [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];

        }
        
        //NSLog(@"%f,%f",diffcount,op);
        
        player.opacity = op;
        block.opacity = op;
        block2.opacity = op;
        
    }
}

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    HelloWorldLayer *layer = [HelloWorldLayer node];
    
    [scene addChild: layer];
    
    return scene;
}

-(void) calculateblocks
{
    blockside1 = block.rotation + 55;
    blockside2 = block.rotation + 145;
    blockside3 = block.rotation + 205;
    blockside4 = block.rotation + 325;
    
    blockside1 = [self normalize:blockside1];
    blockside2 = [self normalize:blockside2];
    blockside3 = [self normalize:blockside3];
    blockside4 = [self normalize:blockside4];
    
    
    
}

-(float) normalize:(float)blockside
{
    while((blockside <= 360 && blockside >= 0)==false)
    {
        if (blockside < 0) {
            return blockside + 360;
        }
        
        if (blockside > 360) {
            return blockside - 360;
        }
    }
    return blockside;
}


-(void) changeColorStart
{
    int randcolor = [[NSUserDefaults standardUserDefaults] integerForKey:@"color"];
    
    colorseeking = randcolor;
    
    int r;
    int g;
    int b;
    
    switch(randcolor)
    {
        case 0:
            r = 22;
            g = 160;
            b = 133;
            break;
        case 1:
            //rgb(46, 204, 113)
            r = 46;
            g = 204;
            b = 113;
            break;
        case 2:
            //rgb(52, 152, 219)
            r = 52;
            g = 152;
            b = 219;
            break;
        case 3:
            //rgb(142, 68, 173)
            r = 142;
            g = 68;
            b = 173;
            break;
        case 4:
            //rgb(241, 196, 15)
            r = 241;
            g = 196;
            b = 15;
            break;
        case 5:
            //rgb(230, 126, 34)
            r = 230;
            g = 126;
            b = 34;
            break;
        case 6:
            //rgb(231, 76, 60)
            r = 231;
            g = 76;
            b = 60;
            break;
    }
    
    id tint = [CCTintTo actionWithDuration:0.01f red:r green:g blue:b];
    id tint2 = [CCTintTo actionWithDuration:0.01f red:r*3/4 green:g*3/4 blue:b*3/4];
    id tint3 = [CCTintTo actionWithDuration:0.01f red:r*3/4 green:g*3/4 blue:b*3/4];
    
    [block runAction:tint2];
    [block2 runAction:tint3];
    
    [player runAction:tint];
}

-(void) changeColor
{
    int randcolor = arc4random() % 7;
    
    colorseeking = randcolor;
    
    int r;
    int g;
    int b;
    
    switch(randcolor)
    {
        case 0:
            r = 22;
            g = 160;
            b = 133;
            break;
        case 1:
            //rgb(46, 204, 113)
            r = 46;
            g = 204;
            b = 113;
            break;
        case 2:
            //rgb(52, 152, 219)
            r = 52;
            g = 152;
            b = 219;
            break;
        case 3:
            //rgb(142, 68, 173)
            r = 142;
            g = 68;
            b = 173;
            break;
        case 4:
            //rgb(241, 196, 15)
            r = 241;
            g = 196;
            b = 15;
            break;
        case 5:
            //rgb(230, 126, 34)
            r = 230;
            g = 126;
            b = 34;
            break;
        case 6:
            //rgb(231, 76, 60)
            r = 231;
            g = 76;
            b = 60;
            break;
    }
    
    id tint = [CCTintTo actionWithDuration:1.0f red:r green:g blue:b];
    id tint2 = [CCTintTo actionWithDuration:1.0f red:r*3/4 green:g*3/4 blue:b*3/4];
    id tint3 = [CCTintTo actionWithDuration:1.0f red:r*3/4 green:g*3/4 blue:b*3/4];
    
    [block runAction:tint2];
    [block2 runAction:tint3];
    
    [player runAction:tint];
}

-(void) streaking
{
    CGPoint endPoint;
    endPoint.x = sinf(CC_DEGREES_TO_RADIANS(player.rotation - 30)) * 40;
    endPoint.y = cosf(CC_DEGREES_TO_RADIANS(player.rotation - 30)) * 40;
    endPoint = ccpAdd(player.position, endPoint);
    
    CGPoint endPoint2;
    endPoint2.x = sinf(CC_DEGREES_TO_RADIANS(player.rotation + 30)) * 40;
    endPoint2.y = cosf(CC_DEGREES_TO_RADIANS(player.rotation + 30)) * 40;
    endPoint2 = ccpAdd(player.position, endPoint2);
    
    
    blockstreak.position = endPoint;
    
    blockstreak2.position = endPoint2;
    
}

-(void) rollover
{
    if(player.position.y > 700)
    {
        if(!isdead)
        {
            [self dead];
        }
        isdead = true;
    }
    
    if(player.position.y < -700)
    {
        if(!isdead)
        {
            [self dead];
        }
        isdead = true;
    }
    
    if(player.position.x > 700)
    {
        
        if(!isdead)
        {
            [self dead];
        }
        isdead = true;
    }
    
    if(player.position.x < -700)
    {
        if(!isdead)
        {
            [self dead];
        }
        isdead = true;
        
        
        
    }
    
    
    
}

-(void) blur
{
    //    //motion streak
    //    blockstreak = [CCMotionStreak streakWithFade:1.5 minSeg:1 width:25 color:ccc3(255,255,255) textureFilename:@"orange.png"];
    //    blockstreak.position = block.position;
    //    [layer addChild:blockstreak];
    //
    //    blockstreak2 = [CCMotionStreak streakWithFade:1.5 minSeg:1 width:25 color:ccc3(255,255,255) textureFilename:@"orange.png"];
    //    blockstreak2.position = block2.position;
    //    [layer addChild:blockstreak2];
}

-(void) camerad
{
    [layer runAction:[CCFollow actionWithTarget:(player) worldBoundary:CGRectMake(-1000,-1000,2000,2000)]];
}

-(void) positioning
{
    block.position = player.position;
    block2.position = player.position;
}


-(void) karthusult
{
    karthus = true;
    deadrotation = block.rotation;
}

-(void) movement
{
    float angle = block.rotation + 180;
    float speed = 2; // Move 50 pixels in 60 frames (1 second)
    
    float vx = cos(angle * M_PI / 180) * speed;
    float vy = sin(angle * M_PI / 180) * speed;
    
    CGPoint direction = ccp(vx,-vy);
    
    if(!isdead)
    {
        
        player.position = ccpAdd(player.position, direction);
        
        //scorelabel.position = ccpAdd(scorelabel.position, direction);
        
        player.rotation = angle + 90;
    }
    
    
}

-(void) bounceAnim:(CCSprite*) sprite
{
    float orginialscale = sprite.scaleY;
    id scalein = [CCScaleTo actionWithDuration:0.5f scaleX:orginialscale/5 scaleY:orginialscale];
    id delayTimeAction = [CCDelayTime actionWithDuration:0.2];
    
    int rands = arc4random() % 10;
    
    float sc = 0.05 + (rands * 0.02);
    
    id scaleout = [CCScaleTo actionWithDuration:0.2f scale:sc];
    
    id action = [CCSequence actions:scalein,scaleout, nil];
    [sprite runAction:action];
}

-(void) bounceAnimY:(CCSprite*) sprite
{
    float orginialscale = sprite.scaleY;
    id scalein = [CCScaleTo actionWithDuration:0.5f scaleX:orginialscale scaleY:orginialscale/5];
    id delayTimeAction = [CCDelayTime actionWithDuration:0.2];
    
    int rands = arc4random() % 10;
    
    float sc = 0.05 + (rands * 0.02);
    
    id scaleout = [CCScaleTo actionWithDuration:0.2f scale:sc];
    
    id action = [CCSequence actions:scalein,scaleout, nil];
    [sprite runAction:action];
}

-(void) enemies
{
    for(NSUInteger i = 0; i < [circle2 count];i++)
    {
        
        CCSprite* temp = [circle2 objectAtIndex:i];
        NSNumber *anglea = [circle2dir objectAtIndex:i];
        float angle = [anglea floatValue];
        float speed = enemyspeed; // Move 50 pixels in 60 frames (1 second)
        
        float vx = cos(angle * M_PI / 180) * speed;
        float vy = sin(angle * M_PI / 180) * speed;
        
        CGPoint direction = ccp(vx,-vy);
        
        temp.position = ccpAdd(temp.position, direction);
        
        temp.rotation = angle + 90;
        
        float hitdir = angle;
        
        
        if(temp.position.y > 700)
        {
            if(hitdir > 180)
            {
                hitdir = 180 - (hitdir-180);
            }
            else if(hitdir < 180)
            {
                hitdir = 180 + (180-hitdir);
            }
            [circle2dir replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:hitdir]];
            [self bounceAnimY:temp];
        }
        
        if(temp.position.y < -700)
        {
            //            }
            hitdir = 360 - hitdir;
            [circle2dir replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:hitdir]];
            [self bounceAnimY:temp];
        }
        
        if(temp.position.x > 700)
        {
            if(hitdir > 270)
            {
                hitdir = 270 - (hitdir - 270);
            }
            else if(hitdir < 270)
            {
                hitdir = 270 + (270 - hitdir);
            }
            [circle2dir replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:hitdir]];
            [self bounceAnim:temp];
        }
        
        if(temp.position.x < -700)
        {
            if(hitdir > 90)
            {
                hitdir = 90 - (hitdir - 90);
            }
            else if(hitdir < 90)
            {
                hitdir = 90 + (90 - hitdir);
            }
            [circle2dir replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:hitdir]];
            [self bounceAnim:temp];
        }
    }
    
    
}

-(void) rotations
{
    KKInput *input = [KKInput sharedInput];
    input.multipleTouchEnabled = true;
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    if(!isdead || karthus)
    {
        
        if(pos.x != 0 && pos.y != 0)
        {
            //        [self divideAngularSections];
            
            
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
                
                if(karthus)
                {
                    diffcount += diff;
                   
                }
                
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
}

-(void) circleCollisionWith
{
    
    
    //    [self updateCollisionCounter];
    
    if(!isdead)
    {
        
        for(NSUInteger i = 0; i < [circle2 count]; i++)
        {
            CCSprite* tempSprite = [circle2 objectAtIndex:i];
            float c1radius = (player.boundingBox.size.width/2) - 15; //[circle1 boundingBox].size.width/2; // circle 1 radius
            // NSLog(@"Circle 1 Radius: %f", c1radius);
            float c2radius = [tempSprite boundingBox].size.width/2; // circle 2 radius
            //        float c2radius = c.contentSize.width/2;
            float radii = c1radius + c2radius;
            float distX = player.position.x - tempSprite.position.x;
            float distY = player.position.y - tempSprite.position.y;
            float distance = sqrtf((distX * distX) + (distY * distY));
            
            
            if (distance <= radii) { // did the two circles collide at all??
                
                
                if([[circle2color objectAtIndex:i] intValue] == colorseeking)
                {
                    score++;
                    [scorelabel setString:[NSString stringWithFormat:@"%d",score]];
                    
                    //id tint = [CCTintTo actionWithDuration:1.0 red:255 green:255 blue:255];
                    id fade = [CCFadeTo actionWithDuration:1.0];
                    [tempSprite runAction:fade];//[self removeChild:tempSprite cleanup:YES];
                    [circle2color removeObjectAtIndex:i];
                    [circle2dir removeObjectAtIndex:i];
                    [circle2 removeObjectAtIndex:i];
                    [self changeColor];
                }
                else
                {
                    if(!isdead)
                    {
                        [self dead];
                    }
                    isdead = true;
                    
                }
                
                //
            }
            
            
        }
        
    }
}

-(void) conv360:(float) shipAngle
{
    if (shipAngle < 0)
    {
        shipAngle+=360;
    }
    
    if (shipAngle > 360) {
        shipAngle-= 360;
    }
    
}

- (CGFloat) pointPairToBearingDegrees:(CGPoint)startingPoint secondPoint:(CGPoint) endingPoint
{
    CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y); // get origin point to origin by subtracting end from start
    float bearingRadians = atan2f(originPoint.y, originPoint.x); // get bearing in radians
    float bearingDegrees = bearingRadians * (180.0 / M_PI); // convert to degrees
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees)); // correct discontinuity
    return bearingDegrees;
}

@end
