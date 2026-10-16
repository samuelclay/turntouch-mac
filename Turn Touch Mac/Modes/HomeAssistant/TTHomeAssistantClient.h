#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^TTHACompletion)(id _Nullable result, NSError * _Nullable error);
extern NSString * const TTHAConnectionChanged;
extern NSString * const TTHAClientID;
extern NSString * const TTHARedirectURI;

@interface TTHomeAssistantClient : NSObject <NSURLSessionTaskDelegate>
@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) NSArray<NSDictionary *> *entities;
@property (nonatomic, readonly) NSDictionary *services;
@property (nonatomic, readonly) NSString *lastError;
+ (instancetype)sharedClient;
+ (nullable NSString *)normalizedURL:(NSString *)input;
+ (NSArray<NSDictionary *> *)actionsForEntity:(NSDictionary *)entity services:(NSDictionary *)services;
+ (nullable NSDictionary *)serviceBodyForEntity:(NSString *)entityID data:(NSString *)json error:(NSError **)error;
- (void)connectToURL:(NSString *)url token:(NSString *)token completion:(TTHACompletion)completion;
- (void)exchangeCode:(NSString *)code serverURL:(NSString *)url completion:(TTHACompletion)completion;
- (BOOL)restoreConnectionToURL:(NSString *)url;
- (void)refreshCatalog:(TTHACompletion)completion;
- (void)callAction:(NSString *)service entity:(NSString *)entityID data:(NSString *)json completion:(TTHACompletion)completion;
- (void)disconnect;
@end
NS_ASSUME_NONNULL_END
