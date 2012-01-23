//
// @author Jonny Brannum <jonny.brannum@gmail.com> 
//         1/21/12
//

#import <Foundation/Foundation.h>

@class MazeCell;
@class CCSprite;

@interface MazeGenerator : NSObject
@property (nonatomic, retain) NSMutableDictionary *grid;
@property (nonatomic, assign) CGSize size;
- (void)generateGrid;

- (void)addToNeighbors:(MazeCell *)cell;

- (void)createUsingDepthFirstSearch;

- (void)searchUsingDepthFirstSearch:(CGPoint)start endingAt:(CGPoint)end movingEntity:(CCSprite *)entity;


@end