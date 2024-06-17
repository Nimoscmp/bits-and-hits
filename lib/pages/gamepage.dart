//import 'dart:js_util';

import 'dart:async';

import 'package:flutter/material.dart';

class Gamepage extends StatefulWidget {
  const Gamepage({super.key});

  @override
  State<Gamepage> createState() => _GamepageState();
}

class _GamepageState extends State<Gamepage> {
  @override
  void initState() {
    super.initState();
    numberToReveal = generateRandomNumber();
  }

  Timer? timer;
  List<int> writtenNumbers = [];
  List<int> numberToReveal = [];
  List<TableRow> tableResults = [];
  int bits = 0;
  int hits = 0;
  int attempts = 0;
  BorderSide tableBorder = BorderSide(width: 0.5, color: Colors.grey.shade600);
  ScrollController tableScrollController = ScrollController();

  List<Text> setHeadTexts(List<String> texts) {
    List<Text> headTexts = [];

    for(final text in texts) {
      headTexts.add(
        Text(
          text,
          textAlign: TextAlign.center,
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.teal[600]),
        )
      );
    }

    return headTexts;
  }

  List<Text> setResultTexts(List<String> texts) {
    List<Text> resultTexts = [];

    for(final text in texts) {
      resultTexts.add(Text(text, textAlign: TextAlign.center, textScaleFactor: 1.5));
    }

    return resultTexts;
  }
  
  List<int> generateRandomNumber() {
    List<int> digits = List.generate(10, (index) => index); // Create a list of digits 0-9
    // Shuffle the list of digits
    digits.shuffle();

    List<int> number = [];

    for (int i = 0; i < 4; i++) {
      number.add(digits[i]);
    }

    return number;
  }

  bool preventWriting(int number) {
    if (writtenNumbers.isEmpty) {
      return false;
    }

    if (writtenNumbers.length == 4) {
      return true;
    }

    for (var char in writtenNumbers) {
      if (number == char) return true;
    }

    return false;
  }

  void resetGame() {
    setState(() {
      numberToReveal = generateRandomNumber();
      writtenNumbers.clear();
      tableResults.clear();
      bits = 0;
      hits = 0;
      attempts = 0;
    });
  }

  void calculateBitsAndHits() {
    for (int i = 0; i < 4; i++) {
      int writtenNumber = writtenNumbers[i];
      int indexOf = numberToReveal.indexOf(writtenNumber);

      if (indexOf == i) {
        hits += 1;
      } else if (indexOf != -1) {
        bits += 1;
      }
    }
  }

  void checkBitsAndHits() {
    if (hits == 4) {
      String winNumber = numberToReveal.join("");
      _dialogBuilder(
        context,
        "You won",
        "You found out the number $winNumber in $attempts attemps!\nCongratulations!",
        false,
        true,
        resetGame,
        true
      );
    }
  }

  void saveNumberInTable() {
    calculateBitsAndHits();
    tableResults.add(TableRow(
        children: setResultTexts([writtenNumbers.join(""), bits.toString(), hits.toString()])
    ));
    checkBitsAndHits();
    bits = 0;
    hits = 0;
  }

  void tableScrollDown() {
    if (tableScrollController.hasClients) {
      final position = tableScrollController.position.maxScrollExtent + 40;

      tableScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _dialogBuilder(
      BuildContext context,
      String title,
      String content,
      bool barrierDismisable,
      bool hideCancel,
      Function? onPressed,
      bool? acceptBgColor,
    ) {
    List<Widget> textButtons = [
      TextButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
          backgroundColor: acceptBgColor != null ? const Color(0xFFFF9000) : Colors.transparent
        ),
        child: const Text('Accept'),
        onPressed: () {
          if(onPressed != null) {
            onPressed();
          }

          Navigator.of(context).pop();
        },
      )
    ];

    if (!hideCancel) {
      textButtons.add(
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
            backgroundColor: const Color(0xFFFF9000),
          ),
          child: const Text('Cancel', style: TextStyle(color: Colors.white),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismisable,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: textButtons,
        );
      },
    );
  }

  List<Widget> setAllNumbers() {
    List<Widget> widgetList = [];

    for (var i = 1; i < 13; i++) {
      var index = i;
      var color = Colors.teal.shade100;

      if (i == 11) index = 0;

      dynamic button = TextButton(onPressed: () {}, child: const Text(""));

      if (i == 10) {
        button = IconButton(
          onPressed: () {
            if(writtenNumbers.isEmpty) return;
            setState(() {
              writtenNumbers.removeLast();
              widgetList[index] = const Text("");
            });
          },
          icon: const Icon(
            Icons.backspace_rounded,
            size: 35,
          ),
        );
      } else if (i == 12) {
        if (writtenNumbers.length != 4) {
          color = Colors.grey.shade300;
        } else {
          color = Colors.teal.shade300;
        }

        button = IconButton(
          onPressed: () {
            setState(() {
              if (writtenNumbers.length != 4) return;
              attempts += 1;
              saveNumberInTable();
              tableScrollDown();
              writtenNumbers.clear();
            });
          },
          icon: const Icon(
            Icons.done,
            size: 35,
          ),
        );
      } else {
        if (writtenNumbers.contains(index)) {
          color = Colors.grey.shade300;
        }

        button = TextButton(
          onPressed: () {
            if(preventWriting(index)) return;
            setState(() {
              writtenNumbers.add(index);
            });
          },
          child: Text("$index", textScaleFactor: 2, style: const TextStyle(color: Colors.black87),),
        );
      }

      widgetList.add(
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: color,
          ),
          child: button,
        )
      );
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bit the hit'),
        backgroundColor: const Color(0xFFFF9000),
        foregroundColor: const Color(0xFFFFFFFF),
        shadowColor: const Color(0xAAAAAAAA),
        actions: [
          IconButton(
            onPressed: () {
              _dialogBuilder(
                context,
                "Reset game",
                "Are you sure you want to reset the game? \nYou will lose all your progress",
                true,
                false,
                resetGame,
                null
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.list,
            ),
          ),
        ],
      ),
      body:Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
            verticalDirection: VerticalDirection.down,
            children: [
              /* Container(
                width: 90,
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text(
                  numberToReveal.join(""),
                  textScaleFactor: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade300),
                ),
              ),*/
              const Text("Write your number:", textScaleFactor: 1.75),
              Container(
                width: 90,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Colors.amber.shade100),
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: Text(writtenNumbers.join(""), textScaleFactor: 2, textAlign: TextAlign.start),
              ),
              Container(
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxHeight: 270),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: tableScrollController,
                      child: Table(
                        border: TableBorder(
                            top: tableBorder,
                            bottom: tableBorder,
                            horizontalInside: tableBorder
                        ),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                              children: setHeadTexts(["Number", "Bits", "Hits"])
                          ),
                          ...tableResults
                        ],
                      ),
                    ),
                  )
              ),
              const Spacer(),
              Stack(
                children: [
                  Positioned(
                    child:
                      GridView(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            crossAxisCount: 3,
                            childAspectRatio: 1.75
                        ),
                        children: <Widget>[
                          ...setAllNumbers()
                        ],
                      )
                  )
                ],),
            ]),
      )
    );
  }
}
