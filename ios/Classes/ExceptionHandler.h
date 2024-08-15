#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@interface ExceptionHandler : NSObject
+ (nullable PKAddPassesViewController *)safeAddPassesViewControllerWithIssuerData:(NSData *_Nonnull)issuerData
                                                                        signature:(NSData *_Nonnull)signature;
@end
