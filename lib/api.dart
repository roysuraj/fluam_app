import 'package:fluam_app/data/decoder/flarum/flarum.dart';
import 'package:fluam_app/io/http.dart';

import 'data/app/Flarum.dart';
import 'data/app/FlarumSite.dart';

class AppWebApi {
  /// get siteInfo with Url
  static Future<FlarumSiteInfo> getFlarumSiteData(String siteUrl) async {
    final httpStartTime = DateTime.now().millisecondsSinceEpoch;
    final r = await http!.get(siteUrl + "/api");
    final httpUsedTime = DateTime.now().millisecondsSinceEpoch - httpStartTime;
    return FlarumSiteInfo.formDataAndConnectionTime(
        FlarumSiteData.formBase(FlarumBaseData.formJson(r.body)), httpUsedTime);
  }

  /// get getDiscussionsList with siteData
  static Future<FlarumDiscussionsInfo> getDiscussionsList(
      FlarumSiteInfo site, int index) async {
    index = index * 20;
    return getDiscussionsListWithUrl(
        site,
        "${site.data.apiUrl}/"
        "discussions?include=user,lastPostedUser,firstPost,tags&sort&page[offset]=$index");
  }

  static Future<FlarumDiscussionsInfo> getDiscussionsListWithUrl(
      FlarumSiteInfo site, String url) async {
    final r = await http!.get(url);
    return FlarumDiscussionsInfo(site,
        FlarumDiscussionsData.formBase(FlarumBaseData.formJson((r.body))));
  }

  static AppHttp? _h;

  static AppHttp? get http {
    if (_h == null) {
      _h = AppHttp();
    }
    return _h;
  }
}
