//
//  LSMyDaysTableViewController.m
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//
#include "Log-Prefix.pch"
#import <QuartzCore/QuartzCore.h>

#import "LSManagedObjectContextHelper.h"
#import "LSMyDaysTableViewController.h"
#import "LSMyDayTableViewCell.h"

#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"

#import "LSSoundPlayerUtil.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "LS10NoteSequence.h"
#import "LS001NoteSequence.h"
#import "LS220000NoteSequence.h"
#import "LSDateHelper.h"

#import "TSMessage.h"
#import "POVoiceHUD.h"
#import "SoundManager.h"

@interface LSMyDaysTableViewController () <POVoiceHUDDelegate, VoiceMemoDelegate>
@property (nonatomic) NSMutableArray *myDaysArray;
@property (nonatomic) SoundBankPlayer *soundBankPlayer;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *playMusicButton;
@end

@implementation LSMyDaysTableViewController {
    LSNoteSequencePlayer *_sequencePlayer;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UIView *_playingOverlayView;
    NSIndexPath *_changedCellIndexPath; // 记录当前处于滑块菜单状态的cell位置
    
    POVoiceHUD *_voiceHud;
    NSIndexPath *_recordingCellIndexPath; //正在录音的cell位置

    NSInteger _visibleYear;
}

// 时光曲初始音阶序列
const int notes[8] = {48,50,52,53,55,57,59,60};

#pragma mark lifecycle interface
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor cloudsColor]];
    self.tableView.rowHeight = [self rowHeight];
    self.navigationController.navigationBar.clipsToBounds = NO;

    // 自定义导航按钮外观
    self.navigationItem.title = NSLocalizedString(@"AppTitle", nil);
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Listen", nil);
    [self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:[UIColor clearColor]
                                                        highlightedColor:[UIColor clearColor]
                                                            cornerRadius:0.0f];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor emerlandColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightTextColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateHighlighted];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor blackColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateDisabled];

    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor clearColor]
                                                       highlightedColor:[UIColor clearColor]
                                                           cornerRadius:0.0f];

    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setMenuButtonColor:[UIColor lightTextColor] forState:UIControlStateSelected];
    [leftDrawerButton setMenuButtonColor:[UIColor emerlandColor] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    // 初始化voicehud view
    _voiceHud = [[POVoiceHUD alloc] initWithParentView:self.tableView];
    _voiceHud.title = @"";
    [_voiceHud setDelegate:self];
    [self.tableView addSubview:_voiceHud];

    // add notification listener when the app comes from background to foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDate *now = [NSDate new];
    _visibleYear = [LSDateHelper yearOfDate:now];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _soundBankPlayer = nil;
}

