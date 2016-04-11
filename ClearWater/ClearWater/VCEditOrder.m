//
//  VCEditOrder.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "VCEditOrder.h"
#import "UIKit/UITableView.h"
#import "UIView+SSUIViewCategory.h"
#import "OrderModel.h"
#import "ServerHandler.h"
#import "CWSchedule.h"

#define kTableGeneralCellID @"kTableGeneralCellID"
#define CompCellID(x,y) [NSString stringWithFormat:@"SECTION %li ITEM %li", (long)x, (long)y]
#define kDefaultCellHeight 60.f
#define kUserDefsKeyLastOrder @"LastOrder"
#define kDatePickerHeight 150.f
#define kDeliveryTimePickerHeight kDatePickerHeight
#define NOT(__x__) !(__x__)
#define kDateFormat @"dd/MM/yyyy"

// Table items enums
typedef enum : NSUInteger {
    SECTION_CLIENT,
    SECTION_ADDRESS,
    SECTION_SCHEDULE,
    SECTION_CONTENT,
    SECTION_CONFIRM,
    SECTION_COMMENTS,
    SECTION_COUNTER
} Sections;

typedef enum : NSUInteger {
    ITEM_CLIENTCODE=0,
    ITEM_CLIENTCODE_COUNTER,
    ITEM_ADDRESS_CITY=0,
    ITEM_ADDRESS_STREET,
    ITEM_ADDRESS_HOUSE,
    ITEM_ADDRESS_OFFICE,
    ITEM_ADDRESS_CONTACTNAME,
    ITEM_ADDRESS_CONTACTPHONE,
    ITEM_ADDRESS_COUNTER,
    ITEM_SCHEDULE_DATE=0,
    ITEM_SCHEDULE_DATE_PICKER,
    ITEM_SCHEDULE_TIME,
    ITEM_SCHEDULE_TIME_PICKER,
    ITEM_SCHEDULE_COUNTER,
    ITEM_CONTENT_CLEARWATER=0,
    ITEM_CONTENT_FLUORIDATED,
    ITEM_CONTENT_IODINATED,
//    ITEM_CONTENT_ADDITIONAL,
    ITEM_CONTENT_COUNTER,
    ITEM_CONFIRM_SMS=0,
    ITEM_CONFIRM_EMAIL,
    ITEM_CONFIRM_PHONE,
    ITEM_CONFIRM_COUNTER,
    ITEM_COMMENTS=0,
    ITEM_COMMENTS_COUNTER
} OrderItems;

//----------------------------------------------------------------------
@interface VCEditOrder ()
{
    BOOL _isKBVisible;
    CGFloat _viewShiftDelta;
    OrderModel *_order;
    NSArray *_deliveryTimes;

    UIActivityIndicatorView *_activity;
    UIView *_activityBG;
    UILabel *_activityText;
}
-(IBAction)sendOrderTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnSendOrder;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UITextField *clientCode;
@property (strong, nonatomic) UITextField *addressCity;
@property (strong, nonatomic) UITextField *addressStreet;
@property (strong, nonatomic) UITextField *addressHouse;
@property (strong, nonatomic) UITextField *addressApt;
@property (strong, nonatomic) UITextField *addressContactName;
@property (strong, nonatomic) UITextField *addressContactPhone;
@property (strong, nonatomic) UITextField *scheduleTime;
@property (strong, nonatomic) UITextField *scheduleDate;
@property (strong, nonatomic) UILabel     *contentClearWater;
@property (strong, nonatomic) UILabel     *contentFluoride;
@property (strong, nonatomic) UILabel     *contentIodinated;
@property (strong, nonatomic) UITextField *confirmSMS;
@property (strong, nonatomic) UITextField *confirmPhone;
@property (strong, nonatomic) UITextField *confirmEmail;
@property (strong, nonatomic) UITextField *orderComments;

