import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/viewModel/registerViewModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/view/register/components/register_detail.dart';
import 'package:firebase_login/components/common_components.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late List<Map<String, String>> universityList = [];
  TextEditingController textSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 데이터를 초기에 가져오기
    fetchData();
  }

  Future<void> fetchData() async {
    final ViewModel = Provider.of<RegisterViewModel>(context, listen: false);
    if (ViewModel.model.universityList.isEmpty) {
      final re = await ViewModel.getUniversityList();
      if (re == true) {
        if (mounted) {
          setState(() {
            universityList = ViewModel.model.universityList;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          universityList = ViewModel.model.universityList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // The future is complete; build the UI
          return buildUI();
        } else {
          // Show a loading indicator while waiting for the future
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/components/background.png'),
              ),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget buildUI() {
    return Consumer<RegisterViewModel>(
      builder: (context, registerViewModel, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/components/background.png'), // 배경 이미지
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 240, 244, 248), //색변경
              ),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  registerViewModel.setUniversity("");
                  Navigator.of(context).pop();
                },
              ),
            ),
            backgroundColor: Colors.transparent, // 배경색을 투명으로 설정
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 30),
                  /* Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: Center(
                        child: Text(
                      "WELCOME TO\n EARTHWAP!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: ColorStyles.primary),
                    )),
                  ),*/
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                        child: Text(
                      "재학중인 대학교를 입력해주세요!",
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: UniInput(
                      dataList: universityList,
                      textSearchController: textSearchController,
                    ),
                    // 사용자로 부터 그냥 대학교 입력 받는 UI
                    /*child: CustomTextInput(
                      controller:
                          _controller)
                          */
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: TextRoundButton(
                      text: "START",
                      enable: registerViewModel.isValid_uni(),
                      call: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuthEmailLayout(viewmodel: registerViewModel),
                          ),
                        );
                      },
                    ),
                  ),
                  /*
                  StartButton(
                    viewmodel: registerViewModel,
                    isEnabled: registerViewModel.isValid_uni(),
                  ),*/
                  const LoginButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StartButton extends StatelessWidget {
  final bool isEnabled;
  final RegisterViewModel _registerViewModel;

  const StartButton(
      {required RegisterViewModel viewmodel, isEnabled, super.key})
      : _registerViewModel = viewmodel,
        isEnabled = isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorStyles.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: isEnabled
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AuthEmailLayout(viewmodel: _registerViewModel),
                  ),
                );
              }
            : null,
        child: const Text(
          'START',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.05,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          const Text('이미 계정이 있으신가요? 바로',
              style: TextStyle(color: ColorStyles.text)),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextButton(
                onPressed: () {
                  // Login Page로 이동
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('로그인하세요',
                    style: TextStyle(
                        fontFamily: "SUIT",
                        fontWeight: FontWeight.bold,
                        color: ColorStyles.primary))),
          )
        ]));
  }
}

class CustomTextInput extends StatefulWidget {
  final RegisterViewModel _viewmodel;

  const CustomTextInput({required RegisterViewModel viewmodel, super.key})
      : _viewmodel = viewmodel;

  @override
  _CustomTextInputState createState() => _CustomTextInputState();
}

class _CustomTextInputState extends State<CustomTextInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isInputFocused = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          enableInteractiveSelection: true,
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: _isInputFocused
                ? null
                : const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
            hintText: "대학교를 입력해주세요",
            hintStyle: const TextStyle(color: Colors.blue),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            suffixIcon: _isInputFocused
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        widget._viewmodel.setUniversity("");
                        _isInputFocused = false;
                      });
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (text) {
            setState(() {
              widget._viewmodel.setUniversity(text);
              _isInputFocused = true;
            });
          },
        ),
      ],
    );
  }
}

class UniInput extends StatefulWidget {
  List<Map<String, String>> dataList;
  TextEditingController textSearchController;
  UniInput(
      {required this.dataList, required this.textSearchController, super.key});

  @override
  _UniInputState createState() => _UniInputState();
}

class _UniInputState extends State<UniInput> {
  bool isUniversitySelected = false;
  String selectedID = ""; // 선택된 대학 ID를 저장할 변수

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<RegisterViewModel>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            enableInteractiveSelection: true,
            controller: widget.textSearchController,
            onChanged: (query) {
              filterData(query);
            },
            decoration: InputDecoration(
              hintText: "대학교를 검색해주세요",
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              suffixIcon: isUniversitySelected
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          isUniversitySelected = false;
                          selectedID = "";
                          widget.textSearchController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        if (!isUniversitySelected &&
            widget.textSearchController.text.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            child: ListView.builder(
              cacheExtent: 1000,
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredList[index]["id"] ?? ""),
                  onTap: () {
                    setState(() {
                      isUniversitySelected = true;
                      selectedID = filteredList[index]["id"] ?? "";
                      // 선택된 대학 ID에 해당하는 도메인 정보 가져오기
                      String selectedDomain = widget.dataList.firstWhere(
                              (item) => item["id"] == selectedID,
                              orElse: () => {"domain": "도메인 없음"})["domain"] ??
                          "도메인 없음";
                      ViewModel.setUniversity(selectedID);
                      ViewModel.setDomain(selectedDomain);
                      widget.textSearchController.text = selectedID;
                    });
                  },
                );
              },
            ),
          )
      ],
    );
  }

  List<Map<String, String>> filteredList = [];

  void filterData(String query) {
    setState(() {
      filteredList = widget.dataList
          .where((item) =>
              item["id"]?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    });
  }
}
