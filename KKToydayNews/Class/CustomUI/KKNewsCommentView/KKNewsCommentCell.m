//
//  KKNewsCommentCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/21.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNewsCommentCell.h"
#import "KKAttributeTextView.h"

#define HorizSpace 8
#define VeritSpace 5
#define ImageWH 35
#define TextViewWidth (UIDeviceScreenWidth - 2 * kkPaddingNormal - HorizSpace - ImageWH)
#define replayTextWidth (TextViewWidth - 2 * kkPaddingNormal)
#define LabelHeight 20
#define ButtonHeight 25
#define LineSpace 5 //文字的上下间距

#define commentTextFont [UIFont systemFontOfSize:16]
#define replyFont [UIFont systemFontOfSize:14]

#define MaxReplyCount 5

@interface KKNewsCommentCell()
@property(nonatomic)UIView *bgView;
@property(nonatomic)UIImageView *headImageView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UIButton *diggBtn;
@property(nonatomic)UILabel *commentTexyView;
@property(nonatomic)UILabel *createTimeLabel;
@property(nonatomic)UILabel *totalCommentLabel;
@property(nonatomic)UIView *replayView;

@property(nonatomic,weak)KKCommentItem *item ;
@property(nonatomic,weak)KKCommentObj *obj ;

@end

@implementation KKNewsCommentCell

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
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.headImageView];
    [self.bgView addSubview:self.diggBtn];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.commentTexyView];
    [self.bgView addSubview:self.createTimeLabel];
    [self.bgView addSubview:self.totalCommentLabel];
    [self.bgView addSubview:self.replayView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(ImageWH, ImageWH));
    }];
    
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.bottom.mas_equalTo(self.headImageView.mas_centerY);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.headImageView.mas_centerY).mas_offset(-2);
        make.left.mas_equalTo(self.headImageView.mas_right).mas_offset(HorizSpace);
        make.right.mas_equalTo(self.diggBtn.mas_left).mas_offset(-HorizSpace);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.commentTexyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(VeritSpace);
        make.width.mas_equalTo(TextViewWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.createTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentTexyView);
        make.top.mas_equalTo(self.commentTexyView.mas_bottom).mas_offset(VeritSpace);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.totalCommentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.createTimeLabel.mas_right).mas_offset(HorizSpace);
        make.centerY.mas_equalTo(self.createTimeLabel);
        make.height.mas_equalTo(ButtonHeight);
        make.width.mas_equalTo(0);
    }];
    
    [self.replayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCommentLabel.mas_bottom).mas_offset(VeritSpace);
        make.left.mas_equalTo(self.createTimeLabel);
        make.width.mas_equalTo(TextViewWidth);
        make.height.mas_equalTo(0);
    }];
    
    UILabel *lastView = nil ;
    for(NSInteger i = 0 ; i < MaxReplyCount ; i ++){
        UILabel *label = [UILabel new];
        label.numberOfLines = 0 ;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.tag = 1000 + i ;
        label.userInteractionEnabled = YES ;
        [self.replayView addSubview:label];
        [label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.replayView).mas_offset(kkPaddingNormal);
            if(i == 0){
                make.top.mas_equalTo(self.replayView).mas_offset(kkPaddingNormal);
            }else{
                make.top.mas_equalTo(lastView.mas_bottom).mas_offset(VeritSpace);
            }
            make.width.mas_equalTo(replayTextWidth);
            make.height.mas_equalTo(0);
        }];
        lastView = label ;
    }
    
    UILabel *label = [self createShowAllLabel];
    label.tag = 1000 + MaxReplyCount ;
    label.userInteractionEnabled = YES ;
    [self.replayView addSubview:label];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKCommentItem *)item{
    self.item = item ;
    if(!item.comment.attriTextData){
        item.comment.attriTextData = [KKNewsCommentCell createCommentData:item];
    }
    self.commentTexyView.attributedText = item.comment.attriTextData.attriText;
    self.commentTexyView.lineBreakMode = item.comment.attriTextData.lineBreak;//设置attributedText之后lineBreakMode失效，必须重新设置
    [self.commentTexyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.comment.attriTextData.attriTextHeight);
    }];
    if(item.comment.reply_to_comment){
        NSString *toUser = item.comment.reply_to_comment.user_name;
        @weakify(self);
        [self.commentTexyView addAttributeTapActionWithStrings:@[toUser] tapClicked:^(NSString *string, NSRange range, NSInteger index) {
            @strongify(self);
            if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                NSString *userId = self.item.comment.reply_to_comment.user_id;
                if(!userId.length){
                    userId = self.obj.reply_to_comment.user_id;
                }
                [self.delegate jumpToUserPage:userId];
            }
        }];
    }
    
    NSString *headUrl = item.comment.user_profile_image_url;
    if(!headUrl){
        headUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    @weakify(imageCache);
    [imageCache diskImageExistsWithKey:headUrl completion:^(BOOL isInCache) {
        @strongify(imageCache);
        if(isInCache){
            [self.headImageView setCornerImage:[imageCache imageFromCacheForKey:headUrl]];
        }else{
            [self.headImageView setCornerImageWithURL:[NSURL URLWithString:headUrl] placeholder:[UIImage imageNamed:@"head_default"]];
        }
    }];
    
    self.nameLabel.text = item.comment.user_name;
    
    NSString *diggCount = [[NSNumber numberWithInteger:[item.comment.digg_count longLongValue]]convert];
    [self.diggBtn setTitle:[NSString stringWithFormat:@" %@",diggCount] forState:UIControlStateNormal];
    
    NSDictionary *dic = @{NSFontAttributeName:self.diggBtn.titleLabel.font};
    CGSize size = [self.diggBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 20);
    }];
    
    self.createTimeLabel.text = [NSString stringIntervalSince1970RuleOne:item.comment.create_time.longLongValue];
    
    NSString *totalReplay = @"";
    long long replayCnt = [item.comment.reply_count longLongValue] ;
    if(replayCnt > 0){
        totalReplay = [[NSNumber numberWithInteger:replayCnt]convert];
        totalReplay = [NSString stringWithFormat:@"%@回复",totalReplay];
        self.totalCommentLabel.backgroundColor = KKColor(244, 245, 246, 1.0);
        self.totalCommentLabel.text = totalReplay ;
    }else{
        totalReplay = @"回复";
        self.totalCommentLabel.backgroundColor = [UIColor clearColor];
        self.totalCommentLabel.text = totalReplay ;
    }
    dic = @{NSFontAttributeName:self.totalCommentLabel.font};
    size = [totalReplay boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    [self.totalCommentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + (replayCnt ? 15 : 3 ));
    }];
    
    [self checkReplyList];
}

