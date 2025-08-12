/// The channels to be used while initializing the player.
enum Channels {
  /// One channel.
  mono(1),

  /// Two channels.
  stereo(2),

  /// Four channels.
  quad(4),

  /// Six channels.
  surround51(6),

  /// Eight channels.
  dolby71(8);

  const Channels(this.count);

  /// The channels count.
  final int count;

  /// Returns a human-friendly channel name.
  @override
  String toString() {
    switch (this) {
      case Channels.mono:
        return 'Mono';
      case Channels.stereo:
        return 'Stereo';
      case Channels.quad:
        return 'Quad';
      case Channels.surround51:
        return 'Surround 5.1';
      case Channels.dolby71:
        return 'Dolby 7.1';
    }
  }
}
