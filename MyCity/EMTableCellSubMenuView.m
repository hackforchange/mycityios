//
//  EMTableCellSubMenuView.m
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import "EMTableCellSubMenuView.h"


@implementation EMTableCellSubMenuView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect btnFrame = CGRectInset(frame, 40.0, 5.0);
        _mainBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [_mainBtn setFrame:btnFrame];
        [_mainBtn addTarget:self action:@selector(mainBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_mainBtn];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)mainBtnTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tableCellSubMenuViewButtonWasTapped:)]) {
        [self.delegate tableCellSubMenuViewButtonWasTapped:self];
    }
}

- (void)dealloc
{
    self.delegate = nil;
    [_mainBtn release];
    _mainBtn = nil;
    [super dealloc];
}

@end
