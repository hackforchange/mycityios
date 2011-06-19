//
//  MCIssue.h
//  MyCity
//
//  Created by Emerson Malca on 6/18/11.
//  Copyright 2011 OneZeroWare. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MCIssue : NSObject {
    
}

@property (nonatomic, retain) NSNumber *server_id;
@property (nonatomic, retain) NSNumber *votes_count;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSDate *created_at;
@property (nonatomic, retain) NSDate *updated_at;

@end