- (void)checkReplyList{
    
    UILabel *lastView = nil ;
    
    __block CGFloat totalHeight = 0 ;
    NSInteger count = self.item.comment.reply_list.count;
    for(NSInteger i = 0 ; i <= MaxReplyCount ; i ++){
        if(i >= count){
            UILabel *label = [self.replayView viewWithTag:1000 + i];
            label.hidden = YES ;
            continue ;
        }
        KKCommentObj *obj = [self.item.comment.reply_list safeObjectAtIndex:i];
        if(!obj.attriTextData){
            obj.attriTextData = [KKNewsCommentCell createReplyCommentData:obj];
        }
        
        totalHeight += obj.attriTextData.attriTextHeight ;
        
        UILabel *label = [self.replayView viewWithTag:1000 + i];
        label.hidden = NO ;
        label.attributedText = obj.attriTextData.attriText;
        label.userData = @{@"userId":obj.user_id,@"mediaId":obj.media_info.media_id.length ? obj.media_info.media_id : @""};
        label.lineBreakMode = obj.attriTextData.lineBreak;
        
        @weakify(label);
        @weakify(self);
        [label addAttributeTapActionWithStrings:@[obj.user_name] tapClicked:^(NSString *string, NSRange range, NSInteger index) {
            @strongify(label);
            @strongify(self);
            if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                NSDictionary *dic = (NSDictionary *)label.userData;
                NSString *userId = dic[@"userId"];
                [self.delegate jumpToUserPage:userId];
            }
        }];
        [label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(obj.attriTextData.attriTextHeight);
        }];
        lastView = label ;
    }
    
    if(count){
        
        totalHeight += 2 * kkPaddingNormal ;
        totalHeight += count * VeritSpace;
        totalHeight += LabelHeight;
        
        long long replayCnt = [self.item.comment.reply_count longLongValue] ;
        UILabel *label = [self.replayView viewWithTag:1000+MaxReplyCount];
        label.text = [NSString stringWithFormat:@"显示全部%@条回复",[[NSNumber numberWithInteger:replayCnt]convert]];
        label.hidden = NO ;
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).mas_offset(VeritSpace);
            make.left.mas_equalTo(lastView);
        }];
    }
    
    self.replayView.hidden = !count ;
    [self.replayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(totalHeight);
    }];
}

