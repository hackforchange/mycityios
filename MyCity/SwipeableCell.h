//
//  SwipeableCell.h
//  SwipeableExample
//
//  Created by Tom Irving on 16/06/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TISwipeableTableView.h"

@protocol SwipeableCellDelegate;

@interface SwipeableCell : TISwipeableTableViewCell {
	
	NSString * text;
    NSNumber * votes;
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * votes;
@property (nonatomic, retain) UIButton *btnVote;

@property (nonatomic, assign) id<SwipeableCellDelegate> delegate;

- (void)drawShadowsWithHeight:(CGFloat)shadowHeight opacity:(CGFloat)opacity InRect:(CGRect)rect forContext:(CGContextRef)context;

@end

@protocol SwipeableCellDelegate <NSObject>
@optional
- (void)swipeableCellFixItButtonWasPressed:(SwipeableCell *)cell;

@end
