import 'package:flutter/material.dart';

ShapeBorder? getShapeBorder(int index, int finalIndex) {
  if (finalIndex == 0) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
  } else if (index == finalIndex) {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
    );
  }
  switch (index) {
    case 0:
      return const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      );
    default:
      return null;
  }
}
