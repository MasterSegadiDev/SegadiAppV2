import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/viewmodels/services_operator/detail_service.dart';

class StatusSupport extends StatefulWidget {
  @override
  _StatusSupport createState() => _StatusSupport();
}

class _StatusSupport extends State<StatusSupport> {
  @override
  Widget build(BuildContext context) {
    // String status = '';

    Color? cardBackgroundColor24;
    Color? cardBackgroundColor22;
    Color? cardBackgroundColor38;
    Color? cardBackgroundColor39;

    Color? coloricon24;
    Color? coloricon22;
    Color? coloricon38;
    Color? coloricon39;
    final detail = Provider.of<DetailViewModel>(context);

    if (detail.item!.statusId == 24 && detail.item!.type == 'begin') {
      cardBackgroundColor24 = Colors.white;
      cardBackgroundColor22 = Colors.grey;
      cardBackgroundColor38 = Colors.grey;
      cardBackgroundColor39 = Colors.grey;

      coloricon24 = Colors.blue;
      coloricon22 = Colors.white;
      coloricon38 = Colors.white;
      coloricon39 = Colors.white;
    }
    if (detail.item!.statusId == 22 && detail.item!.type == 'begin') {
      cardBackgroundColor24 = Colors.grey;
      cardBackgroundColor22 = Colors.white;
      cardBackgroundColor38 = Colors.grey;
      cardBackgroundColor39 = Colors.grey;

      coloricon24 = Colors.white;
      coloricon22 = Colors.orange;
      coloricon38 = Colors.white;
      coloricon39 = Colors.white;
    }
    if (detail.item!.statusId == 38 && detail.item!.type == 'begin') {
      cardBackgroundColor24 = Colors.grey;
      cardBackgroundColor22 = Colors.grey;
      cardBackgroundColor38 = Colors.white;
      cardBackgroundColor39 = Colors.grey;

      coloricon24 = Colors.white;
      coloricon22 = Colors.white;
      coloricon38 = Colors.black;
      coloricon39 = Colors.white;
    }
    if (detail.item!.statusId == 39 && detail.item!.type == 'begin') {
      cardBackgroundColor24 = Colors.grey;
      cardBackgroundColor22 = Colors.grey;
      cardBackgroundColor38 = Colors.grey;
      cardBackgroundColor39 = Colors.white;

      coloricon24 = Colors.white;
      coloricon22 = Colors.white;
      coloricon38 = Colors.white;
      coloricon39 = Colors.green;
    }

    if (detail.item!.type == '') {
      coloricon24 = Colors.blue;
      coloricon22 = Colors.orange;
      coloricon38 = Colors.black;
      coloricon39 = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: SizedBox(
        width: 300,
        height: 300,
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(10.0),
          childAspectRatio: 8.0 / 9.0,
          children: <Widget>[
            GestureDetector(
              onTap: detail.item!.isButtonEnabledBano!
                  ? () async {
                      await detail.changeStatusSupport(
                          24, detail.item!.statusSupportModal!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Card(
                color: cardBackgroundColor24,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 50,
                          color: coloricon24,
                          image: AssetImage("assets/images/toilet.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: detail.item!.isButtonEnabledComer!
                  ? () async {
                      await detail.changeStatusSupport(
                          22, detail.item!.statusSupportModal!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Card(
                color: cardBackgroundColor22,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 50,
                          color: coloricon22,
                          image: AssetImage("assets/images/restaurant.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: detail.item!.isButtonEnabledDormir!
                  ? () async {
                      await detail.changeStatusSupport(
                          38, detail.item!.statusSupportModal!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Card(
                color: cardBackgroundColor38,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 50,
                          color: coloricon38,
                          image: AssetImage("assets/images/sleeping.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: detail.item!.isButtonEnabledGas!
                  ? () async {
                      await detail.changeStatusSupport(
                          39, detail.item!.statusSupportModal!);
                      Navigator.pop(context);
                    }
                  : null,
              child: Card(
                color: cardBackgroundColor39,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SizedBox(
                        child: Image(
                          width: 50,
                          height: 50,
                          color: coloricon39,
                          image: AssetImage("assets/images/gas.png"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
