//
//  LUDefines.h
//  LessionUtility
//
//  Created by 256 on 5/12/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#ifndef LessionUtility_LUDefines_h
#define LessionUtility_LUDefines_h

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HEXACOLOR(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

// 高亮色      #69af05
#define COLOR_HIGHLIGHT             HEXCOLOR(0x69af05)
// 重要信息     #fa6400
#define COLOR_IMPORTMENT_INFO       HEXCOLOR(0xfa6400)
// 个别地方     #fa9600
#define COLOR_SEVERAL               HEXCOLOR(0xfa9600)
// 标题文字     #000000
#define COLOR_TITLE                 HEXCOLOR(0x000000)
// 次要标题     #323232
#define COLOR_SECOND_TITLE          HEXCOLOR(0x323232)
// 中灰       #646464
#define COLOR_HALF_GRAY             HEXCOLOR(0x646464)
// 浅灰       #969696
#define COLOR_LIGHT_GRAY            HEXCOLOR(0x969696)
// 灰色背景     #f0f0f0
#define COLOR_GRAY_BACKGROUND       HEXCOLOR(0xf0f0f0)
// 分割线灰色   #dcdcdc
#define COLOR_SEPARATOR_LINE        HEXCOLOR(0xdcdcdc)
// 警告红色     #fe0000
#define COLOR_WARNING_RED           HEXCOLOR(0xfe0000)
// 抢购黄色     #eb5307
#define COLOR_PURCHASE_YELLOW       HEXCOLOR(0xeb5307)
// 直供黄色     #ef6c02
#define COLOR_RECOMMEND_YELLOW      HEXCOLOR(0xef6c02)
// 优选黄色     #f39a00
#define COLOR_SFBEST_YELLOW         HEXCOLOR(0xf39a00)


#endif
