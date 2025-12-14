import 'package:himx/models/user_model.dart';
import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';

class DadadogLogger {
  static void setUser(UserInfo user) {
    DatadogSdk.instance.setUserInfo(id: user.userId.toString(), name: user.nickName, email: user.email);
    DatadogSdk.instance.addUserExtraInfo({'plan': user.level.name, "isOrganic": true, "utmCampaign": ''});
  }

  static void logAction(RumActionType actionType, String actionName, Map<String, dynamic> attributes) {
    try {
      print('addRumAction $actionName $attributes ${DatadogSdk.instance.rum}');
      DatadogSdk.instance.rum?.addAction(actionType, actionName, attributes);
    } catch (e) {
      print('addRumAction error $e');
    }
  }
}
