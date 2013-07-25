//
// Created by lichong on 13-7-24.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LS220000NoteSequence.h"


@implementation LS220000NoteSequence {
    NSUInteger _skipper;
}

- (id)initWithNotesArray:(NSArray *)notesArr  {
    self = [super initWithNotesArray:notesArr];
    _skipper = 1;
    self.speedUnit = .2f;
    return self;
}

- (NSInteger)nextNote {
    int _curr_skipper = _skipper;
    _skipper++;
    if (_skipper > 12) _skipper = 1; // loop
    if (_curr_skipper % 4 == 1) {
        NSLog(@"%d", _curr_skipper);
        return [super nextNote];
    } else if (_curr_skipper > 9 && _curr_skipper <= 12) {
        NSLog(@"%d", _curr_skipper);
        return [super nextNote];
    } else {
        NSLog(@"Skip %d", _curr_skipper);
        return -1;
    }
}
@end