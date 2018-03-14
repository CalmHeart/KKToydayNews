//
//  KKArticleSmallCorverCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKArticleSmallCorverCell.h"

#define space 5.0
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define imageWidth ((KKTitleWidth - 2 * space) / 3.0)
#define imageHeight (imageWidth * 3 / 4)
#define splitViewHeight 5

@interface KKArticleSmallCorverCell ()
@property(nonatomic,strong)UIView *imageContentView;
@property(nonatomic,strong)UILabel *dateLabel;
@property(nonatomic,weak)KKPersonalSummary *summary;

@end

@implementation KKArticleSmallCorverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.imageContentView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.dateLabel];
    [self.bgView addSubview:self.splitView];
    [self.bgView addSubview:self.newsTipBtn];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.imageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(space);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    
    UIImageView *lastView = nil ;
    for(NSInteger i = 0 ; i < 3 ; i++ ){
        UIImageView *view = [self createImageView];
        view.tag = 1000 + i ;
        [self.imageContentView addSubview:view];
        if(i == 0){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.imageContentView);
                make.left.mas_equalTo(self.imageContentView);
                make.width.mas_equalTo(imageWidth);
                make.height.mas_equalTo(imageHeight);
            }];
        }else{
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastView);
                make.left.mas_equalTo(lastView.mas_right).mas_offset(space);
                make.width.mas_equalTo(imageWidth);
                make.height.mas_equalTo(imageHeight);
            }];
        }
        lastView = view ;
    }
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastView).mas_offset(-space);
        make.bottom.mas_equalTo(lastView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(lastView.mas_bottom).mas_offset(space + 3);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.dateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.titleLabel);
        make.centerY.mas_equalTo(self.descLabel);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(splitViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithSummary:(KKPersonalSummary *)summary{
    self.summary = summary ;
    
    [KKArticleSmallCorverCell initAttriTextData:summary];
    
    for(NSInteger i = 0 ; i < 3 ; i++){
        NSString *url = [summary.image_list safeObjectAtIndex:i].url;
        if(!url.length || [url isKindOfClass:[NSNull class]]){
            url = @"";
        }
        UIImageView *view = [self.bgView viewWithTag:1000+i];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        UIImage *image = [imageCache imageFromCacheForKey:url] ;
        if(image){
            [view setImage:image];
        }else{
            @weakify(imageCache);
            [imageCache diskImageExistsWithKey:url completion:^(BOOL isInCache) {
                @strongify(imageCache);
                if(isInCache){
                    [view setImage:[imageCache imageFromCacheForKey:url]];
                }else{
                    [view kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
                }
            }];
        }
    }
    
    self.dateLabel.text = summary.datetime;
    
    NSString *readCount = [[NSNumber numberWithLong:summary.total_read_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@ 阅读",readCount];
    
    self.titleLabel.attributedText = summary.attriTextData.attriText;
    self.titleLabel.lineBreakMode = summary.attriTextData.lineBreak;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(summary.attriTextData.attriTextHeight);
    }];
    
    BOOL gallaryStyle = [summary.has_gallery boolValue] ;
    self.newsTipBtn.hidden = !gallaryStyle;
    if(gallaryStyle){
        NSInteger picCnt = [summary.gallery_pic_count integerValue];
        [self.bgView bringSubviewToFront:self.newsTipBtn];
        [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%ld图",picCnt] forState:UIControlStateNormal];
        
        NSInteger newsTipWidth = [self fetchNewsTipWidth];
        [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(newsTipWidth + 15) ;
        }];
    }
}

+ (CGFloat)fetchHeightWithSummary:(KKPersonalSummary *)summary{
    [KKArticleSmallCorverCell initAttriTextData:summary];
    return 2 * kkPaddingLarge + 2 * space + imageHeight + summary.attriTextData.attriTextHeight + descLabelHeight + splitViewHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKPersonalSummary *)summary{
    if(summary.attriTextData == nil ){
        summary.attriTextData = [KKAttriTextData new];
        summary.attriTextData.lineSpace = 3 ;
        summary.attriTextData.textColor = [UIColor kkColorBlack];
        summary.attriTextData.lineBreak = NSLineBreakByTruncatingTail;
        summary.attriTextData.originalText = summary.title;
        summary.attriTextData.maxAttriTextWidth = KKTitleWidth ;
        summary.attriTextData.textFont = KKTitleFont ;
    }
}

#pragma mark -- 计算视频时间字符、图片个数字符等宽度

- (CGFloat)fetchNewsTipWidth{
    if(self.summary.newsTipWidth <= 0 ){
        NSDictionary *dic = @{NSFontAttributeName:self.newsTipBtn.titleLabel.font};
        CGSize size = [self.newsTipBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, newsTipBtnHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        self.summary.newsTipWidth = size.width;
    }
    return self.summary.newsTipWidth;
}

- (UIImageView *)createImageView{
    UIImageView *view = [UIImageView new];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.layer.masksToBounds = YES ;
    return view ;
}

#pragma mark -- 

- (UIView *)imageContentView{
    if(!_imageContentView){
        _imageContentView = ({
            UIView *view = [UIView new];
            view.userInteractionEnabled = YES ;
            @weakify(view);
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(view);
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(clickImageWithItem:rect:fromView:image:indexPath:)]){
                    [self.delegate clickImageWithItem:self.summary rect:view.frame fromView:self.bgView image:nil indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _imageContentView;
}

- (UILabel *)dateLabel{
    if(!_dateLabel){
        _dateLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor kkColorLightgray];
            view.font = KKDescFont;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.backgroundColor = [UIColor clearColor];
            view.textAlignment = NSTextAlignmentRight;
            view ;
        });
    }
    return _dateLabel;
}

@end
