/*
 problems to handle:
    1. delete audio file after mix operation completed.
    2.
 */


#import "ScreenCaptureView.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+Date.h"

@interface ScreenCaptureView(Private)
<
AVAudioRecorderDelegate
>

@end

@implementation ScreenCaptureView
{
    NSString *currentOutPath;
    BOOL isPaused;
	//video writing
	AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput, *audioWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
	
	NSDate* startedAt;
	void* bitmapData;
    NSInteger offsetTimeIntervalPause;// 暂停时已经录制的时间
    
    //Variable setup for access in the class
    NSURL *recordedTmpFile;
    AVAudioRecorder *recorder;
    //    NSError *error;
    float delayRateTime;
}
@synthesize delegate;

- (void) initialize {
	// Initialization code
	self.clearsContextBeforeDrawing = YES;

	self.frameRate = 24.0f;     //frames per seconds
	_recording = false;
	videoWriter = nil;
	videoWriterInput = nil;
	avAdaptor = nil;
	startedAt = nil;
	bitmapData = NULL;
    
    //Instanciate an instance of the AVAudioSession object.
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    //Setup the audioSession for playback and record.
    //We could just use record and then switch it to playback leter, but
    //since we are going to do both lets set it up once.
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    //Activate the session
    [audioSession setActive:YES error: &error];
    
    delayRateTime = 1 / self.frameRate;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)setFrameRate:(float)frameRate {
    _frameRate = frameRate;
    delayRateTime = 1.0 / _frameRate;
}

- (CGContextRef) createBitmapContext {
	static CGContextRef context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = self.frame.size;
        size_t bitmapBytesPerRow   = (size.width * 4);
        size_t bitmapByteCount     = (bitmapBytesPerRow * size.height);
        void* bitmapData1;
        if (bitmapData1 != NULL) {
            free(bitmapData1);
        }
        bitmapData1 = malloc( bitmapByteCount );
        if (bitmapData1 == NULL) {
            fprintf (stderr, "Memory not allocated!");
        } else {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            NSInteger bitmapInfo = kCGImageAlphaNoneSkipFirst;
            context= CGBitmapContextCreate (bitmapData1,
                                            size.width,
                                            size.height,
                                            8,      // bits per component
                                            bitmapBytesPerRow,
                                            colorSpace,
                                            bitmapInfo);
            
            CGContextSetAllowsAntialiasing(context, NO);
            if (context== NULL) {
                free (bitmapData1);
                fprintf (stderr, "Context not created!");
            }
            CGColorSpaceRelease(colorSpace);
            
            //not sure why this is necessary...image renders upside-down and mirrored
            CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
            CGContextConcatCTM(context, flipVertical);
        }
    });
    
	return context;
}

//static int frameCount = 0;            //debugging
- (void) drawRect:(CGRect)rect {

    if (!_recording) {
        [super drawRect:rect];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGContextRef context = [self createBitmapContext];
        [self.layer renderInContext:context];

        _timeIntervalElapsed = [[NSDate date] timeIntervalSinceDate:startedAt];
//        NSLog(@"%@, %f", startedAt, _timeIntervalElapsed);
        [self writeVideoFrameAtTime:CMTimeMake((int)(_timeIntervalElapsed * 1000.0), 1000)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRateTime];
        });
    });

//    [self.layer renderInContext:context];
    
    //debugging
    //if (frameCount < 40) {
    //      NSString* filename = [NSString stringWithFormat:@"Documents/frame_%d.png", frameCount];
    //      NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    //      [UIImagePNGRepresentation(self.currentScreen) writeToFile: pngPath atomically: YES];
    //      frameCount++;
    //}
    
    //NOTE:  to record a scrollview while it is scrolling you need to implement your UIScrollViewDelegate such that it calls
    //       'setNeedsDisplay' on the ScreenCaptureView.
    
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    //    UIImage* background = [UIImage imageWithCGImage: cgImage];
    //    CGImageRelease(cgImage);
    //
    //    self.currentScreen = background;
    //        });
}

- (void) cleanupWriter {
	avAdaptor = nil;
	videoWriterInput = nil;
	videoWriter = nil;
	startedAt = nil;
	
	if (bitmapData != NULL) {
		free(bitmapData);
		bitmapData = NULL;
	}
}

- (void)dealloc {
	[self cleanupWriter];
}

- (NSURL *)tempFileURL {
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"outputMovie.mp4"];
    currentOutPath = outputPath;
	NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:outputPath]) {
		NSError* error_;
		if ([fileManager removeItemAtPath:outputPath error:&error_] == NO) {
			NSLog(@"Could not delete old recording file at path:  %@", outputPath);
		}
	}
	
    return outputURL;
}