@property (strong, nonatomic) UIStepper *stepperClearWater;
@property (strong, nonatomic) UIStepper *stepperFluoride;
@property (strong, nonatomic) UIStepper *stepperIodinate;

@property (strong, nonatomic) UIDatePicker *pickerScheduleDate;
@property (strong, nonatomic) UIPickerView *pickerScheduleTime;


@end

//----------------------------------------------------------------------
@implementation VCEditOrder

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initFields];
    _order = [[OrderModel alloc] init];
    [[self navigationItem] setTitle:LOC(@"title.MainScreen")];
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:LOC(@"button.RestoreOrder") style:UIBarButtonItemStylePlain target:self action:@selector(restoreOrderTapped:)]];

    // handle keyboard appearance to change UI layout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

-(void)restoreOrderTapped:(id)sender
{
    OrderModel* model = [self restoreOrder];
    if( model ) {
        [self fillUIFromOrder:model];
        _order = model;
    }
    else {
        [self showError:@"No previously sent orders found"];
    }
}

-(void)initFields
{
    _clientCode = [self newFieldWithPlaceholder:LOC(@"placeholder.ClientCode") andKeyboard:UIKeyboardTypeNumberPad];
    _addressCity = [self newFieldWithPlaceholder:LOC(@"placeholder.AddressCity")];
    _addressStreet = [self newFieldWithPlaceholder:LOC(@"placeholder.AddressStreet")];
    _addressHouse = [self newFieldWithPlaceholder:LOC(@"placeholder.addressHouse")];
    _addressApt = [self newFieldWithPlaceholder:LOC(@"placeholder.addressApt")];
    _addressContactName = [self newFieldWithPlaceholder:LOC(@"placeholder.addressContactName")];
    _addressContactPhone = [self newFieldWithPlaceholder:LOC(@"placeholder.addressContactPhone") andKeyboard:UIKeyboardTypePhonePad];
    _scheduleTime = [self newFieldWithPlaceholder:LOC(@"placeholder.scheduleTime")];
    [_scheduleTime setUserInteractionEnabled:NO];
    _scheduleDate = [self newFieldWithPlaceholder:LOC(@"placeholder.scheduleDate")];
    [_scheduleDate setUserInteractionEnabled:NO];
//    _contentClearWater = [self newFieldWithPlaceholder:LOC(@"placeholder.contentClearWater")];
//    _contentFluoride = [self newFieldWithPlaceholder:LOC(@"placeholder.contentFluoride")];
//    _contentIodinated = [self newFieldWithPlaceholder:LOC(@"placeholder.contentIodinated")];
    _confirmSMS = [self newFieldWithPlaceholder:LOC(@"placeholder.confirmSMS") andKeyboard:UIKeyboardTypePhonePad];
    _confirmPhone = [self newFieldWithPlaceholder:LOC(@"placeholder.confirmPhone") andKeyboard:UIKeyboardTypePhonePad];
    _confirmEmail = [self newFieldWithPlaceholder:LOC(@"placeholder.confirmEmail") andKeyboard:UIKeyboardTypeEmailAddress];
    _orderComments = [self newFieldWithPlaceholder:LOC(@"placeholder.orderComments")];
    
    _stepperClearWater = [self newStepper];
    _stepperFluoride = [self newStepper];
    _stepperIodinate = [self newStepper];
    _contentClearWater = [self newLabel];
    _contentFluoride = [self newLabel];
    _contentIodinated = [self newLabel];
    
    // date picker setting up
    _pickerScheduleDate = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 375, kDatePickerHeight)];
    [_pickerScheduleDate setDatePickerMode:UIDatePickerModeDate];
    [_pickerScheduleDate setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:(60*60*24)]]; // minimal date is tomorrow
    [_pickerScheduleDate addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    [_pickerScheduleDate setHidden:YES];

    // delivery time periods picker setting
    _pickerScheduleTime = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 375, kDeliveryTimePickerHeight)];
    [_pickerScheduleTime setDelegate:self];
    [_pickerScheduleTime setDataSource:self];
    [_pickerScheduleTime selectRow:0 inComponent:0 animated:NO];
    [_pickerScheduleTime setHidden:YES];
    _deliveryTimes = [CWSchedule deliveryPeriods];
}