- (void)awakeFromNib {
    // Create the player and tell it which sound bank to use.
    _soundBankPlayer = [[SoundBankPlayer alloc] init];
    [_soundBankPlayer setSoundBank:@"Piano"];
    _managedObjectContext = [LSManagedObjectContextHelper getDefaultMOC];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observer handler
- (void)becomeActive:(NSNotification *)notification {
    // TODO: 从用户配置里读取时间跨度
    [self loadLSMyDaysWithDuration:365]; // 一年？
}
#pragma mark - Data logic
/**
 * 获取指定天数跨度的日子
 */
- (void)loadLSMyDaysWithDuration:(NSUInteger)duration
{
    //dispatch_async(dispatch_get_main_queue(), ^{
    
        // Execute the fetch.
        NSError *error;
        
        [self.fetchedResultsController.fetchRequest setFetchBatchSize:duration];
        if (self.fetchedResultsController)
        {
            if (![[self fetchedResultsController] performFetch:&error])
            {
                DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    
        // Set self's events array to a mutable copy of the fetch results.
        [self setMyDaysArray:[self.fetchedResultsController.fetchedObjects mutableCopy]];
    //});
}

/**
 * 重载属性setter
 */
- (void)setMyDaysArray:(NSMutableArray *)mutableArray
{
    NSDate *today = [NSDate new];
    if ([mutableArray count] == 0) {
        // 补充今天、昨天、前天数据
        [mutableArray insertObject:[self makeLSMyDayForDate:
        [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-2 fromDate:today]] withSmileValue:16] atIndex:0];
        [mutableArray insertObject:[self makeLSMyDayForDate:
                [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-1 fromDate:today]] withSmileValue:16] atIndex:0];
        [mutableArray insertObject:[self makeLSMyDayForDate:[LSDateHelper dateWithoutTime:today] withSmileValue:16] atIndex:0];
    } else {
        LSMyDay *firstLSMyDay = mutableArray[0];
        NSInteger firstDiff = [LSDateHelper daysDiffBetweenDate:firstLSMyDay.date andDate:today];
        if (firstDiff > 2) {
            // 第一项是前天之前的
            // 补充今天，昨天，前天数据
            [mutableArray insertObject:[self makeLSMyDayForDate:
                    [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-2 fromDate:today]] withSmileValue:16] atIndex:0];
            [mutableArray insertObject:[self makeLSMyDayForDate:
                    [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-1 fromDate:today]] withSmileValue:16] atIndex:0];
            [mutableArray insertObject:[self makeLSMyDayForDate:[LSDateHelper dateWithoutTime:today] withSmileValue:16] atIndex:0];
        } else if (firstDiff == 2) {
            // 第一项是前天
            // 补充昨天，今天数据
            [mutableArray insertObject:[self makeLSMyDayForDate:
                    [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-1 fromDate:today]] withSmileValue:16] atIndex:0];
            [mutableArray insertObject:[self makeLSMyDayForDate:
                    [LSDateHelper dateWithoutTime:today] withSmileValue:16] atIndex:0];
        } else if (firstDiff == 1) {
            // 第一项是昨天
            // 尝试检测第二项是否为前天数据
            LSMyDay *secondLSMyDay = mutableArray[1];
            if ([LSDateHelper daysDiffBetweenDate:secondLSMyDay.date andDate:today] > 2) {
                // 补充前天数据
                [mutableArray insertObject:[self makeLSMyDayForDate:
                        [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-2 fromDate:today]] withSmileValue:16] atIndex:1];
            }
            [mutableArray insertObject:[self makeLSMyDayForDate:[LSDateHelper dateWithoutTime:today] withSmileValue:16] atIndex:0];
        } else {
            // 第一项是今天
            // 尝试检测第二项是否为昨天数据
            LSMyDay *secondLSMyDay = mutableArray[1];
            NSInteger secondDiff = [LSDateHelper daysDiffBetweenDate:secondLSMyDay.date andDate:today];
            if (secondDiff > 1) {
                // 缺少昨天
                // 补充昨天数据
                [mutableArray insertObject:[self makeLSMyDayForDate:
                        [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-1 fromDate:today]] withSmileValue:16] atIndex:1];
                if (secondDiff > 2) {
                    // 缺少前天
                    // 补充前天数据
                    [mutableArray insertObject:[self makeLSMyDayForDate:
                            [LSDateHelper dateWithoutTime:[LSDateHelper rollDays:-2 fromDate:today]] withSmileValue:16] atIndex:2];
                }
            }
        }
    }

    _myDaysArray = mutableArray;
    [self.tableView reloadData]; // 重新刷新tableview
}

- (LSMyDay *)makeLSMyDayForDate:(NSDate *)date withSmileValue:(NSInteger)smileValue {
    LSMyDay *today = (LSMyDay *)[NSEntityDescription insertNewObjectForEntityForName:@"LSMyDay"
                                                              inManagedObjectContext:self.managedObjectContext];
    today.smileValue = smileValue;
    today.date = date;
    return today;
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)playDays:(id)sender {
    [sender setEnabled:NO];
    
    // 恢复cell滑块
    if (_changedCellIndexPath) {
        [((SWTableViewCell *)[self.tableView cellForRowAtIndexPath:_changedCellIndexPath]) hideUtilityButtonsAnimated:YES];
    }
    
    if (!_playingOverlayView) {
        _playingOverlayView = [[UIView alloc]init];
    }
    _playingOverlayView.frame = CGRectMake(self.tableView.bounds.origin.x, self.tableView.bounds.origin.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height * [_myDaysArray count] / 7);
    _playingOverlayView.backgroundColor = [UIColor clearColor];
    [self.tableView addSubview:_playingOverlayView];
    self.tableView.scrollEnabled = NO;
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    LSNoteSequence *sequence = [self makeNoteSequence];
    _sequencePlayer = [[LSNoteSequencePlayer alloc] initWithNoteSequence:sequence andSpeed:sequence.speedUnit];
    _sequencePlayer.delegate = self;
    DDLogInfo(@"Play");
    [_sequencePlayer play];
}

- (void)installStopPlayListener {
    if (_tapGestureRecognizer == nil)
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStopPlay:)];
    [self.tableView addGestureRecognizer:_tapGestureRecognizer];
}

