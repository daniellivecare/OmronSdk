//
//  BSOSettingsViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSettingsViewController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"

typedef NS_ENUM(NSUInteger, TableItemRowType) {
    TableItemRowTypeVersion,
    TableItemRowTypeAcknowledgements,
};

@interface BSOSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation BSOSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
}

@end
