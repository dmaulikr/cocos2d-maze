//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import <Foundation/Foundation.h>

@interface MazeCell : NSObject
- (id)initWithIndex:(NSNumber *)index;

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, retain) NSMutableDictionary *neighbors;
@property (nonatomic, retain) NSMutableDictionary *walls;
@end

@interface MazeGenerator : NSObject

- (void)generate;

- (void)addToNeighbors:(MazeCell *)cell;

- (void)depthFirstSearch;


@end