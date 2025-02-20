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
  static int numberInRow = 11; // Número de cuadros por fila
  int numberOfSquares = numberInRow * 17; // Número total de cuadros en el tablero
  int player = numberInRow * 15 + 1; // Posición inicial del jugador
  int ghost = numberInRow * 1 + 1; // Posición inicial del fantasma

  // Lista de posiciones que representan las barreras (paredes)
  List<int> barriers = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 22, 33, 44, 55, 66, 77, 99, 110,
    121, 132, 143, 154, 165, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185,
    186, 175, 164, 153, 142, 131, 120, 109, 87, 76, 65, 54, 43, 32, 21, 57,
    46, 35, 24, 37, 26, 38, 39, 28, 30, 41, 52, 63, 59, 61, 70, 72, 78, 79, 80,
    81, 83, 84, 85, 86, 100, 101, 102, 103, 105, 106, 107, 108, 114, 116, 125,
    127, 123, 134, 145, 156, 129, 140, 151, 162, 147, 148, 149, 158, 160
  ];

  List<int> food = []; // Lista de posiciones de la comida
  String direction = "right"; // Dirección inicial del jugador
  bool preGame = true; // Estado pre-juego (antes de iniciar)
  bool mouthClosed = false; // Estado de la boca del jugador (abierta/cerrada)
  int score = 0; // Puntuación del jugador
  Timer? gameTimer; // Temporizador para controlar el flujo del juego

  // Método para inicializar la comida en el tablero
  void getFood() {
    food.clear(); // Limpiar la lista de comida existente
    for (int i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i); // Agregar comida en posiciones que no son barreras
      }
    }
  }

  // Método para reiniciar el juego
  void resetGame() {
    setState(() {
      player = numberInRow * 15 + 1; // Reiniciar posición del jugador
      ghost = numberInRow * 1 + 1; // Reiniciar posición del fantasma
      score = 0; // Reiniciar la puntuación
      direction = "right"; // Reiniciar la dirección del jugador
      preGame = true; // Volver al estado pre-juego
      food.clear(); // Limpiar la lista de comida
      getFood(); // Inicializar la comida nuevamente
    });
  }

  // Método para iniciar el juego
  void startGame() {
    preGame = false; // Cambiar al estado de juego activo
    getFood(); // Inicializar la comida
    gameTimer = Timer.periodic(Duration(milliseconds: 190), (timer) {
      // Verificar si el jugador recolecta comida
      if (food.contains(player)) {
        setState(() {
          food.remove(player); // Eliminar la comida recolectada
          score++; // Incrementar la puntuación
        });
      }

      // Verificar si el jugador ha ganado (score == 87)
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
                    Navigator.of(context).pop(); // Cerrar el diálogo
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

      // Verificar si el jugador ha perdido (colisión con el fantasma)
      if (player == ghost) {
        timer.cancel(); // Detener el temporizador
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("¡Perdiste!", style: TextStyle(fontWeight: FontWeight.bold),),
              content: Text("El fantasma te ha atrapado."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
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

      // Teletransporte automático entre los cuadros 88 y 98
      if (player == 88) {
        setState(() {
          player = 98; // Teletransportar al jugador al cuadro 98
        });
      } else if (player == 98) {
        setState(() {
          player = 88; // Teletransportar al jugador al cuadro 88
        });
      }

      moveGhost(); // Mover el fantasma

      // Mover al jugador según la dirección actual
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

  // Método para mover al jugador hacia la izquierda
  void moveLeft() {
    if (!barriers.contains(player - 1)) {
      setState(() {
        player--; // Mover al jugador a la izquierda
      });
    }
  }

  // Método para mover al jugador hacia la derecha
  void moveRight() {
    if (!barriers.contains(player + 1)) {
      setState(() {
        player++; // Mover al jugador a la derecha
      });
    }
  }

  // Método para mover al jugador hacia arriba
  void moveUp() {
    if (!barriers.contains(player - numberInRow)) {
      setState(() {
        player -= numberInRow; // Mover al jugador hacia arriba
      });
    }
  }

  // Método para mover al jugador hacia abajo
  void moveDown() {
    if (!barriers.contains(player + numberInRow)) {
      setState(() {
        player += numberInRow; // Mover al jugador hacia abajo
      });
    }
  }

  // Método para mover el fantasma
  void moveGhost() {
    int newGhostPosition = ghost;

    // Calcular la posición del jugador y el fantasma
    int playerRow = player ~/ numberInRow;
    int playerCol = player % numberInRow;
    int ghostRow = ghost ~/ numberInRow;
    int ghostCol = ghost % numberInRow;

    // Mover el fantasma hacia el jugador
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
      ghost = newGhostPosition; // Actualizar la posición del fantasma
    });
  }

  // Método para construir la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro
      body: Column(
        children: [
          // Área del tablero de juego
          Expanded(
            flex: 5,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                // Cambiar la dirección al arrastrar verticalmente
                if (details.delta.dy > 0) {
                  direction = "down";
                } else if (details.delta.dy < 0) {
                  direction = "up";
                }
              },
              onHorizontalDragUpdate: (details) {
                // Cambiar la dirección al arrastrar horizontalmente
                if (details.delta.dx > 0) {
                  direction = "right";
                } else if (details.delta.dx < 0) {
                  direction = "left";
                }
              },
              child: Container(
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(), // Deshabilitar desplazamiento
                  itemCount: numberOfSquares, // Número total de cuadros
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numberInRow, // Número de columnas
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    // Renderizar cada cuadro del tablero
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
                      // Renderizar al jugador con rotación según la dirección
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
                      // Renderizar al fantasma
                      return MyGhost();
                    } else if (barriers.contains(index)) {
                      // Renderizar barreras
                      return MyPixel(
                        innerColor: Colors.blue[900],
                        outerColor: Colors.blue[800],
                      );
                    } else if (food.contains(index)) {
                      // Renderizar comida
                      return MyPath(
                        innerColor: Colors.yellow,
                        outerColor: Colors.black,
                      );
                    } else {
                      // Renderizar camino vacío
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
          // Área de puntuación y botón de inicio
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Score: " + score.toString(), // Mostrar la puntuación
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  GestureDetector(
                    onTap: startGame, // Iniciar el juego al tocar
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