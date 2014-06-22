//
//  Title.m
//  Rotate
//
//  Created by Kevin Frans on 6/19/14.
//
//

#import "Title.h"
#import "HelloWorldLayer.h"

@implementation Title

CCSprite* player;
CCSprite* block;
CCSprite* block2;


-(id) init
{
	if ((self = [super init]))
	{
        [self scheduleUpdate];
        
        
        CCSprite* bg = [CCSprite spriteWithFile:@"titlebg.png"];
        bg.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:bg];
        
        CCLabelTTF* title = [CCLabelTTF labelWithString:@"rotate" fontName:@"HelveticaNeue-UltraLight" fontSize:60];
        title.color = ccc3(0,0,0);
        title.position = ccp([CCDirector sharedDirector].screenCenter.x,[CCDirector sharedDirector].screenCenter.y + 100);
        [self addChild:title];
        //title.scale = 0;
        
        title.opacity = 0;
        
        CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0];
        CCFadeIn* fadein = [CCFadeIn actionWithDuration:1.0];
        CCSequence* actions = [CCSequence actions:delay,fadein, nil];
        
        [title runAction:actions];
        
        CGPoint screencenter = [CCDirector sharedDirector].screenCenter;
        
        //player sprite
        player = [CCSprite spriteWithFile:@"orange.png"];
        player.position = screencenter;
        [self addChild:player z:3];
        player.scale = 0;
        player.anchorPoint = ccp(0.5,0.5);
        
        //blockades
        block = [CCSprite spriteWithFile:@"block.png"];
        block.position = screencenter;
        [self addChild:block z:3];
        block.scale = 0;
        
        block2 = [CCSprite spriteWithFile:@"block.png"];
        block2.position = screencenter;
        [self addChild:block2 z:3];
        block2.scale = 0;
        block2.rotation = 180;
        
        id scale = [CCScaleTo actionWithDuration:1.0f scale:0.15f];
        id scale2 = [CCScaleTo actionWithDuration:1.0f scale:0.15f];
        id scale3 = [CCScaleTo actionWithDuration:1.0f scale:0.15f];
        
        [player runAction:scale];
        [block runAction:scale2];
        [block2 runAction:scale3];
        
        
        [self changeColor];
        

        
        
    }
    return self;
}


-(void) changeColor
{
    int randcolor = arc4random() % 7;
    [[NSUserDefaults standardUserDefaults] setInteger:randcolor forKey:@"color"];
    
    
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

-(void)update:(ccTime)dt
{
    
    if ([KKInput sharedInput].anyTouchBeganThisFrame)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:player.rotation forKey:@"rotation"];
        [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    }
    
    player.rotation = player.rotation + 1;
    block.rotation = block.rotation + 1;
    block2.rotation = block2.rotation + 1;
}

@end
