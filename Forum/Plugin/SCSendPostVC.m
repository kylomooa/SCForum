//
//  SCSendPostVC.m
//  BaitingMember
//
//  Created by 管理员 on 2017/4/7.
//  Copyright © 2017年 Goose. All rights reserved.
//

#import "SCSendPostVC.h"
#import "DFPlainGridImageView.h"
#import "SCCurrentColumnView.h"
#import "JFImagePickerController.h"
#import "SCBGRecordImageViewVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ImageGridWidth [UIScreen mainScreen].bounds.size.width*0.7

@interface SCSendPostVC () <DFPlainGridImageViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate, JFImagePickerDelegate>
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) UITextView *contentView;

@property (nonatomic, strong) SCCurrentColumnView *columnView;

@property (nonatomic, strong) UIView *mask;

@property (nonatomic, strong) UILabel *placeholder;

@property (nonatomic, strong) DFPlainGridImageView *gridView;

@property (nonatomic, strong) UIImagePickerController *pickerController;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation SCSendPostVC

- (instancetype)initWithImages:(NSArray *) images
{
    self = [super init];
    if (self) {
        _images = [NSMutableArray array];
        if (images != nil) {
            [_images addObjectsFromArray:images];
            [_images addObject:[UIImage imageNamed:@"AlbumAddBtn"]];
        }
    }
    return self;
}

- (void)dealloc
{
    
    [_mask removeGestureRecognizer:_panGestureRecognizer];
    [_mask removeGestureRecognizer:_tapGestureRecognizer];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = WHITE_COLOR;
    if ([self leftBarButtonItem] != nil) {
        self.navigationItem.leftBarButtonItem = [self leftBarButtonItem];
    }
    
    
    if ([self rightBarButtonItem] != nil) {
        self.navigationItem.rightBarButtonItem = [self rightBarButtonItem];
    }
    [self initView];
    
}

-(void) initView
{
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat labelX, labelY, labelWidth, LabelHeight;
    labelX = 0;
    labelY = 0;
    labelWidth = self.view.frame.size.width;
    LabelHeight = 48;
    _columnView = [[SCCurrentColumnView alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, LabelHeight)];
    [self.view addSubview:_columnView];
    
    CGFloat x, y, width, heigh;
    x=10;
    y=74;
    width = self.view.frame.size.width -2*x;
    heigh = 100;
    _contentView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, heigh)];
    _contentView.scrollEnabled = YES;
    _contentView.delegate = self;
    _contentView.font = [UIFont systemFontOfSize:17];
    //_contentView.layer.borderColor = [UIColor redColor].CGColor;
    //_contentView.layer.borderWidth =2;
    [self.view addSubview:_contentView];
    
    //placeholder
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(x+5, y+5, 150, 25)];
    _placeholder.text = @"这一刻的想法...";
    _placeholder.font = [UIFont systemFontOfSize:14];
    _placeholder.textColor = [UIColor lightGrayColor];
    _placeholder.enabled = NO;
    [self.view addSubview:_placeholder];
    
    
    _gridView = [[DFPlainGridImageView alloc] initWithFrame:CGRectZero];
    _gridView.delegate = self;
    [self.view addSubview:_gridView];
    
    
    _mask = [[UIView alloc] initWithFrame:self.view.bounds];
    _mask.backgroundColor = [UIColor clearColor];
    _mask.hidden = YES;
    [self.view addSubview:_mask];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    [_mask addGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    [_mask addGestureRecognizer:_tapGestureRecognizer];
    
    
    
    [self refreshGridImageView];
}

-(void) refreshGridImageView
{
    CGFloat x, y, width, heigh;
    x=10;
    y = CGRectGetMaxY(_contentView.frame)+10;
    width  = ImageGridWidth;
    heigh = [DFPlainGridImageView getHeight:_images maxWidth:width];
    _gridView.frame = CGRectMake(x, y, width, heigh);
    [_gridView updateWithImages:_images];
}

-(UIBarButtonItem *)leftBarButtonItem
{
//    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    CGSize titleSize = [SCTools sizeOfStr:NSLocalizedString(@"取消", nil) withFont:[UIFont systemFontOfSize:15] withMaxWidth:SCREEN_WIDTH*0.5 withLineBreakMode:NSLineBreakByTruncatingTail];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, 30)];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor darkGrayColor];
    [btn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn]; //[UIBarButtonItem text:@"取消" selector:@selector(cancel) target:self];
}

