import 'package:hive/hive.dart';

/// Model for a daily challenge level.
class DailyChallenge extends HiveObject {
  int levelNumber;
  String seed;
  Duration? bestTime;

  DailyChallenge({
    required this.levelNumber,
    required this.seed,
    this.bestTime,
  });
}

class DailyChallengeAdapter extends TypeAdapter<DailyChallenge> {
  @override
  final int typeId = 2;

  @override
  DailyChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final bestTimeMs = fields[2] as int?;
    return DailyChallenge(
      levelNumber: fields[0] as int? ?? 1,
      seed: fields[1] as String? ?? '',
      bestTime: bestTimeMs != null ? Duration(milliseconds: bestTimeMs) : null,
    );
  }

  @override
  void write(BinaryWriter writer, DailyChallenge obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.levelNumber)
      ..writeByte(1)
      ..write(obj.seed)
      ..writeByte(2)
      ..write(obj.bestTime?.inMilliseconds);
  }
}
