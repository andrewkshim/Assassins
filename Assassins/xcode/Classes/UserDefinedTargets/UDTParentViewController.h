/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import <UIKit/UIKit.h>
#import "ARParentViewController.h"
#import "ScannerOverlayView.h"
#import "CustomToolbar.h"
#import "CustomToolbarDelegateProtocol.h"

@interface UDTParentViewController : ARParentViewController <CustomToolbarDelegateProtocol>
{
@public
    CustomToolbar *toolbar;
    UIBarButtonItem *addButton;
    UIBarButtonItem *cameraButton;
    ScannerOverlayView *overlayView;
    UILabel *topLabel;
    
    BOOL isCameraModeEnabled;
}

-(void)setCameraMode:(BOOL)isEnabled;

@end
