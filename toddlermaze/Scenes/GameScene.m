//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import "GameScene.h"
#import "MazeGenerator.h"

@implementation GameScene
- (id)init
{
    self = [super init];
    MazeGenerator *generator = [[[MazeGenerator alloc] init] autorelease];
    return self;
}
@end