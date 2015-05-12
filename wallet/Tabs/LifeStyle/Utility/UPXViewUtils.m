//
//  UPXViewUtils.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//


#import "UPXViewUtils.h"
#import "UPWAppUtil.h"

@implementation UPXViewUtils


+ (void)drawImage:(UIImage *)image rect:(CGRect)rect
{
    CGSize  size    = image.size;
    CGFloat originX = (NSInteger)(rect.origin.x + (rect.size.width  - size.width)  / 2);
    CGFloat originY = (NSInteger)(rect.origin.y + (rect.size.height - size.height) / 2);
    [image drawInRect:CGRectMake(originX, originY, size.width, size.height)];
}



+ (UIViewController*)viewController:(UINavigationController*)navi ofClass:(Class)cls
{
    UIViewController* result = nil;
    
    NSArray* vcArr = navi.viewControllers;
    
    NSEnumerator *enumerator = [vcArr reverseObjectEnumerator];
    for (UIViewController* vc in enumerator) {
        if ([vc isKindOfClass:cls]) {
            result = vc;
            break;
        }
    }
    return result;
}


+ (UIViewController*)findUIViewController:(UIResponder*)responder
{
    id nextResponder = [responder nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        return nextResponder;
    }
    else if ([nextResponder isKindOfClass:[UIView class]])
    {
        return [UPXViewUtils findUIViewController:nextResponder];
    }
    else
    {
        return nil;
    }
}


+ (UIViewController*)findRootController:(UIView*)view
{
    UIViewController* result  = [self findUIViewController:view];
    if (result)
    {
        return result;
    }
    
    for (UIView *subView in view.subviews)
    {
        result = [UPXViewUtils findUIViewController:subView];
        if (result != nil)
        {
            return result;
        }
    }
    return nil;
    
}



+ (UIView *)findFirstResponder:(UIView*)view
{
    if (view.isFirstResponder)
    {
        return view;
    }
    
    for (UIView *subView in view.subviews)
    {
        UIView *firstResponder = [UPXViewUtils findFirstResponder:subView];
        if (firstResponder != nil)
        {
            return firstResponder;
        }
    }
    
    return nil;
}




+ (NSArray *)editableTextInputsInView:(UIView*)view
{
    
    NSMutableArray *textInputs = [NSMutableArray new] ;
    for (UIView *subview in view.subviews)
    {
        BOOL isTextField = [subview isKindOfClass:[UITextField class]] & !subview.hidden;
        BOOL isEditableTextView = [subview isKindOfClass:[UITextView class]] && [(UITextView *)subview isEditable]& !subview.hidden;
        if (isTextField || isEditableTextView)
            [textInputs addObject:subview];
        else
            [textInputs addObjectsFromArray:[self editableTextInputsInView:subview]];
    }
    return textInputs;
}

//去掉输入框中的 markedText

+ (void)deleteMarkedTextWithView:(id<UITextInput>) inputView{
    if (!inputView.markedTextRange.isEmpty) {
        if ([UPWAppUtil deviceOS] >= 7.0) {
            //replaceRange: withText: 方法7.0无效果
            NSInteger startOffset = [inputView offsetFromPosition:inputView.beginningOfDocument toPosition:inputView.markedTextRange.start];
            NSInteger endOffset = [inputView offsetFromPosition:inputView.beginningOfDocument toPosition:inputView.markedTextRange.end];
            NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
            [inputView setMarkedText:@"" selectedRange:offsetRange];
        }else{
            [inputView replaceRange:inputView.markedTextRange withText:@""];
        }
    }
}

//push HomeVc
//+ (void)customPushHomeVCWithVC:(UPXBaseViewController *)vc{
//    UPXHomeViewController *homeVC = (UPXHomeViewController *)[self viewControllerOfClass:[UPXHomeViewController class]];
//    if (!homeVC) {
//        UPXHomeViewController *newHomeVC = [[UPXHomeViewController alloc] init];
//        UP_SHDAT.homeVC = newHomeVC;
//        [vc customPushViewController:newHomeVC withType:kUPAnimationFade subType:kUPAnimationFromBottom removeCurrent:YES];
//        [newHomeVC release];
//    }else{
//        UP_SHDAT.homeVC = homeVC;
//      [vc.navigationController popToViewController:homeVC animated:YES];
//    }
//}




@end
