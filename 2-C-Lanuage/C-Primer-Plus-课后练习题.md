## 第一章练习题

#### 1、对编程而言，可移植性意味着什么?

- 意味着程序无需修改源代码或者仅修改少量平台差异代码，就能在不同的计算机系统中成功编译的程序。

#### 2、解释源代码文件、目标代码文件和可执行文件有什么区别?

- 源代码文件：是程序员使用任何编程语言编写的代码，没有经过任何编译处理。
- 目标代码文件：经由编译器编译处理后生成的目标文件，包含机器语言代码。
- 可执行文件：最终生成的完整的机器语言代码文件，可以由操作系统执行。

#### 3、编程的7个步骤是？

- 确定程序目标，即程序要解决什么问题。
- 设计程序：即采用何种编程语言、如何设计界面、如何组织程序代码结构、期望的完成时间等。
- 编写代码：把解决问题的具体过程转换成编程语言。
- 编译程序：编译写好的源代码文件，生成可执行程序。
- 运行程序：运行最终生成的程序，确保程序能够初步使用功能。
- 测试和调试程序：反复测试程序功能，利用工具调试程序找出程序bug。
- 维护和修改代码：拓展程序功能、修复程序中的Bug。

#### 4、编译器的任务是什么

- 把程序源代码编译成目标代码文件，包含机器语言代码。

#### 5、链接器的任务是什么

- 链接多个目标代码文件、引入的其他库文件、启动代码等，生成一个可执行程序。

## 第二章练习题

#### 1、C语言的基本模块是什么?

- C语言是由一个或多个函数组成的，所以C语言的基本模块就是函数。

#### 2、什么是语法错误？什么是语义错误？

- 语法错误：编程时不符合C语言规范，例如缺少逗号、引号、拼写字母错误等
- 语义错误：变量名称、函数名称的含义错误，与实际功能不符合。

#### 3、某新手程序员编写了如下代码，指出下面程序的错误

```c
include studio.h
    
int main {void}

(
	int s
    s :=56
    print(There are s weeks in a year.);
	return 0;
```

包含的错误有：

- 单词拼写错误。
- 宏定义指令使用错误。
- 语法错误，括号未正确使用，分号未正确使用。
- 声明的变量赋值错误，没有使用。

修正后的程序如下：

```c
#include <stdio.h>

int main(void) {
    int s;
    s = 56;
    printf("Thre are s weeks in a year: %d", s);
    
    return 0;
}
```

#### 4、假设下面的4个例子都是完整程序中的一部分，它们都输出什么结果?

a. printf("Baa Baa Black Sheep.");
    printf("Have you any wool?\n");

b. printf("Begone!\nO creature of lard!\n");

c. printf("what?\nNo/nfish?\n");

d. int num

   num = 2;

   printf("%d + %d = %d"，num, num，num+num);

输出结果为：

```
a. Baa Baa Black Sheep.Have you any wool?

b. Begone!
   O creature of lard

c. What?
   No/nfish?

d. 2 + 2 = 4  ( +号在printf函数中可以计算 )
```

#### 5、在main、int、function、char、=中，哪些是C语言的关键字?

- 关键字只有`int`和`char`。
- main是特殊的函数名称
- function在C语言中不是关键字
- =号是运算符

#### 6、如何如何以下面的格式输出变量words和lines的值?

There were 3020 words and 350 lines. (这里，3020和 350代表两个变量的值)

```c
int words = 3020;
int lines = 350;
printf("There were %d words and %d lines.", words, lines)
```

## 第三章练习题

#### 1、指出下面各种数据使用的合适数据类型(有些可使用多种数据类型)：

- a. East Simpleton 的人口
  - 只要是整型即可，short、int比较合适
- b.DVD 影碟的价格
  - float类型最为合适
- c.本章出现次数最多的字母
  - char类型
- d.本章出现次数最多的字母次数
  - short类型足够，int也不是不行

#### 2、在什么情况下要用long 类型的变量代替int类型的变量?

超出了int所能表示的数据范围该使用long类型

- int 表示范围为2^32 -1
- long表示范围为2^64-1

#### 3、使用哪些可移植的数据类型可以获得32位有符号整数?选择的理由是什么?

- C99新增了两个头文件`stdint.h`和`inttypes.h`可以确保C语言类型在不同系统中功能相同。
- 如果正好是32位有符号整数，则使用`int32_t`类型即可，这是精确宽度类型。
- 最小宽度类型：int_least32_t。
- 最快计算类型：int_fast32_t。

#### 4、指出下列常量的类型和含义(如果有的话)：

- `'\b'` char类型，表示转移字符
- `1066` int类型常量
- `99.44` double类型常量，如果是float类型，数字后面得加f,例如99.44f
- `0XAA`， unsigned int类型常量，十六进制格式
- `2.0e30`表示 2.0 * 10 的30次方，显然是double类型了