-(BOOL) setUpWriter {
	NSError* error_ = nil;
	videoWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL] fileType:AVFileTypeQuickTimeMovie error:&error_];
	NSParameterAssert(videoWriter);
	
	//Configure video
	NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithDouble:1024.0*1024.0], AVVideoAverageBitRateKey,
										   nil ];
	
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:self.frame.size.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:self.frame.size.height], AVVideoHeightKey,
								   videoCompressionProps, AVVideoCompressionPropertiesKey,
								   nil];
	
	videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	
	NSParameterAssert(videoWriterInput);
	videoWriterInput.expectsMediaDataInRealTime = YES;
	NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
	
	avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];

    //Configure audio -- Audio writer input for test, non-work
//    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
//                                   [NSNumber numberWithFloat:44110], AVSampleRateKey,
//                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
//                                   nil];
//    audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
//    NSParameterAssert(audioWriterInput);
//    [videoWriter addInput:audioWriterInput];
    
	//add input
	[videoWriter addInput:videoWriterInput];
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
	
	return YES;
}

- (void) completeRecordingSession {
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//	
//	
//	
//	[pool drain];
    
    @autoreleasepool {
        [videoWriterInput markAsFinished];
        
        // Wait for the video
        NSInteger status = videoWriter.status;
        while (status == AVAssetWriterStatusUnknown) {
            NSLog(@"Waiting...");
            [NSThread sleepForTimeInterval:0.5f];
            status = videoWriter.status;
        }
        
        @synchronized(self) {
            [recorder stop];
            
            [videoWriter finishWritingWithCompletionHandler:^{
                [self cleanupWriter];
                
                id delegateObj = self.delegate;
                
                NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:currentOutPath];
                
                NSLog(@"Completed recording, file is stored at:  %@", outputURL);
                if ([delegateObj respondsToSelector:@selector(recordingFinished:)]) {
                    [delegateObj performSelectorOnMainThread:@selector(recordingFinished:) withObject:outputURL waitUntilDone:YES];
                }
            }];
        }
    }
    
    // mix video & audio
    [self mixAudio:recordedTmpFile.absoluteString withVideo:currentOutPath];
}

- (bool) startRecording {
	bool result = NO;
	@synchronized(self) {
		if (! _recording) {
            offsetTimeIntervalPause = 0;
			result = [self setUpWriter];
			startedAt = [NSDate dateWithTimeIntervalSinceNow:offsetTimeIntervalPause];
			_recording = true;
            [self startRecordAudio];
            [self setNeedsDisplay];
		}
	}
	
	return result;
}

- (void) stopRecording {
	@synchronized(self) {
		if (_recording) {
			_recording = false;
			[self completeRecordingSession];
		}
	}
}

/*
 pause and resume function is added by 256 @20140408
 */
- (void)pause {
    @synchronized(self) {
        _recording = NO;
        offsetTimeIntervalPause = [startedAt timeIntervalSinceNow];
        [self pauseRecordAudio];
        NSLog(@"pasued~~~~~~~~%@ %d", startedAt, offsetTimeIntervalPause);
    }
}
- (void)resume {
    @synchronized(self) {
        if (! _recording) {
            /*
             从暂停状态恢复到录制状态，视频录制会延续暂停前的时间，即从暂停前的时间继续录制，i.e.:暂停前录制到55s，无论暂停多长时间，恢复后都从55s开始录制
             
             从暂停恢复到录制状态，需要将开始时间做偏移。此处多偏移1s，原因是恢复录制后时间会出现误差，录制暂停前的内容
             计算方法：
                1.暂停时，offsetTimeIntervalPause记录已经录制的时间
                2.继续录制，通过已经录制的时间，将当前系统时间往前推已录制时间，计算出虚拟的开始时间
             */
			startedAt = [NSDate dateWithTimeIntervalSinceNow:offsetTimeIntervalPause-1];

            offsetTimeIntervalPause = 0;
			_recording = true;
            [self resumeRecordAudio];
            
            _timeIntervalElapsed = [[NSDate date] timeIntervalSinceDate:startedAt];
            [videoWriter startSessionAtSourceTime:CMTimeMake((int)(_timeIntervalElapsed * 1000.0), 1000)];
            NSLog(@"%@ %f", startedAt, _timeIntervalElapsed);
            [self setNeedsDisplay];
		}
    }
}
-(void) writeVideoFrameAtTime:(CMTime)time {
	if (![videoWriterInput isReadyForMoreMediaData]) {
		NSLog(@"Not ready for video data");
	}
	else {
		@synchronized (self) {
            CGContextRef context = [self createBitmapContext];
            CGImageRef cgImage = CGBitmapContextCreateImage(context);
//            UIImage* background = [UIImage imageWithCGImage: cgImage];
//            CGImageRelease(cgImage);
//			UIImage* newFrame = self.currentScreen;
			CVPixelBufferRef pixelBuffer = NULL;
//			CGImageRef cgImage = CGImageCreateCopy([newFrame CGImage]);
			CFDataRef image = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
			
			CVReturn status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, avAdaptor.pixelBufferPool, &pixelBuffer);
			if(status != kCVReturnSuccess){
				//could not get a buffer from the pool
				NSLog(@"Error creating pixel buffer:  status=%d", status);
			}
			// set image data into pixel buffer
			CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
			uint8_t* destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
			CFDataGetBytes(image, CFRangeMake(0, CFDataGetLength(image)), destPixels);  //XXX:  will work if the pixel buffer is contiguous and has the same bytesPerRow as the input data
			if(status == kCVReturnSuccess){
				BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
				if (!success)
					NSLog(@"Warning:  Unable to write buffer to video");
			}
			
			//clean up
			CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
			CVPixelBufferRelease( pixelBuffer );
			CFRelease(image);
			CGImageRelease(cgImage);
		}
		
	}
	
}

