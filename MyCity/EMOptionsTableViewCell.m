//
//  EMOptionsTableViewCell.m
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import "EMOptionsTableViewCell.h"

#define kSubMenuViewHeight  44.0
#define kSubMenuAnimationDuration 0.3

@implementation EMOptionsTableViewCell

@synthesize delegate = _delegate;
@synthesize subMenuView = _subMenuView;
@synthesize titleLabel = _titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    if (_subMenuView) {
        [_subMenuView release];
        _subMenuView = nil;
    }
    self.delegate = nil;
    self.titleLabel = nil;
    [super dealloc];
}

- (EMTableCellSubMenuView *)subMenuView {
    if (_subMenuView == nil) {
        CGRect subMenuFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), kSubMenuViewHeight);
        _subMenuView = [[EMTableCellSubMenuView alloc] initWithFrame:subMenuFrame];
        [_subMenuView setDelegate:self];
    }
    
    return _subMenuView;
}

#pragma mark -
#pragma mark Custom methods

- (void)showSubMenu {
    [self.contentView addSubview:self.subMenuView];
    //Animate down
    CGRect subMenuFinalFrame = CGRectMake(0.0, CGRectGetMaxY(self.contentView.bounds), CGRectGetWidth(self.contentView.bounds), kSubMenuViewHeight);
    [UIView animateWithDuration:kSubMenuAnimationDuration
                     animations:^ {
                         [self.subMenuView setFrame:subMenuFinalFrame];
                         NSLog(@"Final submenu frame x:%f, y:%f, width:%f, height:%f", subMenuFinalFrame.origin.x, subMenuFinalFrame.origin.y, subMenuFinalFrame.size.width, subMenuFinalFrame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(optionsTableViewCellDidShowSubMenu:)]) {
                             [self.delegate optionsTableViewCellDidShowSubMenu:self];
                         }
                     }];
}

- (void)hideSubMenu {
    //Animate up
    CGRect subMenuFinalFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), kSubMenuViewHeight);
    [UIView animateWithDuration:kSubMenuAnimationDuration
                     animations:^ {
                         [self.subMenuView setFrame:subMenuFinalFrame];
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(optionsTableViewCellDidHideSubMenu:)]) {
                             [self.delegate optionsTableViewCellDidHideSubMenu:self];
                         }
                         [self.subMenuView removeFromSuperview];
                         [_subMenuView release];
                         _subMenuView = nil;
                     }];
}

#pragma mark -
#pragma mark EMTableCellSubMenuView

- (void)tableCellSubMenuViewButtonWasTapped:(EMTableCellSubMenuView *)subMenu {
    if ([self.delegate respondsToSelector:@selector(optionsTableViewCellSubMenuButtonsWasTapped:)]) {
        [self.delegate optionsTableViewCellSubMenuButtonsWasTapped:self];
    }
}

@end
