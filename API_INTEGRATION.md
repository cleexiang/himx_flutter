# API 对接说明

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── models/                        # 数据模型
│   ├── boyfriend.dart             # 男友模型
│   ├── character_settings.dart    # 角色设定模型
│   └── chat_message.dart          # 聊天消息模型
├── pages/                         # 页面
│   ├── home_page.dart             # 首页（男友列表）
│   ├── character_settings_page.dart  # 角色设定页
│   └── dating_page.dart           # 约会页（主要交互页）
├── services/                      # 服务层
│   └── api_service.dart           # API服务（需要对接）
└── widgets/                       # 自定义组件（暂时为空）
```

## 需要对接的API接口

### 1. 获取男友列表

**文件位置**: `lib/services/api_service.dart:22`

```dart
Future<List<Boyfriend>> getBoyfriendList() async
```

**请求方式**: GET
**接口路径**: `/boyfriends`
**返回数据格式**:

```json
{
  "data": [
    {
      "id": "1",
      "name": "温柔绅士",
      "imageUrl": "https://example.com/image1.jpg",
      "videoUrl": "https://example.com/video1.mp4",  // 可选
      "description": "温柔体贴的绅士型男友"
    }
  ]
}
```

**当前状态**: 使用本地模拟数据（lib/pages/home_page.dart:17）

---

### 2. 发送聊天消息

**文件位置**: `lib/services/api_service.dart:38`

```dart
Future<String> sendChatMessage({
  required String boyfriendId,
  required String message,
  required String nickname,
  required String personality,
  required String userNickname,
}) async
```

**请求方式**: POST
**接口路径**: `/chat`
**请求参数**:

```json
{
  "boyfriendId": "1",
  "message": "用户发送的消息",
  "nickname": "给男友的称呼",
  "personality": "性格喜好描述",
  "userNickname": "男友对用户的称呼"
}
```

**返回数据格式**:

```json
{
  "reply": "AI男友的回复消息"
}
```

**当前状态**: 返回固定模拟消息（lib/pages/dating_page.dart:70）

---

### 3. 保存角色设定

**文件位置**: `lib/services/api_service.dart:69`

```dart
Future<void> saveCharacterSettings({
  required String boyfriendId,
  required String nickname,
  required String personality,
  required String userNickname,
}) async
```

**请求方式**: POST
**接口路径**: `/settings`
**请求参数**:

```json
{
  "boyfriendId": "1",
  "nickname": "给男友的称呼",
  "personality": "性格喜好描述",
  "userNickname": "男友对用户的称呼"
}
```

**当前状态**: 仅保存到本地（暂未实现持久化）

---

## 如何对接API

### 步骤 1: 修改API基础URL

在 `lib/services/api_service.dart` 中修改 `baseUrl`:

```dart
_dio = Dio(BaseOptions(
  baseUrl: 'https://your-api-url.com/api',  // 修改为你的API地址
  ...
));
```

### 步骤 2: 在首页使用API获取男友列表

修改 `lib/pages/home_page.dart`:

```dart
class _HomePageState extends State<HomePage> {
  List<Boyfriend> boyfriends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoyfriends();
  }

  Future<void> _loadBoyfriends() async {
    try {
      final data = await ApiService().getBoyfriendList();
      setState(() {
        boyfriends = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // 显示错误提示
    }
  }

  // ...
}
```

### 步骤 3: 在约会页面使用API发送聊天消息

修改 `lib/pages/dating_page.dart` 的 `_sendMessage` 方法:

```dart
void _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final userMessage = ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: _messageController.text,
    isUser: true,
    timestamp: DateTime.now(),
  );

  setState(() {
    _messages.add(userMessage);
    _isLoading = true;
  });

  final messageText = _messageController.text;
  _messageController.clear();
  _scrollToBottom();

  try {
    // 调用API发送消息
    final reply = await ApiService().sendChatMessage(
      boyfriendId: widget.boyfriend.id,
      message: messageText,
      nickname: widget.settings.nickname,
      personality: widget.settings.personality,
      userNickname: widget.settings.userNickname,
    );

    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
      _isLoading = false;
    });

    _scrollToBottom();
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    // 显示错误提示
  }
}
```

---

## 运行项目

```bash
# 安装依赖
flutter pub get

# 运行应用（iOS模拟器）
flutter run

# 运行应用（Android模拟器）
flutter run

# 运行应用（Chrome浏览器）
flutter run -d chrome
```

---

## 注意事项

1. **视频URL**: 如果男友数据包含视频URL，应用会优先显示视频；否则显示图片
2. **图片资源**: 当前使用网络图片，如需使用本地图片，将图片放入 `assets/images/` 并修改引用路径
3. **错误处理**: 建议在API调用处添加完善的错误处理和重试机制
4. **聊天历史**: 当前聊天记录仅保存在内存中，退出页面会丢失，如需持久化请使用本地数据库
5. **性能优化**: 聊天消息过多时建议实现分页加载

---

## 待开发功能

右侧功能按钮（Date、Sing、Diary、Gift）目前仅显示"功能开发中"提示，具体功能可后续扩展。