#pragma mark -
#pragma mark - Audio
- (void)startRecordAudio {
    
    //Begin the recording session.
    //Error handling removed.  Please add to your own code.
    
    //Setup the dictionary object with all the recording settings that this
    //Recording sessoin will use
    //Its not clear to me which of these are required and which are the bare minimum.
    //This is a good resource: http://www.totodotnet.net/tag/avaudiorecorder/
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    
    [recordSetting setValue:[NSNumber numberWithFloat:44110] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    //Now that we have our settings we are going to instanciate an instance of our recorder instance.
    //Generate a temp file for use by the recording.
    //This sample was one I found online and seems to be a good choice for making a tmp file that
    //will not overwrite an existing one.
    //I know this is a mess of collapsed things into 1 call.  I can break it out if need be.
    recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    NSLog(@"Using File called: %@",recordedTmpFile);
    //Setup the recorder to use this file and record to it.
    NSError *error;

    recorder = [[AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.
    //Found this in antother example, but Im fuzzy on this still.
    [recorder setDelegate:self];
    //We call this to start the recording process and initialize
    //the subsstems so that when we actually say "record" it starts right away.
    [recorder prepareToRecord];
    //Start the actual Recording
    [recorder record];
    //There is an optional method for doing the recording for a limited time see
    //[recorder recordForDuration:(NSTimeInterval) 10]
}

- (void)pauseRecordAudio {
    [recorder pause];
}
- (void)resumeRecordAudio {
    [recorder record];
}

- (void)play_button_pressed{
    
    //The play button was pressed...
    //Setup the AVAudioPlayer to play the file that we just recorded.
    NSError *error;

    AVAudioPlayer * avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedTmpFile error:&error];
    [avPlayer prepareToPlay];
    [avPlayer play];
    
}

- (void)removeAudioFile {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //Clean up the temp file.
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError *error;

    [fm removeItemAtPath:[recordedTmpFile path] error:&error];
    //Call the dealloc on the remaining objects.
//    [recorder dealloc];
    recorder = nil;
    recordedTmpFile = nil;
}

#pragma mark -
#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
}

#pragma mark -
#pragma mark -
-(void)mixAudio:(NSString*)audio withVideo:(NSString*)video {
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL URLWithString:audio] options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", video]] options:nil];
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionCommentaryTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                        ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    NSString* videoName = [NSString stringWithFormat:@"outputMovie_%@.mov", [NSString currentTime]];
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        // remove audio recoreded
        [self removeAudioFile];
        
        NSString *path = [exportUrl path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (path)) {
            NSLog(@"Path:%@",path);
            UISaveVideoAtPathToSavedPhotosAlbum (path, self, @selector(video:didFinishSavingWithError:contextInfo:), (__bridge void *)(path));
        }
    }];
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    id delegateObj = self.delegate;
    if (!error) {
        if ([delegateObj respondsToSelector:@selector(processFinish:)]) {
            [delegateObj performSelectorOnMainThread:@selector(processFinish:) withObject:[NSURL fileURLWithPath:videoPath] waitUntilDone:YES];
        }
    } else {
        if ([delegateObj respondsToSelector:@selector(processFailed:)]) {
            [delegateObj performSelectorOnMainThread:@selector(processFailed:) withObject:error waitUntilDone:YES];
        }
    }
}

@end