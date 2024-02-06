//
//  BSOHistoryCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import <UIKit/UIKit.h>

@interface BSOHistoryCell : UITableViewCell

@property (assign, nonatomic) NSInteger number;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *userName;
@property (assign, nonatomic) BSOOperation operation;
@property (assign, nonatomic) BSOProtocol protocol;
@property (strong, nonatomic) NSString *modelName;
@property (strong, nonatomic) NSString *localName;
@property (strong, nonatomic) NSString *status;

@end
