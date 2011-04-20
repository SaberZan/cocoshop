/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CSSprite.h"
#import "CCNode+Additions.h"
#import "CSObjectController.h"
#import "CSModel.h"

@implementation CSSprite

@synthesize border=border_;
@synthesize key=key_;
@synthesize filename=filename_;
@synthesize name=name_;
@synthesize locked=locked_;

- (id)init
{
	if((self=[super init]))
	{
		[self setKey:nil];
		[self setFilename:nil];
		[self setName:nil];
		locked_ = NO;
	}
	
	return self;
}

- (void)onEnter
{
	[super onEnter];
	
	CGSize size = [self contentSize];
	CGSize fixedSize = CGSizeMake(size.width + kCSSpriteStrokeSize * 2, size.height + kCSSpriteStrokeSize * 2);
	
	if(!border_)
	{
		border_ = [[CCNode node] retain];
		
		fill_ = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[fill_ changeWidth:size.width height:size.height];
		[border_ addChild:fill_];
		
		CCLayerColor *left = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
		[left setPosition:ccp(-kCSSpriteStrokeSize,-kCSSpriteStrokeSize)];
		[left changeWidth:kCSSpriteStrokeSize height:fixedSize.height];
		[border_ addChild:left];
		
		CCLayerColor *right = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
		[right setPosition:ccp(size.width,-kCSSpriteStrokeSize)];
		[right changeWidth:kCSSpriteStrokeSize height:fixedSize.height];
		[border_ addChild:right];
		
		CCLayerColor *top = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
		[top setPosition:ccp(-kCSSpriteStrokeSize,size.height)];
		[top changeWidth:fixedSize.width height:kCSSpriteStrokeSize];
		[border_ addChild:top];
		
		CCLayerColor *bottom = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
		[bottom setPosition:ccp(-kCSSpriteStrokeSize,-kCSSpriteStrokeSize)];
		[bottom changeWidth:fixedSize.width height:kCSSpriteStrokeSize];
		[border_ addChild:bottom];
		
		anchor_ = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
		[border_ addChild:anchor_];
		
		CGSize s = [anchor_ contentSize];
		positionLabel_ = [[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d, %d", (NSInteger)position_.x, (NSInteger)position_.y] fntFile:@"arial.fnt"] retain];
		[positionLabel_ setPosition:ccp(s.width/2, -10)];
		[anchor_ addChild:positionLabel_ z:2];		
	}
	
	[self addChild:border_];
}

- (void)onExit
{
	[self removeChild:border_ cleanup:YES];
	[super onExit];
}

- (void)setName:(NSString *)aName
{
	if(name_ != aName)
	{
		// make the key alphanumerical + underscore
		NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
		aName = [[aName componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];		
		
		[name_ release];
		name_ = [aName copy];
	}
}

- (void)setAnchorPoint:(CGPoint)anchor
{
	if(!locked_)
	{
		[super setAnchorPoint:anchor];
		
		// update position of anchor point
		CGSize size = [self contentSize];
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	}
}

- (void)setPosition:(CGPoint)pos
{
	if(!locked_)
	{
		[super setPosition:pos];
		
		// update the position label
		[positionLabel_ setString:[NSString stringWithFormat:@"%d, %d", (NSInteger)position_.x, (NSInteger)position_.y]];
		CGSize s = [anchor_ contentSize];
		[positionLabel_ setPosition:ccp(s.width/2, -10)];		
	}
}

- (void)setRotation:(float)rot
{
	if(!locked_)
	{
		[super setRotation:rot];
		[anchor_ setRotation:-rot];
	}
}

- (void)setScale:(float)s
{
	if(!locked_)
	{
		[super setScale:s];
		[anchor_ setScale:(s != 0) ? 1.0f/s : 0];
	}
}

- (void)setOpacity:(GLubyte)anOpacity
{
	if(!locked_)
	{
		[super setOpacity:anOpacity];
	}
}

- (void)setIsRelativeAnchorPoint:(BOOL)relative
{
	if(!locked_)
	{
		[super setIsRelativeAnchorPoint:relative];
		
		// update position of anchor point
		CGSize size = [self contentSize];
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	}
}

- (void)dealloc
{
	[anchor_ release];
	[positionLabel_ release];
	[border_ release];
	[fill_ release];
	[self setKey:nil];
	[self setFilename:nil];
	[self setName:nil];
	[super dealloc];
}

@end