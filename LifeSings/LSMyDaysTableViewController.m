//
//  LSMyDaysTableViewController.m
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "LSManagedObjectContextHelper.h"
#import "LSMyDaysTableViewController.h"
#import "LSMyDayTableViewCell.h"

#import "UIColor+FlatUI.h"
#import "UIBarButtonItem+FlatUI.h"

#import "LSSoundPlayerUtil.h"

#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "LSNoteSequence.h"
#import "LSNoteSequencePlayer.h"
#import "LS10NoteSequence.h"
#import "LS001NoteSequence.h"
#import "LS220000NoteSequence.h"

@interface LSMyDaysTableViewController ()
@property (nonatomic) NSMutableArray *myDaysArray;
@property (nonatomic) SoundBankPlayer *soundBankPlayer;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *playMusicButton;
@end

@implementation LSMyDaysTableViewController {
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

    // 自定义导航按钮外观
    [self.navigationItem.rightBarButtonItem configureFlatButtonWithColor:[UIColor clearColor]
                                                        highlightedColor:[UIColor clearColor]
                                                            cornerRadius:0.0f];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor emerlandColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightTextColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateSelected];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor clearColor],
            UITextAttributeFont: [UIFont boldSystemFontOfSize:15.0f]} forState:UIControlStateDisabled];

    [self.navigationItem.leftBarButtonItem configureFlatButtonWithColor:[UIColor clearColor]
                                                       highlightedColor:[UIColor clearColor]
                                                           cornerRadius:0.0f];

    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setMenuButtonColor:[UIColor lightTextColor] forState:UIControlStateSelected];
    [leftDrawerButton setMenuButtonColor:[UIColor emerlandColor] forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    // add notification listener when the app comes from background to foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib {
    // Create the player and tell it which sound bank to use.
//    _soundBankPlayer = [[SoundBankPlayer alloc] init];
//    [_soundBankPlayer setSoundBank:@"Piano"];
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
    /*
	 Fetch existing LSMyDays.
	 Create a fetch request for the Event entity; add a sort descriptor; then execute the fetch.
	 */
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"LSMyDay" inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
	[request setFetchBatchSize:duration];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date<=%@", [NSDate date]];
    
    // Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	[request setSortDescriptors:sortDescriptors];
    [request setPredicate:predicate];
    //    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"forDate",@"blackValue",@"whiteValue", nil]];
    //[request setResultType:NSDictionaryResultType];
    
	// Execute the fetch.
	NSError *error;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (fetchResults == nil) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
    
	// Set self's events array to a mutable copy of the fetch results.
	[self setMyDaysArray:[fetchResults mutableCopy]];
}

/**
 * 重载属性setter
 */
- (void)setMyDaysArray:(NSMutableArray *)mutableArray
{
    LSMyDay *today = NULL;
    if ([mutableArray count] == 0) {
        today = [self makeLSMyDayForDate:[self todayWithoutTime] withSmileValue:16];
        [mutableArray insertObject:today atIndex:0];
    } else {
        LSMyDay *firstLSMyDay = mutableArray[0];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyyMMdd"];
        NSString *firstDateStr = [dateFormat stringFromDate: firstLSMyDay.date];
        NSString *expectedDateStr = [dateFormat stringFromDate:[NSDate date]];
        if ([firstDateStr isEqual:expectedDateStr] != YES) {
            // add new today ata
            today = [self makeLSMyDayForDate:[self todayWithoutTime] withSmileValue:16];
            [mutableArray insertObject:today atIndex:0];
        }
    }

    _myDaysArray = mutableArray;
    [self.tableView reloadData]; // 重新刷新tableview
}

- (NSDate *)todayWithoutTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *todayDateWithoutTime = [calendar dateFromComponents:components];
    return todayDateWithoutTime;
}

- (LSMyDay *)makeLSMyDayForDate:(NSDate *)date withSmileValue:(NSInteger)smileValue {
    LSMyDay *today = (LSMyDay *)[NSEntityDescription insertNewObjectForEntityForName:@"LSMyDay" inManagedObjectContext:self.managedObjectContext];
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
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    LSNoteSequence *sequence = [self makeNoteSequence];
    LSNoteSequencePlayer *sequencePlayer = [[LSNoteSequencePlayer alloc] initWithNoteSequence:sequence andSpeed:sequence.speedUnit];
    sequencePlayer.delegate = self;
    [sequencePlayer play];
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
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(index) inSection:0]].contentView.backgroundColor = [UIColor silverColor];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(index  -1) inSection:0]].contentView.backgroundColor = [UIColor clearColor];
}

- (void)willStarPlayAtIndex:(NSInteger)index {
    // TODO:是否应该停用菜单
}

- (void)didStopPlayAtIndex:(NSInteger)index {
    [self.playMusicButton setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(index  -1) inSection:0]].contentView.backgroundColor = [UIColor clearColor];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

    // 返回第一行
    //

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSUInteger fetchedCnt = [self.myDaysArray count];
    // FIXME: default show today, but if there is not today, should plus 1
    return fetchedCnt > 0 ? fetchedCnt : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.tableView.frame.size.height) / 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LSMyDayCell";
    LSMyDayTableViewCell *cell = (LSMyDayTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		cell = [[LSMyDayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    cell.delegate = self;

    // Get the black/white day corresponding to the current index path and configure the table view cell.
    LSMyDay *aDay = (LSMyDay *)self.myDaysArray[indexPath.row];
    //NSLog(@"--->%d", LSMyDay.blackValue);
    [cell configureWithMyDay: aDay];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

@end
