import AVFoundation

enum SoundService {
    static var enabled: Bool = true

    private static var player: AVAudioPlayer?

    /// Coin-earned chime. Uses `.ambient` so the ring/silent switch mutes it —
    /// no new permissions, no ducking other audio.
    static func coinEarned() {
        guard enabled,
              let url = Bundle.main.url(forResource: "achieved", withExtension: "mp3") else { return }
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            p.play()
            player = p
        } catch {
            player = nil
        }
        #endif
    }
}
