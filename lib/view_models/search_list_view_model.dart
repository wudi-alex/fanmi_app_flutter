import 'package:fanmi/config/page_size_config.dart';
import 'package:fanmi/entity/card_preview_entity.dart';
import 'package:fanmi/enums/card_type_enum.dart';
import 'package:fanmi/enums/search_enum.dart';
import 'package:fanmi/net/card_service.dart';
import 'package:fanmi/view_models/view_state_refresh_list_model.dart';

class SearchListViewModel extends ViewStateRefreshListModel<CardPreviewEntity> {
  String? searchWord;
  int rankType = SearchRankTypeEnum.DEFAULT;
  CardTypeEnum cardTypeEnum = CardTypeEnum.ALL;
  int? genderFilter;

  @override
  int get pageSize => PageSizeConfig.SEARCH_PAGE_SIZE;

  @override
  Future<List<CardPreviewEntity>> loadData({int? pageNum}) async {
    if (searchWord != null && searchWord != "") {
      var res = await CardService.cardSearch(
        searchWord: searchWord!,
        rankType: rankType,
        page: pageNum!,
        genderFilter: genderFilter,
        cardFilter:
            cardTypeEnum != CardTypeEnum.ALL ? cardTypeEnum.value : null,
      );
      return res;
    } else {
      var res = await CardService.cardRec(
        rankType: rankType,
        page: pageNum!,
        genderFilter: genderFilter,
        cardFilter:
            cardTypeEnum != CardTypeEnum.ALL ? cardTypeEnum.value : null,
      );
      return res;
    }
  }

  setSearchWord(String word) {
    searchWord = word;
    notifyListeners();
  }

  setCardType(CardTypeEnum cardType) async {
    cardTypeEnum = cardType;
    notifyListeners();
    await initData();
  }

  setGenderFilter(int? gender) async {
    genderFilter = gender;
    notifyListeners();
    await initData();
  }

  setRankType(int type) async {
    rankType = type;
    notifyListeners();
    await initData();
  }
}
