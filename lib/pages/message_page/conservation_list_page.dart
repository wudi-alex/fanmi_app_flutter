
import 'package:fanmi/view_models/conversion_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ConversionListPage extends StatefulWidget {
  @override
  _ConversionListPageState createState() => _ConversionListPageState();
}

class _ConversionListPageState extends State<ConversionListPage> {
  @override
  Widget build(BuildContext context) {
    ConversionListModel conversionListModel =
        Provider.of<ConversionListModel>(context);

    return ListView();
  }
}
