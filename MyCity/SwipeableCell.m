//
//  SwipeableCell.m
//  SwipeableExample
//
//  Created by Tom Irving on 16/06/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "SwipeableCell.h"

#define kVoteSquareSize 40.0
#define kVoteStringBoxHeight 14.0

@implementation SwipeableCell
@synthesize text;
@synthesize votes;
@synthesize btnVote = _btnVote;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.btnVote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.btnVote setTitle:@"Fix it!" forState:UIControlStateNormal];
        [self.btnVote setFrame:CGRectMake(80.0, 10.0, 320.0 - 80.0*2, 57.0 - 10*2)];
        [self.backView addSubview:self.btnVote];
    }
	
    return self;
}

- (void)setVotes:(NSNumber *)aVote {
	if (aVote != votes){
		[votes release];
		votes = [aVote retain];
		[self setNeedsDisplay];
	}
}

- (void)setText:(NSString *)aString {
	
	if (aString != text){
		[text release];
		text = [aString retain];
		[self setNeedsDisplay];
	}
}

- (void)drawContentView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor * backgroundColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]];
	UIColor * textColour = [UIColor blackColor];
    UIFont * textFont = [UIFont fontWithName:@"Futura" size:16.0];
	
	if (self.isSelected) {
		backgroundColour = [UIColor colorWithRed:0.189 green:0.495 blue:0.903 alpha:1];
		textColour = [UIColor whiteColor];
	}
	
	[backgroundColour set];
	CGContextFillRect(context, rect);
	
	[textColour set];
    
    CGFloat leftTextOffset = 60.0;
    CGFloat rightTextOffset = 20.0;
    CGFloat topOffset = 5.0;
    
    //Draw the voting square
    CGRect voteFrame = CGRectMake((leftTextOffset - kVoteSquareSize)/2, (rect.size.height - kVoteSquareSize)/2, kVoteSquareSize, kVoteSquareSize);
    UIColor *voteColor = [UIColor darkGrayColor];
    [voteColor set];
    CGContextFillRect(context, voteFrame);
    
    //Draw the voting string box
    CGRect voteStringBox = CGRectMake(voteFrame.origin.x, 
                                      CGRectGetMaxY(voteFrame) - kVoteStringBoxHeight, 
                                      voteFrame.size.width,
                                      kVoteStringBoxHeight);
    [[UIColor colorWithRed:99.0/255.0 green:168.0/255.0 blue:32.0/255.0 alpha:1.0] set];
    CGContextFillRect(context, voteStringBox);
    
    //Draw the voting number
    NSString *voteNumber = [NSString stringWithFormat:@"%d",[votes integerValue]];
    [[UIColor whiteColor] set];
    CGSize numberSize = [voteNumber sizeWithFont:textFont];
    CGPoint numberPoint = CGPointMake(CGRectGetMaxX(voteFrame) - CGRectGetWidth(voteFrame)/2 - numberSize.width/2, 
                                      CGRectGetMaxY(voteFrame) - kVoteStringBoxHeight - ((CGRectGetHeight(voteFrame)-kVoteStringBoxHeight)/2) - numberSize.height/2);
    [voteNumber drawAtPoint:numberPoint withFont:textFont];
	
	[textColour set];
	CGSize textSize = [text sizeWithFont:textFont constrainedToSize:CGSizeMake(rect.size.width - leftTextOffset - rightTextOffset, rect.size.height - topOffset*2)];
	[text drawInRect:CGRectMake(leftTextOffset, 
								topOffset + ((rect.size.height - topOffset*2 - textSize.height)/2),
								textSize.width, textSize.height)
            withFont:textFont
       lineBreakMode:UILineBreakModeCharacterWrap
           alignment:UITextAlignmentLeft];
	
	if (self.isSelected){
		[self drawShadowsWithHeight:7 opacity:0.1 InRect:rect forContext:context];
	}
}

- (void)drawBackView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIImage imageNamed:@"patternBgGray.png"] drawAsPatternInRect:rect];
	[self drawShadowsWithHeight:10 opacity:0.3 InRect:rect forContext:context];
}

- (void)drawShadowsWithHeight:(CGFloat)shadowHeight opacity:(CGFloat)opacity InRect:(CGRect)rect forContext:(CGContextRef)context {
	
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	
	CGFloat topComponents[8] = {0, 0, 0, opacity, 0, 0, 0, 0};
	CGGradientRef topGradient = CGGradientCreateWithColorComponents(space, topComponents, nil, 2);
	CGPoint finishTop = CGPointMake(rect.origin.x, rect.origin.y + shadowHeight);
	CGContextDrawLinearGradient(context, topGradient, rect.origin, finishTop, kCGGradientDrawsAfterEndLocation);
	
	CGFloat bottomComponents[8] = {0, 0, 0, 0, 0, 0, 0, opacity};
	CGGradientRef bottomGradient = CGGradientCreateWithColorComponents(space, bottomComponents, nil, 2);
	CGPoint startBottom = CGPointMake(rect.origin.x, rect.size.height - shadowHeight);
	CGPoint finishBottom = CGPointMake(rect.origin.x, rect.size.height);
	CGContextDrawLinearGradient(context, bottomGradient, startBottom, finishBottom, kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(topGradient);
	CGGradientRelease(bottomGradient);
}

- (void)dealloc {
	
	[text release];
    [votes release];
    [_btnVote release];
    [super dealloc];
}

@end
