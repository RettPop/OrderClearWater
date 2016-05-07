//
//  OrdersList.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-15.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBase.h"
#import "WebKit/WKNavigationDelegate.h"


@interface OrdersList : VCBase<UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, WKNavigationDelegate>

@end
