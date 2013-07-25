//
// Created by lichong on 13-7-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LSNoteSequence.h"


@implementation LSNoteSequence {
}
- (id)initWithNotesArray:(NSArray *)notesArr  {
    if (self = [super init]) {
        self.notes = [[NSArray alloc]initWithArray:notesArr];
        _rhythmPointer = 0; // start point
        _speedUnit = .5f;
    }
    return self;
}

/**
* 默认实现:返回音符数组下一个音符
* @return note/-1:没有下一个音符/-2:延续当前音符/-3:休止符/
* 子类可以覆盖本函数
*/
- (NSInteger)nextNote {
    NSNumber *note = self.notes[_rhythmPointer];
    _rhythmPointer++;
    return note.intValue;
}

- (BOOL)hasNextNote {
    return _rhythmPointer < [_notes count];
}

@end