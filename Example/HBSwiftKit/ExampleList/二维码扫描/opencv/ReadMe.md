##开头吐槽: 
垃圾Swift, 本来低版本系统直接编译成功, 结果到了高版本的系统报Swift版本低, 故有这篇文章. 虽然Swift是大势所趋, 但是吹Swift省省吧, 多余的时间用来享受不香吗, 折腾不成熟的东西, 脑袋大.

还有本来我调试arm64已成功, 最终兼容模拟器的时候又去编译x86_64, 引出问题4/5, 蛋疼.

😄😄😄想要opencv2.framework的直接看最后, 别浪费时间
##先说环境: 
macos Monterey 12.6.3 / M1 MacbookAir / Xcode14.2

[opencv: 4.6.0](https://github.com/opencv/opencv)

[opencv_contrib: 4.6.0](https://github.com/opencv/opencv_contrib/tree/4.6.0)

下载opencv_contrib后把里面的wechat_qrcode目前拷贝到/opencv-4.6.0/modules/wechat_qrcode


#编译及问题

cd到你的opencv-4.6.0目录, 直接使用默认的python编译(python3): 

	python platforms/ios/build_framework.py ios
得到如下错误:

###错误1: 

	-- Configuring incomplete, errors occurred!
	
	See also "/Users/***/Desktop/opencv-4.6.0/ios/build/build-arm64-iphoneos/CMakeFiles/CMakeOutput.log".
	
	See also "/Users/***/Desktop/opencv-4.6.0/ios/build/build-arm64-iphoneos/CMakeFiles/CMakeError.log".
	
	CMakeErrorLog
	
	出现此问题:
	
	Undefined symbols for architecture arm64:
	
	  "_iconv", referenced from:
	
	      _main in src.o
	
	  "_iconv_close", referenced from:
	
	      _main in src.o
	
	  "_iconv_open", referenced from:
	
	      _main in src.o
	
	ld: symbol(s) not found for architecture arm64
	
	clang: error: linker command failed with exit code 1 (use -v to see invocation)

  

	解决方案: 安装libiconv
	
	xu@VIVO-S3 opencv-4.6.0 % brew install libiconv

  


重新编译得到错误

###错误2:

In file included from /Users/***/Desktop/opencv-4.6.0/3rdparty/libjpeg-turbo/src/jdphuff.c:26:

	**/Users/***/Desktop/opencv-4.6.0/3rdparty/libjpeg-turbo/src/jdhuff.h:77:19:** **error:**
	
	**invalid token at start of a preprocessor expression**
	
	if SIZEOF_SIZE_T == 8 || defined(_WIN64)
	
	**^**
	
	1 error generated.


	解决方案: 
	
	降低cmake版本, 安装 3.24.0
	
	https://cmake.org/files/  下载对应的dmg包. 然后拖到/Applications目录, 然后安装命令行: 
	sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install
	
###⚠️⚠️⚠️此处多说一句, Xcode和cmake有个对应关系, 两者版本不一致, 编译各种问题. [大多数问题在编译x86_64的情况下出现](), 自己善于查看CMakeError.log和CMakeOutput.log, 有时日志最后显示BUILD SUCCESS, 记得往上面看  ** BUILD FAILED

  
重新编译得到错误

###错误3:
	CMake Error at CMakeLists.txt:113 (enable_language):
	  No CMAKE_CXX_COMPILER could be found.
		
	CMake Error at CMakeLists.txt:113 (enable_language):
	  No CMAKE_C_COMPILER could be found.


	解决方案:
	
	删掉缓存目录, 之前编译生成的ios目录, 你的opencv-4.6.0目录下面的ios目录

###错误4:
CMake Error at CMakeLists.txt:11 (message):
 
	  FATAL: In-source builds are not allowed.

         You should create a separate directory for build files.
		
	解决方案:
	
	不熟悉C++和cmake, 所以直接直接删掉opencv-4.6.0, 重新弄一个新的再次cd进去编译
	github issue里面提到删除CMakeCache.txt, 我测试无效  issue链接: https://github.com/opencv/opencv/pull/8582
	
###错误5(兼容问题):

	error: Cannot code sign because the target does not have an Info.plist file and one is not being generated automatically. Apply an Info.plist file to the target using the INFOPLIST_FILE build setting or generate one automatically by setting the GENERATE_INFOPLIST_FILE build setting to YES (recommended). (in target 'CompilerIdC' from project 'CompilerIdC')

	调整cmake版本为3.24.0😖

  
重新编译, 成功.


###使用:

针对不熟悉C++的朋友, 比如我. 其实编译后的opencv都有封装成oc代码, 所以直接用就行了.  直接查看header里面, 很多封装好的oc对象, 参考下面几个头文件


	#import "opencv2/opencv2.h"
	#import "opencv2/imgcodecs/ios.h"  
	#import "opencv2/imgproc/types_c.h"
	#import "opencv2/imgproc/imgproc_c.h"
	#import "opencv2/core/types_c.h"

Image和Mat对象的转换也是有的 (opencv2/imgcodecs/ios.h):

	CV_EXPORTS CGImageRef MatToCGImage(const cv::Mat& image) CF_RETURNS_RETAINED;
	CV_EXPORTS void CGImageToMat(const CGImageRef image, cv::Mat& m, bool alphaExist = false);
	CV_EXPORTS UIImage* MatToUIImage(const cv::Mat& image);
	CV_EXPORTS void UIImageToMat(const UIImage* image,
	                             cv::Mat& m, bool alphaExist = false);


微信的那几个模型文件其实在编译时, 会自动给你下载 /Users/***/Desktop/opencv-4.6.0/ios/build/build-arm64-iphoneos/downloads/wechat_qrcode: 

	sr.prototxt	sr.caffemodel	detect.caffemodel	detect.prototxt
OC简单使用:

    NSString *path = [[NSBundle mainBundle] pathForResource:@"wechat_qrcode" ofType:@"bundle"];

	WeChatQRCode  *wechatQRCode = [[WeChatQRCode alloc] initWithDetector_prototxt_path:[NSString stringWithFormat:@"%@/%@", path, @"detect.prototxt"] detector_caffe_model_path:[NSString stringWithFormat:@"%@/%@", path, @"detect.caffemodel"] super_resolution_prototxt_path:[NSString stringWithFormat:@"%@/%@", path, @"sr.prototxt"] super_resolution_caffe_model_path:[NSString stringWithFormat:@"%@/%@", path, @"sr.caffemodel"]];
	Mat *mat = [[Mat alloc] init];
	 
	UIImageToMat(image, mat.nativeRef);
	 
	NSArray *results = [wechatQRCode detectAndDecode:mat];
	
	
	
参考链接:
[opencv_wechat_qrcode文档](https://docs.opencv.org/4.x/d5/d04/classcv_1_1wechat__qrcode_1_1WeChatQRCode.html)
编译好的[opencv2.framework]():

这个东西只是识别二维码, 相机录制以及后续集成请自己努力, 同时感谢微信团队的开源, 让我们这些垃圾仔多摸鱼.
