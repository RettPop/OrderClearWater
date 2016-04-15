//
//  VCEditOrder.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"

@interface VCEditOrder : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

-(void)displayOrder:(OrderModel *)order;

@end
