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
    }
    return self;
}

-(void)update:(ccTime)dt
{
    
    if ([KKInput sharedInput].anyTouchBeganThisFrame)
    {
        [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
    }
}

@end
