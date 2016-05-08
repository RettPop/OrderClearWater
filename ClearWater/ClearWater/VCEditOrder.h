//
//  VCEditOrder.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"
#import "VCBase.h"

@interface VCEditOrder : VCBase<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITabBarDelegate>

-(void)displayOrder:(OrderModel *)order;

@end
