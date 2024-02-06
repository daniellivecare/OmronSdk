//
//  BSOUserSelectionViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOUserSelectionViewController.h"
#import "OHQReferenceCode.h"
#import "BSODefines.h"
#import "BSOAppDelegate.h"
#import "BSOUserCell.h"
#import "BSOProfileViewController.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "REFrostedViewController.h"

typedef NS_ENUM(NSUInteger, Section) {
    SectionUsers = 0,
    SectionGuest,
    NumberOfSections,
};

@interface BSOUserSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@property (strong, nonatomic) NSArray<BSOUserEntity *> *userEntities;

@end

@implementation BSOUserSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSFetchRequest *fetchRequest = [BSOUserEntity fetchRequest];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    BSOPersistentContainer *container = [BSOPersistentContainer sharedPersistentContainer];
    self.userEntities = [container.viewContext executeFetchRequest:fetchRequest error:nil];
    
    [self.tableView reloadData];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.leftBarButtonItem]) {
        // close view
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSString *userName = BSOGuestUserName;
        if (indexPath.section == 0) {
            BSOUserEntity *userEntity = self.userEntities[indexPath.row];
            userName = userEntity.name;
        }
        
        if ([segue.destinationViewController isKindOfClass:[BSOProfileViewController class]]) {
            BSOProfileViewController *profileViewController = segue.destinationViewController;
            profileViewController.userName = userName;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == SectionUsers ? self.userEntities.count : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSOUserCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    switch (indexPath.section) {
        case SectionUsers: {
            BSOUserEntity *userEntity = self.userEntities[indexPath.row];
            cell.userNameLabel.text = userEntity.name;
            cell.userImageView.image = ([userEntity.gender isEqualToString:OHQGenderMale] ?
                                        [UIImage imageNamed:@"img_male"] : [UIImage imageNamed:@"img_female"]);
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
            break;
        }
        case SectionGuest: {
            cell.userNameLabel.text = BSOGuestUserName;
            cell.userImageView.image = [UIImage imageNamed:@"img_anonymous"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BSOUserCell rowHeight];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destViewController = nil;
    
    switch (indexPath.section) {
        case SectionUsers: {
            BSOUserEntity *userEntity = self.userEntities[indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:userEntity.name forKey:BSOAppConfigCurrentUserNameKey];
            destViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserHomeViewController"];
            break;
        }
        case SectionGuest: {
            [[NSUserDefaults standardUserDefaults] setObject:BSOGuestUserName forKey:BSOAppConfigCurrentUserNameKey];
            destViewController = [storyboard instantiateViewControllerWithIdentifier:@"GuestUserHomeViewController"];
            break;
        }
        default:
            break;
    }
    
    if (destViewController) {
        BSOAppDelegate *appDelegate = (BSOAppDelegate *)[UIApplication sharedApplication].delegate;
        UINavigationController *rootNavigationController = (UINavigationController *)appDelegate.frostedViewController.contentViewController;
        rootNavigationController.viewControllers = @[destViewController];
    }
    
    // close view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
