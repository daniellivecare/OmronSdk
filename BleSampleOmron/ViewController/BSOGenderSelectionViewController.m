//
//  BSOGenderSelectionViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOGenderSelectionViewController.h"

@interface BSOGenderSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *maleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *femaleCell;

@end

@implementation BSOGenderSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bso_updateCheckMark];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.gender = OHQGenderMale;
    }
    else {
        self.gender = OHQGenderFemale;
    }

    [self bso_updateCheckMark];
    if ([self.delegate respondsToSelector:@selector(genderSelectionViewControllerDidUpdateValue:)]) {
        [self.delegate genderSelectionViewControllerDidUpdateValue:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - Private methods

- (void)bso_updateCheckMark {
    if ([self.gender isEqualToString:OHQGenderMale]) {
        self.maleCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.femaleCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        self.maleCell.accessoryType = UITableViewCellAccessoryNone;
        self.femaleCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
