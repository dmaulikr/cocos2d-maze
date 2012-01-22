//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import <Foundation/Foundation.h>

static const CGPoint kNorth = {0, 1};
static const CGPoint kSouth = {0, -1};
static const CGPoint kWest = {-1, 0};
static const CGPoint kEast = {1, 0};

@interface MazeCell : NSObject
- (id)initWithIndex:(NSNumber *)index;

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, retain) NSMutableDictionary *neighbors;
@property (nonatomic, retain) NSMutableDictionary *walls;
@end

@interface MazeGenerator : NSObject
@property (nonatomic, retain) NSMutableDictionary *grid;
@property (nonatomic, assign) CGSize size;
- (void)generate;

- (void)addToNeighbors:(MazeCell *)cell;

- (void)depthFirstSearch;


@end