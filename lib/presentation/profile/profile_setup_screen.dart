import 'package:flutter/material.dart';
import 'package:firebase_login/app/style/app_color.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_login/app/config/constant.dart';
import 'package:firebase_login/presentation/common/widgets/toast_widget.dart';

class ProfileSetUpScreen extends StatefulWidget {
  const ProfileSetUpScreen({
    super.key,
  });

  @override
  _ProfileSetUpScreenState createState() => _ProfileSetUpScreenState();
}

class _ProfileSetUpScreenState extends State<ProfileSetUpScreen> {
  bool _isPick = false;
  String? _pickImg;
  String? _selectedProvince; // 변경: null로 초기화
  String? _selectedDistrict; // 변경: null로 초기화
  late Map<String, List<String>> _locations;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _locations = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);
    _locations = viewmodel.getLocationService().locations;
  }

  Future getImage() async {
    final _user = UserService.instance;
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      viewmodel
          .uploadImage(UploadType.profile, _user.uid.toString(), pickedFile)
          .then((url) {
        if (url != null) {
          _user.setProfileImage(url);
        }
      });
      setState(() {
        _pickImg = pickedFile.path;
        _isPick = true;
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = UserService.instance;
    final viewmodel = Provider.of<MypageViewModel>(context, listen: false);

    return PlatformScaffold(
      backgroundColor: AppColor.gray1C,
      appBar: PlatformAppBar(
        backgroundColor: Colors.transparent,
        material: (context, platform) {
          return MaterialAppBarData(
            centerTitle: true,
          );
        },
        title: const Text('프로필 설정',
            style: TextStyle(
                fontFamily: "SUIT", fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: MediaQuery.of(context).padding.top +
                (Platform.isIOS ? kToolbarHeight : 0)),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _pickImg == null
                    ? null
                    : FileImage(File(_pickImg!)) as ImageProvider<Object>,
                child: _isPick == false
                    ? const Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: AppColor.grayF9,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20.0),
            Text("닉네임을 입력해주세요",
                style: TextStyle(
                    fontFamily: "SUIT",
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            PlatformTextField(
              keyboardAppearance: Brightness.dark,
              enableInteractiveSelection: true,
              hintText: "닉네임",
              style: const TextStyle(
                fontSize: 16,
                color: AppColor.grayF9,
                fontWeight: FontWeight.bold,
              ),
              cupertino: (context, platform) {
                return CupertinoTextFieldData(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColor.grayF9,
                        width: 0.5, // Adjust the width as needed
                      ),
                    ),
                  ),
                );
              },
              controller:
                  TextEditingController(text: _user.nickname.toString()),
              onChanged: (value) {
                _user.setNickname(value);
              },
            ),
            const SizedBox(height: 20.0),
            Text("자기 소개를 해주세요",
                style: TextStyle(
                    fontFamily: "SUIT",
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            PlatformTextField(
              enableInteractiveSelection: true,
              hintText: '자기소개',
              style: const TextStyle(
                fontSize: 16,
                color: AppColor.grayF9,
                fontWeight: FontWeight.bold,
              ),
              cupertino: (context, platform) {
                return CupertinoTextFieldData(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColor.grayF9,
                        width: 0.5, // Adjust the width as needed
                      ),
                    ),
                  ),
                );
              },
              controller: TextEditingController(
                text: _user.description.toString(), // 초기값은 _controller에서 가져오기
              ),
              onChanged: (value) {
                // onChanged 콜백 함수 내에서 _controller를 업데이트
                _user.setDescription(value);
              },
            ),
            const SizedBox(height: 20.0),
            Text("거래 희망 지역을 선택해주세요",
                style: TextStyle(
                    fontFamily: "SUIT",
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Container(
                child: _buildProvinceDropdown()
            ),
            const SizedBox(height: 20.0),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/main');
                    showtoastMessage("안녕하세요. 어스왑입니다~", toastStatus.success);

                    viewmodel.updateProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                        fontFamily: "SUIT",
                        fontSize: 20,
                        color: AppColor.grayF9,
                        fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }
Widget _buildProvinceDropdown() {
  return Platform.isIOS
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 30.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedProvince = _locations.keys.toList()[index];
                          _selectedDistrict = null;
                        });
                      },
                      children: _locations.keys
                          .map((String province) => Text(
                                province,
                                style: TextStyle(
                                  fontFamily: "SUIT",
                                  fontSize: 16,
                                                                  color: AppColor.grayF9,

                                  fontWeight: FontWeight.bold,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
              child: Text(
                _selectedProvince ?? 'Select Province',
                style: TextStyle(
                  fontFamily: "SUIT",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selectedProvince != null)
              SizedBox(height: 20),
            if (_selectedProvince != null) _buildDistrictDropdown(),
          ],
        )
      : DropdownButton<String>(
          value: _selectedProvince,
          onChanged: (String? newValue) {
            setState(() {
              _selectedProvince = newValue;
              _selectedDistrict = null; 
            });
          },
          items: _locations.keys.map((String province) {
            return DropdownMenuItem<String>(
              value: province,
              child: Text(
                province,
                style: TextStyle(
                  fontFamily: "SUIT",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        );
}
Widget _buildDistrictDropdown() {
  return Platform.isIOS
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CupertinoButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    child: CupertinoPicker(
                      itemExtent: 30.0,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDistrict =
                              _locations[_selectedProvince]![index];
                        });
                      },
                      children: _locations[_selectedProvince]!
                          .map(
                            (String district) => Text(
                              district,
                              style: TextStyle(
                                color: AppColor.grayF9,
                                fontFamily: "SUIT",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: Text(
                _selectedDistrict ?? 'Select District',
                style: TextStyle(
                  fontFamily: "SUIT",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
      : DropdownButton<String>(
          value: _selectedDistrict,
          onChanged: (String? newValue) {
            setState(() {
              _selectedDistrict = newValue;
            });
          },
          items: _locations[_selectedProvince]!
              .map<DropdownMenuItem<String>>((String district) {
            return DropdownMenuItem<String>(
              value: district,
              child: Text(
                district,
                style: TextStyle(
                  fontFamily: "SUIT",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        );
}
}
