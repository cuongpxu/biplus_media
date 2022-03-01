import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlantStats extends StatelessWidget {
  const PlantStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 40,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.bolt,
                size: 20,
                color: Colors.yellow[600],
              ),
              const SizedBox(width: 3),
              const Text(
                '25%',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          height: 40,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.tint,
                size: 20,
                color: Colors.teal[50],
              ),
              const SizedBox(width: 3),
              const Text(
                '80%',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          height: 40,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.cloudSun,
                size: 20,
                color: Colors.yellow[600],
              ),
              const SizedBox(width: 3),
              const Text(
                '60%',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}