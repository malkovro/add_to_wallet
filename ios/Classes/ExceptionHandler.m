#import "ExceptionHandler.h"
#if __has_include(<add_to_wallet/add_to_wallet-Swift.h>)
#import <add_to_wallet/add_to_wallet-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "add_to_wallet-Swift.h"
#endif

@implementation ExceptionHandler

+ (nullable PKAddPassesViewController *)safeAddPassesViewControllerWithIssuerData:(NSData *)issuerData signature:(NSData *)signature {
    @try {
        if (@available(iOS 16.4, *)) {
            NSError* error;
            PKAddPassesViewController* controller = [[PKAddPassesViewController alloc] initWithIssuerData:issuerData signature:signature error: &error];
            if (error != nil) {
                NSLog(@"Error happened: %@", error);
                return nil;
            }
            else {
                return controller;
            }
        } else {
            NSLog(@"ios version too old");
            return nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return nil;
    }
}

@end