- (void)uninstallStopPlayListener {
    [self.tableView removeGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizer = nil;
}

- (void)tapToStopPlay:(UITapGestureRecognizer *)sender {
    [_sequencePlayer stop];
}

/**
* 构造要进行播放的时光音序
*/
- (LSNoteSequence *)makeNoteSequence {
    NSMutableArray *noteArray = [[NSMutableArray alloc] initWithCapacity:[self.myDaysArray count] ];
    for (id o in self.myDaysArray) {
        LSMyDay *toPlayLSMyDay = (LSMyDay *)o;
        int notePos = toPlayLSMyDay.smileValue % 8;
        int noteGrade = toPlayLSMyDay.smileValue / 8;
        int note = noteGrade * 12 + notes[notePos];
        [noteArray addObject:[NSNumber numberWithInt:note]];
    }
    // TODO:根据配置节奏选择构造哪种音序
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger typeNum = [userDefaults integerForKey:@"rynthm_type"];
    LSNoteSequence *sequence = nil;
    switch (typeNum) {
        case 2: {
            sequence = [[LS10NoteSequence alloc] initWithNotesArray:noteArray];
            break;
        }
        case 3: {
            sequence = [[LS001NoteSequence alloc] initWithNotesArray:noteArray];
            break;
        }
        case 4: {
            sequence = [[LS220000NoteSequence alloc] initWithNotesArray:noteArray];
            break;
        }
        default:
            sequence = [[LSNoteSequence alloc] initWithNotesArray:noteArray];
            break;
    }

    return sequence;
}

# pragma mark - 音符序列播放器回调协议
- (void)willPlayNoteAtIndex:(NSInteger)index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self.tableView cellForRowAtIndexPath:
            [NSIndexPath indexPathForRow:(index) inSection:0]].contentView.backgroundColor = [UIColor silverColor];
    [self.tableView cellForRowAtIndexPath:
            [NSIndexPath indexPathForRow:(index  -1) inSection:0]].contentView.backgroundColor = [UIColor cloudsColor];
}

- (void)willStarPlayAtIndex:(NSInteger)index {
    [self installStopPlayListener];
}

- (void)didStopPlayAtIndex:(NSInteger)index {
    [self uninstallStopPlayListener];
    _sequencePlayer = nil; // release
    [self.playMusicButton setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(index  -1) inSection:0]].contentView.backgroundColor = [UIColor cloudsColor];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_playingOverlayView removeFromSuperview];
    _playingOverlayView = nil; //GC
    self.tableView.scrollEnabled = YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.myDaysArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: 非nib的cell高度如何根据cell数量来动态调整？
    return [self rowHeight];
}

- (CGFloat)rowHeight
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            return 83.66f;
        } else {
            return 69.0f;
        }
    }
    return (self.tableView.bounds.size.height - 2) / 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LSMyDayCell";
    LSMyDayTableViewCell *cell = (LSMyDayTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Get the black/white day corresponding to the current index path and configure the table view cell.
    LSMyDay *aDay = (LSMyDay *)self.myDaysArray[indexPath.row];
    if (cell == nil)
	{
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
		cell = [[LSMyDayTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:CellIdentifier
                                       containingTableView:self.tableView // Used for row height and selection
                                        leftUtilityButtons:leftUtilityButtons
                                       rightUtilityButtons:rightUtilityButtons];
	} else {
        [cell resetRightUtilityButtons];
    }

    cell.delegate = self;
    DDLogVerbose(@"--->%d", aDay.smileValue);
    [cell configureWithMyDay: aDay];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //Then you change the properties (label, text, color etc..) in your case, the background color
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    /*
	 Fetch existing LSMyDays.
	 Create a fetch request for the Event entity; add a sort descriptor; then execute the fetch.
	 */
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"LSMyDay" inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
	//[request setFetchBatchSize:duration];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date<=%@", [NSDate date]];
    
    // Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    //    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"forDate",@"blackValue",@"whiteValue", nil]];
    //[request setResultType:NSDictionaryResultType];
    
    // Edit the section name key path and cache name if appropriate,
    // nil for section name key path means "no sections"
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    //aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}
    
#pragma mark - scrollview事件代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
    {
        NSArray* cells = self.tableView.visibleCells;
        NSDate *firstVisibleCellDayDate = ((LSMyDayTableViewCell *)[cells firstObject]).myDay.date;
        if (firstVisibleCellDayDate != nil) {
            NSInteger visibleDaysYear = [LSDateHelper yearOfDate:firstVisibleCellDayDate];
            if (visibleDaysYear != _visibleYear) {
                _visibleYear = visibleDaysYear;
                [TSMessage showNotificationInViewController:self
                                                      title:[NSString stringWithFormat: NSLocalizedString(@"VisibleYear", nil),_visibleYear]
                                                   subtitle:nil
                                                       type:TSMessageNotificationTypeMessage
                                                   duration:3.0f
                                                   callback:nil
                                                buttonTitle:nil
                                             buttonCallback:nil
                                                 atPosition:TSMessageNotificationPositionTop
                                        canBeDismisedByUser:YES];
            }
        }
    }

#pragma mark - cell内滑块值变化协议处理
- (void)onSliderValueChanged:(int)newVal
{
    int notePos = newVal % 8;
    int noteGrade = newVal / 8;
    int note = noteGrade * 12 + notes[notePos];
    [_soundBankPlayer noteOn:note gain:.6f];
}

#pragma mark - cell左侧滑出按钮事件
-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    if (index == 0) {

    }
}
    
-(void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
//    switch (index) {
//        case 0: {
//            LSMyDay *toRecordDay = ((LSMyDayTableViewCell *)cell).myDay;
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat: @"yyyyMMdd"];
//            NSString *voiceMemoFileName = [NSString stringWithFormat:@"%@.caf", [formatter stringFromDate:toRecordDay.date]];
//            // 弹出录音提示
//            [_voiceHud startForFilePath:[NSString stringWithFormat:@"%@/Documents/%@",
//                            NSHomeDirectory(), voiceMemoFileName]];
//
//            _recordingCellIndexPath = [self.tableView indexPathForCell:cell];
//            break;
//        }
//        case 1: {
//            LSMyDay *toRecordDay = ((LSMyDayTableViewCell *)cell).myDay;
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat: @"yyyyMMdd"];
//            NSString *voiceMemoFileName = [NSString stringWithFormat:@"%@.caf", [formatter stringFromDate:toRecordDay.date]];
//            // 弹出录音提示
//            NSString *voiceMemoPath = [NSString stringWithFormat:@"%@/Documents/%@",
//                                                                 NSHomeDirectory(), voiceMemoFileName];
//
//            // 播放语音
//            if (![SoundManager sharedManager].isPlayingMusic)
//                [[SoundManager sharedManager] playMusic:voiceMemoPath looping:NO];
//            break;
//        }
//        default:
//            break;
//    }
}

