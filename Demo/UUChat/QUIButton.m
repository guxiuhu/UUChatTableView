//
//  QUIButton.m
//  QKeyboardExample
//
//  Created by 古秀湖 on 2017/5/11.
//  Copyright © 2017年 南天. All rights reserved.
//

#import "QUIButton.h"

@implementation QUIButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    BOOL inside = [super pointInside: point withEvent: event];
    
    NSLog(@"%d   %d    %d",inside,self.isHighlighted,event.type);
    
    if (inside && !self.isHighlighted && event.type == UIEventTypeTouches){
        self.highlighted = YES;
        
        NSLog(@"commmmmmmmmmmmm");
    }
    
    return inside;
}

@end
