import 'http_client.dart';

class UserService{
  static Future getUserInfo({required int uid}) async {
    var resp = await http.post('/user/get_user_info', data: {"uid": uid});
    return resp;
  }
}