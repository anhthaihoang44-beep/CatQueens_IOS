import 'package:hive/hive.dart';

/// Model representing the user's profile.
class UserProfile extends HiveObject {
  String id;
  int avatarIndex;
  int frameIndex;
  int catSkinIndex;

  UserProfile({
    required this.id,
    this.avatarIndex = 0,
    this.frameIndex = 0,
    this.catSkinIndex = 0,
  });
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String? ?? 'CAT001',
      avatarIndex: fields[1] as int? ?? 0,
      frameIndex: fields[2] as int? ?? 0,
      catSkinIndex: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.avatarIndex)
      ..writeByte(2)
      ..write(obj.frameIndex)
      ..writeByte(3)
      ..write(obj.catSkinIndex);
  }
}
