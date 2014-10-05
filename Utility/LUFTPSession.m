//
//  LUFTPSession.m
//  LessionUtility
//
//  Created by SFBest on 14-3-31.
//  Copyright (c) 2014年 256. All rights reserved.
//

#import "LUFTPSession.h"
#import "SFTipView.h"
#import "GRRequestsManager.h"

enum {
    kSendBufferSize = 32768//上传的缓冲区大小，可以设置
};

@interface LUFTPSession ()
<
//NSStreamDelegate
GRRequestsManagerDelegate
>

@property (nonatomic, strong) GRRequestsManager *requestsManager;

//@property (nonatomic, readonly) BOOL isSending;
//@property (nonatomic, retain)   NSOutputStream *networkStream;
//@property (nonatomic, retain)   NSInputStream *fileStream;
//@property (nonatomic, readonly) uint8_t *buffer;
//@property (nonatomic, assign)   size_t bufferOffset;
//@property (nonatomic, assign)   size_t bufferLimit;

@end
@implementation LUFTPSession
{
//    uint8_t _buffer[kSendBufferSize];
    void(^ProgressBlock)(float);
}

+ (id)sharedInstance {
    static LUFTPSession *ftp_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ftp_ = [LUFTPSession new];
    });
    return ftp_;
}
- (id)init {
    if (self = [super init]) {
        [self _setupManager];
    }
    return self;
}
- (void)_setupManager
{
    self.requestsManager = [[GRRequestsManager alloc] initWithHostname:@"ftp://www.cdfx.cn"
                                                                  user:@"lool"
                                                              password:@"wankecsfx"];
    self.requestsManager.delegate = self;
}

- (void)ftp:(NSString *)filePath progress:(void(^)(float progress))block {
    if (!filePath) {
        return;
    }
    ProgressBlock = block;
//    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"TestFile" ofType:@"txt"];
    NSString *fileName = [filePath lastPathComponent];
    [self.requestsManager addRequestForUploadFileAtLocalPath:filePath toRemotePath:[NSString stringWithFormat:@"/%@", fileName]];
    [self.requestsManager startProcessingRequests];
}
#pragma mark -
#pragma mark - GRRequestsManagerDelegate
- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didScheduleRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didScheduleRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteListingRequest:(id<GRRequestProtocol>)request listing:(NSArray *)listing
{
    NSLog(@"requestsManager:didCompleteListingRequest:listing: \n%@", listing);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteCreateDirectoryRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteCreateDirectoryRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDeleteRequest:(id<GRRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDeleteRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompletePercent:(float)percent forRequest:(id<GRRequestProtocol>)request
{
    if (ProgressBlock) {
        ProgressBlock(percent);
    }
    NSLog(@"requestsManager:didCompletePercent:forRequest: %f", percent);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteUploadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    if (ProgressBlock) {
        ProgressBlock(1);
    }
    NSLog(@"requestsManager:didCompleteUploadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didCompleteDownloadRequest:(id<GRDataExchangeRequestProtocol>)request
{
    NSLog(@"requestsManager:didCompleteDownloadRequest:");
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailWritingFileAtPath:(NSString *)path forRequest:(id<GRDataExchangeRequestProtocol>)request error:(NSError *)error
{
    NSLog(@"requestsManager:didFailWritingFileAtPath:forRequest:error: \n %@", error);
}

- (void)requestsManager:(id<GRRequestsManagerProtocol>)requestsManager didFailRequest:(id<GRRequestProtocol>)request withError:(NSError *)error
{
    NSLog(@"requestsManager:didFailRequest:withError: \n %@", error);
}
//- (uint8_t *)buffer
//{
//    return self->_buffer;
//}
//- (void)ftp:(NSString *)filePath {
//    
//    NSURL *url = [NSURL URLWithString:@"ftp://www.cdfx.cn"];//ftp服务器地址
//    NSString *account = @"tuhy";//账号
//    NSString *password = @"66197751";//密码
//    CFWriteStreamRef ftpStream;
//    
//    //添加后缀（文件名称）
////    url = [NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) url, (CFStringRef)
////                                                                   [filePath lastPathComponent], false)) autorelease];
//    url = CFBridgingRelease(CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef)url, (CFStringRef)[filePath lastPathComponent], false));
//    
//    //读取文件，转化为输入流
//    self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
//    [self.fileStream open];
//    
//    //为url开启CFFTPStream输出流
//    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
//    self.networkStream = (__bridge NSOutputStream *) ftpStream;
//    
//    //设置ftp账号密码
//    [self.networkStream setProperty:account forKey:(id)kCFStreamPropertyFTPUserName];
//    [self.networkStream setProperty:password forKey:(id)kCFStreamPropertyFTPPassword];
//    
//    //设置networkStream流的代理，任何关于networkStream的事件发生都会调用代理方法
//    self.networkStream.delegate = self;
//    
//    //设置runloop
//    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [self.networkStream open];
//    
//    //完成释放链接  
//    CFRelease(ftpStream);  
//}  
//#pragma mark -
//#pragma mark - NSStreamDelegate
//- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
//{
//    //aStream 即为设置为代理的networkStream
//    switch (eventCode) {
//        case NSStreamEventOpenCompleted: {
//            NSLog(@"NSStreamEventOpenCompleted");
//        } break;
//        case NSStreamEventHasBytesAvailable: {
//            NSLog(@"NSStreamEventHasBytesAvailable");
//            assert(NO);     // 在上传的时候不会调用
//        } break;
//        case NSStreamEventHasSpaceAvailable: {
//            NSLog(@"NSStreamEventHasSpaceAvailable");
//            NSLog(@"bufferOffset is %zd",self.bufferOffset);
//            NSLog(@"bufferLimit is %zu",self.bufferLimit);
//            if (self.bufferOffset == self.bufferLimit) {
//                NSInteger   bytesRead;
//                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
//                
//                if (bytesRead == -1) {
//                    //读取文件错误
////                    [self _stopSendWithStatus:@"读取文件错误"];
//                } else if (bytesRead == 0) {
//                    //文件读取完成 上传完成
////                    [self _stopSendWithStatus:nil];
//                } else {
//                    self.bufferOffset = 0;
//                    self.bufferLimit  = bytesRead;
//                }
//            }
//            
//            if (self.bufferOffset != self.bufferLimit) {
//                //写入数据
//                NSInteger bytesWritten;//bytesWritten为成功写入的数据
//                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset]
//                                               maxLength:self.bufferLimit - self.bufferOffset];
//                assert(bytesWritten != 0);
//                if (bytesWritten == -1) {
////                    [self _stopSendWithStatus:@"网络写入错误"];
//                } else {
//                    self.bufferOffset += bytesWritten;
//                }
//            }
//        } break;
//        case NSStreamEventErrorOccurred: {
////            [self _stopSendWithStatus:@"Stream打开错误"];
//            assert(NO);
//        } break;
//        case NSStreamEventEndEncountered: {
//            // 忽略
//        } break;
//        default: {
//            assert(NO);
//        } break;
//    }
//}
//- (void)_stopSendWithStatus:(NSString *)statusString
//{
//    if (self.networkStream != nil) {
//        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        self.networkStream.delegate = nil;
//        [self.networkStream close];
//        self.networkStream = nil;
//    }
//    if (self.fileStream != nil) {
//        [self.fileStream close];
//        self.fileStream = nil;
//    }
////    [self _sendDidStopWithStatus:statusString];
//}


@end