- (void)swippableTableViewCell:(SWTableViewCell *)cell didUtilityButtonVisiblilityChanged:(BOOL)visible
{
    NSIndexPath *indexPathOfThisCell = [self.tableView indexPathForCell:cell];
    if (_changedCellIndexPath && indexPathOfThisCell.row != _changedCellIndexPath.row) {
        [((SWTableViewCell *)[self.tableView cellForRowAtIndexPath:_changedCellIndexPath]) hideUtilityButtonsAnimated:YES];
    }
    if ([SoundManager sharedManager].isPlayingMusic)
        [[SoundManager sharedManager] stopMusic:NO];
    if (visible == YES)
        _changedCellIndexPath = [self.tableView indexPathForCell:cell];
    else
        _changedCellIndexPath = nil;
}
    
#pragma mark - 录音hud代理
- (void)POVoiceHUD:(POVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    NSLog(@"Sound recorded with file %@ for %.2f seconds", [recordPath lastPathComponent], recordLength);
    LSMyDayTableViewCell *recordingCell = (LSMyDayTableViewCell *)[self.tableView cellForRowAtIndexPath:_recordingCellIndexPath];
    LSMyDay *toRecordDay = recordingCell.myDay;
    toRecordDay.voiceMemoName = [recordPath lastPathComponent];
    toRecordDay.voiceMemoDuration = recordLength;
    // 保存数据
    NSError *error;
    if (![[LSManagedObjectContextHelper getDefaultMOC] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    // 预先准备声音
    [[SoundManager sharedManager] prepareToPlayWithSound:recordPath];
    [self.tableView reloadData];
}
    
- (void)voiceRecordCancelledByUser:(POVoiceHUD *)voiceHUD {
    DDLogVerbose(@"Voice recording cancelled for HUD: %@", voiceHUD);
}

#pragma mark -
- (void)recordVoiceMemoForCell:(LSMyDayTableViewCell *)cell {

#ifndef __IPHONE_7_0
    typedef void (^PermissionBlock)(BOOL granted);
#endif

    PermissionBlock permissionBlock = ^(BOOL granted) {
        if (granted)
        {
            // 弹出录音提示
            [_voiceHud startForFilePath:[cell voiceMemoFilePath]];
            _recordingCellIndexPath = [self.tableView indexPathForCell:cell];
        }
        else
        {
            // Warn no access to microphone
            UIAlertView *cantRecordAlert =
                    [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"NoMicWarningTitle", nil)
                                               message: NSLocalizedString(@"NoMicWarningMsg", nil)
                                              delegate: nil
                                     cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                     otherButtonTitles: nil];
            [cantRecordAlert show];
        }
    };

    // iOS7+
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                              withObject:permissionBlock];
    }
    else
    {
        // 弹出录音提示
        [_voiceHud startForFilePath:[cell voiceMemoFilePath]];
        _recordingCellIndexPath = [self.tableView indexPathForCell:cell];
    }

}


@end
