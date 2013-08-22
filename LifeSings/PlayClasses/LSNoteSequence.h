//
// Created by lichong on 13-7-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@interface LSNoteSequence : NSObject
@property (nonatomic) NSArray *notes;
@property (nonatomic) NSUInteger rhythmPointer;
@property (nonatomic) CGFloat speedUnit; // 代表秒

- (id)initWithNotesArray:(NSArray *)notesArr;
- (NSInteger)nextNote;
- (BOOL)hasNextNote;
@end