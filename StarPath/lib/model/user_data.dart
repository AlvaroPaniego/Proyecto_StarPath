class UserData {
  String id_user = "vacio";
  String username = "vacio";
  String profile_picture = "vacio";
  String followers = "-1";
  bool privacy = false;

  UserData.empty();

  UserData(this.id_user, this.username, this.profile_picture, this.followers, this.privacy);
}
