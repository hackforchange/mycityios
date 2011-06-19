//
//  EMOptionsTableViewCell.h
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTableCellSubMenuView.h"

@protocol EMOptionsTableViewCellDelegate;

@interface EMOptionsTableViewCell : UITableViewCell <EMTableCellSubMenuViewDelegate> {
    
}
@property (nonatomic, assign) id<EMOptionsTableViewCellDelegate>delegate;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, readonly) EMTableCellSubMenuView *subMenuView;

- (void)showSubMenu;
- (void)hideSubMenu;

@end

@protocol EMOptionsTableViewCellDelegate <NSObject>
@optional
- (void)optionsTableViewCellDidShowSubMenu:(EMOptionsTableViewCell *)optionsCell;
- (void)optionsTableViewCellDidHideSubMenu:(EMOptionsTableViewCell *)optionsCell;
- (void)optionsTableViewCellSubMenuButtonsWasTapped:(EMOptionsTableViewCell *)optionsCell;
@end
