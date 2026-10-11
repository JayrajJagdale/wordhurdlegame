import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart' as words;
import 'package:word_hurdle_puzzle/wordle.dart';

class HurdleProvider extends ChangeNotifier {
  final random = Random.secure();
  List<String> totalWords = [];
  List<String> rowInputs = [];
  List<String> excludedLetters = [];
  List<Wordle> hurdleBoard = [];
  String targetWord = '';
  int count = 0;
  final lettersPerRow = 5;
  int index = 0;
  bool wins = false;
  final totalAttempts = 6;
  int attempts = 0;
  final player = AudioPlayer();

  void init() {
    totalWords = words.all.where((element) => element.length == 5).toList();
    generateBoard();
    generateRandomWord();
  }

  void generateBoard() {
    hurdleBoard = List.generate(30, (index) => Wordle(letter: ''));
  }

  void generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    print(targetWord);
  }

  bool get isAValidWord =>
      totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts == totalAttempts;

  void inputLetter(String letter) {
    if (count < lettersPerRow) {
      count++;
      rowInputs.add(letter);
      hurdleBoard[index] = Wordle(letter: letter);
      index++;
      notifyListeners();
    }
  }

  void deleteLetter() {
    if (rowInputs.isNotEmpty) {
      rowInputs.removeAt(rowInputs.length - 1);
      print(rowInputs);
    }
    if (count > 0) {
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
      notifyListeners();
    }
  }

  Future<void> checkAnswer() async {
    final input = rowInputs.join('');
    if (targetWord == input) {
      wins = true;
      await player.play(AssetSource('audio/win.mp3'));
    } else {
      await player.play(AssetSource('audio/lose.mp3'));
      _markLetterOnBoard();
      if (attempts < totalAttempts) {
        _goToNextRow();
      }
    }
    notifyListeners();
  }

  void _markLetterOnBoard() {
    for (int i = 0; i < hurdleBoard.length; i++) {
      if (hurdleBoard[i].letter.isNotEmpty &&
          targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else if (hurdleBoard[i].letter.isNotEmpty &&
          !targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].doesNotExistInTarget = true;
        excludedLetters.add(hurdleBoard[i].letter);
      }
    }
    notifyListeners();
  }

  void _goToNextRow() {
    attempts++;
    count = 0;
    rowInputs.clear();
  }

  void reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}
