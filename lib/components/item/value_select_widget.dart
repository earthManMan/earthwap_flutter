import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/components/apply_button_widget.dart';
import 'package:flutter/services.dart';

class ValueRangeButton extends StatefulWidget {
  final String _text;
  final Function(int, int, int) _onPressed;
  int userPrice;
  int priceStart;
  int priceEnd;
  ValueRangeButton(
      {required text,
      required this.userPrice,
      required this.priceStart,
      required this.priceEnd,
      required Function(int, int, int) call,
      super.key})
      : _text = text,
        _onPressed = call;

  @override
  _ValueRangeButtonState createState() => _ValueRangeButtonState();
}

class _ValueRangeButtonState extends State<ValueRangeButton> {
  RangeValues _currentRangeValues = const RangeValues(-50, 50);
  late TextEditingController _priceController;

  bool isValue = false;

  @override
  void initState() {
    super.initState();
    if (widget.userPrice == 0) {
      _priceController = TextEditingController();
      isValue = false;
    } else {
      _priceController =
          TextEditingController(text: widget.userPrice.toString());
      isValue = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorStyles.text, width: 1.0),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: const Color.fromARGB(255, 20, 22, 25),
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 50,
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text(
                                    "가격범위",
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.white,
                                    onPressed: () => {Navigator.pop(context)},
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 1,
                              color: ColorStyles.background,
                            ),
                            SizedBox(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      enableInteractiveSelection: true,
                                      controller: _priceController, // 컨트롤러 설정
                                      onChanged: (value) {
                                        // 사용자가 입력한 가격을 double로 파싱
                                        //widget.userPrice =
                                        //   double.tryParse(value) ?? 0;
                                        isValue = true;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9.]'),
                                        ),
                                      ],
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '가격 입력',
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                      ),
                                      textAlign:
                                          TextAlign.right, // 텍스트를 오른쪽 정렬로 설정
                                    ),
                                  ),
                                  if (isValue) const Text("원"),
                                ],
                              ),
                            ),
                            if (isValue)
                              SizedBox(
                                height: 100,
                                child: Column(
                                  children: <Widget>[
                                    RangeSlider(
                                      values: _currentRangeValues,
                                      min: -50,
                                      max: 50,
                                      divisions: 20,
                                      activeColor: ColorStyles.primary,
                                      inactiveColor: const Color.fromARGB(
                                          255, 120, 120, 128),
                                      labels: RangeLabels(
                                        "${_currentRangeValues.start.round()}%",
                                        "${_currentRangeValues.end.round()}%",
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          widget.priceStart =
                                              int.parse(_priceController.text) +
                                                  ((values.start * 0.01) *
                                                          int.parse(
                                                              _priceController
                                                                  .text))
                                                      .toInt();

                                          widget.priceEnd =
                                              int.parse(_priceController.text) +
                                                  ((values.end * 0.01) *
                                                          int.parse(
                                                              _priceController
                                                                  .text))
                                                      .toInt();

                                          _currentRangeValues = values;
                                        });
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${(_currentRangeValues.start.round()).clamp(-50, 50)}%",
                                          style: const TextStyle(
                                            color: ColorStyles.primary,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          "${(_currentRangeValues.end.round()).clamp(-50, 50)}%",
                                          style: const TextStyle(
                                            color: ColorStyles.primary,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              height: 1,
                              color: ColorStyles.background,
                            ),
                            SizedBox(
                              height: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                        icon: const Icon(
                                            Icons.rotate_right_sharp),
                                        color: Colors.white,
                                        onPressed: () => {
                                          setState(() {
                                            widget.priceStart = ((-50 * 0.01) *
                                                    int.parse(
                                                        _priceController.text))
                                                .toInt();

                                            widget.priceEnd = ((50 * 0.01) *
                                                    int.parse(
                                                        _priceController.text))
                                                .toInt();

                                            _currentRangeValues =
                                                const RangeValues(-50, 50);
                                          })
                                        },
                                      ),
                                      const Text(
                                        "초기화",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ApplyButton(onApply: () {
                                    widget.priceStart =
                                        int.parse(_priceController.text) +
                                            ((_currentRangeValues.start *
                                                        0.01) *
                                                    int.parse(
                                                        _priceController.text))
                                                .toInt();

                                    widget.priceEnd =
                                        int.parse(_priceController.text) +
                                            ((_currentRangeValues.end * 0.01) *
                                                    int.parse(
                                                        _priceController.text))
                                                .toInt();

                                    widget._onPressed(
                                        int.parse(_priceController.text),
                                        widget.priceStart,
                                        widget.priceEnd);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget._text,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              "${widget.priceStart}원 ~ ${widget.priceEnd}원",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 20.0),
          ],
        ),
      ),
    );
  }
}
