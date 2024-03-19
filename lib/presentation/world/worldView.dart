import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_login/presentation/world/components/world_detail.dart';
import 'package:firebase_login/presentation/components/theme.dart';
import 'package:firebase_login/presentation/components/common_components.dart';
import 'package:provider/provider.dart';

class WorldView extends StatefulWidget {
  const WorldView({super.key});

  @override
  _WorldViewState createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MenuItem> _MenuItem = [];
  String _university = "대학교";
  int _currentTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(fetchDatatabControll);
    final userService = UserService.instance;

    userService.addListener(fetchDataUniversity);
  }

  @override
  void dispose() {
    _tabController.removeListener(fetchDatatabControll);
    _tabController.dispose();
    final userService = UserService.instance;
    userService.removeListener(fetchDataUniversity);

    super.dispose();
  }

  void fetchDatatabControll() async {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  void fetchDataUniversity() async {
    final userService = UserService.instance;

    if (userService.university!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _university = userService.university.toString();
        });
      }
    }
  }

  void buildMenuItem(BuildContext context) {
    if (_MenuItem.isEmpty) {
      _MenuItem.add(MenuItem(
          callback: () {
            setState(() {
              final ViewModel =
                  Provider.of<WorldViewModel>(context, listen: false);
              ViewModel.sortPostItemsBycreate();
              Navigator.pop(context);
            });
          },
          Content: '최신 등록 순',
          textColor: Colors.white));
      _MenuItem.add(MenuItem(
          callback: () {
            setState(() {
              final ViewModel =
                  Provider.of<WorldViewModel>(context, listen: false);
              ViewModel.sortPostItemsByview();
              Navigator.pop(context);
            });
          },
          Content: '조회수 순',
          textColor: Colors.white));
      _MenuItem.add(MenuItem(
          callback: () {
            setState(() {
              final ViewModel =
                  Provider.of<WorldViewModel>(context, listen: false);
              ViewModel.sortPostItemsBylike();
              Navigator.pop(context);
            });
          },
          Content: '좋아요 순',
          textColor: Colors.white));
    }
  }

  Widget _buildFloatingActionButton(WorldViewModel model) {
    if (_currentTabIndex == 1) {
      return FloatingActionButton.extended(
        backgroundColor: ColorStyles.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrashRequestForm(viewmodel: model),
            ),
          );
        },
        label: const Text(
          '수거 신청하기',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "SUIT"),
        ),
      );
    } else {
      return FloatingActionButton.extended(
        backgroundColor: ColorStyles.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostPage(
                model: model,
              ),
            ),
          ).then((returnValue) {
            if (returnValue != null) {
              setState(() {});
            }
          });
        },
        label: const Text(
          '글쓰기',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "SUIT",
              fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    buildMenuItem(context);
    return Consumer<WorldViewModel>(builder: (context, worldViewModel, child) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 20, 22, 25),
          automaticallyImplyLeading: false,
          title: Text(
            _university,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontFamily: "SUIT", fontSize: 22),
          ),
          actions: [
            if (_currentTabIndex != 1)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showOptions(context, '리스트 정렬', _MenuItem),
              ),
          ],
          bottom: TabBar(
            labelStyle: const TextStyle(
                fontFamily: "SUIT", fontSize: 16, fontWeight: FontWeight.bold),
            indicatorColor: ColorStyles.primary,
            indicatorPadding: const EdgeInsets.only(left: 20, right: 20),
            controller: _tabController,
            tabs: const [
              Tab(text: '커뮤니티'),
              Tab(text: '쓰레기 수거'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            CommunityPage(
              scaffoldKey: _scaffoldKey,
            ),
            const ReCyclePage(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(worldViewModel),
      );
    });
  }
}
