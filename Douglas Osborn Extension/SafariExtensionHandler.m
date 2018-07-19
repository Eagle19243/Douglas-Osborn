//
//  SafariExtensionHandler.m
//  Douglas Osborn Extension
//
//  Created by eagle on 6/16/17.
//  Copyright © 2017 Douglas-Osborn. All rights reserved.
//

#import "SafariExtensionHandler.h"
#import "SafariExtensionViewController.h"
#import "AFNetworking.h"

@interface SafariExtensionHandler () {

}
@end

@implementation SafariExtensionHandler

- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        NSLog(@"The extension received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, properties.url, userInfo);
    }];
    if ([messageName  isEqual: @"SaveData"]) {
        [self saveData: userInfo];
    } else if ([messageName  isEqual: @"GetData"]) {
        [self getData: userInfo];
    } else if ([messageName  isEqual: @"RequestToServer"]) {
        [self requestToServer: userInfo];
    }
}

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window {
    // This method will be called when your toolbar item is clicked.
    NSLog(@"The extension's toolbar item was clicked");
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler {
    // This method will be called whenever some state changes in the passed in window. You should use this as a chance to enable or disable your toolbar item and set badge text.
    validationHandler(YES, nil);
}

- (SFSafariExtensionViewController *)popoverViewController {
    return [SafariExtensionViewController sharedController];
}

- (void) saveData: (NSDictionary *)data {
    NSMutableArray * appData = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppStorage"]];
    
    if (appData == nil) {
        appData = [NSMutableArray array];
    }
    
    [appData addObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:appData forKey:@"AppStorage"];
    [self sendMessage:@"SaveData" :@{
         @"Success" : @"true",
         @"callbackCode" : data[@"CallbackCode"]
    }];
}

- (void) getData: (NSDictionary *)data {
    NSMutableArray * appData = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppStorage"]];
    
    if (appData != nil || appData.count > 0) {
        for (int i=0; i<appData.count; i++) {
            if (appData[i][@"Name"] == data[@"Name"]) {
                [self sendMessage:@"GetData" :@{
                    @"data": appData[i][@"Data"],
                    @"callbackCode" : data[@"CallbackCode"]
                }];
            }
        }
    } else {
        [self sendMessage:@"GetData" :@{
            @"data": @"",
            @"callbackCode": data[@"CallbackCode"]
        }];
    }
    
}

- (void) requestToServer: (NSDictionary *)data {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([data[@"Request"]  isEqual: @"GET"]) {
        [manager GET: data[@"URL"] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            [self sendMessage:@"RequestToServer" : @{
                @"success": @"true",
                @"code"   : [NSNumber numberWithInt:(int) httpResponse.statusCode],
                @"data"   : responseObject,
                @"callbackCode" : data[@"CallbackCode"]
            }];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } else if ([data[@"Request"]  isEqual: @"POST"]) {
        [manager POST: data[@"URL"] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            [self sendMessage:@"RequestToServer" : @{
                 @"success": @"true",
                 @"code"   : [NSNumber numberWithInt:(int) httpResponse.statusCode],
                 @"data"   : responseObject,
                 @"callbackCode" : data[@"CallbackCode"]
             }];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void) sendMessage: (NSString *) messageName :(NSDictionary *)object {
    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
        [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
            [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
                if (activePage == nil) return;
                [activePage dispatchMessageToScriptWithName: messageName userInfo:object];
            }];
        }];
    }];
}

@end
