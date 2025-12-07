# 首页设计说明

## 🎨 最新设计更新

### 角色卡片样式

#### 1. **移除白色背景**
- ❌ 移除了原来的白色渐变背景
- ✅ 按钮后方使用半透明黑色背景（alpha: 0.6）
- 效果：卡片更加简洁，突出角色图片

#### 2. **3px 黑色边框**
```dart
border: Border.all(
  color: Colors.black,
  width: 3,
),
```
- 所有卡片都有 3px 黑色边框
- 圆角半径：20px
- 与内容区域的圆角差：17px（避免图片边缘溢出）

#### 3. **古铜色按钮**
```dart
backgroundColor: Color(0xFFCD7F32)  // 古铜色
```
- 颜色代码：`#CD7F32`
- 白色文字，阴影效果（elevation: 5）
- 圆角：25px
- 尺寸：横向 40px padding，纵向 12px padding

#### 4. **古铜金色光圈选中效果**
当卡片被选中时，会显示双层古铜金色光晕（柔和版本）：

**外层光晕**（金色，更柔和）：
```dart
BoxShadow(
  color: Color(0xFFD4AF37).withValues(alpha: 0.4),  // 金色 #D4AF37
  blurRadius: 25,
  spreadRadius: 5,
)
```

**内层光晕**（古铜色，更柔和）：
```dart
BoxShadow(
  color: Color(0xFFCD7F32).withValues(alpha: 0.5),  // 古铜色 #CD7F32
  blurRadius: 15,
  spreadRadius: 3,
)
```

**未选中状态**：
```dart
BoxShadow(
  color: Colors.black.withValues(alpha: 0.3),
  blurRadius: 10,
  spreadRadius: 2,
)
```

---

## 🔄 选中状态管理

### 实现方式
使用 `_currentIndex` 状态变量追踪当前选中的卡片：

```dart
int _currentIndex = 0;

// 轮播滑动时更新选中索引
onPageChanged: (index, reason) {
  setState(() {
    _currentIndex = index;
  });
}

// 判断是否选中
final isSelected = index == _currentIndex;
```

### 选中效果触发
- 初始状态：第一张卡片（index: 0）显示金色光圈
- 滑动轮播：自动更新选中卡片
- 平滑过渡：Flutter 自动处理阴影动画

---

## 🎯 视觉效果

### 卡片层次结构
```
Container (外层容器 - 黑色边框 + 阴影)
└── Column
    ├── Image (角色图片 - 占 flex: 3)
    └── Container (按钮区域 - 半透明黑色背景)
        └── ElevatedButton (古铜色按钮)
```

### 圆角处理
- 外层容器：20px
- 图片上方圆角：17px（适配 3px 边框）
- 按钮区域下方圆角：17px
- 按钮本身：25px

### 颜色方案
| 元素 | 颜色 | 说明 |
|------|------|------|
| 边框 | `#000000` | 纯黑色，3px |
| 按钮背景 | `#CD7F32` | 古铜色 |
| 按钮文字 | `#FFFFFF` | 白色 |
| 按钮区域背景 | `rgba(0,0,0,0.6)` | 半透明黑色 |
| 选中光晕（外） | `rgba(212,175,55,0.4)` | 金色（柔和） |
| 选中光晕（内） | `rgba(205,127,50,0.5)` | 古铜色（柔和） |
| 未选中阴影 | `rgba(0,0,0,0.3)` | 半透明黑色 |

---

## 📐 尺寸规格

### 卡片
- 宽度：300px
- 高度：由轮播组件控制（500px）
- 边框：3px

### 图片区域
- flex 比例：3
- 适应方式：`BoxFit.cover`
- 上方圆角：17px

### 按钮区域
- 内边距：16px
- 背景：半透明黑色
- 下方圆角：17px

### 按钮
- 横向 padding：40px
- 纵向 padding：12px
- 字体大小：18px
- 字体粗细：bold

---

## 🌟 特色亮点

### 1. 动态古铜金色光晕效果
- 选中卡片：双层古铜金色光晕，柔和而高级
- 颜色：内层古铜色 + 外层金色，更协调统一
- 强度：削弱透明度和扩散范围，更加优雅
- 未选中卡片：简单黑色阴影
- 自动切换：滑动时流畅过渡

### 2. 深色主题设计
- 黑色边框 + 半透明黑色背景
- 与剧场背景协调统一
- 突出角色图片

### 3. 古铜金色主题
- 按钮使用古铜色（#CD7F32）
- 光晕使用古铜色 + 金色渐变
- 整体色调统一协调
- 高级、复古的视觉风格

### 4. 极简布局
- 移除文字描述
- 只保留核心元素：图片 + 按钮
- 视觉焦点集中

---

## 🎨 设计理念

### 剧场主题
- 黑色边框：模拟舞台边框
- 金色光晕：舞台聚光灯效果
- 古铜色：复古剧场装饰元素

### 高级感
- 深色调：神秘、优雅
- 金属质感：古铜色 + 金色
- 精致细节：双层光晕、圆角过渡

### 互动体验
- 清晰的选中反馈
- 流畅的切换动画
- 视觉引导用户操作

---

## 🔧 代码关键点

### 选中状态判断
```dart
final isSelected = index == _currentIndex;
return _buildBoyfriendCard(boyfriend, isSelected);
```

### 条件渲染阴影
```dart
boxShadow: isSelected
    ? [金色双层光晕]
    : [黑色简单阴影]
```

### 半透明背景
```dart
color: Colors.black.withValues(alpha: 0.6)
```

### 古铜色定义
```dart
backgroundColor: const Color(0xFFCD7F32)
```

---

## 📝 调整建议

如需调整样式，可以修改以下参数：

### 光晕强度
```dart
// 增强光晕
blurRadius: 40,      // 原 30
spreadRadius: 12,    // 原 8

// 减弱光晕
blurRadius: 20,      // 原 30
spreadRadius: 4,     // 原 8
```

### 光晕颜色
```dart
// 更亮的金色
Color(0xFFFFD700).withValues(alpha: 0.8)  // 原 0.6

// 古铜色光晕（替代金色）
Color(0xFFCD7F32).withValues(alpha: 0.7)
```

### 边框粗细
```dart
width: 5,  // 更粗的边框（原 3）
width: 2,  // 更细的边框（原 3）
```

### 按钮颜色
```dart
// 金色按钮
backgroundColor: const Color(0xFFD4AF37)

// 银色按钮
backgroundColor: const Color(0xFFC0C0C0)
```

---

## 文件位置
`lib/pages/home_page.dart:90-166`
