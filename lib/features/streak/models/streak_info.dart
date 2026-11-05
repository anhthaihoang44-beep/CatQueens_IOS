import 'package:hive/hive.dart';

/// Model lưu thông tin chuỗi hằng ngày.
class StreakInfo extends HiveObject {
  int currentStreak;
  int bestStreak;
  String lastPlayedDate; // ISO string (yyyy-MM-dd)

  StreakInfo({
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDate = '',
  });
}

class StreakInfoAdapter extends TypeAdapter<StreakInfo> {
  @override
  final int typeId = 1;

  @override
  StreakInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakInfo(
      currentStreak: fields[0] as int? ?? 0,
      bestStreak: fields[1] as int? ?? 0,
      lastPlayedDate: fields[2] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, StreakInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.bestStreak)
      ..writeByte(2)
      ..write(obj.lastPlayedDate);
  }
}
