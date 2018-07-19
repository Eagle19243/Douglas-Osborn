//
//  SafariExtensionViewController.h
//  Douglas Osborn Extension
//
//  Created by eagle on 6/16/17.
//  Copyright © 2017 Douglas-Osborn. All rights reserved.
//

#import <SafariServices/SafariServices.h>

@interface SafariExtensionViewController : SFSafariExtensionViewController
- (IBAction)onSaveData:(id)sender;
- (IBAction)onGetData:(id)sender;
- (IBAction)onRequest:(id)sender;
+ (SafariExtensionViewController *)sharedController;
@end
