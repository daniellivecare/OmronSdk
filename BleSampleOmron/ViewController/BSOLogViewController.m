//
//  BSOLogViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOLogViewController.h"
#import "BSODefines.h"
#import "NSDate+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "OHQReferenceCode.h"
#import "BSOLogZipUtils.h"

@interface BSOLogViewController () <UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cleanButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (strong, nonatomic) dispatch_source_t reloadTimer;
@property (copy, nonatomic) NSArray<NSString *> *logSnapShot;
@property (strong, nonatomic) BSOLogZipUtils *zipUtils;

@end

@implementation BSOLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 34;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.actionButton.enabled = NO;
    self.zipUtils = [[BSOLogZipUtils alloc] init];
    
    self.reloadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.reloadTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.reloadTimer, ^{
        self.logSnapShot = [[OHQLogStore sharedStore] logRecordsWithLevel:OHQLogLevelVerbose];
        BOOL logAvailable = self.logSnapShot.count > 0;
        self.actionButton.enabled = logAvailable;
        [self.tableView reloadData];
    });
    
    // remove temporary log files
    [self.zipUtils bso_removeLogFilesInDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self bso_startPeriodicUpdateForTable];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self bso_pausePeriodicUpdateForTable];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
    else if ([barButtonItem isEqual:self.actionButton]) {
        // show action
        NSString * _Nullable parameterFileName = nil;
        BOOL isHistory = NO;
        NSURL *resultZipURL = [self.zipUtils createZipFile:isHistory fileName:parameterFileName];
        
        if (resultZipURL) {
            // show interaction controller
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:resultZipURL];
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOptionsMenuFromBarButtonItem:barButtonItem animated:YES];
        }
    }
    else if ([barButtonItem isEqual:self.cleanButton]) {
        // remove log
        [[OHQLogStore sharedStore] removeAllLogRecords];
        [self.zipUtils bso_removeLogFilesInDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logSnapShot.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.logSnapShot[indexPath.row];
    return cell;
}

#pragma mark - Private methods

- (void)bso_startPeriodicUpdateForTable {
    dispatch_resume(self.reloadTimer);
}

- (void)bso_pausePeriodicUpdateForTable {
    dispatch_suspend(self.reloadTimer);
}

- (void)bso_saveArray:(NSArray *)array toURL:(NSURL *)URL usingTimeStamp:(NSDate *)timeStamp completion:(dispatch_block_t)completion {
    __block NSMutableString *text = [BSOLogHeaderString(timeStamp) mutableCopy];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [text appendString:[NSString stringWithFormat:@"%@\r\n", obj]];
    }];
    NSError *error;
    if (![text writeToURL:URL atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        abort();
    }
    if (completion) {
        completion();
    }
}

@end
