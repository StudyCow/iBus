//
//  PublishBaseController.m
//  iBus-iPhone
//
//  Created by yanghua on 6/22/13.
//  Copyright (c) 2013 yanghua. All rights reserved.
//

#import "PublishBaseController.h"

typedef enum{
    TAG_TOOLBAR_PHOTO,
	TAG_TOOLBAR_CAMERA,
	TAG_TOOLBAR_LBSPOSITION,
	TAG_TOOLBAR_AT,
	TAG_TOOLBAR_TOPIC
}TAGS;

typedef enum {
    TAG_CLICKED_LABEL_CLEAR,
    TAG_CLICKED_LABEL_IMGSWITCH,
}TAGS_OF_CLICKED_LABEL;

typedef enum{
    ACTION_TYPE_PUBLISHINGCONTENT,
    ACTION_TYPE_PHOTO
}ACTION_TYPE;

@interface PublishBaseController ()

@property (nonatomic,retain) UIView                 *tipbarView;
@property (nonatomic,retain) UIView                 *toolbarView;
@property (nonatomic,retain) ClickableLabel         *strLengthLabel;
@property (nonatomic,retain) UIButton               *delBtn;

@property (nonatomic,assign) ACTION_TYPE            currentActionType;




@end

@implementation PublishBaseController

- (void)dealloc{
    [_photoArray release],_photoArray=nil;
    [_strLengthLabel release];
    [_publishTxtView release];
    [_tipbarView release];
    [_toolbarView release];
    [_followedList release],_followedList=nil;
    [_publishingContent release],_publishingContent=nil;
    
    [Default_Notification_Center removeObserver:self
                                           name:Notification_For_AtSomebody
                                         object:nil];
    
    [Default_Notification_Center removeObserver:self];
    
	[super dealloc];
}

- (void)loadView{
    self.view=[[[UIView alloc] initWithFrame:Default_TableView_Frame] autorelease];
    self.view.backgroundColor=Default_TableView_BackgroundColor;
    
    [self layoutSubViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:self.publishTxtView];
	[self.view addSubview:self.tipbarView];
	[self.tipbarView addSubview:self.strLengthLabel];
	[self.tipbarView addSubview:self.delBtn];
	[self.view addSubview:self.toolbarView];
    
	
    [self setLeftBarButtonForNavigationBar];
    [self setRightBarButtonForNavigationBar];
    
    [self registerKeyboardNotification];
    [self registerAtNotification];
    [self.publishTxtView becomeFirstResponder];
    
    self.imageSwitch=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.publishTxtView.text=Default_Fill_Txt;
    [self textViewDidChange:self.publishTxtView];
}

#pragma mark - private methods -
- (void)toolBarBotton_touchUpInside:(id)sender{
	UIButton *clickedBtn=(UIButton*)sender;
	switch(clickedBtn.tag){
        case TAG_TOOLBAR_PHOTO:
        {
            
        }
            break;
            
		case TAG_TOOLBAR_CAMERA:
		{
            
		}
			break;
			
		case TAG_TOOLBAR_LBSPOSITION:
		{
			
		}
			break;
			
		case TAG_TOOLBAR_AT:
		{
			if([self.delegate respondsToSelector:@selector(atBtn_handle:)]){
				[self.delegate atBtn_handle:sender];
			}
            
		}
			break;
			
		case TAG_TOOLBAR_TOPIC:
		{
			
		}
			break;
	}
}


