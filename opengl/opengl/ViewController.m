//
//  ViewController.m
//  opengl
//
//  Created by FlyOceanFish on 2018/8/1.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES3/gl.h>

//    self.view.transform = CGAffineTransformScale(<#CGAffineTransform t#>, <#CGFloat sx#>, <#CGFloat sy#>)
//    CGContextTranslateCTM(<#CGContextRef  _Nullable c#>, <#CGFloat tx#>, <#CGFloat ty#>)
//    CGContextScaleCTM(<#CGContextRef  _Nullable c#>, <#CGFloat sx#>, <#CGFloat sy#>)

@interface ViewController ()
{
    GLuint vertextBufferID;
    EAGLContext *context;
    GLKBaseEffect *mEffect;//着色器或光照
    GLKTextureInfo *textureInfo2;
    GLKTextureInfo *textureInfo;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:context];
    
    /** 获取支持的压缩纹理方式，此方法必须在上下文初始化后调用才行
    NSString *extensionsString = [NSString stringWithCString:(char *)glGetString(GL_EXTENSIONS) encoding:NSUTF8StringEncoding];
     NSLog(@"%@",extensionString);
     */
    
    /***********************  加载顶点数据  ******************************/

//    用来开启更新深度缓冲区，OpenGL在绘制的时候就会检查，当前像素前面是否有别的像素，如果有别的像素挡着了它，那它就不会绘制，也就是说，OpenGL就只绘制第一层；当我们需要绘制透明图片时，就需要关闭它。
//    glEnable(GL_DEPTH_TEST);
//    glDisable(GL_DEPTH_TEST);

//    前三顶点(X,Y,Z),后2(U,V)与纹理进行映射
    GLfloat vertextData[]={
        0.5f,-0.5f,0.0f, 1.0f,0.0f,
        0.5f,0.5f,0.0f, 1.0f,1.0f,
        -0.5f,0.5f,0.0f, 0.0f,1.0f,
        
        0.5f,-0.5f,0.0f, 1.0f,0.0f,
        -0.5f,0.5f,0.0f, 0.0f,1.0f,
        -0.5f,-0.5f,0.0f, 0.0f,0.0f,
    };
    glGenBuffers(1, &vertextBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertextBufferID);
    /**
    GL_STATIC_DRAW：表示该缓存区不会被修改；
    GL_DyNAMIC_DRAW：表示该缓存区会被周期性更改；
    GL_STREAM_DRAW：表示该缓存区会被频繁更改；
    **/
//    为缓存分配足够的内存（CPU数据复制到GPU）
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertextData), vertextData, GL_STATIC_DRAW);
//  告诉OpenGL ES是否使用缓存中的数据 (启用顶点位置(坐标)数组，opengl是状态机，需要什么状态就启动什么状态)
    glEnableVertexAttribArray(GLKVertexAttribPosition);
// 告诉OpenGL ES缓存数据类型和所有需要访问的数据的内存偏移值
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL);
    
//  启用纹理坐标(u, v)
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    设置纹理坐标
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    /** 多纹理 ***
    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
                                                                                                                                                                                                                                 (GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
     */
    
    /***********************  加载纹理  ******************************/
    /**
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//纹素数量大于片元的数量，多个纹素对应一个片元
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);//纹素数量小片元的数量

    当U、V坐标的值小于0或大于1时，有两个选择，要么尽可能多地重复纹理以填满映射到几何图形的整个U、V区域，要么U、V超出S、T坐标系的范围时，取样纹理边缘。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//截取
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);//S方向重复纹理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);//T方向重复纹理
    */
    
//读取纹理 GLKTextureLoader会调用glTexParameteri
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
//    如果不设置options，则绘制的图像是倒置的
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    CGImageRef imageRef = [UIImage imageNamed:@"test"].CGImage;
//    GLKTextureLoader会自动调用glTexParameteri()方法来为创建的纹理缓存设置OpenGL ES取样和循环模式
    textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:options error:NULL];
    
    CGImageRef imageRef2 = [[UIImage imageNamed:@"aa"] CGImage];
    textureInfo2 = [GLKTextureLoader textureWithCGImage:imageRef2 options:options error:NULL];
//    着色器
    mEffect = [[GLKBaseEffect alloc] init];

    /***  混合 多通道渲染的时候  ***
     //    mEffect.constantColor = GLKVector4Make(1.0f,0.0f,0.0f,0.5f);
     glEnable(GL_BLEND);//开启混合(用来绘制两张图片叠加的效果，一张透明一张不透明)
     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混合函数，比较常用的，混合结果有公式可以计算，Red(final)=Alpha(fragment)*Red(fragment)+(1-alpha(frament))*Red(frame Buffer)
     */
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f,1.0f,0.0f,0.5f);//清空当前的所有颜色,并设置背景色
    /**
     GL_COLOR_BUFFER_BIT:    当前可写的颜色缓冲
     GL_DEPTH_BUFFER_BIT:    深度缓冲
     GL_ACCUM_BUFFER_BIT:   累积缓冲
     　　GL_STENCIL_BUFFER_BIT: 模板缓冲
     **/
    //    表示要清除颜色缓冲以及深度缓冲(将以前绘制的擦除)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);//这行代码如果注释掉，整个都是黑色的，不会绘制任何东西
    
    
    mEffect.texture2d0.enabled = GL_TRUE;
    mEffect.texture2d0.name = textureInfo.name;
    mEffect.texture2d0.target = textureInfo.target;
    
    //以下两句代码可以使图片不变形
    const GLfloat aspectRatio = (GLfloat)view.drawableWidth/(GLfloat)view.drawableHeight;
    mEffect.transform.projectionMatrix = GLKMatrix4MakeScale(1, aspectRatio, 1);
    
    /** 多纹理 **
    mEffect.texture2d1.enabled = GL_TRUE;
    mEffect.texture2d1.name = textureInfo2.name;
    mEffect.texture2d1.target = textureInfo2.target;
    mEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    */
    [mEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    /**  两张图片叠加的效果，此方法是多通道渲染  **
     mEffect.texture2d0.enabled = GL_TRUE;
     mEffect.texture2d0.name = textureInfo2.name;
     mEffect.texture2d0.target = textureInfo2.target;
     [mEffect prepareToDraw];
     glDrawArrays(GL_TRIANGLES, 0, 6);
    **/

}
- (void)dealloc
{
    [EAGLContext setCurrentContext:nil];
    if (0 != vertextBufferID) {
        glDeleteBuffers(1, &vertextBufferID);
        vertextBufferID = 0;
    }
}
@end