- (UILabel *)createShowAllLabel{
    UILabel *view = [UILabel new];
    view.font = replyFont;
    view.textColor = KKColor(25, 93, 157, 1);;
    view.lineBreakMode = NSLineBreakByTruncatingTail;
    view.textAlignment = NSTextAlignmentLeft;
    view.width = replayTextWidth;
    view.userInteractionEnabled = YES ;
    
    @weakify(self);
    [view addTapGestureWithBlock:^(UIView *gestureView) {
        @strongify(self);
        if(self.delegate && [self.delegate respondsToSelector:@selector(showAllComment:)]){
            [self.delegate showAllComment:self.item.comment.Id];
        }
    }];
    return view ;
}

- (void)refreshWithObj:(KKCommentObj *)obj{
    self.obj = obj ;
    if(!self.obj.attriTextData){
        self.obj.attriTextData = [KKNewsCommentCell createCommentWithObj:obj];
    }
    self.commentTexyView.attributedText = self.obj.attriTextData.attriText;
    [self.commentTexyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.obj.attriTextData.attriTextHeight);
    }];
    if(self.obj.reply_to_comment){
        @weakify(self);
        NSString *toUser = self.obj.reply_to_comment.user_name;
        [self.commentTexyView addAttributeTapActionWithStrings:@[toUser] tapClicked:^(NSString *string, NSRange range, NSInteger index) {
            @strongify(self);
            if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                NSString *userId = self.obj.reply_to_comment.user_id;
                if(!userId.length){
                    userId = self.obj.user.user_id;
                }
                [self.delegate jumpToUserPage:userId];
            }
        }];
    }
    
    NSString *headUrl = self.obj.user.avatar_url;
    if(!headUrl){
        headUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    @weakify(imageCache);
    [imageCache diskImageExistsWithKey:headUrl completion:^(BOOL isInCache) {
        @strongify(imageCache);
        if(isInCache){
            [self.headImageView setCornerImage:[imageCache imageFromCacheForKey:headUrl]];
        }else{
            [self.headImageView setCornerImageWithURL:[NSURL URLWithString:headUrl] placeholder:[UIImage imageNamed:@"head_default"]];
        }
    }];
    
    self.nameLabel.text = self.obj.user.screen_name;
    
    NSString *diggCount = [[NSNumber numberWithInteger:[self.obj.digg_count longLongValue]]convert];
    [self.diggBtn setTitle:[NSString stringWithFormat:@" %@",diggCount] forState:UIControlStateNormal];
    
    NSDictionary *dic = @{NSFontAttributeName:self.diggBtn.titleLabel.font};
    CGSize size = [self.diggBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 20);
    }];
    
    self.createTimeLabel.text = [NSString stringIntervalSince1970RuleOne:self.obj.create_time.longLongValue];
    
    NSString *totalReplay = @"";
    long long replayCnt = [self.obj.reply_count longLongValue] ;
    if(replayCnt > 0){
        totalReplay = [[NSNumber numberWithInteger:replayCnt]convert];
        totalReplay = [NSString stringWithFormat:@"%@回复",totalReplay];
        self.totalCommentLabel.backgroundColor = KKColor(244, 245, 246, 1.0);
        self.totalCommentLabel.text = totalReplay ;
    }else{
        totalReplay = @"回复";
        self.totalCommentLabel.backgroundColor = [UIColor clearColor];
        self.totalCommentLabel.text = totalReplay ;
    }
    dic = @{NSFontAttributeName:self.totalCommentLabel.font};
    size = [totalReplay boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    [self.totalCommentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + (replayCnt ? 15 : 3 ));
    }];
}

