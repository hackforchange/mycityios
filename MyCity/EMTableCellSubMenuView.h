//
//  EMTableCellSubMenuView.h
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMTableCellSubMenuViewDelegate;

@interface EMTableCellSubMenuView : UIView {
    UIButton *_mainBtn;
}

@property (nonatomic, assign) id<EMTableCellSubMenuViewDelegate> delegate;


@end

@protocol EMTableCellSubMenuViewDelegate <NSObject>

- (void)tableCellSubMenuViewButtonWasTapped:(EMTableCellSubMenuView *)subMenu;

@end
