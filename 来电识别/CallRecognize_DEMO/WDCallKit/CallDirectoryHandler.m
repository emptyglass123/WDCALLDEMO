//
//  CallDirectoryHandler.m
//  WDCallKit
//
//  Created by 朱辉 on 2017/5/3.
//  Copyright © 2017年 jxx. All rights reserved.
//

#import "CallDirectoryHandler.h"
#define CallNumberGroupString @"group.CALLGROUP"
#define CallNumberGroupPath   @"Library/Caches/good"
@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;

    if (![self addBlockingPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add blocking phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:1 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    if (![self addIdentificationPhoneNumbersToContext:context]) {
        NSLog(@"Unable to add identification phone numbers");
        NSError *error = [NSError errorWithDomain:@"CallDirectoryHandler" code:2 userInfo:nil];
        [context cancelRequestWithError:error];
        return;
    }
    
    [context completeRequestWithCompletionHandler:nil];
}

- (BOOL)addBlockingPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    // Retrieve phone numbers to block from data store. For optimal performance and memory usage when there are many phone numbers,
    // consider only loading a subset of numbers at a given time and using autorelease pool(s) to release objects allocated during each batch of numbers which are loaded.
    //
    // Numbers must be provided in numerically ascending order.
    CXCallDirectoryPhoneNumber phoneNumbers[] = { 14085555555, 18005555555 };
    NSUInteger count = (sizeof(phoneNumbers) / sizeof(CXCallDirectoryPhoneNumber));

    for (NSUInteger index = 0; index < count; index += 1) {
        CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[index];
        [context addBlockingEntryWithNextSequentialPhoneNumber:phoneNumber];
    }

    return YES;
}

- (BOOL)addIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:CallNumberGroupString];
    containerURL = [containerURL URLByAppendingPathComponent:CallNumberGroupPath];
    NSArray *callNumberArray = [NSArray arrayWithContentsOfURL:containerURL];
    
    if (callNumberArray) {
        
        NSUInteger count = [callNumberArray count];
        CXCallDirectoryPhoneNumber *phoneNumbers = malloc(sizeof(CXCallDirectoryPhoneNumber)*count);
        for (NSUInteger i = 0; i < count; i += 1) {
            
            NSDictionary *dic = callNumberArray[i];
            NSString *phoneString = dic[@"CALL_NUMBER"];
            phoneNumbers[i] = [phoneString longLongValue];
            CXCallDirectoryPhoneNumber phoneNumber = phoneNumbers[i];
            NSString *label = [NSString stringWithFormat:@"%@-%@-%@",dic[@"CALL_NAME"],dic[@"CALL_SEX"],dic[@"CALL_ADDRESS"]];
            [context addIdentificationEntryWithNextSequentialPhoneNumber:phoneNumber label:label];
            
        }
        
        free(phoneNumbers);
        
    }


    return YES;
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(CXCallDirectoryExtensionContext *)extensionContext withError:(NSError *)error {
    // An error occurred while adding blocking or identification entries, check the NSError for details.
    // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
    //
    // This may be used to store the error details in a location accessible by the extension's containing app, so that the
    // app may be notified about errors which occured while loading data even if the request to load data was initiated by
    // the user in Settings instead of via the app itself.
}

@end