#### 5、找出程序的错误。

```
include <stdio.h>
int main
(
    float g;h;
    float tax,rate;
    g=e21;
    tax = rate*g;
)
```

修正后如下：

```c
#include <stdio.h>
int main(void)
{
    float g;
    float h;
    float tax,rate = 0.08;
    g = 1.0e21;
    tax = rate*g;
    
    return 0;
}
```

#### 6、写出下列常量在声明中使用的数据类型和在printf()中对应的转换说明。

| 常量      | 类型                   | 转换说明(%转换字符) |
| --------- | ---------------------- | ------------------- |
| 12        | int                    | %d                  |
| 0X3       | unsigned int           | %#X                 |
| 'C'       | char                   | %c                  |
| 2.34E07   | double                 | %e                  |
| '\040'    | char                   | %s                  |
| 7.0       | double                 | %f                  |
| 6L        | long                   | %ld                 |
| 6.0f      | float                  | %f                  |
| 0x5.b6p12 | float                  | %a                  |
| 012       | unsigned int           | %#o                 |
| 2.9e05L   | long double            | %Le                 |
| 's'       | char                   | %c                  |
| 100000    | long（如果考虑移植性） | %ld                 |
| '\n'      | char                   | %c                  |
| 20.0f     | float                  | %f                  |
| 0x44      | unsigned int           | %x                  |
| -40       | int                    | %d                  |

#### 7、假设程序开头有如下声明：

```c
int imate = 2;
long shot = 53456;
char grade = 'A';
float log = 2.71828;
```

使用printf打印出这些数据类型。

如下：

```c
printf("imate: %d, show: %ld \n", imate, shot);
printf("grade: %c, log: %f \n", grade, log);
```

#### 8、假设 ch是 char 类型的变量。分别使用转义序列、十进制值、八进制字符常量和十六进制字符常量把回车字符赋给ch(假设使用ASCII编码值)。

回车的转移序列表示为：`\r`

查阅ASCII码表，回车对应的值为：13

```c
ch = '\r';
ch = 13;
ch = '\015';
ch = '\xd';
```

#### 9、指出下列转义序列的含义：

- `\n`：表示换行字符
- `\\`：表示一个反斜杠字符
- `\"`：表示一个双引号字符
- `\t`：表示一个制表字符

### 编程练习：

#### 1、通过试验(即编写带有此类问题的程序)观察系统如何处理整数上溢、浮点数上溢和浮点数下溢的情况。

编程代码如下：

```c
#include <stdio.h>
#include <limits.h>
#include <float.h>

int main(void)
{
	// 2147483647
	printf("int类型整数最大值为：%d \n", INT_MAX);
	// 得到的结果为：-2147483648
	printf("int类型整数最大值为,+1后产生上溢：%d \n", INT_MAX + 1);

	// 340282346638528859811704183484516925440.000000
	printf("float类型最大值：%f \n", FLT_MAX);
	printf("float类型最大值下溢：%f \n", FLT_MAX - 1);
	// 340282346638528859811704183484516925440.000000
	printf("float类型最大值上溢：%f \n", FLT_MAX + 1);
    return 0;
}
```

问题：为什么float类型的最大值、+1、-1后打印的值没有变化呢？

经过询问豆包AI得知：

