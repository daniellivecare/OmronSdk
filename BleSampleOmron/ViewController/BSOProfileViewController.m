//
//  BSOProfileViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOProfileViewController.h"
#import "BSODefines.h"
#import "BSOGenderSelectionViewController.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"

static NSString * const DateOfBirthCellIdentifier = @"DateOfBirthCell";
static NSString * const DatePickerCellIdentifier = @"DatePickerCell";
static NSString * const HeightCellIdentifier = @"HeightCell";
static NSString * const GenderCellIdentifier = @"GenderCell";
static NSString * const HeightUnit = @"cm";
static const NSInteger ValueViewTag = 1;

static NSNumberFormatter *_decimalStyleFormatter = nil;

@interface BSOProfileViewController () <UITextFieldDelegate, BSOGenderSelectionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *heightField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;

@property (assign, nonatomic) CGFloat datePickerCellHeight;
@property (strong, nonatomic) NSMutableArray *cellIdentifiers;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BSOUserEntity *userEntity;

@end

@implementation BSOProfileViewController

+ (void)initialize {
    if (self == [BSOProfileViewController class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _decimalStyleFormatter = [NSNumberFormatter new];
            _decimalStyleFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            _decimalStyleFormatter.maximumFractionDigits = 1;
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.userName) {
        self.userName = [[NSUserDefaults standardUserDefaults] stringForKey:BSOAppConfigCurrentUserNameKey];
    }
    
    NSFetchRequest *fetchRequest = [BSOUserEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.userName];
    self.context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    self.userEntity = [self.context executeFetchRequest:fetchRequest error:nil].firstObject;
    
    self.tableView.rowHeight = 44.0f;
    
    UITableViewCell *datePickerCell = [self.tableView dequeueReusableCellWithIdentifier:DatePickerCellIdentifier];
    self.datePickerCellHeight = CGRectGetHeight(datePickerCell.frame);
    self.cellIdentifiers = [@[DateOfBirthCellIdentifier, HeightCellIdentifier, GenderCellIdentifier] mutableCopy];
    
    self.navigationItem.leftBarButtonItem = (self.frostedViewController ? self.menuButton : nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (![self.navigationController.viewControllers.lastObject isKindOfClass:[BSOGenderSelectionViewController class]]) {
        if (self.userEntity.hasChanges) {
            [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull deviceEntity, NSUInteger idx, BOOL * _Nonnull stop) {
                if (deviceEntity.databaseChangeIncrement && !deviceEntity.databaseUpdateFlag.boolValue) {
                    deviceEntity.databaseChangeIncrement = @(deviceEntity.databaseChangeIncrement.unsignedIntValue + 1);
                    deviceEntity.databaseUpdateFlag = @YES;
                }
            }];
            NSError *error = nil;
            if (![self.context save:&error]) {
                NSLog(@"User information update failed. %@", error);
            }
        }
    }
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    // show drawer
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
}

- (IBAction)datePickerDidUpdateValue:(UIDatePicker *)datePicker {
    NSString *updatedDateOfBirth = [datePicker.date localTimeStringWithFormat:@"yyyy-MM-dd"];
    if (![self.userEntity.dateOfBirth isEqualToString:updatedDateOfBirth]) {
        self.userEntity.dateOfBirth = updatedDateOfBirth;
    }
    NSUInteger rowIndex = [self.cellIdentifiers indexOfObject:DateOfBirthCellIdentifier];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[BSOGenderSelectionViewController class]]) {
        BSOGenderSelectionViewController *genderSelectionViewController = segue.destinationViewController;
        genderSelectionViewController.gender = self.userEntity.gender;
        genderSelectionViewController.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellIdentifiers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = self.cellIdentifiers[indexPath.row];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if ([identifier isEqualToString:DateOfBirthCellIdentifier]) {
        self.dateLabel = (UILabel *)[cell viewWithTag:ValueViewTag];
        self.dateLabel.text = self.userEntity.dateOfBirth;
    }
    else if ([identifier isEqualToString:DatePickerCellIdentifier]) {
        NSDate *date = [NSDate dateWithLocalTimeString:self.userEntity.dateOfBirth format:@"yyyy-MM-dd"];
        self.datePicker = (UIDatePicker *)[cell viewWithTag:ValueViewTag];
        self.datePicker.date = date;
        self.datePicker.maximumDate = [NSDate date];
    }
    else if ([identifier isEqualToString:HeightCellIdentifier]) {
        self.heightField = (UITextField *)[cell viewWithTag:ValueViewTag];
        self.heightField.text = [NSString stringWithFormat:@"%@ cm", [_decimalStyleFormatter stringFromNumber:self.userEntity.height]];
        self.heightField.delegate = self;
    }
    else if ([identifier isEqualToString:GenderCellIdentifier]) {
        self.genderLabel = (UILabel *)[cell viewWithTag:ValueViewTag];
        self.genderLabel.text = ([self.userEntity.gender isEqualToString:OHQGenderMale] ? @"Male" : @"Female");
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ret = self.tableView.rowHeight;
    NSString *identifier = self.cellIdentifiers[indexPath.row];
    if ([identifier isEqualToString:DatePickerCellIdentifier]) {
        ret = self.datePickerCellHeight;
    }
    return ret;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = self.cellIdentifiers[indexPath.row];
    
    if (![identifier isEqualToString:GenderCellIdentifier]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    if ([self.cellIdentifiers containsObject:DatePickerCellIdentifier]) {
        if (![identifier isEqualToString:DatePickerCellIdentifier]) {
            [self bso_dismissDatePickerCell];
        }
    }
    else {
        if ([identifier isEqualToString:DateOfBirthCellIdentifier]) {
            [self bso_showDatePickerCell];
        }
    }
    
    if (![identifier isEqualToString:HeightCellIdentifier]) {
        [self.heightField resignFirstResponder];
    }
    else {
        [self.heightField becomeFirstResponder];
    }
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self bso_dismissDatePickerCell];
    
    NSScanner *scanner = [NSScanner localizedScannerWithString:textField.text];
    NSDecimal decimal = {0};
    [scanner scanDecimal:&decimal];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    textField.text = [_decimalStyleFormatter stringFromNumber:decimalNumber];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSScanner *scanner = [NSScanner localizedScannerWithString:textField.text];
    NSDecimal decimal = {0};
    [scanner scanDecimal:&decimal];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:1
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSDecimalNumber *updatedHeight = [decimalNumber decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    if (![self.userEntity.height isEqualToNumber:updatedHeight]) {
        self.userEntity.height = updatedHeight;
    }
    NSUInteger rowIndex = [self.cellIdentifiers indexOfObject:HeightCellIdentifier];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Gender selection view controller delegate

- (void)genderSelectionViewControllerDidUpdateValue:(BSOGenderSelectionViewController *)genderSelectionViewController {
    if (![self.userEntity.gender isEqualToString:genderSelectionViewController.gender]) {
        self.userEntity.gender = genderSelectionViewController.gender;
    }
    NSUInteger rowIndex = [self.cellIdentifiers indexOfObject:GenderCellIdentifier];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Private methods

- (void)bso_showDatePickerCell {
    if (![self.cellIdentifiers containsObject:DatePickerCellIdentifier]) {
        [self.tableView beginUpdates];
        NSUInteger pickerRowIndex = [self.cellIdentifiers indexOfObject:DateOfBirthCellIdentifier] + 1;
        [self.cellIdentifiers insertObject:DatePickerCellIdentifier atIndex:pickerRowIndex];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pickerRowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)bso_dismissDatePickerCell {
    if ([self.cellIdentifiers containsObject:DatePickerCellIdentifier]) {
        [self.tableView beginUpdates];
        NSUInteger pickerRowIndex = [self.cellIdentifiers indexOfObject:DatePickerCellIdentifier];
        [self.cellIdentifiers removeObject:DatePickerCellIdentifier];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pickerRowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

@end
