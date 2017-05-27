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
#import "SCColumnListShowView.h"
#import "SDPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+SCEmoji.h"


#define ImageGridWidth [UIScreen mainScreen].bounds.size.width*0.7
static const NSInteger maxImageNum=6;

@interface SCSendPostVC () <DFPlainGridImageViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate, JFImagePickerDelegate, SCColumnViewDelegate, SCColumnListShowDelegate, SDPhotoBrowserDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, readonly) UIImage *albumAddBtnImage; //加号按钮image

@property (nonatomic, strong) UITextView *contentView;

@property (nonatomic, strong) SCCurrentColumnView *columnView;

@property (nonatomic, strong) SCColumnListShowView *columnListview;


@property (nonatomic, strong) UIView *mask;

@property (nonatomic, strong) UILabel *placeholder;

@property (nonatomic, strong) DFPlainGridImageView *gridView;

@property (nonatomic, strong) UIImagePickerController *pickerController;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSMutableArray *keysArray;

//提示字数2000最大
@property (nonatomic, strong) UILabel *Tiplabel;

@end

@implementation SCSendPostVC

-(UILabel *)Tiplabel{
    if (nil == _Tiplabel) {
        _Tiplabel = [[UILabel alloc]init];
        _Tiplabel.text = @"0/2000";
        _Tiplabel.textColor = WEBRBGCOLOR(0x888888);
    }
    return _Tiplabel;
}

- (instancetype)initWithImages:(NSArray *) images
{
    self = [super init];
    if (self) {
        _images = [NSMutableArray array];
        if (images != nil) {
            [_images addObjectsFromArray:images];
            [_images addObject:self.albumAddBtnImage];
        }
    }
    return self;
}

- (void)dealloc
{
    
    [_mask removeGestureRecognizer:_panGestureRecognizer];
    [_mask removeGestureRecognizer:_tapGestureRecognizer];
    
    [self.columnListview hide];
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
    _columnView.delegate = self;
    [_columnView resetColumnBtnTitle:[self.columnArray objectAtIndex:self.index]];

    [self.view addSubview:_columnView];
    
    CGFloat x, y, width, heigh;
    x=10;
    y=CGRectGetMaxY(_columnView.frame) + 5; //74;
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
    _placeholder.text = @"发表你的想法...";
    _placeholder.font = [UIFont systemFontOfSize:14];
    _placeholder.textColor = [UIColor lightGrayColor];
    _placeholder.enabled = NO;
    [self.view addSubview:_placeholder];
    
    
    _gridView = [[DFPlainGridImageView alloc] initWithFrame:CGRectZero];
    _gridView.delegate = self;
    [self.view addSubview:_gridView];
    
    
    [self.view addSubview:self.Tiplabel];
    [self.Tiplabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentView.bottom).offset(10);
        make.right.equalTo(_contentView.right);
    }];
    
    _mask = [[UIView alloc] initWithFrame:self.view.bounds];
    _mask.backgroundColor = [UIColor clearColor];
    _mask.hidden = YES;
    [self.view addSubview:_mask];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    [_mask addGestureRecognizer:_panGestureRecognizer];
    //_panGestureRecognizer.maximumNumberOfTouches = 1;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPanAndTap:)];
    //[_mask addGestureRecognizer:_tapGestureRecognizer];
    
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
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(UIBarButtonItem *)rightBarButtonItem
{
//    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"发送", nil) style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //[btn setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"send_post"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(void) cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadImageToQNFilePath:(NSString *)filePath andUploadToken:(NSString *)token{

    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);
    }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:nil];
    
    [upManager putFile:filePath key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
        [self.keysArray addObject:resp[@"key"]];
        
        if (self.keysArray.count == [self getValidImages].count) {
            //开始发帖
            [SCForumPost getForumPost:self.user.userId cateId:self.cateIdArray[_index] content:self.contentView.text images:self.keysArray success:^(NSArray *objects) {
                [self hideHud];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSendPostSuccess object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSError *error) {
                [self hideHud];
                [self showHint:@"发送失败，请稍候尝试"];
            }];
        }
    }
                option:uploadOption];
}

#pragma mark - 移除添加按钮图片后的有效图片
-(NSMutableArray *)getValidImages
{
    NSMutableArray *valid = [NSMutableArray array];
    [valid addObjectsFromArray:_images];
    while ([[valid lastObject] isEqual:self.albumAddBtnImage]) {
        [valid removeLastObject];
    }
    return valid;
}

