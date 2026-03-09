String getVehicleAsset(String? modelName) {
  final String normalized = (modelName ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  if (normalized.contains('hatchback') || normalized.contains('hatch')) {
    return 'assets/image/hatchback.png';
  }
  if (normalized.contains('sedan')) {
    return 'assets/image/sedan.png';
  }
  if (normalized.contains('suv')) {
    return 'assets/image/suv.png';
  }
  if (normalized.contains('ridesafe')) {
    return 'assets/image/ridesafe.png';
  }
  if (normalized.contains('bike') || normalized.contains('motorbike')) {
    return 'assets/image/bike.png';
  }

  return 'assets/image/car_placeholder.png';
}
