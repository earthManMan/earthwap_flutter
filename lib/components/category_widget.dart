import 'package:flutter/material.dart';
import 'package:firebase_login/components/theme.dart';
import 'package:firebase_login/components/apply_button_widget.dart';

typedef CategorySelectionCallback = void Function(
    List<String> selectedCategories);

class CategorySelectionPage extends StatefulWidget {
  final CategorySelectionCallback? onPressed;
  List<String> categories = [];
  List<String> selected = [];
  List<int> selectedCategoryIndices = [];
  bool isSingleSelection;

  CategorySelectionPage({
    super.key,
    this.onPressed,
    required this.categories,
    required this.selected,
    this.isSingleSelection = false, // 기본값은 다중 선택
  }) {
    selectedCategoryIndices = List.generate(categories.length, (index) {
      if (selected.contains(categories[index])) {
        return index;
      }
      return -1; // 선택되지 않은 경우 -1을 반환
    }).where((index) => index != -1).toList();
  }

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(size: 20, Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('카테고리',
            style: TextStyle(
                color: Color.fromARGB(255, 241, 240, 240),
                fontFamily: "SUIT",
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 22, 25),
        actions: <Widget>[
          if (!widget.isSingleSelection)
            TextButton(
              onPressed: () {
                setState(() {
                  widget.selectedCategoryIndices =
                      List.generate(widget.categories.length, (index) => index);
                });
              },
              child: const Text(
                "전체선택",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < widget.categories.length; i++)
              Row(
                children: [
                  Expanded(
                    child: Text(widget.categories[i]),
                  ),
                  Checkbox(
                    value: widget.selectedCategoryIndices.contains(i),
                    activeColor: ColorStyles.primary,
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          if (widget.isSingleSelection) {
                            // 단일 선택인 경우 현재 선택된 항목 제거
                            widget.selectedCategoryIndices.clear();
                          }
                          widget.selectedCategoryIndices.add(i);
                        } else {
                          widget.selectedCategoryIndices.remove(i);
                        }
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 20, 22, 25),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.selectedCategoryIndices = [];
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.rotate_right,
                      size: 30,
                      color: Colors.white,
                      weight: 50,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "초기화",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ApplyButton(onApply: () {
                List<String> selectedCategories = widget.selectedCategoryIndices
                    .map((index) => widget.categories[index])
                    .toList();
                if (widget.onPressed != null) {
                  widget.onPressed!(selectedCategories);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String text;

  const CategoryItem({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: const BorderSide(
            width: 1, // the thickness
            color: Color.fromARGB(255, 255, 255, 255) // the color of the border
            ),
        backgroundColor: Colors.black,
        animationDuration: Duration.zero, // No animation
        splashFactory: NoSplash.splashFactory, // No splash effect

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      onPressed: null,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.0,
          //fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class CategoryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CategoryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CurvedAnimation _animation;
  List<Widget> additionalButtons = [];

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addButtonWithAnimation(String str) {
    setState(() {
      additionalButtons.add(
        Padding(
            padding: const EdgeInsets.all(5),
            child: FadeTransition(
              opacity: _animation,
              child: CategoryItem(text: str),
            )),
      );
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ColorStyles.text, width: 1.0),
            ),
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              backgroundColor: const Color.fromARGB(255, 20, 22, 25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_forward, size: 20.0),
              ],
            ),
          ),
        ),
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: additionalButtons,
            ),
          ),
        ),
      ],
    );
  }
}
