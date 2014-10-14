//
//  ViewController.m
//  SocketDemo0
//
//  Created by jianleer on 14-10-14.
//  Copyright (c) 2014年 jianleer. All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"



#define SERVER_CONNECT_END 0
#define SERVER_CONNECT_SUCCESS 1
#define SERVER_CONNECT_FAILE 2

#define HOST_IP @"127.0.0.1"
#define HOST_PORT1 8888
@interface ViewController ()<AsyncSocketDelegate>{
    //1.1 声明asysncsocket 对象
    AsyncSocket     *_clientSocket;
    
    UITextField*_tf;
}
@property(nonatomic,strong)AsyncSocket  *clientSocket;

-(int)connectServer:(NSString*)hostIP port:(int)hostPort;
-(void)showMessage:(NSString*)msg;

@end

@implementation ViewController

@synthesize clientSocket = _clientSocket;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initView];
}
-(void)initView{
    
    
    
    UIButton*button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"联机" forState:normal];
    [button addTarget:self action:@selector(connectServer:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(80, 150, 60, 44);
    [self.view addSubview:button];
    
    
    UIButton*button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setTitle:@"发消息" forState:normal];
    [button1 addTarget:self action:@selector(sendMessageToServer:) forControlEvents:UIControlEventTouchUpInside];
    button1.frame = CGRectMake(220,150, 60, 44);
    [self.view addSubview:button1];
    
    
    
    
    UITextField*tf = [[UITextField alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width - 100, 44)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.placeholder = @"请输入内容";
   // tf.backgroundColor = [UIColor brownColor];
    [self.view addSubview:tf];
    _tf = tf;
    
    
    
    
}

-(void)sendMessageToServer:(id)sender
{
    
    NSLog(@"联机");
    NSString*str =_tf.text;
    NSData*data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [_clientSocket writeData:data withTimeout:-1 tag:0];
    _tf.text = @"";
}



-(void)connectServer:(id)sender
{
    NSLog(@"发消息");
    int stat = [self connectServer:HOST_IP port:HOST_PORT1];
    switch (stat) {
        case SERVER_CONNECT_SUCCESS:
        {
            [self showMessage:@"connect success"];
            break;
        }
            case SERVER_CONNECT_END:
        {
            [self showMessage:@"It's connect,don't agian"];
            break;
        }
            case SERVER_CONNECT_FAILE:
        {
            [self showMessage:@"connect failed"];
            break;
        }
        default:
            break;
    }
    
    
}




-(int)connectServer:(NSString *)hostIP port:(int)hostPort{
    NSLog(@"创建或读取");
    //如果没有创建socket则创建socket
    if (!_clientSocket) {
        //1.2 创建socket
        _clientSocket = [[AsyncSocket alloc] initWithDelegate:self];
        NSError*error = nil;
        //1.3联机
        BOOL ret = [_clientSocket connectToHost:hostIP onPort:hostPort error:&error];
        if (!ret) {
            NSLog(@"%ld,%@",[error code],error.localizedDescription);
            return SERVER_CONNECT_FAILE;
        }else
        {
            NSLog(@"Connect OK!");
            return SERVER_CONNECT_SUCCESS;
        }
    }else
    {
        //有socket等待读取Socket
        [_clientSocket readDataWithTimeout:-1 tag:0];
        NSLog(@"Connect end");
        return SERVER_CONNECT_END;
    }
    
}

-(void)showMessage:(NSString *)msg{
    NSLog(@"-------%@--------",msg);
}




#pragma mark AsySocket Delegate
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    NSLog(@"链接到主机");
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"Error : %@",err.localizedDescription);
    NSLog(@"链接发生错误");
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"连接失败");
    self.clientSocket = nil;
}

-(void)onSocket:(AsyncSocket*)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"得到数据");
    NSString*aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Have received Datasheetis:%@",aStr);
    [sock readDataWithTimeout:-1 tag:0];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





















