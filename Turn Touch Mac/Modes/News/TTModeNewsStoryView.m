//
//  TTModeNewsStoryView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/8/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeNewsStoryView.h"
#import "TTNewsBlurUtilities.h"
#import "TTModeNewsFeedView.h"

@interface TTModeNewsStoryView ()

@property (nonatomic, strong) TTPairingSpinner *loadingSpinner;
@property (nonatomic) BOOL inTextView;

@end

@implementation TTModeNewsStoryView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.wantsLayer = YES;
//        self.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 0.1);
        self.layer.backgroundColor = CGColorCreateGenericRGB(1, 1, 1, 1);
        self.layer.opacity = 0.1;
        
        self.webView = [[WebView alloc] init];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.resourceLoadDelegate = self;
        
//        webView.drawsBackground = NO;
        [self addSubview:self.webView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1. constant:0]];

        self.loadingSpinner = [[TTPairingSpinner alloc] init];
        self.loadingSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.loadingSpinner];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1. constant:-64]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1. constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:64]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadingSpinner attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:64]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

- (void)showLoadingView {
    self.loadingSpinner.hidden = NO;
}

- (void)blurStory {
    // NSLog(@"Blurring: %@", story.storyTitle);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    animation.toValue = [NSNumber numberWithFloat:0.1f];
    animation.duration = 0.3f;// * 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"opacity"];
    self.layer.opacity = 0.1f;

}

- (void)focusStory {
    // NSLog(@"Focusing: %@", story.storyTitle);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    animation.toValue = [NSNumber numberWithFloat:1.f];
    animation.duration = 0.65f;// * 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"opacity"];
    self.layer.opacity = 1.f;
}

- (void)adjustSize {
    [self.webView stringByEvaluatingJavaScriptFromString:@"resizeWindow();"];
}

- (void)adjustSize:(CGFloat)width {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"resizeWindow(%f);", width]];
}

- (void)adjustFontSize {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"adjustFontSize(\"%@\")", [self fontSize]]];
}

#pragma mark - Customizations

- (NSString *)fontSize {
    NSString *fontSize;
    switch ([[self.appDelegate.modeMap modeOptionValue:@"fontSize"] integerValue]) {
        case 0:
            fontSize = @"xs";
            break;
        case 1:
            fontSize = @"small";
            break;
        case 2:
            fontSize = @"medium";
            break;
        case 3:
            fontSize = @"large";
            break;
        case 4:
            fontSize = @"xl";
            break;
    }
    
    return fontSize;
}

#pragma mark - Loading URLs

