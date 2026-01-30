import 'package:flutter/material.dart';

class BlutoothStatus extends StatefulWidget {

  const BlutoothStatus({super.key});

  @override
  State<BlutoothStatus> createState() => _BlutoothStatusState();
}

class _BlutoothStatusState extends State<BlutoothStatus> {
  bool bluetooth_status=false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Bluetooth Status:",
          style: Theme.of(context).textTheme.titleSmall,),
          IconButton(onPressed: (){
            setState(() {
              bluetooth_status=!bluetooth_status;
            });
          }, icon: Icon(
            bluetooth_status?
            Icons.toggle_on:Icons.toggle_off_sharp,size: 50,
          color:bluetooth_status?
          Colors.green:Colors.red))
        ],
      ),
    );
  }
}
