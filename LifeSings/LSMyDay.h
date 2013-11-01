//
//  BWDay.h
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LSMyDay : NSManagedObject
@property (nonatomic) NSDate *date;
@property (nonatomic) NSDate *lastModifiedDate;
@property (nonatomic) NSInteger smileValue;
@property (nonatomic) NSString *voiceMemoName;
@property (nonatomic) float voiceMemoDuration;
@end