-(void)dateSelected:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    if( picker == _pickerScheduleDate )
    {
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:kDateFormat];
        NSSTring *dateStr = [form stringFromDate:[picker date]];
        [_scheduleDate setText:dateStr];
        [_order setScheduleDate:dateStr];
    }
}

-(void)deliveryTimeSelected:(id)sender
{
    
}

-(UILabel *)newLabel
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 94, kDefaultCellHeight)];
    [lbl setTextAlignment:NSTextAlignmentRight];
    return lbl;
}

-(UIStepper *)newStepper
{
    UIStepper *newStepper = [[UIStepper alloc] initWithFrame:CGRectMake(0, 0, 94, 29)];
    [newStepper setStepValue:1];
    [newStepper setMinimumValue:0];
    [newStepper setMaximumValue:100];
    [newStepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
    
    return newStepper;
}

-(void)stepperChanged:(id)sender
{
    NSUInteger val = [(UIStepper *)sender value];
    if( sender == _stepperClearWater ) {
        [_order orderClearWater:val];
        [_contentClearWater setText:[NSString stringWithFormat:@"%lu", (unsigned long)[_order clearWater]]];
    }
    else if( sender == _stepperFluoride ) {
        [_order orderFluoridedWater:val];
        [_contentFluoride setText:[NSString stringWithFormat:@"%lu", (unsigned long)[_order fluoridedWater]]];
    }
    else if( sender == _stepperIodinate ) {
        [_order orderIonidedWater:val];
        [_contentIodinated setText:[NSString stringWithFormat:@"%lu", (unsigned long)[_order iondinatedWater]]];
    }
}

-(UITextField *)newFieldWithPlaceholder:(NSString *) placeholder
{
    return [self newFieldWithPlaceholder:placeholder andKeyboard:UIKeyboardTypeDefault];
}

-(UITextField *)newFieldWithPlaceholder:(NSString *) placeholder andKeyboard:(UIKeyboardType)keyboardType
{
    UITextField *newField = [[UITextField alloc] init];
//    [newField setBorderStyle:UITextBorderStyleRoundedRect];
    [newField setBorderStyle:UITextBorderStyleNone];
    [newField setKeyboardType:keyboardType];
    [newField setReturnKeyType:UIReturnKeyDone];
    [newField setDelegate:self];
    [newField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [newField setPlaceholder:placeholder];
    //[newField setBackgroundColor:[UIColor grayColor]];
    
    return newField;
}

-(void)formatTextField:(UITextField *)field forCell:(UITableViewCell *)cell
{
    //    field.frame = [[cell contentView] frame];
    //    [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
    //    [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)sendOrderTapped:(id)sender
{
    if( ![self checkFields] ) {
        return;
    }
    
    [self hidePickers];
    
//    DEBUG_START
//    //  Delete after tests. Only successfuly sent Order is tended to be stored
//    [self storeOrder:_order];
//    DEBUG_END

    [self fillOrderFromUI];
    [self showActivity];
ASYNC_BLOCK_START
    BOOL isSent = [[ServerHandler sharedInstance] sendOrder:_order];
    
    SYNC_BLOCK_START
        if( isSent ) {
            [self storeOrder:_order];
            [self showMessage:LOC(@"message.OrderWasSent") withTitle:LOC(@"title.Success")];
        }
        else {
            [self showError:LOC(@"message.ErrorSendingOrder")];
        }
        [self hideActivity];
    SYNC_BLOCK_END
ASYNC_BLOCK_END
}

-(void)storeOrder:(OrderModel *)order
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_order];
    [def setObject:data forKey:kUserDefsKeyLastOrder];
}

-(OrderModel *)restoreOrder
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSData *data = [def valueForKey:kUserDefsKeyLastOrder];
    OrderModel *model = nil;
    if( data ) {
        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return model;
}

-(void)fillOrderFromUI
{
    [_order setClientCode:[_clientCode text]];
    [_order setAddressCity:[_addressCity text]];
    [_order setAddressStreet:[_addressStreet text]];
    [_order setAddressHouse:[_addressHouse text]];
    [_order setAddressApt:[_addressApt text]];
    [_order setAddressContactPhone:[_addressContactPhone text]];
    [_order setAddressContactName:[_addressContactName text]];
    [_order setScheduleTime:[_scheduleTime text]];
    [_order setScheduleDate:[_scheduleDate text]];
    //    [_order setContentClearWater;
    //    [_order setContentFluorided;
    //    [_order setContentIodinated;
    [_order setConfirmSMS:[_confirmSMS text]];
    [_order setConfirmPhone:[_confirmPhone text]];
    [_order setConfirmEmail:[_confirmEmail text]];
    [_order setOrderComments:[_orderComments text]];
}

-(void)fillUIFromOrder:(OrderModel *)order
{
    
    [_clientCode setText: [order clientCode]];
    [_addressCity setText: [order addressCity]];
    [_addressStreet setText: [order addressStreet]];
    [_addressHouse setText: [order addressHouse]];
    [_addressApt setText: [order addressApt]];
    [_addressContactName setText: [order addressContactName]];
    [_addressContactPhone setText: [order addressContactPhone]];
    [_scheduleTime setText: [order scheduleTime]];
    [_scheduleDate setText: [order scheduleDate]];
    [_confirmSMS setText: [order confirmSMS]];
    [_confirmPhone setText: [order confirmPhone]];
    [_confirmEmail setText: [order confirmEmail]];
    [_orderComments setText: [order orderComments]];
    
    // Buttles numbers are stored as numbers
    [_stepperClearWater setValue: [order clearWater]];
    [_stepperFluoride setValue: [order fluoridedWater]];
    [_stepperIodinate setValue: [order iondinatedWater]];
    [_contentClearWater setText: [[order contentClearWater] stringValue]];
    [_contentFluoride setText: [[order contentFluorided] stringValue]];
    [_contentIodinated setText: [[order contentIodinated] stringValue]];
}

-(BOOL)checkFields
{
    BOOL isOK = YES;
    
    if( [[_addressStreet text] length] == 0 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    if( [[_addressHouse text] length] == 0 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    if( [[_addressContactName text] length] == 0 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    if( [[_addressContactPhone text] length] == 0 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    if( [[_scheduleDate text] length] == 0 )
    {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    else
    {
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:kDateFormat];
        NSDate *date = [form dateFromString:[_scheduleDate text]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dcomp = [calendar components:NSCalendarUnitWeekday fromDate:date];
#define WEEKDAY_SATURDAY 7
#define WEEKDAY_SUNDAY 1

        if( [dcomp weekday] == WEEKDAY_SUNDAY )
        {
            isOK = NO;
            [self showError:LOC(@"error.DeliveryProhibitedInSunday")];
        }
    }
    if( [[_scheduleTime text] length] == 0 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotAllFieldsFilled")];
    }
    if( ([_order clearWater] + [_order fluoridedWater] + [_order iondinatedWater]) < 2 ) {
        isOK = NO;
        [self showError:LOC(@"error.NotEnoughItemsOrdered")];
    }
    
    return isOK;
}

#pragma mark -
#pragma mark UITableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = kDefaultCellHeight;
    
    if( SECTION_SCHEDULE == indexPath.section )
    {
        switch (indexPath.row) {
            case ITEM_SCHEDULE_DATE_PICKER:
            case ITEM_SCHEDULE_TIME_PICKER:
            {
                // choose one from existing pickers
                UIView *picker = _pickerScheduleDate;
                if( indexPath.row == ITEM_SCHEDULE_TIME_PICKER ) {
                    picker = _pickerScheduleTime;
                }
                
                // decide returning height
                if( [picker isHidden] ) {
                    height = 0;
                }
                else {
                    height = CGRectGetHeight([picker bounds]);
                }
                break;
            }
            default:
                break;
        }
    }
    
    return height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNTER;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCnt = 0;
    switch (section) {
        case SECTION_CLIENT:
            rowsCnt = ITEM_CLIENTCODE_COUNTER;
            break;
            
        case SECTION_ADDRESS:
            rowsCnt = ITEM_ADDRESS_COUNTER;
            break;
            
        case SECTION_CONTENT:
            rowsCnt = ITEM_CONTENT_COUNTER;
            break;
            
        case SECTION_SCHEDULE:
            rowsCnt = ITEM_SCHEDULE_COUNTER;
            break;
            
        case SECTION_COMMENTS:
            rowsCnt = ITEM_COMMENTS_COUNTER;
            break;
            
        case SECTION_CONFIRM:
            rowsCnt = ITEM_CONFIRM_COUNTER;
            break;
            
        default:
            break;
    }
    
    return rowsCnt;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    
    switch (section) {
        case SECTION_CLIENT:
            header = LOC(@"table.section.Client");
            break;
            
        case SECTION_ADDRESS:
            header = LOC(@"table.section.Address");
            break;
            
        case SECTION_CONTENT:
            header = LOC(@"table.section.Content");
            break;
            
        case SECTION_SCHEDULE:
            header = LOC(@"table.section.Schedule");
            break;
            
        case SECTION_COMMENTS:
            header = LOC(@"table.section.Comments");
            break;
            
        case SECTION_CONFIRM:
            header = LOC(@"table.section.Confirm");
            break;
            
        default:
            break;
    }

    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = CompCellID(indexPath.section, indexPath.row);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
#define BORDER_DEFAULT -20.f
#define SHIFT_DEFAULT 10.f
    
    NSLog(@"Create cell %@ ", cellID);
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell contentView] setNewHeight:kDefaultCellHeight];
        [cell setNewWidth:CGRectGetWidth([tableView bounds])];
        [[cell contentView] setNewWidth:CGRectGetWidth([tableView bounds])];
        
        // create separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([cell bounds]), 1.f)];
        [separator setBackgroundColor:[UIColor lightGrayColor]];
        [separator changeSizeWidthDelta:-SHIFT_DEFAULT*2 heightDelta:.0f];
        [[cell contentView] addSubview:separator];
        [separator alignVerticalsWithMasterView:[cell contentView]];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:13.f]];
        
        switch (indexPath.section)
        {
            case SECTION_CLIENT:
            {
                UITextField *field = [@[_clientCode] objectAtIndex:indexPath.row];
                field.frame = [[cell contentView] frame];
                [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
                [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
                [[cell contentView] addSubview:field];
                [field alignVerticalsWithMasterView:[field superview]];
                [field alignHorizontalsWithMasterView:[field superview]];
                [[cell detailTextLabel] setText:[field placeholder]];
                DLog(@"%@", field);
                break;
            }
            case SECTION_ADDRESS:
            {
                UITextField *field = [@[_addressCity,
                                        _addressStreet,
                                        _addressHouse,
                                        _addressApt,
                                        _addressContactName,
                                        _addressContactPhone] objectAtIndex:indexPath.row];
                field.frame = [[cell contentView] frame];
                [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
                [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
                [[cell contentView] addSubview:field];
                [field alignVerticalsWithMasterView:[field superview]];
                [[cell detailTextLabel] setText:[field placeholder]];

                break;
            }
                
            case SECTION_CONTENT:
            {
                UIStepper *stepper = [@[_stepperClearWater,
                                        _stepperFluoride,
                                        _stepperIodinate] objectAtIndex:indexPath.row];
                [stepper setFrameX:CGRectGetWidth([[cell contentView] bounds]) - CGRectGetWidth([stepper bounds]) - SHIFT_DEFAULT
                            andY:SHIFT_DEFAULT];
                [[cell contentView] addSubview:stepper];

                UILabel *label = [@[_contentClearWater,
                                    _contentFluoride,
                                    _contentIodinated] objectAtIndex:indexPath.row];
                [label setFrame:[stepper frame]];
                [label setFrameX:CGRectGetMinX([stepper frame]) - CGRectGetWidth([label bounds]) - SHIFT_DEFAULT
                            andY:SHIFT_DEFAULT];
                [[cell contentView] addSubview:label];
                // place text labels and values
                switch (indexPath.row)
                {
                    case ITEM_CONTENT_CLEARWATER:
                    {
                        [label setText:[NSString stringWithFormat:@"%li", [_order clearWater]]];
                        [[cell textLabel] setText:LOC(@"cellText.ClearWater")];
                        break;
                    }
                    case ITEM_CONTENT_FLUORIDATED:
                    {
                        [label setText:[NSString stringWithFormat:@"%li", [_order fluoridedWater]]];
                        [[cell textLabel] setText:LOC(@"cellText.FluoridedWater")];
                        break;
                    }
                    case ITEM_CONTENT_IODINATED:
                    {
                        [label setText:[NSString stringWithFormat:@"%li", [_order iondinatedWater]]];
                        [[cell textLabel] setText:LOC(@"cellText.IodinatedWater")];
                        break;
                    }
                    default:
                        break;
                }

                break;
            }
            case SECTION_SCHEDULE:
            {
                switch (indexPath.row) {
                    case ITEM_SCHEDULE_DATE:
                    case ITEM_SCHEDULE_TIME:
                    {
                        UITextField *field = [@[_scheduleDate,
                                                _pickerScheduleDate,
                                                _scheduleTime,
                                                _pickerScheduleTime] objectAtIndex:indexPath.row];
                        field.frame = [[cell contentView] frame];
                        [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
                        [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
                        [[cell contentView] addSubview:field];
                        [field alignVerticalsWithMasterView:[field superview]];
                        [[cell detailTextLabel] setText:[field placeholder]];

                        // date cell should be selectable to change table UI and display date picker
                        if( _scheduleDate == field ) {
                            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
                        }
                        break;
                    }
                    
                    case ITEM_SCHEDULE_DATE_PICKER:
                        //case ITEM_SCHEDULE_TIME_PICKER:
                    {
                        _pickerScheduleDate.frame = [[cell contentView] frame];
                        [_pickerScheduleDate setNewHeight:kDatePickerHeight];
                        [[cell contentView] setFrame:[_pickerScheduleDate frame]];
                        [[cell contentView] addSubview:_pickerScheduleDate];
                        [separator setHidden:YES];
                        break;
                    }
                    
                    case ITEM_SCHEDULE_TIME_PICKER:
                    {
                        _pickerScheduleTime.frame = [[cell contentView] frame];
                        [_pickerScheduleTime setNewHeight:kDeliveryTimePickerHeight];
                        [[cell contentView] setFrame:[_pickerScheduleTime frame]];
                        [[cell contentView] addSubview:_pickerScheduleTime];
                        [separator setHidden:YES];
                        break;
                    }
                    default:
                        break;
                }
                
                break;
            }
            case SECTION_COMMENTS:
            {
                UITextField *field = [@[_orderComments] objectAtIndex:indexPath.row];
                field.frame = [[cell contentView] frame];
                [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
                [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
                [[cell contentView] addSubview:field];
                [field alignVerticalsWithMasterView:[field superview]];
                [[cell detailTextLabel] setText:[field placeholder]];

                break;
            }
            case SECTION_CONFIRM:
            {
                UITextField *field = [@[_confirmSMS,
                                        _confirmPhone,
                                        _confirmEmail] objectAtIndex:indexPath.row];
                field.frame = [[cell contentView] frame];
                [field changeSizeWidthDelta:BORDER_DEFAULT heightDelta:BORDER_DEFAULT];
                [field changeFrameXDelta:SHIFT_DEFAULT yDelta:SHIFT_DEFAULT];
                [[cell contentView] addSubview:field];
                [field alignVerticalsWithMasterView:[field superview]];
                [[cell detailTextLabel] setText:[field placeholder]];

                break;
            }
            default:
                break;
        }
        [separator alignBottomsWithMasterView:[separator superview]];
    }
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // switch picker visibility
    switch (indexPath.section)
    {
        case SECTION_SCHEDULE:
        {
            switch (indexPath.row)
            {
                case ITEM_SCHEDULE_DATE:
                {
                    // hide Time picker preliminary
                    [self setPicker:_pickerScheduleTime
                             hidden:YES
                       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_DATE_PICKER inSection:SECTION_SCHEDULE]
                        ofTableView:tableView];

                    
                    // switch picker visibility
                    [self setPicker:_pickerScheduleDate
                            hidden:NOT([_pickerScheduleDate isHidden])
                       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_DATE_PICKER inSection:SECTION_SCHEDULE]
                        ofTableView:tableView];

                    // if corresponding text field already contains date, try to slect it in the picker
                    if( ([[_scheduleDate text] length] > 0) && NOT([_pickerScheduleDate isHidden]) )
                    {
                        NSDateFormatter *form = [[NSDateFormatter alloc] init];
                        [form setDateFormat:kDateFormat];
                        NSDate *date = [form dateFromString:[_scheduleDate text]];
                        
                        if( date ) {
                            [_pickerScheduleDate setDate:date];
                        }
                    }

                    break;
                }
                case ITEM_SCHEDULE_TIME:
                {
                    // hide Date picker preliminary
                    [self setPicker:_pickerScheduleDate
                             hidden:YES
                       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_DATE_PICKER inSection:SECTION_SCHEDULE]
                        ofTableView:tableView];

                    
                    // switch picker visibility
                    [self setPicker:_pickerScheduleTime
                            hidden:NOT([_pickerScheduleTime isHidden])
                       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_TIME_PICKER inSection:SECTION_SCHEDULE]
                        ofTableView:tableView];

                    // if corresponding text field already contains some text, try to find it in array and select the item in picker
                    if( ([[_scheduleTime text] length] > 0) && NOT([_pickerScheduleTime isHidden]) )
                    {
                        for (NSString *oneStr in _deliveryTimes) {
                            if( [oneStr isEqualToString:[_scheduleTime text]] )
                            {
                                [_pickerScheduleTime selectRow:[_deliveryTimes indexOfObject:oneStr] inComponent:0 animated:NO];
                                break;
                            }
                        }
                    }
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
        {
            [self hidePickers];
            break;
        }
    }
}

-(void)setPicker:(UIView *)picker hidden:(BOOL)state inCellOnPath:(NSIndexPath *)cellPath ofTableView:(UITableView *)tableView
{
    if( [picker isHidden] == state ) {
        return;
    }
    
    // switch picker visibility
    [picker setHidden:state];
    
    // animating row manipulation in table
    [UIView animateWithDuration:.4 animations:^{
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellPath.row inSection:cellPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }];
}

-(void)hidePickers
{
    // hide Time and Date pickers is either was visible
    [self setPicker:_pickerScheduleDate
             hidden:YES
       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_DATE_PICKER inSection:SECTION_SCHEDULE]
        ofTableView:_tableView];
    
    [self setPicker:_pickerScheduleTime
             hidden:YES
       inCellOnPath:[NSIndexPath indexPathForRow:ITEM_SCHEDULE_DATE_PICKER inSection:SECTION_SCHEDULE]
        ofTableView:_tableView];
}

#pragma mark -
#pragma mark UITextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"");
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self hidePickers];
    return YES;
}

#pragma mark -
#pragma mark Keyboard events
-(void)keyboardWillAppear:(NSNotification *)notification
{
    // only change UI if keyboard was invisible
    if( _isKBVisible ) {
        return;
    }
    
    // will shift view UP to make text fields visible
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self handleKeyboardAppearWithSize:kbSize];
}

-(void)keyboardWillDisappear:(NSNotification *)notification
{
    [self handleKeyboardHiding];
}

-(void)handleKeyboardHiding
{
    _isKBVisible = NO;
    // will shift view DOWN on keyboard disappear
    [UIView animateWithDuration:.2f animations:^{
        //[[self view] changeFrameXDelta:.0f yDelta:_viewShiftDelta];
        [[self view] changeSizeWidthDelta:.0f heightDelta:_viewShiftDelta];
        _viewShiftDelta = .0f;
    } completion:^(BOOL finished) {
    }];
}

-(void)handleKeyboardAppearWithSize:(CGSize)kbSize
{
    CGFloat bottomHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetMaxY([[self btnSendOrder] frame]);
    
    CGFloat kbHeight = kbSize.height;
    _viewShiftDelta = kbHeight - bottomHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
    // if keyboard is higher than Login button bottom line shift UI to this delta
    if( _viewShiftDelta > 0 ) {
        [UIView animateWithDuration:.2f animations:^{
            //[[self view] changeFrameXDelta:.0f yDelta:-_viewShiftDelta];
            [[self view] changeSizeWidthDelta:.0f heightDelta:-_viewShiftDelta];
        } completion:^(BOOL finished) {
            if(finished){
                _isKBVisible = YES;
            }
        }];
    }
}

-(void)willResignActive:(NSNotification *)notification
{
    if( _isKBVisible ) {
//        [[self userPass] resignFirstResponder];
//        [[self userName] resignFirstResponder];
    }
}

#pragma mark -
#pragma mark Helpers
-(void)showError:(NSString *)message
{
    [self showMessage:message withTitle:LOC(@"title.Error")];
}

-(void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"button.OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIPickerView
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_deliveryTimes count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_deliveryTimes objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [_scheduleTime setText:[_deliveryTimes objectAtIndex:row]];
}

#pragma mark -
#pragma mark Activity indicator issues

-(void)showActivity
{
    DLog(@"");
    if( _activity ) {
        [self hideActivity];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity setCenter:self.view.center];
        [_activity startAnimating];
        
        _activityBG = [[UIView alloc] initWithFrame:[[self view] bounds]];
        [_activityBG setCenter:[[self view] center]];
        [_activityBG setBackgroundColor:[UIColor blackColor]];
        [_activityBG setAlpha:.7f];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:_activityBG];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_activity];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activityBG];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activity];
        
        _activityText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_activityBG.bounds), 20.f)];
        [_activityText setText:@""];
        [_activityText setFont:[UIFont systemFontOfSize:15.f]];
        [_activityText setTextColor:[UIColor whiteColor]];
        [_activityText setTextAlignment:NSTextAlignmentCenter];
        [[[UIApplication sharedApplication] keyWindow]  addSubview:_activityText];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activityText];
        [_activityText setCenter:[_activityBG center]];
        [_activityText setFrame:CGRectOffset(_activityText.frame, 0.f, 30.f)];
        [[self navigationItem] setHidesBackButton:YES animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    });
}

-(void)changeActivityText:(NSString *)newText
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_activityText setText:newText];
    });
}

-(void)hideActivity
{
    DLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if( _activityBG )
        {
            [_activityText removeFromSuperview];
            _activityText = nil;
            [_activityBG removeFromSuperview];
            _activityBG = nil;
            [_activity removeFromSuperview];
            _activity = nil;
            [[self navigationItem] setHidesBackButton:NO animated:YES];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    });
}


@end
