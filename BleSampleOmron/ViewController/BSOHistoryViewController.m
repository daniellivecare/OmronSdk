//
//  BSOHistoryViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOHistoryViewController.h"
#import "BSOHistoryCell.h"
#import "BSOPersistentContainer.h"
#import "BSOSessionResultNavigationController.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "BSOLogZipUtils.h"

@interface BSOHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (copy, nonatomic) NSArray<BSOHistoryEntity *> *historyEntities;
@property (strong, nonatomic) BSOLogZipUtils *zipUtils;

@end

@implementation BSOHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [BSOHistoryEntity fetchRequest];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"completionDate" ascending:NO]];
    self.context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    self.historyEntities = [self.context executeFetchRequest:fetchRequest error:nil];
    self.zipUtils = [[BSOLogZipUtils alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
    else if ([barButtonItem isEqual:self.trashButton]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete All History" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.historyEntities enumerateObjectsUsingBlock:^(BSOHistoryEntity * _Nonnull historyEntity, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.context deleteObject:historyEntity];
            }];
            [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
            self.historyEntities = nil;
            [self.tableView reloadData];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:deleteAction];
        [alertController addAction:cancelAction];
        alertController.popoverPresentationController.barButtonItem = self.trashButton;
        
        [self presentViewController:alertController animated:YES completion:nil];
        [self.zipUtils bso_removeLogFilesInDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyEntities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSOHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    BSOHistoryEntity *historyEntity = self.historyEntities[indexPath.row];
    cell.number = self.historyEntities.count - indexPath.row;
    cell.date = historyEntity.completionDate;
    cell.userName = historyEntity.userName;
    cell.operation = historyEntity.operation;
    cell.protocol = historyEntity.protocol;
    cell.modelName = historyEntity.modelName;
    cell.localName = historyEntity.localName;
    cell.status = historyEntity.status;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BSOHistoryEntity *historyEntity = self.historyEntities[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BSOSessionResultNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SessionResultNavigationController"];
    vc.historyIdentifier = historyEntity.identifier;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