-(UIBarButtonItem *)rightBarButtonItem
{
//    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"发送", nil) style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
    //return [UIBarButtonItem text:@"发送" selector:@selector(send) target:self];
}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) send
{
    if (_delegate && [_delegate respondsToSelector:@selector(onSendTextImage:images:)]) {
        
        [_images removeLastObject];
        [_delegate onSendTextImage:_contentView.text images:_images];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void) onPanAndTap:(UIGestureRecognizer *) gesture
{
    _mask.hidden = YES;
    [_contentView resignFirstResponder];
}



#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![text isEqualToString:@""])
    {
        _placeholder.hidden = YES;
    }else if ([text isEqualToString:@""] && range.location == 0 && range.length == 1)
    {
        _placeholder.hidden = NO;
        
    }
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _mask.hidden = NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _mask.hidden = YES;
}

#pragma mark - DFPlainGridImageViewDelegate

-(void)onClick:(NSUInteger)index
{
    
    if (_images.count <= 6 && index == _images.count-1) {
        [self chooseImage];
    }else{
        

    }
}


-(void)onLongPress:(NSUInteger)index
{
    
    if (_images.count <6 && index == _images.count-1) {
        return;
    }
    
    
    
}

-(void) chooseImage
{
    
    [self selectHeadImageFromCameraOrLibrary];
    
    
    
}

#pragma mark - actionsheet的委托
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 0:
                return;
            case 1: //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 2: //相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
        }
    } else {
        if (buttonIndex == 0) {
            return;
        } else {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    //如果当前分组已满六张照片，弹框提示
    if(self.images.count>=6 && ![[self.images lastObject] isEqual:[UIImage imageNamed:@"AlbumAddBtn"]] ){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"该档案类型照片已满6张", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles: nil, nil];
        [alertView show];
        return;
    }
    // 跳转到相机或相册页面
    if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        JFImagePickerController *picker = [[JFImagePickerController alloc]initWithRootViewController:nil];
        
        int maxCount = 6 - self.images.count;
        
        [JFImagePickerController clear];
        
        ASSETHELPER.maxCount = maxCount;
        picker.pickerDelegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        if (!_pickerController) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            imagePickerController.sourceType = sourceType;
            _pickerController = imagePickerController;
        }
        [self presentViewController:_pickerController animated:YES completion:^{
        }];
    }
}

#pragma mark - 图片选择完成JFImagePickerDelegate
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    NSMutableArray *currentImageDataArray;
    
    NSArray *assetsArray = picker.assets;
    if (assetsArray.count) {
        
    }
    
    NSMutableArray *tempSelectedArray = [NSMutableArray array];
    for (int i = 0;  i < assetsArray.count; i++) {
        //添加本次相册选中图片到临时数组
        //使用字典保存的原因是区分拍照图片还是相册图片
        ALAsset *asset = assetsArray[i];
        UIImage *result = [ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_SCREEN_SIZE];
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        [tempDict setObject:result forKey:@"image"];
        [tempDict setObject:[NSNumber numberWithInt:i]forKey:@"index"];
        [tempSelectedArray addObject:tempDict];
        
        [self.images addObject:result];
    }
    //添加本次选中图片到选中图片数组
    [currentImageDataArray addObjectsFromArray:tempSelectedArray];
    [self imagePickerDidCancel:picker];
    [self refreshGridImageView];
}
- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 从相册或者相机选取头像
/**
 *  从相机或者系统“照片”应用中选取图片
 */
-(void)selectHeadImageFromCameraOrLibrary{
    //首先需要弹出actionsheet让用户选择是从相册还是相机选取图片
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"取消", @"取消") otherButtonTitles:NSLocalizedString(@"从相册选择", @"从相册选择"), NSLocalizedString(@"拍照",@"拍照"), nil];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"取消", @"取消") otherButtonTitles:NSLocalizedString(@"从相册选择", @"从相册选择"), nil];
    }
    //显示actionsheet
    [actionSheet showInView:self.view];
}


-(void) takePhoto
{
    _pickerController = [[UIImagePickerController alloc] init];
    _pickerController.delegate = self;
    _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:_pickerController animated:YES completion:nil];
}

-(void) pickFromAlbum
{
    
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [_images insertObject:image atIndex:(_images.count-1)];
    if (_images.count>6) {
        [_images removeLastObject];
    }
    
    [self refreshGridImageView];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