- (void)loadStory {
    [self loadFeedTitle];
    
    self.loadingSpinner.hidden = YES;
//    NSString *shareBarString = [self getShareBar];
//    NSString *commentString = [self getComments];
    NSString *headerString;
//    NSString *sharingHtmlString;
    NSString *footerString;
    NSString *fontStyleClass = @"";
    NSString *fontSizeClass = [NSString stringWithFormat:@"NB-%@", [self fontSize]];
    NSString *lineSpacingClass = @"NB-line-spacing-";
    NSString *storyContent = self.story.storyContent;
    if (self.inTextView && self.story.originalText) {
        storyContent = self.story.originalText;
    }
    
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    fontStyleClass = [userPreferences stringForKey:@"TT:mode:news:fontStyle"];
    if (!fontStyleClass) {
        fontStyleClass = @"NB-helvetica";
    }
    
    if ([userPreferences stringForKey:@"TT:mode:news:lineSpacing"]){
        lineSpacingClass = [lineSpacingClass stringByAppendingString:[userPreferences stringForKey:@"TT:mode:news:lineSpacing"]];
    } else {
        lineSpacingClass = [lineSpacingClass stringByAppendingString:@"medium"];
    }
    
    int contentWidth = NSWidth(self.frame);
    NSString *contentWidthClass = [NSString stringWithFormat:@"NB-ipad-narrow %@ NB-width-%d",
                                   fontSizeClass,
                                   (int)floorf(CGRectGetWidth(self.frame))];
    
    // Replace image urls that are locally cached, even when online
    //    NSString *storyHash = [story objectForKey:@"story_hash"];
    //    NSArray *imageUrls = [appDelegate.activeCachedImages objectForKey:storyHash];
    //    if (imageUrls) {
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //        NSString *storyImagesDirectory = [[paths objectAtIndex:0]
    //                                          stringByAppendingPathComponent:@"story_images"];
    //        for (NSString *imageUrl in imageUrls) {
    //            NSString *cachedImage = [storyImagesDirectory
    //                                     stringByAppendingPathComponent:[Utilities md5:imageUrl]];
    //            storyContent = [storyContent
    //                            stringByReplacingOccurrencesOfString:imageUrl
    //                            withString:cachedImage];
    //        }
    //    }
    
    NSString *riverClass = @"NB-river";
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    headerString = [NSString stringWithFormat:@
                    "<link rel=\"stylesheet\" type=\"text/css\" href=\"%@/styles/storyDetailView.css\">"
                    "<meta name=\"viewport\" id=\"viewport\" content=\"width=%d, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"/>",
                    resourcePath, contentWidth];
    footerString = [NSString stringWithFormat:@
                    "<script src=\"%@/scripts/jquery-2.0.3.js\"></script>"
                    "<script src=\"%@/scripts/fitvid.js\"></script>"
                    "<script src=\"%@/scripts/velocity.min.js\"></script>"
                    "<script src=\"%@/scripts/storyDetailView.js\"></script>", resourcePath, resourcePath, resourcePath, resourcePath];
    
    NSString *storyHeader = [self getHeader];
    
    NSString *htmlTop = [NSString stringWithFormat:@
                         "<!DOCTYPE html>\n"
                         "<html>"
                         "<head>%@</head>" // header string
                         "<body id=\"story_pane\" class=\"%@ %@\">"
                         "    <div class=\"%@\" id=\"NB-line-spacing\">"
                         "        <div id=\"NB-header-container\">%@</div>", // storyHeader
//                         "        %@", // shareBar
                         headerString,
                         contentWidthClass,
                         riverClass,
                         lineSpacingClass,
                         storyHeader
//                         shareBarString
                         ];
    
    NSString *htmlBottom = [NSString stringWithFormat:@
                            "    </div>" // line-spacing
                            "</body>"
                            "</html>"
                            ];
    
    NSString *htmlContent = [NSString stringWithFormat:@
                             "%@" // header
                             "        <div id=\"NB-story\" class=\"NB-story\">%@</div>"
                             "        <div id=\"NB-comments-wrapper\">"
//                             "            %@" // friends comments
                             "        </div>"
                             "        %@"
                             "%@", // footer
                             htmlTop,
                             storyContent,
//                             commentString,
                             footerString,
                             htmlBottom
                             ];
    
    NSString *htmlString = [htmlTop stringByAppendingString:htmlBottom];
    
    //    NSLog(@"\n\n\n\nStory html (%@):\n\n\n%@\n\n\n", story[@"story_title"], htmlContent);
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    self.loadingURL = baseURL;
    self.loadingHTML = htmlContent;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.hasStory = YES;
        //        NSLog(@"Drawing Story: %@", [story objectForKey:@"story_title"]);
        [[self.webView mainFrame] loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://mac.turntouch.com"]];
    });
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
    if (self.loadingHTML) {
        [[self.webView mainFrame] loadHTMLString:self.loadingHTML baseURL:self.loadingURL];
        self.loadingHTML = nil;
        self.loadingURL = nil;
    }

    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.browserView.zoomFactor]];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    //get the scroll view that contains the frame contents
    NSScrollView* scrollView = [[[[self.webView mainFrame] frameView] documentView] enclosingScrollView];
    [[scrollView verticalScroller] setControlSize: NSSmallControlSize];
    [[scrollView horizontalScroller] setControlSize: NSSmallControlSize];
}

- (void)loadFeedTitle {
    TTModeNewsFeedView *feedTitleView = [[TTModeNewsFeedView alloc] initWithFeed:self.story.feed inFrame:NSMakeRect(0, NSMaxY(self.bounds)-48, NSWidth(self.bounds), 48)];
    feedTitleView.autoresizingMask = NSViewWidthSizable;
    [self addSubview:feedTitleView];
}

#pragma mark -
#pragma mark Story layout

