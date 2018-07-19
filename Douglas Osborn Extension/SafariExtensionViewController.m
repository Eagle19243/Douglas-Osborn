//
//  SafariExtensionViewController.m
//  Douglas Osborn Extension
//
//  Created by eagle on 6/16/17.
//  Copyright © 2017 Douglas-Osborn. All rights reserved.
//

#import "SafariExtensionViewController.h"
#import "AFNetworking.h"
#define BaseURL    @"https://jsonplaceholder.typicode.com"

@interface SafariExtensionViewController ()

@end

@implementation SafariExtensionViewController

- (IBAction)onSaveData:(id)sender {
    [self sendMessage:@"ButtonClicked" :@{
        @"button": @"Save Data"
    }];
}

- (IBAction)onGetData:(id)sender {
    [self sendMessage:@"ButtonClicked" :@{
        @"button": @"Get Data"
    }];
}

- (IBAction)onRequest:(id)sender {
    [self sendMessage:@"ButtonClicked" :@{
        @"button": @"RequestToServer"
    }];
}

- (void) sendMessage: (NSString *) messageName :(NSDictionary<NSString *, id> *)object {
    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
        [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
            [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
                if (activePage == nil) return;
                [activePage dispatchMessageToScriptWithName: messageName userInfo:object];
            }];
        }];
    }];
}

+ (SafariExtensionViewController *)sharedController {
    static SafariExtensionViewController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[SafariExtensionViewController alloc] init];
    });
    return sharedController;
}

@end
