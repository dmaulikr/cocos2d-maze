//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import <Foundation/Foundation.h>

@class MazeCell;
@class CCSprite;
@class Entity;

@interface MazeGenerator : NSObject
@property (nonatomic, retain) NSMutableDictionary *grid;
@property (nonatomic, assign) CGSize size;
- (void)generateGrid;

- (void)addToNeighbors:(MazeCell *)cell;

- (void)createUsingDepthFirstSearch;

- (BOOL)isPositionInMaze:(CGPoint)position;

- (MazeCell *)cellForPosition:(CGPoint)position;

- (void)searchUsingDepthFirstSearch:(CGPoint)start endingAt:(CGPoint)end movingEntity:(Entity *)entity;


@end