- 这是因为`float`类型的精度不足以区分`FLT_MAX`和`FLT_MAX - 1`。`float`类型只有大约 7 位有效数字（具体来说是 24 位二进制有效数字，换算成十进制大约是 6 - 7 位），对于像`FLT_MAX`这样非常大的数，减去 (1基本上不会改变其在float类型中的表示。

#### 2、编写一个程序，要求提示输入一个 ASCII码值(如，66)，然后打印输入的字符。

程序如下：

```c
#include <stdio.h>

int main(void)
{
	printf("请输入一个ASCII码值，提示：\n");
	printf("1、标准的ASCII码值范围为0-127，扩展ASCII码值支持到255 \n");
	printf("2、可打印字符：32 到 126，包括英文字母（大小写）、数字、标点符号等 \n");
	printf("3、不可打印字符：0 到 31 以及 127，这些字符大多不可见，用于控制一些特定操作 \n");
	printf("4、128到255,包含了各种额外的字符,如特殊符号、一些图形符号和数学符号以及各种语言的字母\n");
	printf("请输入一个数字：");

	int ch;

	scanf_s("%d", &ch);

	printf("得到对应的ASCII码表中的字符为：%c", ch);
    return 0;
}
```

#### 3、编写一个程序，发出一声警报，然后打印下面的文本

程序如下：

```c
#include <stdio.h>

int main(void)
{
	printf("\aStartled by the sudden sound,Sally shouted,\n");
	printf("\"By the Great Pumpkin, what was that!\"");
    return 0;
}
```

#### 4、一年大约有3.156×10^7秒，编写一个程序，提示用户输入年龄，然后显示该年龄对应的秒数。

程序如下：

```c
#include <stdio.h>

int main(void)
{
	int f1 = 3.156e7;
	int age;

	//printf("%d", f1);
	printf("请输入你的年龄：");

	scanf_s("%d", &age);
	printf("你的年龄对应度过的秒数为：%d \n", f1 * age);
    return 0;
}
```

#### 5、1个水分子的质量约为3.0×10^-23克。1夸脱水大约是950克。编写一个程序，提示用户输入水的夸脱数，并显示水分子的数量。

程序如下：

```c
#include <stdio.h>

int main(void)
{
	float f1 = 3.0e-23;
	int kt = 950;

	int w_num;

	printf("请输入水的夸脱数: ");
	scanf_s("%d", &w_num);

	printf("你输入的%d夸脱水，总重量是%d克, 包含%e个水分子", w_num, w_num * kt, w_num * kt / f1);
    return 0;
}
```

## 第四章 编程练习

#### 1、编写一个程序，提示用户输入名和姓，然后以“名,姓”的格式打印出来。

程序如下：

```c
#include <stdio.h>

int main(void)
{
	char fisrt_name[10];
	char last_name[10];

	printf("请输入名：");
	scanf_s("%s", fisrt_name, sizeof (fisrt_name));
	printf("请输入姓：");
	scanf_s("%s", last_name, sizeof (last_name));

	printf("名,姓：%s,%s \n", fisrt_name, last_name);

	return 0;
}
```

#### 2、编写一个程序，提示用户输入名和姓，并执行以下操作:

- 打印名和姓，包括双引号;
- 在宽度为20的字段右端打印名和姓，包括双引号；
- 在宽度为20的字段**左端**打印名和姓，包括双引号;
- 在比姓名宽度宽3的字段中打印名和姓。

补充的代码如下：

```c
/*
名,姓："cat,tom"
名,姓："                 cat,                 tom"
名,姓："cat                 ,tom                 "
*/
printf("名,姓：\"%s,%s\" \n", fisrt_name, last_name);
printf("名,姓：\"%20s,%20s\" \n", fisrt_name, last_name);
printf("名,姓：\"%-20s,%-20s\" \n", fisrt_name, last_name);
```

#### 3、编写一个程序，提示用户输入以兆位每秒(Mb/s)为单位的下载速度和以兆字节(MB)为单位的文件大小。程序中应计算文件的下载时间。注意，这里1字节等于8位。使用foat类型，并用/作为除号。该程序要以下面的格式打印3个变量的值(下载速度、文件大小和下载时间)，显示小数点后面两位数字:

程序如下：

```c
#include <stdio.h>

int main(void)
{

	float download_speed;
	float file_size;
	float download_time;

	printf("请输入下载速度(Mb/s): ");
	scanf_s("%f", &download_speed);
	printf("请输入下载文件的大小(MB): ");
	scanf_s("%f", &file_size);

	download_time = file_size * 8 / download_speed;
	printf("当前文件下载速度为 %.2f Mb/s, 文件大小: %.2f MB, 下载时间约 %.2f s \n",
		download_speed, file_size, download_time);

	return 0;
}
```

#### 6、编写一个程序，先提示用户输入名，然后提示用户输入姓。在一行打印用户输入的名和姓，下一行分别打印名和姓的字母数。字母数要与相应名和姓的结尾对齐，如下所示:

![]()

程序如下：

```c
/*
Melissa Honeybee
	  7        8
Melissa Honeybee
7       8
*/

#include <stdio.h>
#include <string.h>

int main(void)
{
	char n1[10];
	char n2[10];

	printf("请输入姓：");
	scanf_s("%s", n1, (unsigned int)sizeof(n1));
	printf("请输入名：");
	scanf_s("%s", n2, (unsigned int)sizeof(n2));

	int len1 = strlen(n1);
	int len2 = strlen(n2);
	printf("%s %s \n", n1, n2);
	printf("%*d %*d \n", len1, len1, len2, len2);

	return 0;
}
```

## 第五章 练习题

#### 1、假设所有变量的类型都是int，下列各项变量的值是多少:

- x = (2+ 3) * 6;		// x = 30	
- x = (12 + 6) / 2 * 3;       // 3   
- y = x = (2 + 3) / 4;         // y = x = 1
- y = 3 + 2 * (x = 7 / 2);  // x=3   y=9

#### 2、假设所有变量的类型都是int，下列各项变量的值是多少:

- x = (int)3.8 + 3.3;	// 6.3
- x=(2+ 3)*10.5;          // 52
- x=3/5*22.0;    // 13
- x=22.0*3/5  // 13
