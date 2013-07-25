//
// Created by lichong on 13-7-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LS10NoteSequence.h"


@implementation LS10NoteSequence {
    NSUInteger _skipper;
}

- (id)initWithNotesArray:(NSArray *)notesArr  {
    self = [super initWithNotesArray:notesArr];
    _skipper = 1;
    return self;
}

- (NSInteger)nextNote {
    int _curr_skipper = _skipper;
    _skipper++;
    if (_curr_skipper % 3 == 2) {
        NSLog(@"Skip %d", _curr_skipper);
        return -1;
    } else {
        NSLog(@"%d", _curr_skipper);
        return [super nextNote];
    }
}

@end