#pragma mark -- 获取cell的高度

+ (CGFloat)fetchHeightWithItem:(KKCommentItem *)item{
    
    CGFloat totalHeight = 0 ;

    if(!item.comment.attriTextData){
        item.comment.attriTextData = [KKNewsCommentCell createCommentData:item];
    }
    
    totalHeight += item.comment.attriTextData.attriTextHeight ;
    
    NSInteger count = item.comment.reply_list.count;
    for(NSInteger i = 0 ; i < count ; i ++){
        KKCommentObj *obj = [item.comment.reply_list safeObjectAtIndex:i];
        if(!obj.attriTextData){
            obj.attriTextData = [KKNewsCommentCell createReplyCommentData:obj];
        }
        
        totalHeight += obj.attriTextData.attriTextHeight ;
    }
    
    if(count){
        totalHeight += 2 * kkPaddingNormal ;
        totalHeight += count * VeritSpace;
        totalHeight += LabelHeight;
    }
    
    return totalHeight + 2 * kkPaddingNormal + 3 * VeritSpace + 2 * LabelHeight ;
}

+ (CGFloat)fetchHeightWithObj:(KKCommentObj *)obj{
    
    CGFloat totalHeight = 0 ;
    
    if(!obj.attriTextData){
        obj.attriTextData = [KKNewsCommentCell createCommentWithObj:obj];
    }
    
    totalHeight += obj.attriTextData.attriTextHeight ;
    
    return totalHeight + 2 * kkPaddingNormal + 3 * VeritSpace + 2 * LabelHeight ;
}

#pragma mark -- 创建评论文本数据

+ (KKAttriTextData *)createCommentData:(KKCommentItem *)item{
    KKAttriTextData *data = [KKAttriTextData new];
    data.maxAttriTextWidth = TextViewWidth;
    data.textFont = commentTextFont;
    data.lineSpace = LineSpace ;
    data.textColor = [UIColor blackColor];
    data.originalText = item.comment.text;
    if(item.comment.reply_to_comment){
        NSString *comment = item.comment.text;
        NSString *toUser = item.comment.reply_to_comment.user_name;
        NSString *toComment = item.comment.reply_to_comment.text;
        NSString *format = [NSString stringWithFormat:@"%@//@%@ : %@",comment,toUser,toComment];
        [data setOriginalText:format];
        [data setSubstringAttribute:toUser attributed:@{NSForegroundColorAttributeName:KKColor(25, 93, 157, 1)}];
    }
    
    CGFloat textHeight = data.attriTextHeight ;
    if(textHeight >= 6 * commentTextFont.lineHeight + 7 * data.lineSpace){
        textHeight =  6 * commentTextFont.lineHeight + 7 * data.lineSpace;
        data.lineBreak = NSLineBreakByTruncatingTail;
    }else{
        data.lineBreak = NSLineBreakByWordWrapping;
    }
    data.attriTextHeight = textHeight;
    
    return data;
}

+ (KKAttriTextData *)createCommentWithObj:(KKCommentObj *)obj{
    KKAttriTextData *data = [KKAttriTextData new];
    data.maxAttriTextWidth = TextViewWidth;
    data.textFont = commentTextFont;
    data.lineSpace = LineSpace ;
    data.textColor = [UIColor blackColor];
    data.originalText = obj.text;
    if(obj.reply_to_comment){
        NSString *comment = obj.text;
        NSString *toUser = obj.reply_to_comment.user_name;
        NSString *toComment = obj.reply_to_comment.text;
        NSString *format = [NSString stringWithFormat:@"%@//@%@ : %@",comment,toUser,toComment];
        [data setOriginalText:format];
        [data setSubstringAttribute:toUser attributed:@{NSForegroundColorAttributeName:KKColor(25, 93, 157, 1)}];
    }
    
    return data;
}

