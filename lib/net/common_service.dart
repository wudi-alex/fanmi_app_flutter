import 'package:fanmi/utils/storage_manager.dart';

import 'http_client.dart';

class CommonService {
  static Future getQiniuToken() async {
    var resp = await http.get('/common/get_qiniu_token');
    return resp.data;
  }

  static Future upLoadContactQr(
      {required String qrUrl, required String qrType}) async {
    var resp = await http.post('/common/upload_contact_qr',
        data: {'qr_url': qrUrl, 'qr_type': qrType});
    return resp;
  }

  static Future verifyImg({required String imgUrl}) async {
    var resp = await http.post('/common/verify_img',
        data: {'uid': StorageManager.uid, 'img_url': imgUrl});
    return resp;
  }

  static Future getTimSig({required int uid}) async {
    var resp = await http.post('/common/verify_img', data: {
      'uid': uid,
    });
    return resp;
  }

  static Future agreeAutoResp({
    required String fromAccount,
    required String text,
    String? wxQrUrl,
    String? qqQrUrl,
  }) async {
    var resp = await http.post('/im/agree_auto_resp', data: {
      "from_account": fromAccount,
      "to_account": StorageManager.uid.toString(),
      "text": text,
      "wx_qr_url": wxQrUrl,
      "qq_qr_url": qqQrUrl,
    });
    return resp;
  }
}