-(void) send
{
    [self.view endEditing:YES];

    if (self.contentView.text.length < 15) {
        [self showHint:@"请最少输入15字" yOffset:-150];
        return;
    }
    
    if (self.contentView.text.length > 2000) {
        [self showHint:@"已超过2000字" yOffset:-150];
        return;
    }
    
    //暂时过滤表情，接口不支持
    if ([NSString stringContainsEmoji:self.contentView.text]) {
        [self showHint:@"输入有误，请输入文字！" yOffset:-150];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(onSendTextImage:images:tid:)]) {
        [self.delegate onSendTextImage:self.contentView.text images:[self getValidImages] tid:self.cateIdArray[_index]];
    }

    [self showHudInView:self.view hint:@"请稍候..."];
    if ([self getValidImages].count == 0) {
        //开始发帖
        [SCForumPost getForumPost:self.user.userId cateId:self.cateIdArray[_index] content:self.contentView.text images:[NSArray array] success:^(NSArray *objects) {
             [[NSNotificationCenter defaultCenter] postNotificationName:kSendPostSuccess object:nil];
            [self hideHud];
            [self dismissViewControllerAnimated:YES completion:nil];

        } failure:^(NSError *error) {
            [self hideHud];
            [self showHint:@"发送失败，请稍候尝试" yOffset:-150];
        }];

    }else{
        [SCQiniuToken getUploadTokenSuccess:^(SCObject *object) {
            SCQiniuToken *token = (SCQiniuToken *)object;
            [[self getValidImages] enumerateObjectsUsingBlock:^(UIImage  *image, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [self uploadImageToQNFilePath:[self getImagePath:image] andUploadToken:token.uploadToken];
            }];

        } failure:^(NSError *error) {
            [self showHint:@"发送失败，请稍候尝试" yOffset:-150];
        }];
    }

}
//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)Image {
    NSString *filePath = nil;
    
    NSData *data=[SCTools compressOriginalImage:Image toMaxDataSizeKBytes:100]; //压缩图片100k
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
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
    }else if ([text isEqualToString:@""] && range.location == 0 && range.length == 1 && textView.text.length<=1)
    {
        _placeholder.hidden = NO;
        
    }
    
    self.Tiplabel.text = [NSString stringWithFormat:@"%u/2000",textView.text.length +  text.length];
    
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
    
    if (_images.count <= maxImageNum && index == _images.count-1 && [[_images objectAtIndex:index] isEqual:self.albumAddBtnImage]) {
        [self chooseImage];
    }else{
        NSUInteger count;
        if([[_images lastObject] isEqual:self.albumAddBtnImage]){
            count = _images.count - 1;
        }else{
            count = _images.count;
        }
        
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.shouldShowDeleteBtn = YES;
        browser.currentImageIndex = index;
        browser.sourceImagesContainerView = _gridView;
        browser.imageCount = count;
        browser.delegate = self;
        [browser show];

    }
}


-(void)onLongPress:(NSUInteger)index
{
    
    if (_images.count <maxImageNum && index == _images.count-1) {
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
    if(self.images.count>=maxImageNum && ![[self.images lastObject] isEqual:self.albumAddBtnImage]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"照片已选满6张", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles: nil, nil];
        [alertView show];
        return;
    }
    // 跳转到相机或相册页面
    if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:nil];
        
        NSInteger maxCount = (maxImageNum + 1) - self.images.count;
        
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
        
        [self.images insertObject:result atIndex:(_images.count-1)];
    }
    
    while (_images.count>maxImageNum) {
        [_images removeLastObject];
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


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [_images insertObject:image atIndex:(_images.count-1)];
    if (_images.count>maxImageNum) {
        [_images removeLastObject];
    }
    
    [self refreshGridImageView];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - protocol SCColumnListShowDelegate <NSObject>

-(void)clickListAtIndex:(NSInteger)index
{
    
    self.index = index;
    [_columnListview hide];
    [self.columnView resetColumnBtnTitle:[self.columnArray objectAtIndex:index]];
}

#pragma mark - protocol SCColumnViewDelegate <NSObject>
-(void) onColumnBtnClick:(id)sender;
{
    if ([self.view.subviews containsObject:_columnListview]){
        [_columnListview hide];
        return;
    }
    
    [self.view endEditing:YES];
    CGRect bound = self.columnView.frame;
    CGRect btnFrame = self.columnView.columnButton.frame;
    CGFloat width, height;
    //最大宽度
    NSString *longest = [self longestColumnTitle];
    CGFloat tempWidth = [SCTools sizeOfStr:longest withFont:[UIFont systemFontOfSize:16] withMaxWidth:SCREEN_WIDTH-btnFrame.origin.x-40 withLineBreakMode:NSLineBreakByTruncatingTail].width;
    width = tempWidth + 40; //btnFrame.size.width+10;
    //最大展示5个半
    CGFloat i=5.5;
    if (self.columnArray.count<i) {
        i=self.columnArray.count;
    }
    height = 44*i;
    if (!_columnListview) {
        _columnListview = [[SCColumnListShowView alloc] initWithFrame:CGRectMake(btnFrame.origin.x, CGRectGetMaxY(bound) - 2, width, height) columnArray:self.columnArray];
    }else{
        _columnListview.frame = CGRectMake(btnFrame.origin.x, CGRectGetMaxY(bound) - 2, width, height);
    }
    _columnListview.delegate = self;
    [_columnListview showInView:self.view];
}

-(NSString *)longestColumnTitle{
    if (self.columnArray.count) {
        NSString *retStr = [self.columnArray firstObject];
        for (NSString *str in self.columnArray) {
            if (str.length > retStr.length) {
                retStr = str;
                continue;
            }
        }
        return retStr;
    }else{
        return nil;
    }
    
}

#pragma mark - SDPhotoBrowserDelegate
-(void)photoWillBeRemoved:(NSInteger)index{
    if (index < self.images.count && ![[self.images objectAtIndex:index] isEqual:self.albumAddBtnImage]) {
        [self.images removeObjectAtIndex:index];
        //如果已经加满，再删的话，要把加图片的图片加上去
        if (self.images.count<maxImageNum && ![[self.images lastObject] isEqual:self.albumAddBtnImage]) {
            [self.images addObject:self.albumAddBtnImage];
        }
        [self refreshGridImageView];
    }
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImage *image= self.images[index];
    return image;
}


#pragma mark - 懒加载
-(UIImage *)albumAddBtnImage{
    static UIImage *addImage;
    static dispatch_once_t myonce;
    dispatch_once(&myonce, ^{
        NSLog(@"%s called once", __func__);
        addImage = [UIImage imageNamed:@"AlbumAddBtn"];
    });
    return addImage;
}

-(NSMutableArray *)columnArray
{
    if (!_columnArray) {
        _columnArray = [NSMutableArray array];
    }
    return _columnArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)keysArray{
    if (nil == _keysArray) {
        _keysArray = [NSMutableArray array];
    }
    return _keysArray;
}



@end
