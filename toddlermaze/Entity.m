//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/22/12
//

#import "Entity.h"
#import "CCActionInterval.h"
#import "CGPointExtension.h"

@implementation Entity
- (id)init
{
    self = [super init];
    CCSprite *glow = [CCSprite spriteWithFile:@"entity.png"];
    [glow setBlendFunc: (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    id sequence = [CCSequence actions:
        [CCFadeTo actionWithDuration:0.5f opacity:100],
        [CCFadeTo actionWithDuration:0.5f opacity:255],
        nil
    ];
    [glow runAction:[CCRepeatForever actionWithAction:sequence]];
    [glow setPosition:ccp(glow.textureRect.size.width/2, glow.textureRect.size.height/2)];
    [self addChild:glow];
    return self;
}
@end