- (NSString *)getHeader {
//    NSString *feedId = [NSString stringWithFormat:@"%@", story.feedId];
    NSString *storyAuthor = @"";
    if ([self.story.storyAuthor length]) {
        NSString *author = [NSString stringWithFormat:@"%@",
                            [[[self.story.storyAuthor stringByReplacingOccurrencesOfString:@"\"" withString:@""]
                              stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
                             stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]];
        if (author && author.length) {
            storyAuthor = [NSString stringWithFormat:@"<span class=\"NB-middot\">&middot;</span><a href=\"http://ios.newsblur.com/classify-author/%@\" "
                           "class=\"NB-story-author\" id=\"NB-story-author\"><div class=\"NB-highlight\"></div>%@</a>",
                           author,
                           author];
        }
    }
    NSString *storyTags = @"";
    if (self.story.storyTags) {
        NSArray *tagArray = self.story.storyTags;
        if ([tagArray count] > 0) {
            NSMutableArray *tagStrings = [NSMutableArray array];
            for (NSString *tag in tagArray) {
                NSString *tagHtml = [NSString stringWithFormat:@"<a href=\"http://ios.newsblur.com/classify-tag/%@\" "
                                     "class=\"NB-story-tag\"><div class=\"NB-highlight\"></div>%@</a>",
                                     tag,
                                     tag];
                [tagStrings addObject:tagHtml];
            }
            storyTags = [NSString
                         stringWithFormat:@"<div id=\"NB-story-tags\" class=\"NB-story-tags\">"
                         "%@"
                         "</div>",
                         [tagStrings componentsJoinedByString:@""]];
        }
    }

//    NSMutableDictionary *titleClassifiers = [[appDelegate.storiesCollection.activeClassifiers
//                                              objectForKey:feedId]
//                                             objectForKey:@"titles"];
//    for (NSString *titleClassifier in titleClassifiers) {
//        if ([storyTitle containsString:titleClassifier]) {
//            int titleScore = [[titleClassifiers objectForKey:titleClassifier] intValue];
//            storyTitle = [storyTitle
//                          stringByReplacingOccurrencesOfString:titleClassifier
//                          withString:[NSString stringWithFormat:@"<span class=\"NB-story-title-%@\">%@</span>",
//                                      titleScore > 0 ? @"positive" : titleScore < 0 ? @"negative" : @"",
//                                      titleClassifier]];
//        }
//    }
    
    NSString *storyDate = [TTNewsBlurUtilities formatLongDateFromTimestamp:[self.story.storyTimestamp integerValue]];
    NSString *storyHeader = [NSString stringWithFormat:@
                             "<div class=\"NB-header\"><div class=\"NB-header-inner\">"
                             "<div class=\"NB-story-title\">"
                             "  <a href=\"%@\" class=\"NB-story-permalink\">%@</a>"
                             "</div>"
                             "<div class=\"NB-story-date\">%@</div>"
                             "%@"
                             "%@"
                             "</div></div>",
                             self.story.storyPermalink,
                             self.story.storyTitle,
                             storyDate,
                             storyAuthor,
                             storyTags];
    return storyHeader;
}

//- (NSString *)getAvatars:(NSString *)key {
//    NSString *avatarString = @"";
//    NSArray *shareUserIds = [story objectForKey:key];
//    
//    for (int i = 0; i < shareUserIds.count; i++) {
//        NSDictionary *user = [appDelegate getUser:[[shareUserIds objectAtIndex:i] intValue]];
//        NSString *avatarClass = @"NB-user-avatar";
//        if ([key isEqualToString:@"commented_by_public"] ||
//            [key isEqualToString:@"shared_by_public"]) {
//            avatarClass = @"NB-public-user NB-user-avatar";
//        }
//        NSString *avatar = [NSString stringWithFormat:@
//                            "<div class=\"NB-story-share-profile\"><div class=\"%@\">"
//                            "<a id=\"NB-user-share-bar-%@\" class=\"NB-show-profile\" "
//                            " href=\"http://ios.newsblur.com/show-profile/%@\">"
//                            "<div class=\"NB-highlight\"></div>"
//                            "<img src=\"%@\" />"
//                            "</a>"
//                            "</div></div>",
//                            avatarClass,
//                            [user objectForKey:@"user_id"],
//                            [user objectForKey:@"user_id"],
//                            [user objectForKey:@"photo_url"]];
//        avatarString = [avatarString stringByAppendingString:avatar];
//    }
//    
//    return avatarString;
//}
//
//- (NSString *)getComments {
//    NSString *comments = @"";
//    
//    if ([story objectForKey:@"share_count"] != [NSNull null] &&
//        [[story objectForKey:@"share_count"] intValue] > 0) {
//        NSDictionary *story = story;
//        NSArray *friendsCommentsArray =  [story objectForKey:@"friend_comments"];
//        NSArray *friendsShareArray =  [story objectForKey:@"friend_shares"];
//        NSArray *publicCommentsArray =  [story objectForKey:@"public_comments"];
//        
//        if ([[story objectForKey:@"comment_count_friends"] intValue] > 0 ) {
//            comments = [comments stringByAppendingString:@"<div class=\"NB-story-comments-group NB-story-comment-friend-comments\">"];
//            NSString *commentHeader = [NSString stringWithFormat:@
//                                       "<div class=\"NB-story-comments-friends-header-wrapper\">"
//                                       "  <div class=\"NB-story-comments-friends-header\">%i comment%@</div>"
//                                       "</div>",
//                                       [[story objectForKey:@"comment_count_friends"] intValue],
//                                       [[story objectForKey:@"comment_count_friends"] intValue] == 1 ? @"" : @"s"];
//            comments = [comments stringByAppendingString:commentHeader];
//            
//            // add friends comments
//            comments = [comments stringByAppendingFormat:@"<div class=\"NB-feed-story-comments\">"];
//            for (int i = 0; i < friendsCommentsArray.count; i++) {
//                NSString *comment = [self getComment:[friendsCommentsArray objectAtIndex:i]];
//                comments = [comments stringByAppendingString:comment];
//            }
//            comments = [comments stringByAppendingString:@"</div>"];
//            comments = [comments stringByAppendingString:@"</div>"];
//        }
//        
//        NSInteger sharedByFriendsCount = [[story objectForKey:@"shared_by_friends"] count];
//        if (sharedByFriendsCount > 0 ) {
//            comments = [comments stringByAppendingString:@"<div class=\"NB-story-comments-group NB-story-comment-friend-shares\">"];
//            NSString *commentHeader = [NSString stringWithFormat:@
//                                       "<div class=\"NB-story-comments-friend-shares-header-wrapper\">"
//                                       "  <div class=\"NB-story-comments-friends-header\">%ld share%@</div>"
//                                       "</div>",
//                                       (long)sharedByFriendsCount,
//                                       sharedByFriendsCount == 1 ? @"" : @"s"];
//            comments = [comments stringByAppendingString:commentHeader];
//            
//            // add friend shares
//            comments = [comments stringByAppendingFormat:@"<div class=\"NB-feed-story-comments\">"];
//            for (int i = 0; i < friendsShareArray.count; i++) {
//                NSString *comment = [self getComment:[friendsShareArray objectAtIndex:i]];
//                comments = [comments stringByAppendingString:comment];
//            }
//            comments = [comments stringByAppendingString:@"</div>"];
//            comments = [comments stringByAppendingString:@"</div>"];
//        }
//        
//        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"show_public_comments"] boolValue] &&
//            [[story objectForKey:@"comment_count_public"] intValue] > 0 ) {
//            comments = [comments stringByAppendingString:@"<div class=\"NB-story-comments-group NB-story-comment-public-comments\">"];
//            NSString *publicCommentHeader = [NSString stringWithFormat:@
//                                             "<div class=\"NB-story-comments-public-header-wrapper\">"
//                                             "  <div class=\"NB-story-comments-public-header\">%i public comment%@</div>"
//                                             "</div>",
//                                             [[story objectForKey:@"comment_count_public"] intValue],
//                                             [[story objectForKey:@"comment_count_public"] intValue] == 1 ? @"" : @"s"];
//            
//            comments = [comments stringByAppendingString:publicCommentHeader];
//            comments = [comments stringByAppendingFormat:@"<div class=\"NB-feed-story-comments\">"];
//            
//            // add public comments
//            for (int i = 0; i < publicCommentsArray.count; i++) {
//                NSString *comment = [self getComment:[publicCommentsArray objectAtIndex:i]];
//                comments = [comments stringByAppendingString:comment];
//            }
//            comments = [comments stringByAppendingString:@"</div>"];
//            comments = [comments stringByAppendingString:@"</div>"];
//        }
//    }
//    
//    return comments;
//}
//
//- (NSString *)getShareBar {
//    NSString *comments = @"<div id=\"NB-share-bar-wrapper\">";
//    NSString *commentLabel = @"";
//    NSString *shareLabel = @"";
//    //    NSString *replyStr = @"";
//    
//    //    if ([[story objectForKey:@"reply_count"] intValue] == 1) {
//    //        replyStr = [NSString stringWithFormat:@" and <b>1 reply</b>"];
//    //    } else if ([[story objectForKey:@"reply_count"] intValue] == 1) {
//    //        replyStr = [NSString stringWithFormat:@" and <b>%@ replies</b>", [story objectForKey:@"reply_count"]];
//    //    }
//    if (![[story objectForKey:@"comment_count"] isKindOfClass:[NSNull class]] &&
//        [[story objectForKey:@"comment_count"] intValue]) {
//        commentLabel = [commentLabel stringByAppendingString:[NSString stringWithFormat:@
//                                                              "<div class=\"NB-story-comments-label\">"
//                                                              "%@" // comment count
//                                                              //"%@" // reply count
//                                                              "</div>"
//                                                              "<div class=\"NB-story-share-profiles NB-story-share-profiles-comments\">"
//                                                              "%@" // friend avatars
//                                                              "%@" // public avatars
//                                                              "</div>",
//                                                              [[story objectForKey:@"comment_count"] intValue] == 1
//                                                              ? [NSString stringWithFormat:@"<b>1 comment</b>"] :
//                                                              [NSString stringWithFormat:@"<b>%@ comments</b>", [story objectForKey:@"comment_count"]],
//                                                              
//                                                              //replyStr,
//                                                              [self getAvatars:@"commented_by_friends"],
//                                                              [self getAvatars:@"commented_by_public"]]];
//    }
//    
//    if (![[story objectForKey:@"share_count"] isKindOfClass:[NSNull class]] &&
//        [[story objectForKey:@"share_count"] intValue]) {
//        shareLabel = [shareLabel stringByAppendingString:[NSString stringWithFormat:@
//                                                          
//                                                          "<div class=\"NB-right\">"
//                                                          "<div class=\"NB-story-share-profiles NB-story-share-profiles-shares\">"
//                                                          "%@" // friend avatars
//                                                          "%@" // public avatars
//                                                          "</div>"
//                                                          "<div class=\"NB-story-share-label\">"
//                                                          "%@" // comment count
//                                                          "</div>"
//                                                          "</div>",
//                                                          [self getAvatars:@"shared_by_public"],
//                                                          [self getAvatars:@"shared_by_friends"],
//                                                          [[story objectForKey:@"share_count"] intValue] == 1
//                                                          ? [NSString stringWithFormat:@"<b>1 share</b>"] :
//                                                          [NSString stringWithFormat:@"<b>%@ shares</b>", [story objectForKey:@"share_count"]]]];
//    }
//    
//    if ([story objectForKey:@"share_count"] != [NSNull null] &&
//        [[story objectForKey:@"share_count"] intValue] > 0) {
//        
//        comments = [comments stringByAppendingString:[NSString stringWithFormat:@
//                                                      "<div class=\"NB-story-shares\">"
//                                                      "<div class=\"NB-story-comments-shares-teaser-wrapper\">"
//                                                      "<div class=\"NB-story-comments-shares-teaser\">"
//                                                      "%@"
//                                                      "%@"
//                                                      "</div>"
//                                                      "</div>"
//                                                      "</div>",
//                                                      commentLabel,
//                                                      shareLabel
//                                                      ]];
//    }
//    comments = [comments stringByAppendingString:[NSString stringWithFormat:@"</div>"]];
//    return comments;
//}
//
//- (NSString *)getComment:(NSDictionary *)commentDict {
//    NSDictionary *user = [appDelegate getUser:[[commentDict objectForKey:@"user_id"] intValue]];
//    NSString *userAvatarClass = @"NB-user-avatar";
//    NSString *userReshareString = @"";
//    NSString *userEditButton = @"";
//    NSString *userLikeButton = @"";
//    NSString *commentUserId = [NSString stringWithFormat:@"%@", [commentDict objectForKey:@"user_id"]];
//    NSString *currentUserId = [NSString stringWithFormat:@"%@", [appDelegate.dictSocialProfile objectForKey:@"user_id"]];
//    NSArray *likingUsersArray = [commentDict objectForKey:@"liking_users"];
//    NSString *likingUsers = @"";
//    
//    if ([likingUsersArray count]) {
//        likingUsers = @"<div class=\"NB-story-comment-likes-icon\"></div>";
//        for (NSNumber *likingUser in likingUsersArray) {
//            NSDictionary *sourceUser = [appDelegate getUser:[likingUser intValue]];
//            NSString *likingUserString = [NSString stringWithFormat:@
//                                          "<div class=\"NB-story-comment-likes-user\">"
//                                          "    <div class=\"NB-user-avatar\"><img src=\"%@\"></div>"
//                                          "</div>",
//                                          [sourceUser objectForKey:@"photo_url"]];
//            likingUsers = [likingUsers stringByAppendingString:likingUserString];
//        }
//    }
//    
//    if ([commentUserId isEqualToString:currentUserId]) {
//        userEditButton = [NSString stringWithFormat:@
//                          "<div class=\"NB-story-comment-edit-button NB-story-comment-share-edit-button NB-button\">"
//                          "<a href=\"http://ios.newsblur.com/edit-share/%@\"><div class=\"NB-story-comment-edit-button-wrapper\">"
//                          "Edit"
//                          "</div></a>"
//                          "</div>",
//                          commentUserId];
//    } else {
//        BOOL isInLikingUsers = NO;
//        for (int i = 0; i < likingUsersArray.count; i++) {
//            if ([[[likingUsersArray objectAtIndex:i] stringValue] isEqualToString:currentUserId]) {
//                isInLikingUsers = YES;
//                break;
//            }
//        }
//        
//        if (isInLikingUsers) {
//            userLikeButton = [NSString stringWithFormat:@
//                              "<div class=\"NB-story-comment-like-button NB-button selected\">"
//                              "<a href=\"http://ios.newsblur.com/unlike-comment/%@\"><div class=\"NB-story-comment-like-button-wrapper\">"
//                              "<span class=\"NB-favorite-icon\"></span>"
//                              "</div></a>"
//                              "</div>",
//                              commentUserId];
//        } else {
//            userLikeButton = [NSString stringWithFormat:@
//                              "<div class=\"NB-story-comment-like-button NB-button\">"
//                              "<a href=\"http://ios.newsblur.com/like-comment/%@\"><div class=\"NB-story-comment-like-button-wrapper\">"
//                              "<span class=\"NB-favorite-icon\"></span>"
//                              "</div></a>"
//                              "</div>",
//                              commentUserId];
//        }
//        
//    }
//    
//    if ([commentDict objectForKey:@"source_user_id"] != [NSNull null]) {
//        userAvatarClass = @"NB-user-avatar NB-story-comment-reshare";
//        
//        NSDictionary *sourceUser = [appDelegate getUser:[[commentDict objectForKey:@"source_user_id"] intValue]];
//        userReshareString = [NSString stringWithFormat:@
//                             "<div class=\"NB-story-comment-reshares\">"
//                             "    <div class=\"NB-story-share-profile\">"
//                             "        <div class=\"NB-user-avatar\"><img src=\"%@\"></div>"
//                             "    </div>"
//                             "</div>",
//                             [sourceUser objectForKey:@"photo_url"]];
//    }
//    
//    NSString *commentContent = [self textToHtml:[commentDict objectForKey:@"comments"]];
//    
//    NSString *comment;
//    NSString *locationHtml = @"";
//    NSString *location = [NSString stringWithFormat:@"%@", [user objectForKey:@"location"]];
//    
//    if (location.length && ![[user objectForKey:@"location"] isKindOfClass:[NSNull class]]) {
//        locationHtml = [NSString stringWithFormat:@"<div class=\"NB-story-comment-location\">%@</div>", location];
//    }
//    
//    if (!self.isPhoneOrCompact) {
//        comment = [NSString stringWithFormat:@
//                   "<div class=\"NB-story-comment\" id=\"NB-user-comment-%@\">"
//                   "<div class=\"%@\">"
//                   "<a class=\"NB-show-profile\" href=\"http://ios.newsblur.com/show-profile/%@\">"
//                   "<div class=\"NB-highlight\"></div>"
//                   "<img src=\"%@\" />"
//                   "</a>"
//                   "</div>"
//                   "<div class=\"NB-story-comment-author-container\">"
//                   "   %@"
//                   "    <div class=\"NB-story-comment-username\">%@</div>"
//                   "    <div class=\"NB-story-comment-date\">%@ ago</div>"
//                   "    <div class=\"NB-story-comment-likes\">%@</div>"
//                   "</div>"
//                   "<div class=\"NB-story-comment-content\">%@</div>"
//                   "%@" // location
//                   "<div class=\"NB-button-wrapper\">"
//                   "    <div class=\"NB-story-comment-reply-button NB-button\">"
//                   "        <a href=\"http://ios.newsblur.com/reply/%@/%@\"><div class=\"NB-story-comment-reply-button-wrapper\">"
//                   "            Reply"
//                   "        </div></a>"
//                   "    </div>"
//                   "    %@" //User Like Button
//                   "    %@" //User Edit Button
//                   "</div>"
//                   "%@"
//                   "</div>",
//                   [commentDict objectForKey:@"user_id"],
//                   userAvatarClass,
//                   [commentDict objectForKey:@"user_id"],
//                   [user objectForKey:@"photo_url"],
//                   userReshareString,
//                   [user objectForKey:@"username"],
//                   [commentDict objectForKey:@"shared_date"],
//                   likingUsers,
//                   commentContent,
//                   locationHtml,
//                   [commentDict objectForKey:@"user_id"],
//                   [user objectForKey:@"username"],
//                   userEditButton,
//                   userLikeButton,
//                   [self getReplies:[commentDict objectForKey:@"replies"] forUserId:[commentDict objectForKey:@"user_id"]]];
//    } else {
//        comment = [NSString stringWithFormat:@
//                   "<div class=\"NB-story-comment\" id=\"NB-user-comment-%@\">"
//                   "<div class=\"%@\">"
//                   "<a class=\"NB-show-profile\" href=\"http://ios.newsblur.com/show-profile/%@\">"
//                   "<div class=\"NB-highlight\"></div>"
//                   "<img src=\"%@\" />"
//                   "</a>"
//                   "</div>"
//                   "<div class=\"NB-story-comment-author-container\">"
//                   "    %@"
//                   "    <div class=\"NB-story-comment-username\">%@</div>"
//                   "    <div class=\"NB-story-comment-date\">%@ ago</div>"
//                   "    <div class=\"NB-story-comment-likes\">%@</div>"
//                   "</div>"
//                   "<div class=\"NB-story-comment-content\">%@</div>"
//                   "%@" // location
//                   "<div class=\"NB-button-wrapper\">"
//                   "    <div class=\"NB-story-comment-reply-button NB-button\">"
//                   "        <a href=\"http://ios.newsblur.com/reply/%@/%@\"><div class=\"NB-story-comment-reply-button-wrapper\">"
//                   "            Reply"
//                   "        </div></a>"
//                   "    </div>"
//                   "    %@" // User Like Button
//                   "    %@" // User Edit Button
//                   "</div>"
//                   "%@"
//                   "</div>",
//                   [commentDict objectForKey:@"user_id"],
//                   userAvatarClass,
//                   [commentDict objectForKey:@"user_id"],
//                   [user objectForKey:@"photo_url"],
//                   userReshareString,
//                   [user objectForKey:@"username"],
//                   [commentDict objectForKey:@"shared_date"],
//                   likingUsers,
//                   commentContent,
//                   locationHtml,
//                   [commentDict objectForKey:@"user_id"],
//                   [user objectForKey:@"username"],
//                   userEditButton,
//                   userLikeButton,
//                   [self getReplies:[commentDict objectForKey:@"replies"] forUserId:[commentDict objectForKey:@"user_id"]]];
//        
//    }
//    
//    return comment;
//}
//
//- (NSString *)getReplies:(NSArray *)replies forUserId:(NSString *)commentUserId {
//    NSString *repliesString = @"";
//    if (replies.count > 0) {
//        repliesString = [repliesString stringByAppendingString:@"<div class=\"NB-story-comment-replies\">"];
//        for (int i = 0; i < replies.count; i++) {
//            NSDictionary *replyDict = [replies objectAtIndex:i];
//            NSDictionary *user = [appDelegate getUser:[[replyDict objectForKey:@"user_id"] intValue]];
//            
//            NSString *userEditButton = @"";
//            NSString *replyUserId = [NSString stringWithFormat:@"%@", [replyDict objectForKey:@"user_id"]];
//            NSString *replyId = [replyDict objectForKey:@"reply_id"];
//            NSString *currentUserId = [NSString stringWithFormat:@"%@", [appDelegate.dictSocialProfile objectForKey:@"user_id"]];
//            
//            if ([replyUserId isEqualToString:currentUserId]) {
//                userEditButton = [NSString stringWithFormat:@
//                                  "<div class=\"NB-story-comment-edit-button NB-story-comment-share-edit-button NB-button\">"
//                                  "<a href=\"http://ios.newsblur.com/edit-reply/%@/%@/%@\">"
//                                  "<div class=\"NB-story-comment-edit-button-wrapper\">"
//                                  "Edit"
//                                  "</div>"
//                                  "</a>"
//                                  "</div>",
//                                  commentUserId,
//                                  replyUserId,
//                                  replyId
//                                  ];
//            }
//            
//            NSString *replyContent = [self textToHtml:[replyDict objectForKey:@"comments"]];
//            
//            NSString *locationHtml = @"";
//            NSString *location = [NSString stringWithFormat:@"%@", [user objectForKey:@"location"]];
//            
//            if (location.length) {
//                locationHtml = [NSString stringWithFormat:@"<div class=\"NB-story-comment-location\">%@</div>", location];
//            }
//            
//            NSString *reply;
//            
//            if (!self.isPhoneOrCompact) {
//                reply = [NSString stringWithFormat:@
//                         "<div class=\"NB-story-comment-reply\" id=\"NB-user-comment-%@\">"
//                         "   <a class=\"NB-show-profile\" href=\"http://ios.newsblur.com/show-profile/%@\">"
//                         "       <div class=\"NB-highlight\"></div>"
//                         "       <img class=\"NB-story-comment-reply-photo\" src=\"%@\" />"
//                         "   </a>"
//                         "   <div class=\"NB-story-comment-username NB-story-comment-reply-username\">%@</div>"
//                         "   <div class=\"NB-story-comment-date NB-story-comment-reply-date\">%@ ago</div>"
//                         "   <div class=\"NB-story-comment-reply-content\">%@</div>"
//                         "   %@" // location
//                         "   <div class=\"NB-button-wrapper\">"
//                         "       %@" // edit
//                         "   </div>"
//                         "</div>",
//                         [replyDict objectForKey:@"reply_id"],
//                         [user objectForKey:@"user_id"],
//                         [user objectForKey:@"photo_url"],
//                         [user objectForKey:@"username"],
//                         [replyDict objectForKey:@"publish_date"],
//                         replyContent,
//                         locationHtml,
//                         userEditButton];
//            } else {
//                reply = [NSString stringWithFormat:@
//                         "<div class=\"NB-story-comment-reply\" id=\"NB-user-comment-%@\">"
//                         "   <a class=\"NB-show-profile\" href=\"http://ios.newsblur.com/show-profile/%@\">"
//                         "       <div class=\"NB-highlight\"></div>"
//                         "       <img class=\"NB-story-comment-reply-photo\" src=\"%@\" />"
//                         "   </a>"
//                         "   <div class=\"NB-story-comment-username NB-story-comment-reply-username\">%@</div>"
//                         "   <div class=\"NB-story-comment-date NB-story-comment-reply-date\">%@ ago</div>"
//                         "   <div class=\"NB-story-comment-reply-content\">%@</div>"
//                         "   %@"
//                         "   <div class=\"NB-button-wrapper\">"
//                         "       %@" // edit
//                         "   </div>"
//                         "</div>",
//                         [replyDict objectForKey:@"reply_id"],
//                         [user objectForKey:@"user_id"],
//                         [user objectForKey:@"photo_url"],
//                         [user objectForKey:@"username"],
//                         [replyDict objectForKey:@"publish_date"],
//                         replyContent,
//                         locationHtml,
//                         userEditButton];
//            }
//            repliesString = [repliesString stringByAppendingString:reply];
//        }
//        repliesString = [repliesString stringByAppendingString:@"</div>"];
//    }
//    return repliesString;
//}

#pragma mark - Interacting with webView

- (NSInteger)currentScroll {
    return [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
}

- (NSInteger)scrollAmount {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    return NSHeight(mainScreen.frame) / 4;
}

- (void)scrollUp {
    [self scroll:-1*self.scrollAmount duration:200];
}

- (void)scrollDown {
    [self scroll:self.scrollAmount duration:360];
}

- (void)scroll:(NSInteger)amount duration:(NSInteger)duration {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('body').velocity('stop').velocity('scroll', {duration: %ld, easing: 'easeOutCubic', queue: false, offset: $('body').scrollTop() + %ld}); console.log(['velocity', $('body').scrollTop(), $('body').velocity()]);", duration, amount]];
}

- (void)zoomIn {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.browserView.zoomFactor]];
}

- (void)zoomOut {
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.documentElement.style.zoom = \"%f\"", self.browserView.zoomFactor]];
}

@end