- (void)layoutSubViews{
    
    //文本输入框（带占位符）
    _publishTxtView=[[UIPlaceHolderTextView alloc] initWithFrame:Publish_TextView_Frame];
    _publishTxtView.backgroundColor=[UIColor whiteColor];
    _publishTxtView.placeholder=@"说点什么吧...";
    _publishTxtView.delegate=self;
    [_publishTxtView setFont:[UIFont fontWithName:@"Arial"
                                             size:Publish_TextView_FontSize]];
    
    CGFloat X_tipbarView=_publishTxtView.frame.origin.x;
    CGFloat y_tipbarView=_publishTxtView.frame.origin.y+_publishTxtView.frame.size.height;
    
    _tipbarView=[[UIView alloc]initWithFrame:CGRectMake(X_tipbarView, y_tipbarView, _publishTxtView.frame.size.width, Tip_View_Height)];
    _tipbarView.backgroundColor=[UIColor whiteColor];
    
    //设置提示字符数的Label
    CGFloat x_lbl=_tipbarView.frame.origin.x+_tipbarView.frame.size.width-60;
    CGFloat y_lbl=0;
    
    //输入字符提示
    _strLengthLabel=[[ClickableLabel alloc]initWithFrame:CGRectMake(x_lbl, y_lbl, 33, 25)];
    [_strLengthLabel setLblDelegate:self];
    _strLengthLabel.textColor=ColorWithRGBA(105, 105, 105, 1.0);
    _strLengthLabel.text=[NSString stringWithFormat:@"%d",STRLENGTH];
    _strLengthLabel.textAlignment=NSTextAlignmentLeft;
    _strLengthLabel.tag=TAG_CLICKED_LABEL_CLEAR;
    
    //删除按钮图片
    _delBtn=[UIButton initButtonInstanceWithType:UIButtonTypeCustom frame:CGRectMake(x_lbl+self.strLengthLabel.frame.size.width, 5, 16, 16)
                                         imgName:@"deleteBtn.png"
                                     eventTarget:self
                                     touchUpFunc:@selector(doClickAtTarget:)
                                   touchDownFunc:nil];
    
    _delBtn.hidden=YES;
    
    CGFloat x_toolBarView=_publishTxtView.frame.origin.x;
    CGFloat y_toolBarView=_publishTxtView.frame.origin.y+_publishTxtView.frame.size.height+_tipbarView.frame.size.height+4;
    _toolbarView=[[UIView alloc]initWithFrame:CGRectMake(x_toolBarView, y_toolBarView, _publishTxtView.frame.size.width, Tool_View_Height)];
    
    
    //----------------------toolBar items------------------
    
    //@ 按钮
    _atBtn=[UIButton initButtonInstanceWithType:UIButtonTypeCustom
                                          frame:At_Button_Frame
                                        imgName:@"atBtn.png"
                                    eventTarget:self
                                    touchUpFunc:@selector(toolBarBotton_touchUpInside:)
                                  touchDownFunc:nil];
    _atBtn.tag=TAG_TOOLBAR_AT;
    [self.toolbarView addSubview:self.atBtn];
    
    //image switch
    _checkboxBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.checkboxBtn.frame=CheckBox_Button_Frame;
    [self.checkboxBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateNormal];
    [self.checkboxBtn addTarget:self
                         action:@selector(checkBox_Button_touchUpInside:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView addSubview:self.checkboxBtn];
    
    //tip lbl
    _imgTipLbl=[[[ClickableLabel alloc] initWithFrame:Imgtip_Label_Frame] autorelease];
    self.imgTipLbl.text=@"附带应用二维码图片";
    self.imgTipLbl.font=[UIFont systemFontOfSize:Imgtip_Label_FontSize];
    self.imgTipLbl.textColor=[UIColor grayColor];
    self.imgTipLbl.backgroundColor=[UIColor clearColor];
    self.imgTipLbl.tag=TAG_CLICKED_LABEL_IMGSWITCH;
    [self.imgTipLbl setLblDelegate:self];
    [self.toolbarView addSubview:self.imgTipLbl];
    
}

#pragma mark - UITextViewDelegate -
-(void)textViewDidChange:(UITextView *)textView{
	int avaliableStrLength=STRLENGTH-[self.publishTxtView.text length];
	if (avaliableStrLength<=20&&avaliableStrLength>0) {
		self.strLengthLabel.textColor=[UIColor redColor];
	}else if (avaliableStrLength<=0) {
		avaliableStrLength=0;
		self.publishTxtView.text=[self.publishTxtView.text substringToIndex:STRLENGTH];
	}else {
		self.strLengthLabel.textColor=[UIColor blackColor];
	}
	
	self.strLengthLabel.text=[NSString stringWithFormat:@"%d",avaliableStrLength];
    
    if ([self.strLengthLabel.text isEqualToString:@"140"]) {
        self.delBtn.hidden=YES;
    }else{
        self.delBtn.hidden=NO;
    }
}

#pragma mark -
#pragma mark Click Event Delegate
-(void)doClickAtTarget:(ClickableLabel *)label{
    
    switch (label.tag) {
        case TAG_CLICKED_LABEL_CLEAR:
        {
            if ([self.publishTxtView.text length]==0) {
                return;
            }
            
            self.currentActionType=ACTION_TYPE_PUBLISHINGCONTENT;
            UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@""
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:@"清空所有內容"
                                                          otherButtonTitles:nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            [actionSheet release];
        }
            break;
            
        case TAG_CLICKED_LABEL_IMGSWITCH:
        {
            [self checkBox_Button_touchUpInside:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            switch (self.currentActionType) {
                case ACTION_TYPE_PUBLISHINGCONTENT:    //点击清除文字
                    [self clearInputFromTextView];
                    break;
                    
                case ACTION_TYPE_PHOTO:                //点击缩略图按钮,同时查看原图
                {
                    
                }
                    break;
                default:
                    break;
            }
            
            break;
            
        case 1:
            switch (self.currentActionType) {
                case ACTION_TYPE_PUBLISHINGCONTENT:
                    break;
                    
                case ACTION_TYPE_PHOTO:                //取消图片选择
                {
                    
                }
                    break;
            }
            break;
            
        case 2:
            break;
    }
}

#pragma mark - about navigationItem Button -
-(void)setLeftBarButtonForNavigationBar{
    UIButton *btn=[UIButton initButtonInstanceWithType:UIButtonTypeCustom
                                                 frame:CGRectMake(0, 0, 30, 30)
                                               imgName:@"closeBtn.png"
                                           eventTarget:self
                                           touchUpFunc:@selector(closeButton_touchUpInside)
                                         touchDownFunc:nil];
	
	UIBarButtonItem *backBarItem=[[UIBarButtonItem alloc]initWithCustomView:btn];
	self.navigationItem.leftBarButtonItem=backBarItem;
	[backBarItem release];
}

-(void)closeButton_touchUpInside{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)setRightBarButtonForNavigationBar{
    UIButton *btn=[UIButton initButtonInstanceWithType:UIButtonTypeCustom
                                                 frame:CGRectMake(0,0,30,30)
                                               imgName:@"sendBtn.png"
                                           eventTarget:self
                                           touchUpFunc:@selector(publish_touchUpInside:)
                                         touchDownFunc:nil];
    
	UIBarButtonItem *menuBtn=[[UIBarButtonItem alloc]initWithCustomView:btn];
	self.navigationItem.rightBarButtonItem=menuBtn;
	[menuBtn release];
}

-(void)publish_touchUpInside:(id)sender{
    if (![self.delegate respondsToSelector:@selector(publishBtn_handle:)]) {
        return;
    }
    
    if ((!self.publishTxtView)||[self.publishTxtView.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"发表内容不能为空!"];
        return;
    }
    
    [self.delegate publishBtn_handle:sender];
}


#pragma mark - other methods -
-(void)clearInputFromTextView{
    self.publishTxtView.text=@"";
    self.strLengthLabel.text=[NSString stringWithFormat:@"%d",STRLENGTH];
}

- (void)checkBox_Button_touchUpInside:(id)sender{
    if (self.imageSwitch==YES) {
        [self.checkboxBtn setBackgroundImage:[UIImage imageNamed:@"unchecked.png"]
                                    forState:UIControlStateNormal];
        self.imageSwitch=NO;
    }else{
        [self.checkboxBtn setBackgroundImage:[UIImage imageNamed:@"checked.png"]
                                    forState:UIControlStateNormal];
        self.imageSwitch=YES;
    }
}

#pragma mark - at(@) notification -
- (void)registerAtNotification{
    [Default_Notification_Center addObserver:self
                                    selector:@selector(handleAtNotification:)
                                        name:Notification_For_AtSomebody
                                      object:nil];
}

- (void)handleAtNotification:(NSNotification*)notification{
    NSDictionary *followedInfo=(NSDictionary*)[notification object];
    [self.followedList addObject:followedInfo];
    self.publishTxtView.text = [NSString stringWithFormat:@"%@ @%@",self.publishTxtView.text,followedInfo[@"userName"]];
    [self textViewDidChange:self.publishTxtView];
}

#pragma mark - keyboard notification -
- (void)registerKeyboardNotification{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    float publishTxtView_newHeight = MainHeight - NavigationBarHeight - keyboardRect.size.height - Tip_View_Height - Tool_View_Height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.publishTxtView.frame=CGRectMake(self.publishTxtView.frame.origin.x,
                                             self.publishTxtView.frame.origin.y,
                                             self.publishTxtView.frame.size.width,
                                             publishTxtView_newHeight);
        
        self.tipbarView.frame=CGRectMake(self.tipbarView.frame.origin.x,
                                         publishTxtView_newHeight,
                                         self.tipbarView.frame.size.width,
                                         Tip_View_Height);
        
        self.toolbarView.frame=CGRectMake(self.toolbarView.frame.origin.x,
                                          publishTxtView_newHeight + Tip_View_Height,
                                          self.toolbarView.frame.size.width,
                                          Tool_View_Height);
        
    }];
    
    
    
    
}


@end