+ (KKAttriTextData *)createReplyCommentData:(KKCommentObj *)obj{
    NSString *userName = obj.user_name;
    NSString *commentText = obj.text;
    NSString *comment = [NSString stringWithFormat:@"%@ : %@",userName,commentText];
    
    KKAttriTextData *data = [KKAttriTextData new];
    data.originalText = comment;
    data.maxAttriTextWidth = replayTextWidth;
    data.textFont = replyFont;
    data.lineSpace = LineSpace ;
    if(data.attriTextHeight >= 2 * data.textFont.lineHeight + 3 * data.lineSpace){
        data.attriTextHeight =  2 * data.textFont.lineHeight + 3 * data.lineSpace;
        data.lineBreak = NSLineBreakByTruncatingTail;
    }else{
        data.lineBreak = NSLineBreakByCharWrapping;
    }
    
    [data setSubstringAttribute:userName attributed:@{NSForegroundColorAttributeName:KKColor(25, 93, 157, 1)}];
    
    return data;
}

#pragma mark -- @property getter

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _bgView;
}

- (UIImageView *)headImageView{
    if(!_headImageView){
        _headImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                    NSString *userId = self.item.comment.user_id;
                    if(!userId.length){
                        userId = self.obj.user.user_id;
                    }
                    NSString *mediaId = self.item.comment.media_info.media_id;
                    if(!mediaId.length){
                        mediaId = self.obj.media_info.media_id;
                    }
                    [self.delegate jumpToUserPage:userId];
                }
            }];
            
            view ;
        });
    }
    return _headImageView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = KKColor(25, 93, 157, 1);
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:14];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                    NSString *userId = self.item.comment.user_id;
                    if(!userId.length){
                        userId = self.obj.user.user_id;
                    }
                    NSString *mediaId = self.item.comment.media_info.media_id;
                    if(!mediaId.length){
                        mediaId = self.obj.media_info.media_id;
                    }
                    [self.delegate jumpToUserPage:userId];
                }
            }];
            
            view;
        });
    }
    return _nameLabel;
}

- (UIButton *)diggBtn{
    if(!_diggBtn){
        _diggBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_night_16x16_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_press_16x16_"] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTitleColor:KKColor(167, 173, 186, 1.0) forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(diggBtnClick:callback:)]){
                    @weakify(self);
                    [self.delegate diggBtnClick:self.item.comment.Id callback:^(BOOL suc) {
                        @strongify(self);
                        self.diggBtn.selected = suc ;
                    }];
                }
            }];
            
            view ;
        });
    }
    return _diggBtn;
}

- (UILabel *)commentTexyView{
    if(!_commentTexyView){
        _commentTexyView = ({
            UILabel *view = [UILabel new];
            view.textColor = KKColor(140, 140, 140, 1.0);
            view.font = commentTextFont;
            view.numberOfLines = 0 ;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.textAlignment = NSTextAlignmentLeft;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _commentTexyView;
}

- (UILabel *)createTimeLabel{
    if(!_createTimeLabel){
        _createTimeLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:12];
            view.textColor = KKColor(40, 40, 40, 1.0);
            view.textAlignment = NSTextAlignmentLeft;
            view;
        });
    }
    return _createTimeLabel;
}

- (UILabel *)totalCommentLabel{
    if(!_totalCommentLabel){
        _totalCommentLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:12];
            view.textColor = KKColor(40, 40, 40, 1.0);
            view.textAlignment = NSTextAlignmentCenter;
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.layer.masksToBounds = YES ;
            view.layer.cornerRadius = ButtonHeight / 2.0 ;
            view;
        });
    }
    return _totalCommentLabel;
}

- (UIView *)replayView{
    if(!_replayView){
        _replayView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _replayView;
}

@end
