import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CardGameScreen(),
    );
  }
}

// Card model
class CardModel {
  final String frontImage; // Unique identifier for the front
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.frontImage,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class CardGameScreen extends StatefulWidget {
  const CardGameScreen({super.key});

  @override
  _CardGameScreenState createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen>
    with SingleTickerProviderStateMixin {
  late List<CardModel> cards;
  int? firstCardIndex; // Index of the first tapped card
  int? secondCardIndex; // Index of the second tapped card
  bool isChecking = false; // Flag to prevent multiple taps during check
  bool gameWon = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create 8 unique pairs for a 4x4 grid (16 cards total)
    final List<String> images = List.generate(8, (index) => 'asset_$index')
      ..addAll(
        List.generate(8, (index) => 'asset_$index'),
      ); // Duplicate for pairs
    images.shuffle();

    cards = images.map((img) => CardModel(frontImage: img)).toList();
    firstCardIndex = null;
    secondCardIndex = null;
    isChecking = false;
    gameWon = false;
    print('Game initialized with ${cards.length} cards');
  }

  void _checkMatch() {
    print(
      'Checking match: firstCardIndex=$firstCardIndex, secondCardIndex=$secondCardIndex',
    );
    if (firstCardIndex != null && secondCardIndex != null) {
      print(
        'First card: ${cards[firstCardIndex!].frontImage}, Second card: ${cards[secondCardIndex!].frontImage}',
      );
      isChecking = true; // Lock further taps during check

      if (cards[firstCardIndex!].frontImage ==
          cards[secondCardIndex!].frontImage) {
        // Match found: Keep cards face-up and mark as matched
        print('Match found!');
        setState(() {
          cards[firstCardIndex!].isMatched = true;
          cards[secondCardIndex!].isMatched = true;
        });
        _checkWinCondition();
        isChecking = false; // Unlock taps after match
        firstCardIndex = null;
        secondCardIndex = null;
      } else {
        // No match: Flip cards face-down after a delay
        print('No match. Scheduling flip back after 1 second.');
        final int firstIdx = firstCardIndex!;
        final int secondIdx = secondCardIndex!;
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            cards[firstIdx].isFaceUp = false;
            cards[secondIdx].isFaceUp = false;
          });
          print(
            'Cards flipped back: ${cards[firstIdx].isFaceUp}, ${cards[secondIdx].isFaceUp}',
          );
          isChecking = false; // Unlock taps after flip
          firstCardIndex = null;
          secondCardIndex = null;
        });
      }
    }
  }

  void _checkWinCondition() {
    if (cards.every((card) => card.isMatched)) {
      gameWon = true;
      setState(() {});
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Victory!'),
            content: const Text('You won!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeGame();
                  setState(() {});
                },
                child: const Text('Restart'),
              ),
            ],
          ),
    );
  }

  void _onCardTap(int index) {
    print(
      'Tapped card at index $index: isFaceUp=${cards[index].isFaceUp}, isMatched=${cards[index].isMatched}, isChecking=$isChecking',
    );
    // Prevent tapping if checking, matched, or already face-up
    if (isChecking || cards[index].isMatched || cards[index].isFaceUp) {
      print(
        'Tap blocked due to: isChecking=$isChecking, isMatched=${cards[index].isMatched}, isFaceUp=${cards[index].isFaceUp}',
      );
      return;
    }

    setState(() {
      cards[index].isFaceUp = true; // Flip the card face-up
      print('Card $index flipped face-up');
    });

    if (firstCardIndex == null) {
      // First card tapped
      firstCardIndex = index;
      print('First card selected: $firstCardIndex');
    } else {
      // Second card tapped
      secondCardIndex = index;
      print('Second card selected: $secondCardIndex');
      _checkMatch(); // Check if they match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Matching Game')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    transform:
                        cards[index].isFaceUp
                            ? (Matrix4.identity()..rotateY(0))
                            : (Matrix4.identity()..rotateY(-3.14159)),
                    transformAlignment: Alignment.center,
                    child: Card(
                      color:
                          cards[index].isMatched ? Colors.green : Colors.grey,
                      child: Center(
                        child:
                            cards[index].isFaceUp || cards[index].isMatched
                                ? Text(
                                  cards[index].frontImage,
                                  style: const TextStyle(fontSize: 20),
                                )
                                : Image.asset(
                                  'assets/images/Card.webp', // Back design
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
