//
//  ShowTimeViewController.m
//  My520Live
//
//  Created by caobin on 16/9/5.
//  Copyright © 2016年 caobin. All rights reserved.
//

#import "ShowTimeViewController.h"
#import <LFLiveKit/LFLiveKit.h>

#define Color(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define KeyColor Color(216, 41, 116)

@interface ShowTimeViewController () <LFLiveSessionDelegate>

@property (strong, nonatomic) UIButton *beautifulBtn;
@property (strong, nonatomic) UIButton *livingBtn;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UIButton *cameraBtn;
/** RTMP地址 */
@property (nonatomic, copy) NSString *rtmpUrl;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, strong) UIView *livingPreView;

@end

@implementation ShowTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup{
    [self closeBtn];
    [self cameraBtn];
    self.beautifulBtn.layer.cornerRadius = self.beautifulBtn.frame.size.height * 0.5;
    self.beautifulBtn.layer.masksToBounds = YES;
    
    self.livingBtn.backgroundColor = KeyColor;
    self.livingBtn.layer.cornerRadius = self.livingBtn.frame.size.height * 0.5;
    self.livingBtn.layer.masksToBounds = YES;
    
    self.statusLabel.numberOfLines = 0;
    
    // 默认开启后置摄像头, 怕我的面容吓到你们了...
    self.session.captureDevicePosition = AVCaptureDevicePositionFront;
}

#pragma mark -- Property

-(UIButton *)beautifulBtn
{
    if(!_beautifulBtn) {
        _beautifulBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautifulBtn setTitle:@"智能美颜已经开启" forState:UIControlStateNormal];
        [_beautifulBtn setTitle:@"智能美颜已经关闭" forState:UIControlStateSelected];
        _beautifulBtn.titleLabel.textColor = [UIColor whiteColor];
        _beautifulBtn.backgroundColor = [UIColor lightGrayColor];
        _beautifulBtn.titleLabel.font = [UIFont systemFontOfSize:18.f];
        [_beautifulBtn setFrame:CGRectMake(5, 30, 180, 30)];
        
        [_beautifulBtn addTarget:self action:@selector(beatifulBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_beautifulBtn];
    }
    
    return _beautifulBtn;
}

-(UIButton *)livingBtn
{
    if(!_livingBtn) {
        _livingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_livingBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_livingBtn setTitle:@"结束直播" forState:UIControlStateSelected];
        [_livingBtn setTintColor:[UIColor whiteColor]];
        [_livingBtn setFrame:CGRectMake(100, 200, 150, 45)];
        [_livingBtn addTarget:self action:@selector(livingBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_livingBtn];
    }
    
    return _livingBtn;
}

-(UILabel *)statusLabel
{
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 80, 180, 30)];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.backgroundColor = [UIColor lightGrayColor];
        _statusLabel.text = @"状态：未知";
        [self.view addSubview:_statusLabel];
    }
    
    return _statusLabel;
}

-(UIButton *)closeBtn
{
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"talk_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setFrame:CGRectMake(self.view.frame.size.width - 60, 30, 40, 40)];
        [self.view addSubview:_closeBtn];
    }
    return _closeBtn;
}

-(UIButton *)cameraBtn
{
    if(!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_change"] forState:UIControlStateNormal];
        [_cameraBtn addTarget:self action:@selector(cameraBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cameraBtn setFrame:CGRectMake(self.view.frame.size.width - 120, 30, 40, 40)];
        [self.view addSubview:_cameraBtn];
    }
    return _cameraBtn;
}

- (UIView *)livingPreView
{
    if (!_livingPreView) {
        UIView *livingPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        livingPreView.backgroundColor = [UIColor clearColor];
        livingPreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:livingPreView atIndex:0];
        _livingPreView = livingPreView;
    }
    return _livingPreView;
}

- (LFLiveSession*)session{
    if(!_session){
        
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2]];
        
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration liveType:LFLiveRTMP];
         */
        
        // 设置代理
        _session.delegate = self;
        _session.running = YES;
        _session.preView = self.livingPreView;
    }
    return _session;
}

#pragma amrk -- Action
-(void)beatifulBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    // 默认是开启了美颜功能的
    self.session.beautyFace = !self.session.beautyFace;
}

-(void)livingBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) { // 开始直播
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        // 如果是跟我blog教程搭建的本地服务器, 记得填写你电脑的IP地址
        stream.url = [NSString stringWithFormat:@"rtmp://%@:%@/rtmplive/%@",_serverAddr,_serverPort,_liveName];
        stream.url = @"rtmp://192.168.1.33:1935/rtmplive/test";
        self.rtmpUrl = stream.url;
        [self.session startLive:stream];
    }else{ // 结束直播
        [self.session stopLive];
        self.statusLabel.text = [NSString stringWithFormat:@"状态: 直播被关闭\nRTMP: %@", self.rtmpUrl];
    }
}

-(void)closeBtnAction:(id)sender
{
    if (self.session.state == LFLivePending || self.session.state == LFLiveStart){
        [self.session stopLive];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cameraBtnAction:(id)sender
{
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSLog(@"切换前置/后置摄像头");
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *tempStatus;
    switch (state) {
        case LFLiveReady:
            tempStatus = @"准备中";
            break;
        case LFLivePending:
            tempStatus = @"连接中";
            break;
        case LFLiveStart:
            tempStatus = @"已连接";
            break;
        case LFLiveStop:
            tempStatus = @"已断开";
            break;
        case LFLiveError:
            tempStatus = @"连接出错";
            break;
        default:
            break;
    }
    
    self.statusLabel.text = [NSString stringWithFormat:@"状态: %@", tempStatus/*self.rtmpUrl*/];
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo{
    
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    
}

@end
