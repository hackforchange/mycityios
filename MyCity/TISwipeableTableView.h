//
//  TISwipeableTableView.h
//  TISwipeableTableView
//
//  Created by Tom Irving on 28/05/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

//==========================================================
// - TISwipeableTableView
//==========================================================

@protocol TISwipeableTableViewDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface TISwipeableTableView : UITableView {

	id <TISwipeableTableViewDelegate> swipeDelegate;
	
	NSIndexPath * indexOfVisibleBackView;
	CGPoint gestureStartPoint;
}

@property (nonatomic, assign) id <TISwipeableTableViewDelegate> swipeDelegate;
@property (nonatomic, retain) NSIndexPath * indexOfVisibleBackView;

- (void)hideVisibleBackView:(BOOL)animated;

- (void)showBackForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

//==========================================================
// - TISwipeableTableViewCell
//==========================================================

@interface TISwipeableTableViewCellView : UIView
@end

@interface TISwipeableTableViewCellBackView : UIView
@end

@interface TISwipeableTableViewCell : UITableViewCell {

	UIView * contentView;
	UIView * backView;
	
	BOOL contentViewMoving;
	BOOL selected;
	BOOL shouldSupportSwiping;
	BOOL shouldBounce;
}

@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) UIView * backView;
@property (nonatomic, assign) BOOL contentViewMoving;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, assign) BOOL shouldSupportSwiping;
@property (nonatomic, assign) BOOL shouldBounce;

- (void)drawContentView:(CGRect)rect;
- (void)drawBackView:(CGRect)rect;

- (void)backViewWillAppear;
- (void)backViewDidAppear;
- (void)backViewWillDisappear;
- (void)backViewDidDisappear;

- (void)revealBackView;
- (void)hideBackView;
- (void)resetViews;

@end
