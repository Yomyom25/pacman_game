import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_game/ghost.dart';
import 'package:pacman_game/path.dart';
import 'package:pacman_game/pixel.dart';
import 'package:pacman_game/player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int numberInRow = 11;
  int numberOfSquares = numberInRow * 17;
  int player = numberInRow * 15 + 1;
  int ghost = numberInRow * 1 + 1; // Posición inicial del fantasma

  List<int> barriers = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 22, 33, 44, 55, 66, 77, 99, 110,
    121, 132, 143, 154, 165, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185,
    186, 175, 164, 153, 142, 131, 120, 109, 87, 76, 65, 54, 43, 32, 21, 57,
    46, 35, 24, 37, 26, 38, 39, 28, 30, 41, 52, 63, 59, 61, 70, 72, 78, 79, 80,
    81, 83, 84, 85, 86, 100, 101, 102, 103, 105, 106, 107, 108, 114, 116, 125,
    127, 123, 134, 145, 156, 129, 140, 151, 162, 147, 148, 149, 158, 160
  ];

  List<int> food = [];
  String direction = "right";
  bool preGame = true;
  bool mouthClosed = false;
  int score = 0;
  Timer? gameTimer;

  // Lógica para inicializar la comida
  void getFood() {
    food.clear(); // Limpiar la lista de comida antes de inicializarla
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  // Reiniciar el juego
  void resetGame() {
    setState(() {
      player = numberInRow * 15 + 1; // Posición inicial del jugador
      ghost = numberInRow * 1 + 1; // Posición inicial del fantasma
      score = 0; // Reiniciar el score
      direction = "right"; // Reiniciar la dirección
      preGame = true; // Volver al estado pre-juego
      food.clear(); // Limpiar la lista de comida
      getFood(); // Inicializar la comida nuevamente
    });
  }

  // Lógica para iniciar el juego
  void startGame() {
    preGame = false;
    getFood(); // Inicializar la lista de comida
    gameTimer = Timer.periodic(Duration(milliseconds: 190), (timer) {
      if (food.contains(player)) {
        setState(() {
          food.remove(player); // Eliminar la comida si el jugador está sobre ella
          score++;
        });
      }

      // Verificar si el jugador ha ganado
      if (score == 87) {
        timer.cancel(); // Detener el temporizador
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("¡Ganaste!"),
              content: Text("Felicidades, has alcanzado un score de 87."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame(); // Reiniciar el juego
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

      // Verificar si el jugador ha perdido
      if (player == ghost) {
        timer.cancel(); // Detener el temporizador
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("¡Perdiste!"),
              content: Text("El fantasma te ha atrapado."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame(); // Reiniciar el juego
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
        return;
      }

      moveGhost(); // Mover el fantasma

      switch (direction) {
        case "left":
          moveLeft();
          break;
        case "right":
          moveRight();
          break;
        case "up":
          moveUp();
          break;
        case "down":
          moveDown();
          break;
      }
    });
  }

  // Lógica del movimiento del jugador
  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--;
      });
    }
  }

  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++;
      });
    }
  }

  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow;
      });
    }
  }

  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow;
      });
    }
  }

  // Lógica para mover el fantasma
  void moveGhost() {
    int newGhostPosition = ghost;

    // Determinar la dirección hacia el jugador
    int playerRow = player ~/ numberInRow;
    int playerCol = player % numberInRow;
    int ghostRow = ghost ~/ numberInRow;
    int ghostCol = ghost % numberInRow;

    if (playerRow < ghostRow && !barriers.contains(ghost - numberInRow)) {
      newGhostPosition = ghost - numberInRow; // Mover hacia arriba
    } else if (playerRow > ghostRow && !barriers.contains(ghost + numberInRow)) {
      newGhostPosition = ghost + numberInRow; // Mover hacia abajo
    } else if (playerCol < ghostCol && !barriers.contains(ghost - 1)) {
      newGhostPosition = ghost - 1; // Mover hacia la izquierda
    } else if (playerCol > ghostCol && !barriers.contains(ghost + 1)) {
      newGhostPosition = ghost + 1; // Mover hacia la derecha
    }

    setState(() {
      ghost = newGhostPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0) {
                  direction = "down";
                } else if (details.delta.dy < 0) {
                  direction = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  direction = "right";
                } else if (details.delta.dx < 0) {
                  direction = "left";
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: numberOfSquares,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (mouthClosed) {
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    } else if (player == index) {
                      // Rotación del jugador según la dirección
                      switch (direction) {
                        case "left":
                          return Transform.rotate(
                            angle: pi,
                            child: MyPlayer(),
                          );
                        case "right":
                          return MyPlayer();
                        case "up":
                          return Transform.rotate(
                            angle: 3 * pi / 2,
                            child: MyPlayer(),
                          );
                        case "down":
                          return Transform.rotate(
                            angle: pi / 2,
                            child: MyPlayer(),
                          );
                        default:
                          return MyPlayer();
                      }
                    } else if (ghost == index) {
                      // Mostrar el fantasma
                      return MyGhost();
                    } else if (barriers.contains(index)) {
                      // Mostrar barreras
                      return MyPixel(
                        innerColor: Colors.blue[900],
                        outerColor: Colors.blue[800],
                      );
                    } else if (food.contains(index)) {
                      // Mostrar comida
                      return MyPath(
                        innerColor: Colors.yellow,
                        outerColor: Colors.black,
                      );
                    } else {
                      // Mostrar camino vacío
                      return MyPath(
                        innerColor: Colors.black,
                        outerColor: Colors.black,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Score: " + score.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  GestureDetector(
                    onTap: startGame,
                    child: Text(
                      "P L A Y",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}