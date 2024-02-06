//
//  BSODrawerMenuViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODrawerMenuViewController.h"
#import "BSODefines.h"
#import "BSOUserHomeViewController.h"
#import "BSOGuestUserHomeViewController.h"
#import "BSOProfileViewController.h"
#import "BSOHistoryViewController.h"
#import "BSOSettingsViewController.h"
#import "BSOLogViewController.h"
#import "BSODiscoveredDeviceSelectionViewController.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "UIColor+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "OHQReferenceCode.h"

@interface BSODrawerMenuViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *homeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *historyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *settingsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logCell;

@property (strong, nonatomic) NSString *currentUserName;

@end

@implementation BSODrawerMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UINavigationController *rootNavigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    UIViewController *rootViewController = rootNavigationController.viewControllers.firstObject;
    UITableViewCell *activeCell = nil;
    if ([rootViewController isKindOfClass:[BSOUserHomeViewController class]] ||
        [rootViewController isKindOfClass:[BSOGuestUserHomeViewController class]]) {
        activeCell = self.homeCell;
    }
    else if ([rootViewController isKindOfClass:[BSOProfileViewController class]]) {
        activeCell = self.profileCell;
    }
    else if ([rootViewController isKindOfClass:[BSOHistoryViewController class]]) {
        activeCell = self.historyCell;
    }
    else if ([rootViewController isKindOfClass:[BSOSettingsViewController class]]) {
        activeCell = self.settingsCell;
    }
    else if ([rootViewController isKindOfClass:[BSOLogViewController class]]) {
        activeCell = self.logCell;
    }
    for (UITableViewCell *cell in @[self.homeCell, self.profileCell, self.historyCell, self.settingsCell, self.logCell]) {
        cell.textLabel.textColor = ([cell isEqual:activeCell] ? [UIColor appBaseColor] : nil);
    }
    
    // get current user name
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.currentUserName = [userDefaults stringForKey:BSOAppConfigCurrentUserNameKey];
    
    self.userNameLabel.text = self.currentUserName;
    if ([self.currentUserName isEqualToString:BSOGuestUserName]) {
        // guest user
        self.userImageView.image = [UIImage imageNamed:@"img_anonymous"];
        self.profileCell.userInteractionEnabled = NO;
        self.profileCell.textLabel.enabled = NO;
    }
    else {
        // registered user
        NSFetchRequest *fetchRequest = [BSOUserEntity fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.currentUserName];
        BSOPersistentContainer *container = [BSOPersistentContainer sharedPersistentContainer];
        BSOUserEntity *currentUserEntity = [container.viewContext executeFetchRequest:fetchRequest error:nil].firstObject;
        if (currentUserEntity) {
            self.userImageView.image = ([currentUserEntity.gender isEqualToString:OHQGenderMale] ?
                                        [UIImage imageNamed:@"img_male"] : [UIImage imageNamed:@"img_female"]);
            self.profileCell.userInteractionEnabled = YES;
            self.profileCell.textLabel.enabled = YES;
        }
        else {
            abort();
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destViewController = nil;
    
    if ([selectedCell isEqual:self.homeCell]) {
        if ([self.currentUserName isEqualToString:BSOGuestUserName]) {
            destViewController = [storyboard instantiateViewControllerWithIdentifier:@"GuestUserHomeViewController"];
        }
        else {
            destViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserHomeViewController"];
        }
    }
    else if ([selectedCell isEqual:self.profileCell]) {
        destViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    }
    else if ([selectedCell isEqual:self.historyCell]) {
        destViewController = [storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    }
    else if ([selectedCell isEqual:self.settingsCell]) {
        destViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    }
    else if ([selectedCell isEqual:self.logCell]) {
        destViewController = [storyboard instantiateViewControllerWithIdentifier:@"LogViewController"];
    }
    
    [self.frostedViewController hideMenuViewController];
    if (destViewController) {
        UINavigationController * rootNavigationController = (UINavigationController *)self.frostedViewController.contentViewController;
        rootNavigationController.viewControllers = @[destViewController];
    }
}

@end
