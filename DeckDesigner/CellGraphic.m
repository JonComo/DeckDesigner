//
//  CellGraphic.m
//  DeckDesigner
//
//  Created by Jon Como on 8/15/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "CellGraphic.h"

@interface CellGraphic ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CellGraphic

- (void)setImage:(UIImage *)image {
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.bounds.size.width, self.contentView.bounds.size.height)];
        [self.contentView addSubview:self.imageView];
    }
    
    self.imageView.image = image;
}

@end
